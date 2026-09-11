# 嵌入式 MCU+RTOS 项目开发规范

> 通用嵌入式软件开发规范，适用于基于 Cortex-M 系列 MCU + RTOS 的固件项目。
> 涵盖 STM32 HAL/LL、uC/OS-III、FreeRTOS 等主流技术栈。

---

## 一、项目目录结构规范

### 1.1 推荐分层架构

采用**四层分离**结构，将代码按职责划分为独立目录：

```
project_root/
│
├── App/                    # [用户管理] 应用层 — 任务函数、IPC逻辑、应用配置
│   ├── app.c / app.h       #   主应用模块
│   ├── app_cfg.h           #   应用配置（优先级、堆栈、队列深度等）
│   └── tasks/              #   可选的子任务目录
│
├── BSP/                    # [用户管理] 板级支持包 — 硬件抽象层
│   ├── bsp.c / bsp.h       #   BSP初始化入口
│   ├── led.c / led.h       #   LED驱动
│   ├── key.c / key.h       #   按键驱动
│   ├── uart_drv.c/h        #   串口驱动
│   └── exti.c / exti.h     #   外部中断
│
├── Driver/                 # [用户管理] 外设驱动层 — 复杂外设的封装
│   ├── sensor/             #   传感器驱动
│   ├── display/            #   显示屏驱动
│   └── comm/               #   通信协议栈
│
├── Kernel/                 # [用户管理] RTOS内核 + 中间件
│   ├── FreeRTOS/           #   FreeRTOS 源码
│   └── CMSIS-RTOS/         #   CMSIS-RTOS 封装层
│
├── MDK-ARM / EWARM / ...   # [IDE管理] IDE工程文件 + 编译输出
│
├── Middlewares/             # [供应商/用户] 第三方中间件
│   ├── FATFS/              #   文件系统
│   ├── LwIP/               #   TCP/IP 协议栈
│   └── GUI/                #   图形界面
│
├── CMakeLists.txt          # 可选的 CMake 构建
└── README.md               # 项目说明
```

### 1.2 目录职责矩阵

| 目录 | 管理方 | 自由修改 | CubeMX生成 | 说明 |
|------|--------|---------|-----------|------|
| `App/` | 开发者 | 是 | 否 | 应用业务逻辑 |
| `BSP/` | 开发者 | 是 | 否 | 板级硬件抽象 |
| `Driver/` | 开发者 | 是 | 否 | 外设驱动封装 |
| `Core/` | CubeMX | **仅USER CODE** | 是 | 主函数、GPIO初始化等 |
| `Kernel/` | 开发者 | 视情况 | 否 | RTOS可替换 |
| `Drivers/` | CubeMX | 否 | 是 | HAL/LL库，不手动修改 |
| `MDK-ARM/` | 开发者 | 手动添加文件 | 否 | 需同步新增.c文件 |

### 1.3 文件命名规范

| 要素 | 规范 | 示例 |
|------|------|------|
| 文件名 | 全小写 + 下划线 | `uart_dma.c`, `adc_measure.c` |
| 头文件 | 与源文件同名 | `led.h` ↔ `led.c` |
| 头文件保护宏 | `__{MODULE}_H__` | `__LED_H__`, `__UART_DMA_H__` |
| 配置文件 | `{module}_cfg.h` | `app_cfg.h`, `rtos_cfg.h` |

### 1.4 头文件保护宏格式

```c
#ifndef __LED_H__
#define __LED_H__

/* ... */

#endif
```

> 对于与CubeMX共存的模块，也可以采用 `__{MODULE}_H`（无末尾双下划线）风格以避免冲突。

---

## 二、代码组织模式

### 2.1 集中式头文件管理（includes.h 模式）

#### 问题

随着项目规模增长，每个 `.c` 文件顶部都会堆叠大量 `#include`：

```c
/* 反模式: 每个文件重复引入大量头文件 */
#include "stm32f4xx_hal.h"
#include "led.h"
#include "gpio_ext.h"
#include "exti_handler.h"
#include "app_cfg.h"
#include "app.h"
#include "bsp.h"
#include "os.h"
#include "os_cfg.h"
```

这不仅冗余，而且当项目新增模块时需要逐个修改所有 `.c` 文件。

#### 规范

在 `UCOSIII/config/`（或 `App/inc/`）下建立一个 **统一的 includes.h**，集中所有公共头文件：

```c
/* includes.h — 项目统一头文件 */
#ifndef __INCLUDES_H__
#define __INCLUDES_H__

/* HAL层 */
#include "stm32f4xx_hal.h"

/* RTOS内核 */
#include "os.h"
#include "os_cfg.h"
#include "os_cfg_app.h"

/* CPU和库抽象 */
#include "cpu.h"
#include "lib_def.h"
#include "lib_mem.h"

/* 应用配置（需最先包含，因为其他模块依赖优先级/堆栈定义） */
#include "app_cfg.h"

/* 应用层 */
#include "app.h"

/* BSP驱动 */
#include "bsp.h"
#include "led.h"
#include "gpio_ext.h"
#include "exti_handler.h"

#endif
```

各 `.c` 文件只需包含一个头文件：

```c
/* app.c — 只需一行include即可访问所有模块 */
#include "includes.h"

/* bsp.c */
#include "includes.h"

/* main.c */
#include "main.h"
#include "includes.h"   /* main.h 单独包含 */
```

#### 优点

| 优势 | 说明 |
|------|------|
| 减少重复 | 每个 `.c` 文件只需写一行 `#include "includes.h"` |
| 统一管理 | 新增模块只需在 includes.h 中添加一行即可全局生效 |
| 依赖清晰 | 项目的整体模块依赖关系一目了然 |
| 维护简单 | 模块拆分组装时无需修改大量文件 |

#### 注意事项

1. **包含顺序有讲究**：基础模块（HAL、RTOS内核）放在前面，依赖它们的应用模块放在后面
2. **保留特例**：`main.c` 通常还需要 `#include "main.h"`（CubeMX生成）
3. **不滥用**：如果某个 `.c` 文件只依赖少数模块，也可以仅包含必需头文件，不经过 includes.h
4. **CubeMX兼容**：includes.h 放在 CubeMX 不触及的目录中（如 `UCOSIII/config/` 或 `App/`），避免被覆盖

### 2.2 main函数精简模式（分层初始化）

#### 问题

反模式：将所有初始化代码直接堆在 main() 中：

```c
/* 反模式: main函数冗长，难以阅读 */
int main(void)
{
    HAL_Init();
    SystemClock_Config();
    MX_GPIO_Init();
    MX_DMA_Init();
    MX_USART1_UART_Init();
    MX_I2C1_Init();
    MX_SPI1_Init();
    LED_Init();
    KEY_Init();
    LCD_Init();
    BSP_Tick_Init();
    Mem_Init();
    OSInit(&err);
    /* ... 创建任务A ... */
    /* ... 创建任务B ... */
    /* ... 创建信号量 ... */
    /* ... 创建互斥量 ... */
    OSTaskCreate(&StartTaskTCB, ...);
    OSStart(&err);
    while(1);
}
```

#### 规范

将 main() 简化为**清晰的启动流程**，将初始化逻辑按职责抽取为语义化函数：

```c
/* Core/Src/main.c — 精简后的main函数 */
int main(void)
{
    HAL_Init();                             /* 1. HAL库初始化 */
    SystemClock_Config();                   /* 2. 系统时钟配置 */

    MX_GPIO_Init();                         /* 3. 基础外设初始化（CubeMX生成） */
    MX_DMA_Init();
    MX_USART1_UART_Init();

    OSInit(&err);                           /* 4. RTOS内核初始化 */

    /* 5. 在start_task中完成所有应用初始化 */
    OSTaskCreate((OS_TCB    *)&StartTaskTCB,
                 (CPU_CHAR  *)"start_task",
                 (OS_TASK_PTR) start_task,
                 (void      *) 0,
                 (OS_PRIO    ) START_TASK_PRIO,
                 (CPU_STK   *)&START_TASK_STK[0],
                 ...
                 (OS_ERR    *)&err);

    OSStart(&err);                          /* 6. 启动调度器（永不返回） */
}
```

将应用级初始化集中到 `start_task` 中，按清晰的语义步骤组织：

```c
/* start_task 内部 — 应用初始化流程 */
static void start_task(void *p_arg)
{
    OS_ERR err;
    (void)p_arg;

    BSP_Init();             /* 第1步: 板级硬件初始化（含BSP_Tick_Init） */

    AppObjCreate();         /* 第2步: 创建所有IPC对象（信号量/互斥量/队列）*/

    AppTaskCreate();        /* 第3步: 创建所有应用任务（会挂起start_task）*/

    /* 以下代码在start_task挂起期间不会被执行到 */
}
```

各层初始化函数的职责划分：

```c
/* BSP/bsp.c — 板级硬件初始化 */
void BSP_Init(void)
{
    BSP_Tick_Init();            /* 配置RTOS系统滴答定时器 */
    LED_Init();                 /* LED驱动初始化（如需） */
    EXTI_Handler_Init();        /* 外部中断初始化（如需） */
    MX_GPIO_Init();             /* CubeMX GPIO初始化（可在此调用） */
}

/* App/app.c — 应用IPC对象创建 */
void APP_ObjCreate(void)
{
    OS_ERR err;
    OSSemCreate(&Sem_TaskC, (CPU_CHAR *)"Sem_TaskC", 0, &err);
    OSMutexCreate(&M_Display, (CPU_CHAR *)"M_Display", &err);
    OSQCreate(&Q_Data, (CPU_CHAR *)"Q_Data", APP_CFG_QUEUE_MAX, &err);
}

/* App/app.c — 应用任务创建 */
void APP_TaskCreate(void)
{
    OS_ERR err;
    OSTaskCreate(&TaskA_TCB, ...);     /* 创建任务A */
    OSTaskCreate(&TaskB_TCB, ...);     /* 创建任务B */
    OSTaskCreate(&TaskC_TCB, ...);     /* 创建任务C */
    // ...
}
```

#### main函数精简的收益

```
精简前: main() 函数 > 50行，初始化 + 任务创建 + IPC创建全部堆在一起
精简后: main() 约15行，只保留 HAL_Init → SystemClock → MX_Init → OSInit → OSStart
        start_task() 约10行，BSP_Init → AppObjCreate → AppTaskCreate
        各初始化函数独立，职责清晰，可独立测试
```

读者通过 main() 一眼就能看出**系统启动的完整流程**，而无须阅读每一行具体实现了什么。

#### 各层初始化职责一览

| 函数 | 所在文件 | 职责 | 调用时机 |
|------|---------|------|---------|
| `HAL_Init()` | HAL库 | HAL库时基、NVIC分组等 | main() 入口 |
| `SystemClock_Config()` | `Core/Src/main.c` | 系统时钟（PLL、总线和Flash延时） | HAL_Init 之后 |
| `MX_GPIO_Init()` | `Core/Src/gpio.c` | 所有GPIO引脚模式配置（CubeMX生成） | 外设初始化阶段 |
| `MX_xxx_Init()` | `Core/Src/` | 各外设初始化（CubeMX生成） | MX_GPIO_Init 之后 |
| `OSInit()` | uCOS内核 | RTOS内核数据结构初始化 | 外设初始化之后 |
| `BSP_Init()` | `BSP/bsp.c` | 板级硬件抽象层初始化 | start_task 中 |
| `AppObjCreate()` | `App/app.c` | 信号量/互斥量/队列等IPC对象创建 | start_task 中 |
| `AppTaskCreate()` | `App/app.c` | 所有应用任务创建 | IPC创建之后 |
| `OSStart()` | uCOS内核 | 启动RTOS调度器（永不返回） | 一切初始化完毕之后 |

---

## 三、命名规范

### 3.1 总览

| 类别 | 风格 | 示例 |
|------|------|------|
| 宏定义常量 | `UPPER_SNAKE_CASE` | `LED_GPIO_PORT`, `TASK_STACK_SIZE` |
| 枚举/结构体类型 | `PascalCase` | `LedState_t`, `UartConfig_t` |
| 类型定义后缀 | `_t` | `uint8_t`, `status_t`, `err_code_t` |
| 函数名 | `Module_Action` 或 `module_action` | `LED_On`, `uart_send` |
| 全局变量 | `g_` 前缀 + 小写蛇形 | `g_system_tick`, `g_uart_rx_buffer` |
| 静态变量 | `s_` 前缀 + 小写蛇形 | `s_init_done`, `s_tx_busy` |
| 局部变量 | 小写蛇形 | `recv_len`, `timeout_ms` |
| 函数参数 | `p_` 前缀 | `p_buffer`, `p_timeout_ms` |

### 3.2 宏定义规范

```c
/* 格式: {MODULE}_{NAME}[_{SUB}]
 * 全大写，下划线分隔，带模块前缀
 */

/* 引脚宏 */
#define LED_R_GPIO_PORT     GPIOB
#define LED_R_PIN           GPIO_PIN_5
#define LED_G_GPIO_PORT     GPIOB
#define LED_G_PIN           GPIO_PIN_0

/* 硬件配置宏 */
#define UART1_BAUDRATE      115200u
#define ADC_SAMPLE_TIME     10u

/* 软件配置宏 */
#define TASK_A_PRIO         4u
#define TASK_A_STACK_SIZE   256u
#define QUEUE_MAX_ITEMS     10u

/* 电平极性抽象 */
#define LED_ON_LEVEL        GPIO_PIN_RESET   /* 低电平点亮 */
#define LED_OFF_LEVEL       GPIO_PIN_SET
```

### 3.3 类型定义规范

```c
/* 结构体: PascalCase + _t 后缀 */
typedef struct {
    uint32_t baudrate;
    uint8_t  data_bits;
    uint8_t  stop_bits;
    uint8_t  parity;
} UartConfig_t;

/* 枚举: PascalCase + _t 后缀 */
typedef enum {
    LED_STATE_OFF = 0,
    LED_STATE_ON,
    LED_STATE_BLINK_SLOW,
    LED_STATE_BLINK_FAST
} LedState_t;

/* 函数指针类型 */
typedef void (*TaskFunc_t)(void *p_arg);
```

### 3.4 函数命名规范

#### BSP/Driver 层 — `{Module}_{Action}`

```c
/* 前缀大写，动作首字母大写 */
void   LED_On(void);
void   LED_Off(void);
void   LED_Toggle(void);
void   LED_SetBrightness(uint8_t percent);
Status_t UART_Send(uint8_t *p_data, uint16_t len);
Status_t UART_Receive(uint8_t *p_buf, uint16_t len, uint32_t timeout_ms);
```

#### 应用层 — `{module}_{action}`

```c
/* 全小写蛇形 */
void task_led(void *p_arg);
void task_comm(void *p_arg);
static void process_rx_packet(void);
```

#### 初始化函数命名

| 层级 | 模式 | 示例 |
|------|------|------|
| 模块级 | `{Module}_Init` | `LED_Init()`, `UART_Init()` |
| BSP级 | `BSP_Init` | 统一初始化所有板级外设 |
| 应用级 | `APP_Init` | 初始化应用组件 |
| RTOS级 | `{Module}_Create` | `APP_TaskCreate()`, `APP_ObjCreate()` |

### 3.5 RTOS对象命名

```c
/* 格式: {Type}_{Purpose} */

OS_SEM     Sem_TxComplete;       /* 信号量 */
OS_MUTEX   M_Display;            /* 互斥量 */
OS_Q       Q_UsbData;            /* 消息队列 */
OS_TCB     TaskLedTCB;           /* 任务控制块 */
CPU_STK    TaskLedStk[256];      /* 任务堆栈 */
TaskHandle_t xTaskCommHandle;    /* FreeRTOS任务句柄 */
QueueHandle_t xDataQueue;        /* FreeRTOS队列句柄 */
```

### 3.6 全局/静态变量命名

```c
/* 全局: g_ + 模块前缀 + 描述名 */
volatile uint32_t g_sys_tick_ms;
volatile uint8_t  g_usb_connected;
static uint8_t    g_uart_tx_buffer[256];    /* 文件作用域静态 */
UART_HandleTypeDef huart1;                  /* HAL句柄（无g_前缀，HAL惯例）*/

/* 函数内静态: s_ + 描述名 */
static uint8_t s_initialized = 0;
```

---

## 四、注释规范

### 4.1 注释语言

- 国内团队项目建议使用**中文**注释，降低沟通成本
- 国际团队或开源项目使用**英文**注释
- **同一项目内保持语言一致**

### 4.2 文件头注释

```c
/**
  ******************************************************************************
  * @file           : led.c
  * @brief          : LED驱动模块 — GPIO控制LED亮灭/闪烁
  * @author         : [作者名/团队名]
  * @date           : 2026-06-23
  * @version        : v1.0
  ******************************************************************************
  * @attention
  * - LED极性: 低电平点亮 (LED_ON_LEVEL = GPIO_PIN_RESET)
  * - 初始化由CubeMX的MX_GPIO_Init()完成, 本模块不重复初始化
  ******************************************************************************
  */
```

### 4.3 函数头注释

```c
/**
  * 函数功能: 初始化指定GPIO为推挽输出模式
  * 输入参数: p_port 是GPIO端口基址 (如 GPIOB)
  * 输入参数: pin    是引脚号 (如 GPIO_PIN_5)
  * 输入参数: level  是初始输出电平 (0=低, 1=高)
  * 返 回 值: Status — STATUS_OK 或 STATUS_ERROR
  * 说    明: 此函数不配置复用功能，仅用于普通GPIO输出
  */
Status_t GPIO_OutputInit(GPIO_TypeDef *p_port, uint16_t pin, uint8_t level)
```

### 4.4 关键设计决策注释

对**为什么这样做**而非**做了什么**进行注释：

```c
/* 注意: IPC对象必须先于应用任务创建。
 * AppTaskCreate()内部会挂起start_task，
 * 如果顺序颠倒，IPC对象将永远不会被创建，
 * 因为start_task被挂起后无法继续执行后续代码。
 */
AppObjCreate();
AppTaskCreate();
```

### 4.5 区块分隔线

```c
/*
 *****************************************************************************
 *                                       全局变量
 *****************************************************************************
 */

/*
 *****************************************************************************
 *                                       模块内部函数
 *****************************************************************************
 */
```

---

## 五、代码格式规范

### 5.1 缩进与括号

| 项目 | 推荐 |
|------|------|
| 缩进 | 4空格 或 Tab（项目内统一） |
| 大括号风格 | Allman（独占一行） |
| 行宽 | 80~120字符 |

```c
if (condition)
{
    /* ... */
}
else
{
    /* ... */
}

for (i = 0; i < count; i++)
{
    /* ... */
}
```

### 5.2 函数最大长度

- **单个函数不超过 100 行**（包括空行和注释）
- 超出时应拆分为多个语义清晰的子函数
- 任务主循环例外，可适当放宽

### 5.3 条件编译标记

```c
#if (OS_CFG_STAT_TASK_EN > 0u)
    OSStatTaskCPUUsageInit(&err);
#endif
```

条件编译后的代码同样遵循项目缩进规范。

### 5.4 指针与引用

```c
/* 指针符号紧贴变量名 */
uint8_t *p_buffer;
void (*callback)(void);

/* 类型转换显式写出 */
uint32_t val = (uint32_t)(CPU_ADDR)p_msg;
```

---

## 六、RTOS使用规范

### 6.1 任务设计原则

```
1. 每个任务一个明确的职责
   ✓ task_led       — 只控制LED
   ✓ task_comm      — 只处理通信
   ✗ task_all_in_one — 同时处理LED、通信、传感器

2. 任务间通过IPC通信，不共享全局变量（必要时加保护）
   ✓ 信号量 / 消息队列 / 事件标志组 传递数据
   ✗ 多个任务直接读写同一个全局数组

3. 任务栈大小根据实际需求配置
   - 中断服务函数嵌套深度
   - 局部变量总大小
   - 函数调用链深度
   - 预留 20%~30% 余量
```

### 6.2 任务优先级分配策略

```c
/* 优先级规划表（注释维护在app_cfg.h中） */

/* 优先级范围: 0(最高) ~ OS_CFG_PRIO_MAX-1(最低) */

/* 硬实时任务 (中断级响应需求) */
#define TASK_MOTOR_PRIO       2u    /* 电机控制 — 最高优先级 */

/* 软实时周期性任务 */
#define TASK_SENSOR_PRIO      3u    /* 传感器采集 — 固定周期 */
#define TASK_COMM_PRIO        4u    /* 通信处理 — 低延迟要求 */

/* 普通应用任务 */
#define TASK_LED_PRIO         5u    /* LED指示 */
#define TASK_DISPLAY_PRIO     6u    /* 显示刷新 */

/* 后台任务 */
#define TASK_IDLE_PRIO        7u    /* 低优先级后台处理 */
```

### 6.3 IPC选型指南

| IPC机制 | 适用场景 | 示例 |
|---------|---------|------|
| 信号量 (Semaphore) | 事件通知、资源计数 | ISR通知任务数据已就绪 |
| 互斥量 (Mutex) | 保护共享资源（含优先级继承） | 多个任务访问LCD/Flash |
| 消息队列 (Queue) | 数据传递、解耦生产者/消费者 | 传感器数据→处理→显示 |
| 事件标志组 (EventFlags) | 等待多个条件的组合 | 等待"按键+定时超时+数据到达" |
| 任务通知 (TaskNotify) | 轻量级单任务通知 | ISR→特定任务（比信号量更快） |

### 6.4 ISR任务通信模式（推荐）

```c
/* ISR端 — 用RTOS的ISR安全API发送 */
void HAL_GPIO_EXTI_Callback(uint16_t GPIO_Pin)
{
    BaseType_t xHigherPriorityTaskWoken = pdFALSE;  /* FreeRTOS */
    // 或: OSIntEnter();                              /* uC/OS-III */

    if (GPIO_Pin == EXTI_BUTTON_PIN)
    {
        /* 值编址: 将整数值编码在指针中，避免动态分配 */
        xQueueSendFromISR(xDataQueue, &g_counter, &xHigherPriorityTaskWoken);
        // 或: OSTaskQPost(&TaskTCB, (void*)(CPU_ADDR)value, ...);
    }

    /* 退出ISR，必要时触发上下文切换 */
    portYIELD_FROM_ISR(xHigherPriorityTaskWoken);
    // 或: OSIntExit();
}

/* 任务端 — 阻塞等待数据 */
void task_receiver(void *p_arg)
{
    uint32_t recv_data;
    while (1)
    {
        if (xQueueReceive(xDataQueue, &recv_data, portMAX_DELAY) == pdPASS)
        {
            process_data(recv_data);
        }
    }
}
```

### 6.5 值编址模式（Zero-Copy IPC）

传递小数据（如计数器、状态码）时使用值编址，避免动态内存分配：

```c
/* 发送端: 将值强制转为指针 */
void *p_msg = (void *)(uint32_t)counter_value;
OSTaskQPost(&TaskTCB, p_msg, sizeof(uint32_t), OS_OPT_POST_FIFO, &err);

/* 接收端: 将指针转回值 */
uint32_t value = (uint32_t)p_msg;
```

**限制**：仅适用于32位及以下的数据。超过32位的数据仍需使用消息队列传递指针到静态缓冲区。

---

## 七、HAL/LL外设驱动开发规范

### 7.1 驱动分层

```c
/* 第1层: HAL初始化 — 由CubeMX生成或BSP调用 */
MX_USART1_UART_Init();      /* 配置波特率/中断/DMA */
MX_GPIO_Init();             /* 配置所有GPIO模式 */

/* 第2层: BSP封装 — 与应用解耦 */
void UART1_Init(void)
{
    MX_USART1_UART_Init();  /* 调用HAL初始化 */
    HAL_UART_Receive_IT(&huart1, s_rx_byte, 1);  /* 启动中断接收 */
}

Status_t UART1_Send(uint8_t *p_data, uint16_t len)
{
    return HAL_UART_Transmit(&huart1, p_data, len, 1000);
}

/* 第3层: 应用层使用BSP接口 */
void task_comm(void *p_arg)
{
    UART1_Send("Hello\r\n", 7);
}
```

### 7.2 回调函数规范

HAL库使用弱函数实现回调，用户需重写：

```c
/* 文件: bsp/uart_callback.c */
void HAL_UART_RxCpltCallback(UART_HandleTypeDef *huart)
{
    if (huart->Instance == USART1)
    {
        BaseType_t xHigherPriorityTaskWoken = pdFALSE;
        xQueueSendFromISR(xRxQueue, &s_rx_byte, &xHigherPriorityTaskWoken);
        HAL_UART_Receive_IT(huart, s_rx_byte, 1);
        portYIELD_FROM_ISR(xHigherPriorityTaskWoken);
    }
}
```

**规范**：回调函数中**不做耗时操作**，仅通过IPC将数据传递给任务处理。

---

## 八、错误处理规范

### 8.1 函数返回值

```c
/* 使用枚举定义统一错误码 */
typedef enum {
    STATUS_OK        = 0,
    STATUS_ERROR     = -1,
    STATUS_TIMEOUT   = -2,
    STATUS_BUSY      = -3,
    STATUS_INVALID   = -4,
} Status_t;
```

### 8.2 RTOS API错误检查

```c
void task_sample(void *p_arg)
{
    OS_ERR err;

    OSSemPend(&Sem_Data, 1000, OS_OPT_PEND_BLOCKING, NULL, &err);
    if (err != OS_ERR_NONE)
    {
        /* 超时或其他错误，做容错处理而非死等 */
        handle_sem_error(err);
        return;
    }

    /* 正常处理 */
}
```

### 8.3 断言机制

```c
/* 参数有效性检查 */
Status_t UART_Send(UART_HandleTypeDef *huart, uint8_t *p_data, uint16_t len)
{
    assert_param(huart != NULL);
    assert_param(p_data != NULL);
    assert_param(len > 0);

    return HAL_UART_Transmit(huart, p_data, len, 1000);
}
```

---

## 九、ISR（中断服务函数）规范

### 9.1 ISR编写原则

```
1. 尽量短小精悍 — 仅做标记/计数/数据转移
2. 不做耗时操作 — 不在ISR中调用printf、延时、复杂计算
3. 使用RTOS的ISR安全API — 不从ISR调用普通RTOS API
4. 数据转移优先 — ISR只负责转移数据，处理交给任务
5. 中断嵌套最小化 — 使用NVIC优先级分组合理分配优先级
```

### 9.2 ISR模板

```c
/* uC/OS-III 风格 */
void HAL_GPIO_EXTI_Callback(uint16_t GPIO_Pin)
{
    OS_ERR err;

    if (GPIO_Pin == USER_BUTTON_PIN)
    {
        OSIntEnter();

        /* 仅做计数 + 发通知 */
        g_button_press_count++;
        OSTaskQPost(&TaskButtonTCB,
                    (void *)(CPU_ADDR)g_button_press_count,
                    sizeof(uint32_t),
                    OS_OPT_POST_FIFO,
                    &err);

        OSIntExit();
    }
}

/* FreeRTOS 风格 */
void HAL_GPIO_EXTI_Callback(uint16_t GPIO_Pin)
{
    BaseType_t xHigherPriorityTaskWoken = pdFALSE;

    if (GPIO_Pin == USER_BUTTON_PIN)
    {
        g_button_press_count++;
        xTaskNotifyFromISR(xButtonTaskHandle,
                          g_button_press_count,
                          eSetValueWithOverwrite,
                          &xHigherPriorityTaskWoken);
    }

    portYIELD_FROM_ISR(xHigherPriorityTaskWoken);
}
```

### 9.3 ISR安全标志

防止ISR在RTOS对象未创建时访问：

```c
/* 全局标志 (在app.c中定义) */
volatile uint8_t g_task_ready = 0;

/* 任务创建完成后设置 */
void APP_TaskCreate(void)
{
    OSTaskCreate(&TaskTCB, ...);
    g_task_ready = 1;   /* ISR现在可以安全地向此任务发送数据 */
}

/* ISR中检查 */
if (g_task_ready)
{
    OSTaskQPost(&TaskTCB, ...);
}
```

---

## 十、CubeMX / 配置代码生成器 协作规范

### 10.1 核心原则

```
1. 用户代码只写在 USER CODE BEGIN/END 块内
2. USER CODE 块之外的所有代码在重新生成时会被覆盖
3. 新增功能应创建独立文件（App/ BSP/），而非塞入 Core/
4. 每次重新生成前备份 startup.s，因为中断向量会被重置
```

### 10.2 受影响的文件

| 文件 | 影响 | 应对 |
|------|------|------|
| `Core/Src/main.c` | 保留USER CODE | 引导代码、start_task在此书写 |
| `Core/Inc/main.h` | 完全覆盖 | 不在此添加自定义声明 |
| `Core/Src/gpio.c` | 完全覆盖 | 引脚配置由CubeMX管理 |
| `Core/Src/stm32f4xx_it.c` | 保留USER CODE | ISR回调函数在此 |
| `Drivers/` | 全部覆盖 | 不修改 |
| `startup_*.s` | 完全覆盖 | 重新应用OS中断向量重命名 |

### 10.3 中断向量修复（uCOS-III专用）

每次CubeMX重新生成后，手动恢复 `startup_stm32f4xx.s` 中的修改：

```
PendSV_Handler      →  OS_CPU_PendSVHandler
SysTick_Handler     →  OS_CPU_SysTickHandler
```

### 10.4 代码生成后的操作清单

```markdown
每次 CubeMX 重新生成后的操作清单:
□ 备份并恢复 startup.s 中的OS中断向量
□ 同步新增的 .c 文件到IDE工程树中
□ 新增目录需加入Keil的 Include Paths
□ 检查 main.c 中的 USER CODE 区域是否保留完整
□ 验证 SystemClock_Config() 是否正确
□ 检查 GPIO 初始化配置是否符合预期
```

---

## 十一、版本控制规范

### 11.1 纳入版本控制的文件

```
必须纳入:
  App/*                    — 应用源码
  BSP/*                    — 板级驱动
  Core/Src/*.c             — CubeMX源码（含USER CODE）
  Core/Inc/*.h             — CubeMX头文件
  *.uvprojx / *.uvoptx     — IDE工程配置
  .mxproject               — CubeMX配置状态
  CMakeLists.txt           — 构建脚本

需确认后纳入:
  MDK-ARM/Obj/ *.o *.d     — 编译中间产物
  *.hex / *.bin            — 固件镜像

不纳入:
  .settings/               — IDE个人设置
  .uvguix.*                — 用户个性化配置
```

### 11.2 提交信息规范

```
<type>: <简短描述>

<详细说明(可选)>

格式:
  feat:   新功能
  fix:    bug修复
  refactor: 重构
  docs:   文档
  config: 配置变更
  style:  代码格式

示例:
  feat: add UART DMA transmission
  fix: correct IPC creation order to prevent deadlock
  refactor: split LED module into separate files
```

---

## 十二、编译与构建规范

### 12.1 编译器警告级别

- 开启 **所有警告**，将警告视为错误（`-Werror` / 勾选"Treat Warnings As Errors"）
- 对不可避免的警告使用 `(void)param` 或 `__attribute__((unused))` 显式抑制

### 12.2 堆栈使用

```c
/* 任务堆栈配置原则 */
#define TASK_STACK_MIN      128u      /* 最小堆栈: 简单任务 */
#define TASK_STACK_NORMAL   256u      /* 一般任务 */
#define TASK_STACK_LARGE    512u      /* 复杂任务 (含printf等) */
#define TASK_STACK_HUGE     1024u     /* 含浮点运算和大量局部变量 */

/* 系统堆/栈配置 */
// Heap: 用于标准库动态分配（通常512B~4KB）
// Stack: 用于主函数和异常处理（通常1KB~2KB）
```

### 12.3 代码优化

| 阶段 | 优化级别 | 说明 |
|------|---------|------|
| 开发调试 | `-O0` 或 Level 0 | 不优化，调试信息完整 |
| 功能验证 | `-O1` 或 Level 1 | 基本优化，可调试 |
| 发布 | `-O2` 或 Level 2 | 性能优化 |
| 代码大小优先 | `-Os` 或 Level 3 | 最小体积 |

---

## 十三、通用设计原则总结

### 13.1 嵌入式C编码黄金法则

```
1. 模块内聚 — 每个.c/.h文件只做一件事
2. 接口最小化 — 头文件只暴露必要内容，内部函数声明为 static
3. 显式优于隐式 — 类型转换不省略、错误码不忽略
4. 不动态分配 — 嵌入式系统避免 malloc（RTOS对象创建除外）
5. 可预测性 — 不使用递归、不依赖未初始化数据
6. 可中断安全 — 全局变量用 volatile、ISR用RTOS安全API
7. 配置集中化 — 所有可调参数放在 cfg.h 文件中
8. 失败可观测 — 每个错误路径有日志/标志/LED指示
```

### 13.2 常见反模式

| 反模式 | 问题 | 正确做法 |
|--------|------|---------|
| ISR中调用 printf | 阻塞、不可重入 | ISR只发IPC，任务中处理输出 |
| 全局变量裸奔 | 竞争条件 | 加互斥量或使用消息队列 |
| 魔法数字 | 不可维护 | 使用宏定义常量 |
| 长函数（>200行） | 难以理解和测试 | 拆分为语义子函数 |
| 条件编译嵌套过深 | 可读性差 | 拆分为独立函数或文件 |
| 忽略RTOS API返回值 | 隐藏错误 | 始终检查返回值 |

### 13.3 文件内布局顺序

每个 `.c` 文件内部的推荐布局：

```c
1. 文件头注释
2. #include 头文件（少量必要头文件，或仅包含 includes.h）
3. 私有宏定义
4. 私有类型定义
5. 私有全局变量 (static)
6. 模块全局变量
7. 私有函数声明 (static)
8. 公有函数实现
9. 私有函数实现
```

每个 `.h` 文件的推荐布局：

```c
1. 文件头注释
2. 头文件保护宏 (#ifndef / #define)
3. #include 依赖
4. 公有类型定义
5. 公有宏定义
6. extern 全局变量声明
7. 公有函数声明
8. #endif
```

---

## 十四、参考示例代码

本章给出完整的源文件示例，将前文所有规范集中体现在实际代码中。
各示例来自一个完整的 uCOS-III + STM32F407 项目片段，可直接作为新项目的开发模板。

---

### 14.1 includes.h — 集中式头文件管理

```c
/*
 *****************************************************************************
 * @file           : includes.h
 * @brief          : 项目统一头文件 — 集中包含所有公共模块
 * @version        : v1.0
 *****************************************************************************
 */

#ifndef __INCLUDES_H__
#define __INCLUDES_H__

/* ========== HAL层 ========== */
#include "stm32f4xx_hal.h"

/* ========== RTOS内核 ========== */
#include "os.h"
#include "os_cfg.h"
#include "os_cfg_app.h"

/* ========== CPU抽象与标准库 ========== */
#include "cpu.h"
#include "lib_def.h"
#include "lib_mem.h"

/* ========== 应用配置（最先包含，供其他模块使用优先级/堆栈定义） ========== */
#include "app_cfg.h"

/* ========== 应用层 ========== */
#include "app.h"

/* ========== BSP驱动层 ========== */
#include "bsp.h"
#include "led.h"
#include "gpio_ext.h"
#include "exti_handler.h"

#endif
```

---

### 14.2 app_cfg.h — 配置文件示例

```c
/*
 *****************************************************************************
 * @file           : app_cfg.h
 * @brief          : 应用配置 — 任务优先级、堆栈大小、队列容量
 *****************************************************************************
 */

#ifndef __APP_CFG_H__
#define __APP_CFG_H__

/* ========== 系统启动任务 ========== */
#define START_TASK_PRIO         2u
#define START_TASK_STK_SIZE     128u

/*
 * ========== 应用任务优先级分配 ==========
 * 优先级数值越小，优先级越高 (0=最高, OS_CFG_PRIO_MAX-1=最低)
 *
 * 硬实时任务         →  优先级 3
 * 周期性采集任务     →  优先级 4
 * 通信处理任务       →  优先级 5
 * 普通应用任务       →  优先级 6~7
 * 后台空闲任务       →  优先级 8
 */
/* 任务A: LED指示灯 — 1Hz闪烁 */
#define APP_CFG_TASKA_PRIO          3u
#define APP_CFG_TASKA_STK_SIZE      128u

/* 任务B: 传感器采集 — 10Hz周期 */
#define APP_CFG_TASKB_PRIO          4u
#define APP_CFG_TASKB_STK_SIZE      128u

/* 任务C: 中断数据处理 */
#define APP_CFG_TASKC_PRIO          5u
#define APP_CFG_TASKC_STK_SIZE      256u

/* 任务D/E: 互斥资源竞争 */
#define APP_CFG_TASKD_PRIO          6u
#define APP_CFG_TASKD_STK_SIZE      128u
#define APP_CFG_TASKE_PRIO          7u
#define APP_CFG_TASKE_STK_SIZE      128u

/* 任务F: 后台数据显示 */
#define APP_CFG_TASKF_PRIO          8u
#define APP_CFG_TASKF_STK_SIZE      256u

/* 消息队列容量 */
#define APP_CFG_QUEUE_MAX           10u

#endif
```

---

### 14.3 led.h — BSP驱动头文件示例

```c
/*
 *****************************************************************************
 * @file           : led.h
 * @brief          : LED驱动 — 引脚定义与功能声明
 *****************************************************************************
 */

#ifndef __LED_H__
#define __LED_H__

/* ========== 引脚宏定义 ========== */

/* LED_A ~ LED_E: 普通指示LED */
#define LED_A_GPIO_PORT             GPIOD
#define LED_A_PIN                   GPIO_PIN_12

#define LED_B_GPIO_PORT             GPIOD
#define LED_B_PIN                   GPIO_PIN_13

#define LED_C_GPIO_PORT             GPIOD
#define LED_C_PIN                   GPIO_PIN_14

#define LED_D_GPIO_PORT             GPIOD
#define LED_D_PIN                   GPIO_PIN_15

#define LED_E_GPIO_PORT             GPIOE
#define LED_E_PIN                   GPIO_PIN_0

/* LED_F0 ~ LED_F7: 8位数据总线式LED */
#define LED_F_GPIO_PORT             GPIOE
#define LED_F_PIN_START             GPIO_PIN_1      /* 起始引脚 PE1 */
#define LED_F_COUNT                 8u              /* 共8个LED */

/* ========== 电平极性配置 ========== */
/* 根据硬件原理图修改: RESET=亮 / SET=灭 */
#define LED_ON_LEVEL                GPIO_PIN_RESET
#define LED_OFF_LEVEL               GPIO_PIN_SET

/* ========== 函数声明 ========== */

void LED_Init(void);        /* LED模块初始化（如需CubeMX之外的配置）*/

void LED_A_On(void);
void LED_A_Off(void);
void LED_A_Toggle(void);

void LED_B_On(void);
void LED_B_Off(void);
void LED_B_Toggle(void);

void LED_C_On(void);
void LED_C_Off(void);
void LED_C_Toggle(void);

void LED_D_On(void);
void LED_D_Off(void);
void LED_D_Toggle(void);

void LED_E_On(void);
void LED_E_Off(void);
void LED_E_Toggle(void);

void LED_F_Set(uint8_t count);      /* 将count的低8位映射到LED_F0~F7 */
void LED_F_Reset(void);             /* 熄灭所有LED_F */

#endif
```

---

### 14.4 led.c — BSP驱动实现示例（完整规范）

```c
/*
 *****************************************************************************
 * @file           : led.c
 * @brief          : LED驱动实现 — GPIO控制LED亮灭与闪烁
 * @date           : 2026-06-23
 * @version        : v1.0
 *****************************************************************************
 * @attention
 * - LED初始化由CubeMX的MX_GPIO_Init()完成，本模块不复位初始化
 * - LED极性通过 LED_ON_LEVEL / LED_OFF_LEVEL 宏配置
 * - 硬件极性: 低电平点亮 (GPIO_PIN_RESET = ON)
 *****************************************************************************
 */

#include "includes.h"

/*
 *****************************************************************************
 *                                       私有宏定义
 *****************************************************************************
 */

#define LED_ON      HAL_GPIO_WritePin(PORT, PIN, LED_ON_LEVEL)
#define LED_OFF     HAL_GPIO_WritePin(PORT, PIN, LED_OFF_LEVEL)
#define LED_TOGGLE  HAL_GPIO_TogglePin(PORT, PIN)

/*
 *****************************************************************************
 *                                       公有函数实现
 *****************************************************************************
 */

/**
  * 函数功能: 初始化LED模块（如需额外的非CubeMX配置）
  * 输入参数: 无
  * 返 回 值: 无
  * 说    明: 默认初始化为全灭。如果CubeMX已配置好GPIO，本函数可为空。
  */
void LED_Init(void)
{
    LED_F_Reset();
}

/**
  * 函数功能: 点亮LED_A
  * 输入参数: 无
  * 返 回 值: 无
  */
void LED_A_On(void)
{
    HAL_GPIO_WritePin(LED_A_GPIO_PORT, LED_A_PIN, LED_ON_LEVEL);
}

/**
  * 函数功能: 熄灭LED_A
  * 输入参数: 无
  * 返 回 值: 无
  */
void LED_A_Off(void)
{
    HAL_GPIO_WritePin(LED_A_GPIO_PORT, LED_A_PIN, LED_OFF_LEVEL);
}

/**
  * 函数功能: 翻转LED_A
  * 输入参数: 无
  * 返 回 值: 无
  */
void LED_A_Toggle(void)
{
    HAL_GPIO_TogglePin(LED_A_GPIO_PORT, LED_A_PIN);
}

/* LED_B ~ LED_E 类似，此处省略... */

/**
  * 函数功能: 将数值的低8位映射到LED_F0 ~ LED_F7
  * 输入参数: count 是待显示的数值 (仅低8位有效)
  * 返 回 值: 无
  * 说    明: bit0 → LED_F0(PE1), bit1 → LED_F1(PE2), ...
  *           该位为1时点亮对应LED，为0时熄灭
  */
void LED_F_Set(uint8_t count)
{
    uint8_t i;
    uint16_t pin;

    for (i = 0; i < LED_F_COUNT; i++)
    {
        pin = (uint16_t)(LED_F_PIN_START << i);
        if (count & (1u << i))
        {
            HAL_GPIO_WritePin(LED_F_GPIO_PORT, pin, LED_ON_LEVEL);
        }
        else
        {
            HAL_GPIO_WritePin(LED_F_GPIO_PORT, pin, LED_OFF_LEVEL);
        }
    }
}

/**
  * 函数功能: 熄灭所有LED_F
  * 输入参数: 无
  * 返 回 值: 无
  */
void LED_F_Reset(void)
{
    /* 将 count=0 传入 LED_F_Set 即可熄灭全部 */
    LED_F_Set(0);
}
```

---

### 14.5 main.c — 精简启动流程示例

```c
/*
 *****************************************************************************
 * @file           : main.c
 * @brief          : 主函数 — 系统启动入口
 * @attention
 *   本文件由CubeMX生成，用户新增代码必须写在 USER CODE 块内。
 *****************************************************************************
 */

/* Includes ------------------------------------------------------------------*/
#include "main.h"
#include "includes.h"

/* Private variables ---------------------------------------------------------*/
/* USER CODE BEGIN PV */

/* 启动任务控制块与堆栈 */
static OS_TCB     StartTaskTCB;
static CPU_STK    START_TASK_STK[START_TASK_STK_SIZE];

/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
static void start_task(void *p_arg);

/**
  * @brief  主函数 — 系统启动入口
  * @note   启动顺序: HAL初始化 → 时钟配置 → 外设初始化
  *                    → OS初始化 → 创建启动任务 → 启动调度器
  * @param  无
  * @retval 无（OSStart后永不返回）
  */
int main(void)
{
    OS_ERR err;

    /* STEP 1: HAL库初始化 */
    HAL_Init();

    /* STEP 2: 配置系统时钟 (HSE 8MHz → PLL → 168MHz) */
    SystemClock_Config();

    /* STEP 3: 初始化基础外设 (CubeMX生成) */
    MX_GPIO_Init();
    MX_DMA_Init();
    MX_USART1_UART_Init();

    /* STEP 4: 初始化uCOS-III内核 */
    OSInit(&err);

    /* STEP 5: 创建启动任务 (所有应用初始化在start_task中完成) */
    OSTaskCreate((OS_TCB    *)&StartTaskTCB,
                 (CPU_CHAR  *)"start_task",
                 (OS_TASK_PTR) start_task,
                 (void      *) 0,
                 (OS_PRIO    ) START_TASK_PRIO,
                 (CPU_STK   *)&START_TASK_STK[0],
                 (CPU_STK_SIZE) START_TASK_STK_SIZE / 10u,
                 (CPU_STK_SIZE) START_TASK_STK_SIZE,
                 (OS_MSG_QTY ) 0u,
                 (OS_TICK    ) 0u,
                 (void      *) 0,
                 (OS_OPT     )(OS_OPT_TASK_STK_CHK | OS_OPT_TASK_STK_CLR),
                 (OS_ERR    *)&err);

    /* STEP 6: 启动RTOS调度器 (永不返回) */
    OSStart(&err);
}

/* USER CODE BEGIN 4 */

/**
  * 函数功能: 启动任务 — 完成所有应用级初始化
  * 输入参数: p_arg 保留参数，未使用
  * 返 回 值: 无
  * 说    明: 执行顺序: BSP硬件初始化 → IPC对象创建 → 应用任务创建 → 挂起自己
  *           注意: AppObjCreate() 必须先于 AppTaskCreate()，
  *           因为AppTaskCreate()会挂起当前任务。
  */
static void start_task(void *p_arg)
{
    OS_ERR err;

    (void)p_arg;

    /* 第1步: 板级硬件初始化 */
    BSP_Init();

    /* 第2步: 创建IPC对象 (信号量/互斥量/队列) */
    AppObjCreate();

    /* 第3步: 创建所有应用任务 */
    AppTaskCreate();

    /* 第4步: 挂起启动任务，不再参与调度 */
    OSTaskSuspend((OS_TCB *)0, &err);
}

/* USER CODE END 4 */
```

---

### 14.6 bsp.c — BSP初始化入口示例

```c
/*
 *****************************************************************************
 * @file           : bsp.c
 * @brief          : 板级支持包 — 统一管理所有板级外设初始化
 * @version        : v1.0
 *****************************************************************************
 * @attention
 * - BSP_Init() 在 start_task 中第一个被调用
 * - 各子模块的Init函数在其中按依赖关系顺序调用
 *****************************************************************************
 */

#include "includes.h"

/*
 *****************************************************************************
 *                                       公有函数实现
 *****************************************************************************
 */

/**
  * 函数功能: 板级支持包初始化 — 统一入口
  * 输入参数: 无
  * 返 回 值: 无
  * 说    明: 调用顺序: 滴答定时器 → GPIO初始化 → 各外设模块初始化
  *           BSP_Tick_Init() 必须先于其他外设，因为uCOS-III需要系统节拍
  */
void BSP_Init(void)
{
    /* 1. 配置uCOS-III系统滴答定时器 (SysTick, 1ms) */
    BSP_Tick_Init();

    /* 2. 初始化CubeMX生成的GPIO引脚配置 */
    MX_GPIO_Init();

    /* 3. 初始化各BSP模块 */
    LED_Init();
    EXTI_Handler_Init();
}
```

---

### 14.7 app.h — 应用层头文件示例

```c
/*
 *****************************************************************************
 * @file           : app.h
 * @brief          : 应用层头文件 — IPC对象、TCB、任务函数声明
 *****************************************************************************
 */

#ifndef __APP_H__
#define __APP_H__

/* ========== uCOS IPC对象声明 ========== */
extern OS_SEM      Sem_TaskC;       /* 信号量: 任务B → 任务C 事件通知 */
extern OS_MUTEX    M_Display;       /* 互斥量: 任务D/E 竞争显示资源 */
extern OS_Q        Q_Data;          /* 消息队列: 任务C → 任务F 数据转发 */

/* ========== 任务控制块声明 ========== */
extern OS_TCB      TaskA_TCB;
extern OS_TCB      TaskB_TCB;
extern OS_TCB      TaskC_TCB;
extern OS_TCB      TaskD_TCB;
extern OS_TCB      TaskE_TCB;
extern OS_TCB      TaskF_TCB;

/* ========== ISR安全标志 ========== */
/* 防止ISR在任务创建前进行OSTaskQPost操作 */
extern volatile uint8_t  g_taskc_ready;

/* ========== 全局变量 ========== */
extern volatile uint32_t g_exti_counter;   /* 外部中断计数 */

/* ========== 初始化函数声明 ========== */
void APP_ObjCreate(void);       /* 创建所有IPC对象 */
void APP_TaskCreate(void);      /* 创建所有应用任务 */

/* ========== 任务函数声明 ========== */
void task_a(void *p_arg);
void task_b(void *p_arg);
void task_c(void *p_arg);
void task_d(void *p_arg);
void task_e(void *p_arg);
void task_f(void *p_arg);

#endif
```

---

### 14.8 app.c — 应用层实现示例（完整RTOS任务模式）

```c
/*
 *****************************************************************************
 * @file           : app.c
 * @brief          : 应用层实现 — 任务函数、IPC创建、任务创建
 *****************************************************************************
 * @attention
 * - 所有任务函数遵循 "阻塞等待 → 处理 → 延时" 的循环模式
 * - IPC通信使用值编址传递32位数据，避免动态内存分配
 * - 文件注释使用80字符宽度星号分隔线划分区块
 *****************************************************************************
 */

#include "includes.h"

/*
 *****************************************************************************
 *                                       全局变量定义
 *****************************************************************************
 */

/* IPC对象存储空间 */
OS_SEM      Sem_TaskC;
OS_MUTEX    M_Display;
OS_Q        Q_Data;

/* 任务控制块 */
OS_TCB      TaskA_TCB;
OS_TCB      TaskB_TCB;
OS_TCB      TaskC_TCB;
OS_TCB      TaskD_TCB;
OS_TCB      TaskE_TCB;
OS_TCB      TaskF_TCB;

/* 任务堆栈 */
CPU_STK     TaskAStk[APP_CFG_TASKA_STK_SIZE];
CPU_STK     TaskBStk[APP_CFG_TASKB_STK_SIZE];
CPU_STK     TaskCStk[APP_CFG_TASKC_STK_SIZE];
CPU_STK     TaskDStk[APP_CFG_TASKD_STK_SIZE];
CPU_STK     TaskEStk[APP_CFG_TASKE_STK_SIZE];
CPU_STK     TaskFStk[APP_CFG_TASKF_STK_SIZE];

/* 全局变量 */
volatile uint32_t g_exti_counter = 0;
volatile uint8_t  g_taskc_ready  = 0;

/*
 *****************************************************************************
 *                                       任务函数实现
 *****************************************************************************
 */

/**
  * 函数功能: 任务A — LED_A以1Hz闪烁10次后挂起
  * 输入参数: p_arg 创建任务时传递的参数（未使用）
  * 返 回 值: 无
  * 说    明: 1个周期 = 500ms亮 + 500ms灭 = 1Hz
  *           10次完成后调用 OSTaskSuspend 挂起自己
  */
void task_a(void *p_arg)
{
    OS_ERR err;
    int i;

    (void)p_arg;

    for (i = 0; i < 10; i++)
    {
        LED_A_On();                         /* 点亮 */
        OSTimeDly(500, OS_OPT_TIME_DLY, &err);

        LED_A_Off();                        /* 熄灭 */
        OSTimeDly(500, OS_OPT_TIME_DLY, &err);
    }

    /* 任务执行完毕，挂起自己 */
    OSTaskSuspend((OS_TCB *)0, &err);
}

/**
  * 函数功能: 任务B — LED_B以10Hz闪烁20次后通知任务C
  * 输入参数: p_arg 未使用
  * 返 回 值: 无
  * 说    明: 10Hz = 50ms亮 + 50ms灭
  *           20次完成后通过 OSSemPost 通知任务C开始工作
  */
void task_b(void *p_arg)
{
    OS_ERR err;
    int i;

    (void)p_arg;

    for (i = 0; i < 20; i++)
    {
        LED_B_On();
        OSTimeDly(50, OS_OPT_TIME_DLY, &err);

        LED_B_Off();
        OSTimeDly(50, OS_OPT_TIME_DLY, &err);
    }

    /* 通知任务C: 准备工作已完成 */
    OSSemPost(&Sem_TaskC, OS_OPT_POST_1, &err);

    /* 挂起自己 */
    OSTaskSuspend((OS_TCB *)0, &err);
}

/**
  * 函数功能: 任务C — 等待信号量后，接收中断数据并转发到队列
  * 输入参数: p_arg 未使用
  * 返 回 值: 无
  * 说    明: 先阻塞在 Sem_TaskC 上等待任务B发信号，
  *           然后循环接收 ISR 发来的计数(通过OSTaskQPend)，
  *           再通过 OSQPost 转发给任务F处理，
  *           同时根据中断计数的奇偶控制 LED_C。
  */
void task_c(void *p_arg)
{
    OS_ERR      err;
    OS_MSG_SIZE msg_size;
    void       *p_msg;
    CPU_TS      ts;
    uint32_t    count;

    (void)p_arg;

    /* 等待任务B发出"准备工作完成"信号 */
    OSSemPend(&Sem_TaskC, 0u, OS_OPT_PEND_BLOCKING, NULL, &err);

    while (1)
    {
        /* 非阻塞方式检查邮箱中有无新消息 */
        p_msg = OSTaskQPend((OS_TICK)0u,
                            OS_OPT_PEND_NON_BLOCKING,
                            &msg_size,
                            &ts,
                            &err);

        if (err == OS_ERR_NONE)
        {
            /* 值编址: 将指针还原为计数值 */
            count = (uint32_t)(CPU_ADDR)p_msg;

            /* 将数据转发到消息队列 */
            OSQPost(&Q_Data,
                    (void *)p_msg,
                    (OS_MSG_SIZE)sizeof(uint32_t),
                    (OS_OPT     )OS_OPT_POST_FIFO,
                    (OS_ERR    *)&err);

            /* 根据计数值控制LED_C */
            if (count % 2 == 0)
            {
                LED_C_On();
            }
            else
            {
                LED_C_Off();
            }
        }

        OSTimeDly(100, OS_OPT_TIME_DLY, &err);  /* 10Hz轮询 */
    }
}

/**
  * 函数功能: 任务D — 检测外部输入PB0，竞争互斥量控制LED_D
  * 输入参数: p_arg 未使用
  * 返 回 值: 无
  * 说    明: 与任务E竞争 M_Display 互斥量，
  *           获取到互斥量后根据PB0电平控制LED_D亮灭。
  *           使用 OSMutexPend 确保资源访问原子性。
  */
void task_d(void *p_arg)
{
    OS_ERR err;
    uint8_t state;

    (void)p_arg;

    while (1)
    {
        state = EXT_IN1_Read();                     /* 读取PB0电平 */

        OSMutexPend(&M_Display,                     /* 请求互斥量 */
                    0u,
                    OS_OPT_PEND_BLOCKING,
                    NULL,
                    &err);

        if (state == GPIO_PIN_SET)
        {
            LED_D_On();
        }
        else
        {
            LED_D_Off();
        }

        OSMutexPost(&M_Display, OS_OPT_POST_NONE, &err);  /* 释放互斥量 */

        OSTimeDly(100, OS_OPT_TIME_DLY, &err);
    }
}

/**
  * 函数功能: 任务E — 检测外部输入PB1，竞争互斥量控制LED_E
  * 输入参数: p_arg 未使用
  * 返 回 值: 无
  * 说    明: 与任务D竞争同一个 M_Display 互斥量，
  *           OSMutexPend 确保同一时间只有一个任务操作显示资源。
  */
void task_e(void *p_arg)
{
    OS_ERR err;
    uint8_t state;

    (void)p_arg;

    while (1)
    {
        state = EXT_IN2_Read();                     /* 读取PB1电平 */

        OSMutexPend(&M_Display,                     /* 请求互斥量 */
                    0u,
                    OS_OPT_PEND_BLOCKING,
                    NULL,
                    &err);

        if (state == GPIO_PIN_SET)
        {
            LED_E_On();
        }
        else
        {
            LED_E_Off();
        }

        OSMutexPost(&M_Display, OS_OPT_POST_NONE, &err);  /* 释放互斥量 */

        OSTimeDly(100, OS_OPT_TIME_DLY, &err);
    }
}

/**
  * 函数功能: 任务F — 从队列接收数据，驱动LED_F显示
  * 输入参数: p_arg 未使用
  * 返 回 值: 无
  * 说    明: 阻塞等待 OSQPend，数据到达后取 data % 8，
  *           结果驱动LED_F0~F7显示对应的二进制图案。
  */
void task_f(void *p_arg)
{
    OS_ERR      err;
    OS_MSG_SIZE msg_size;
    void       *p_msg;
    uint32_t    count;

    (void)p_arg;

    while (1)
    {
        /* 阻塞等待消息队列数据 */
        p_msg = OSQPend(&Q_Data,
                        0u,
                        OS_OPT_PEND_BLOCKING,
                        &msg_size,
                        NULL,
                        &err);

        if (err == OS_ERR_NONE)
        {
            /* 值编址: 将指针还原为计数值 */
            count = (uint32_t)(CPU_ADDR)p_msg;

            /* 取模后驱动LED_F显示 */
            LED_F_Set((uint8_t)(count % 8u));
        }
    }
}

/*
 *****************************************************************************
 *                                       应用初始化函数
 *****************************************************************************
 */

/**
  * 函数功能: 创建所有IPC对象 — 必须在任务创建之前调用
  * 输入参数: 无
  * 返 回 值: 无
  * 说    明: 依次创建信号量、互斥量、消息队列。
  *           此函数必须先于 APP_TaskCreate()，因为任务创建后会挂起
  *           start_task，导致后续代码无法执行。
  */
void APP_ObjCreate(void)
{
    OS_ERR err;

    OSSemCreate((OS_SEM   *)&Sem_TaskC,
                (CPU_CHAR *)"Sem_TaskC",
                (OS_SEM_CTR) 0u,
                (OS_ERR   *)&err);

    OSMutexCreate((OS_MUTEX *)&M_Display,
                  (CPU_CHAR *)"M_Display",
                  (OS_ERR   *)&err);

    OSQCreate((OS_Q      *)&Q_Data,
              (CPU_CHAR  *)"Q_Data",
              (OS_MSG_QTY) APP_CFG_QUEUE_MAX,
              (OS_ERR    *)&err);
}

/**
  * 函数功能: 创建所有应用任务
  * 输入参数: 无
  * 返 回 值: 无
  * 说    明: 按优先级从高到低依次创建任务A~F。
  *           任务C创建完成后设置 g_taskc_ready = 1，
  *           告知ISR可以安全地向TaskC发送邮箱消息。
  *           调用OSTaskSuspend挂起start_task本身。
  */
void APP_TaskCreate(void)
{
    OS_ERR err;

    /* 创建任务A: LED 1Hz闪烁 */
    OSTaskCreate((OS_TCB     *)&TaskA_TCB,
                 (CPU_CHAR   *)"task_a",
                 (OS_TASK_PTR ) task_a,
                 (void       *) 0,
                 (OS_PRIO     ) APP_CFG_TASKA_PRIO,
                 (CPU_STK    *)&TaskAStk[0],
                 (CPU_STK_SIZE) APP_CFG_TASKA_STK_SIZE / 10u,
                 (CPU_STK_SIZE) APP_CFG_TASKA_STK_SIZE,
                 (OS_MSG_QTY ) 0u,
                 (OS_TICK    ) 0u,
                 (void       *) 0,
                 (OS_OPT     )(OS_OPT_TASK_STK_CHK | OS_OPT_TASK_STK_CLR),
                 (OS_ERR     *)&err);

    /* 创建任务B: LED 10Hz闪烁 + 发送信号量 */
    OSTaskCreate((OS_TCB     *)&TaskB_TCB,
                 (CPU_CHAR   *)"task_b",
                 (OS_TASK_PTR ) task_b,
                 (void       *) 0,
                 (OS_PRIO     ) APP_CFG_TASKB_PRIO,
                 (CPU_STK    *)&TaskBStk[0],
                 (CPU_STK_SIZE) APP_CFG_TASKB_STK_SIZE / 10u,
                 (CPU_STK_SIZE) APP_CFG_TASKB_STK_SIZE,
                 (OS_MSG_QTY ) 0u,
                 (OS_TICK    ) 0u,
                 (void       *) 0,
                 (OS_OPT     )(OS_OPT_TASK_STK_CHK | OS_OPT_TASK_STK_CLR),
                 (OS_ERR     *)&err);

    /* 创建任务C: 中断数据处理 + 队列转发 */
    OSTaskCreate((OS_TCB     *)&TaskC_TCB,
                 (CPU_CHAR   *)"task_c",
                 (OS_TASK_PTR ) task_c,
                 (void       *) 0,
                 (OS_PRIO     ) APP_CFG_TASKC_PRIO,
                 (CPU_STK    *)&TaskCStk[0],
                 (CPU_STK_SIZE) APP_CFG_TASKC_STK_SIZE / 10u,
                 (CPU_STK_SIZE) APP_CFG_TASKC_STK_SIZE,
                 (OS_MSG_QTY ) 10u,
                 (OS_TICK    ) 0u,
                 (void       *) 0,
                 (OS_OPT     )(OS_OPT_TASK_STK_CHK | OS_OPT_TASK_STK_CLR),
                 (OS_ERR     *)&err);

    /* ISR安全标志: 通知ISR现在可以安全地向TaskC发送数据 */
    g_taskc_ready = 1;

    /* 创建任务D: 外部输入PB0 + 互斥量 */
    OSTaskCreate((OS_TCB     *)&TaskD_TCB,
                 (CPU_CHAR   *)"task_d",
                 (OS_TASK_PTR ) task_d,
                 (void       *) 0,
                 (OS_PRIO     ) APP_CFG_TASKD_PRIO,
                 (CPU_STK    *)&TaskDStk[0],
                 (CPU_STK_SIZE) APP_CFG_TASKD_STK_SIZE / 10u,
                 (CPU_STK_SIZE) APP_CFG_TASKD_STK_SIZE,
                 (OS_MSG_QTY ) 0u,
                 (OS_TICK    ) 0u,
                 (void       *) 0,
                 (OS_OPT     )(OS_OPT_TASK_STK_CHK | OS_OPT_TASK_STK_CLR),
                 (OS_ERR     *)&err);

    /* 创建任务E: 外部输入PB1 + 互斥量 */
    OSTaskCreate((OS_TCB     *)&TaskE_TCB,
                 (CPU_CHAR   *)"task_e",
                 (OS_TASK_PTR ) task_e,
                 (void       *) 0,
                 (OS_PRIO     ) APP_CFG_TASKE_PRIO,
                 (CPU_STK    *)&TaskEStk[0],
                 (CPU_STK_SIZE) APP_CFG_TASKE_STK_SIZE / 10u,
                 (CPU_STK_SIZE) APP_CFG_TASKE_STK_SIZE,
                 (OS_MSG_QTY ) 0u,
                 (OS_TICK    ) 0u,
                 (void       *) 0,
                 (OS_OPT     )(OS_OPT_TASK_STK_CHK | OS_OPT_TASK_STK_CLR),
                 (OS_ERR     *)&err);

    /* 创建任务F: 队列数据显示 */
    OSTaskCreate((OS_TCB     *)&TaskF_TCB,
                 (CPU_CHAR   *)"task_f",
                 (OS_TASK_PTR ) task_f,
                 (void       *) 0,
                 (OS_PRIO     ) APP_CFG_TASKF_PRIO,
                 (CPU_STK    *)&TaskFStk[0],
                 (CPU_STK_SIZE) APP_CFG_TASKF_STK_SIZE / 10u,
                 (CPU_STK_SIZE) APP_CFG_TASKF_STK_SIZE,
                 (OS_MSG_QTY ) 0u,
                 (OS_TICK    ) 0u,
                 (void       *) 0,
                 (OS_OPT     )(OS_OPT_TASK_STK_CHK | OS_OPT_TASK_STK_CLR),
                 (OS_ERR     *)&err);

    /* 所有任务创建完毕，挂起start_task本身 */
    OSTaskSuspend((OS_TCB *)0, &err);
}
```

---

### 14.9 exti_handler.c — ISR处理示例

```c
/*
 *****************************************************************************
 * @file           : exti_handler.c
 * @brief          : 外部中断处理 — EXTI ISR回调与初始化
 *****************************************************************************
 * @attention
 * - ISR中不做耗时操作，仅执行计数 + OSTaskQPost发送通知
 * - 使用 g_taskc_ready 标志确保ISR不会在TaskC创建前向其发消息
 * - 值编址方式传递计数值，避免动态内存分配
 * - 必须在 OSIntEnter / OSIntExit 包围中调用RTOS API
 *****************************************************************************
 */

#include "includes.h"

/*
 *****************************************************************************
 *                                       全局变量
 *****************************************************************************
 */

/* 外部中断计数器 — volatile防止编译器优化 */
volatile uint32_t g_exti_counter = 0;

/* 外部中断引脚宏定义 */
#define EXT_INT_GPIO_PORT           GPIOA
#define EXT_INT_PIN                 GPIO_PIN_0

/*
 *****************************************************************************
 *                                       公有函数实现
 *****************************************************************************
 */

/**
  * 函数功能: EXTI中断模块初始化 — 空实现
  * 输入参数: 无
  * 返 回 值: 无
  * 说    明: GPIO的EXTI模式和NVIC使能由CubeMX的MX_GPIO_Init()完成。
  *           本函数保留以保持BSP接口一致性，方便后续扩展。
  */
void EXTI_Handler_Init(void)
{
    /* 当前由CubeMX管理EXTI配置，本函数保留为空 */
}

/**
  * 函数功能: HAL_GPIO_EXTI_Callback — 外部中断回调函数
  * 输入参数: GPIO_Pin 是触发中断的引脚号
  * 返 回 值: 无
  * 说    明: 此函数由HAL库在中断服务中自动调用。
  *           每次EXTI触发时递增计数器，并将当前计数值通过
  *           OSTaskQPost发送给TaskC的任务消息队列。
  *
  *           注意：
  *           - 必须使用 OSIntEnter/OSIntExit 包围RTOS API调用
  *           - 必须检查 g_taskc_ready 标志，防止在TaskC尚未创建时
  *             调用 OSTaskQPost 导致系统崩溃
  */
void HAL_GPIO_EXTI_Callback(uint16_t GPIO_Pin)
{
    OS_ERR err;

    if (GPIO_Pin == EXT_INT_PIN)
    {
        /* 通知uCOS内核进入中断上下文 */
        OSIntEnter();

        /* 递增中断计数器 */
        g_exti_counter++;

        /*
         * ISR安全检查: 确认任务C已创建完成
         * 在APP_TaskCreate()中设置g_taskc_ready=1之前，
         * TaskC_TCB尚未完成初始化，OSTaskQPost将访问无效内存
         */
        if (g_taskc_ready)
        {
            /*
             * 值编址模式: 将32位计数值直接编码在指针中传递
             * 无需动态分配内存，ISR中绝对安全
             */
            OSTaskQPost((OS_TCB     *)&TaskC_TCB,
                        (void       *)(CPU_ADDR)g_exti_counter,
                        (OS_MSG_SIZE) sizeof(uint32_t),
                        (OS_OPT     ) OS_OPT_POST_FIFO,
                        (OS_ERR     *)&err);
        }

        /* 通知uCOS内核退出中断上下文（可能触发任务切换）*/
        OSIntExit();
    }
}
```
