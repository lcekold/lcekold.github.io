# 低功耗模式

|模式|CPU状态|外设时钟|唤醒方式|功耗水平|   
|----|----|----|----|----|
|Sleep模式|CPU停止执行命令|外设时钟保持|任意中断|低|
|Stop模式|CPU停止、主时钟关闭|外设时钟关闭、SRAM/寄存器保持|EXTI、RTC、USB唤醒|更低|
|Standby模式|CPU停止，SRAM、寄存器丢失|所有时钟关闭，仅RTC/唤醒引脚可用|唤醒引脚、RTC闹钟、NRST|最低|


# 代码例程

```c
int sleep = 0;
int stop = 0;
int standby = 0;

void HAL_GPIO_EXTI_Callback(uint16_t GPIO_Pin) 
{
    switch(GPIO_Pin) 
    {
        case GPIO_PIN_0: // 进入Sleep模式
            sleep = 1;
            break;
        case GPIO_PIN_1: // 进入Stop模式
            stop = 1;
            break;
        case GPIO_PIN_2: // 进入Standby模式
            standby = 1;
            break;
    }
}

void main()
{
    MX_GPIO_Init();
    MX_USART1_UART_Init();
    printf("System Start\r\n")

    while(1)
    {
        if(sleep) 
        {
            sleep = 0; // 进入Sleep模式前重置标志
            HAL_SuspendTick(); // 暂停SysTick中断，防止唤醒后立即进入Sleep
            __enable_fiq(); // 允许快速中断，确保能唤醒
            __WFI(); // 进入Sleep模式，等待中断唤醒
            HAL_ResumeTick(); // 唤醒后恢复SysTick中断
        }
        else if(stop) 
        {
            stop = 0; // 进入Stop模式前重置标志
            HAL_SuspendTick(); // 暂停SysTick中断，防止唤醒后立即进入Stop
            SCB->SCR |= SCB_SCR_SLEEPDEEP_Msk; // 设置SLEEPDEEP位，进入Stop模式
            __HAL_RCC_PWR_CLK_ENABLE(); // 使能电源控制时钟
            HAL_PWR_EnterSTOPMode(PWR_LOWPOWERREGULATOR_ON, PWR_STOPENTRY_WFI); // 进入Stop模式，等待中断唤醒

            SystemClock_Config(); // 唤醒后重新配置系统时钟
            HAL_ResumeTick(); // 唤醒后恢复SysTick中断
            printf("wake up from stop\r\n");
        }
        else if(standby) 
        {
            standby = 0; // 进入Standby模式前重置标志
            HAL_SuspendTick(); // 暂停SysTick中断，防止唤醒后立即进入Standby
            __HAL_RCC_PWR_CLK_ENABLE(); // 使能电源控制时钟
            __HAL_PWR_CLEAR_FLAG(PWR_FLAG_WU); // 清除唤醒标志
            HAL_PWR_EnableWakeUpPin(PWR_WAKEUP_PIN1); // 使能唤醒引脚1  
            HAL_PWR_EnterSTANDBYMode(); // 进入Standby模式，等待唤醒
        }

        printf("Hello World\r\n");
        HAL_Delay(500);
    }
}
```