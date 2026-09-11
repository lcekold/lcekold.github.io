推荐阅读：
<a href="https://zhuanlan.zhihu.com/p/89240672">串口、COM口、UART口, TTL、RS-232、RS-485区别详解</a>

在学习的过程中，我们很容易造成一些概念的混淆，比如说单片机的串口引脚连接USB转TTL模块后和电脑进行连接，此时电脑的COM口会识别到一个显示为CH340的设备，它们之间究竟有什么关联？我们后续又会接触到RS232和RS485，它们又都是什么意思？

这些事情其实并不复杂，简单来说，串口是一个总称，COM口是电脑对串口设备的一个命名，UART是一种串口通信协议，TTL、RS232、RS485是串口不同的电平标准。

以单片机串口为例：单片机串口通常使用TTL电平来实现，所以常叫做TTL串口，两者是协议+电气的组合关系。至于USB口其实跟串口没多大关联，只不过我们的电脑上由于历史问题实际上已经没有串口接口了，但保留了USB口，所以我们需要一个USB转TTL模块来实现单片机串口和电脑之间的通信。

# 一、TTL、RS232、RS485三种电气标准的区别

|特性|	串口（UART/TTL）|	RS232|	RS485|
|------|------|------|-----|
|电平	|3.3V/5V|	±12V|	差分 (A/B)|
|通信距离	|几十厘米|	15 米|	1200 米|
|连接方式	|1 对 1|	1 对 1|	1 主多从（32 个）|
|抗干扰能力	|弱|	一般|	极强|
|线数	|TX、RX（2 根）|	TX、RX、GN|	A、B（2 根）|
|速度	|快|	中|	中|
|常用场景	|单片机板内通信|	旧电脑 / 设备|	工业长距离通信|


# 二、转换方式

## 2.1 TTL转RS232和RS485

单片机的串口并不能直接接RS232或RS485设备，因为它们的电平标准不同。我们需要使用芯片来实现TTL与RS232或RS485之间的转换。常见的有：

* TTL 串口 ↔ RS232：用 MAX232
* TTL 串口 ↔ RS485：用 MAX485 / SP3485

## 2.2 USB转TTL、USB转RS232和USB转RS485

由于现代电脑已经没有传统的串口接口了，而单片机的串口电平标准是TTL，我们需要使用USB转TTL模块来实现单片机串口和电脑之间的通信。常见的USB转TTL芯片有：

* CH340
* FT232
* PL2303

同理，如果我们需要将电脑连接到RS232或RS485设备上，我们也需要使用相应的USB转RS232或USB转RS485模块。

常见的USB转RS232方案有：

* USB 转 TTL 芯片 + 电平转换芯片（如 MAX232）

电路方案可以看立创开源广场的这个项目：<a href="https://oshwhub.com/xuhuan_0415/usb_rs232">基于CH340的USB转RS232</a>

<center>
<img src="https://cdn.jsdelivr.net/gh/lcekold/blogimage@main/Network/20260326210509540.png"><br>
图：USB转RS232
</center>

常见的USB转RS485方案有：

* USB 转 TTL 芯片 + 485 收发芯片（如 MAX485）

电路方案可以看立创开源广场的这个项目：<a href="https://oshwhub.com/xxlanxx/ch340_rs485_2024-04-27_11-11-53">自制USB转RS485调试器</a>

<center>
<img src="https://cdn.jsdelivr.net/gh/lcekold/blogimage@main/Network/20260326225603849.png"><br>
图：USB转RS485
</center>

# 三、代码

其实TTL、RS232、RS485只是电平标准的不同，通信协议上并没有区别，所以在代码层面上，我们只需要使用UART协议来进行通信即可。我们只需要根据实际的硬件连接来选择相应的串口接口进行通信。

RS232代码：

```c
#include "stm32f1xx_hal.h"

// 串口句柄（UART1 作为 RS232 接口）
UART_HandleTypeDef huart1;

// --------------------------
// 初始化 RS232（UART1）
// --------------------------
void MX_USART1_UART_Init(void)
{
  huart1.Instance = USART1;
  huart1.Init.BaudRate = 9600;        // 波特率
  huart1.Init.WordLength = UART_WORDLENGTH_8B;
  huart1.Init.StopBits = UART_STOPBITS_1;
  huart1.Init.Parity = UART_PARITY_NONE;
  huart1.Init.Mode = UART_MODE_TX_RX;
  huart1.Init.HwFlowCtl = UART_HWCONTROL_NONE;
  huart1.Init.OverSampling = UART_OVERSAMPLING_16;
  HAL_UART_Init(&huart1);
}

// --------------------------
// RS232 发送字符串
// --------------------------
void RS232_SendString(char *str)
{
  HAL_UART_Transmit(&huart1, (uint8_t*)str, strlen(str), 100);
}

// --------------------------
// RS232 接收单个字节（阻塞式）
// --------------------------
uint8_t RS232_ReceiveByte(void)
{
  uint8_t ch;
  HAL_UART_Receive(&huart1, &ch, 1, 100);
  return ch;
}

// --------------------------
// 主函数测试
// --------------------------
int main(void)
{
  HAL_Init();
  SystemClock_Config();
  MX_GPIO_Init();
  MX_USART1_UART_Init();  // RS232 初始化

  RS232_SendString("STM32 RS232 Test\r\n");

  while(1)
  {
    uint8_t ch = RS232_ReceiveByte();
    RS232_SendString("Received: ");
    HAL_UART_Transmit(&huart1, &ch, 1, 100);
    RS232_SendString("\r\n");
  }
}
```

RS485代码：

```c
#include "stm32f1xx_hal.h"
#include <string.h>

UART_HandleTypeDef huart1;

// ==================== RS485 配置 ====================
#define RS485_USART      &huart1      // 使用串口1
#define RS485_DE_RE_PIN  GPIO_PIN_0   // DE/RE控制脚
#define RS485_DE_RE_PORT GPIOB        // 控制脚端口

// ------------------- 初始化串口（RS485用） -------------------
void MX_USART1_UART_Init(void)
{
  huart1.Instance = USART1;
  huart1.Init.BaudRate = 9600;        // 波特率
  huart1.Init.WordLength = UART_WORDLENGTH_8B;
  huart1.Init.StopBits = UART_STOPBITS_1;
  huart1.Init.Parity = UART_PARITY_NONE;
  huart1.Init.Mode = UART_MODE_TX_RX;
  huart1.Init.HwFlowCtl = UART_HWCONTROL_NONE;
  huart1.Init.OverSampling = UART_OVERSAMPLING_16;
  HAL_UART_Init(&huart1);
}

// ------------------- RS485 发送模式 -------------------
void RS485_SendMode(void)
{
  HAL_GPIO_WritePin(RS485_DE_RE_PORT, RS485_DE_RE_PIN, GPIO_PIN_SET); // 高电平 = 发送
}

// ------------------- RS485 接收模式 -------------------
void RS485_ReceiveMode(void)
{
  HAL_GPIO_WritePin(RS485_DE_RE_PORT, RS485_DE_RE_PIN, GPIO_PIN_RESET); // 低电平 = 接收
}

// ------------------- RS485 发送字符串 -------------------
void RS485_SendString(char *str)
{
  int len = strlen(str);
  
  RS485_SendMode();                // 切换到发送模式
  HAL_UART_Transmit(RS485_USART, (uint8_t *)str, len, 100); // 发送数据
  RS485_ReceiveMode();             // 发完立刻切回接收
}

// ------------------- RS485 接收1个字节 -------------------
uint8_t RS485_ReceiveByte(void)
{
  uint8_t ch;
  RS485_ReceiveMode(); // 确保是接收模式
  HAL_UART_Receive(RS485_USART, &ch, 1, 100);
  return ch;
}

// ------------------- 主函数测试 -------------------
int main(void)
{
  HAL_Init();
  SystemClock_Config();
  MX_GPIO_Init();
  MX_USART1_UART_Init();

  // 初始化DE/RE脚为推挽输出
  GPIO_InitTypeDef gpio_conf = {0};
  __HAL_RCC_GPIOB_CLK_ENABLE();
  
  gpio_conf.Pin = RS485_DE_RE_PIN;
  gpio_conf.Mode = GPIO_MODE_OUTPUT_PP;
  gpio_conf.Pull = GPIO_NOPULL;
  gpio_conf.Speed = GPIO_SPEED_FREQ_LOW;
  HAL_GPIO_Init(RS485_DE_RE_PORT, &gpio_conf);

  RS485_ReceiveMode(); // 默认进入接收模式

  RS485_SendString("STM32 RS485 Ready\r\n");

  while(1)
  {
    uint8_t data = RS485_ReceiveByte();
    RS485_SendString("Received: ");
    HAL_UART_Transmit(RS485_USART, &data, 1, 100);
    RS485_SendString("\r\n");
  }
}
```

