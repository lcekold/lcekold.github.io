参考这两篇文档：
<a href="https://blog.csdn.net/qq_73648789/article/details/148962454">【uC/OS】基于STM32+HAL库的uC/OS-III移植与多任务程序示例演示</a>

野火的文档：<a href="https://doc.embedfire.com/rtos/ucos/zh/latest/application/porting_to_stm32.html#startup-stm32f10x-hd-s76-77">2. 移植μC/OS-III到STM32</a>

两篇都要看一眼，第一篇使用的是STM32F103C8T6 使用的是HAL库配置，第二篇使用的是STM32F4系列的板子 使用的是标准库配置，第一篇光讲了如何移植，第二篇也详细讲解了一些文件的作用。并且如果使用的是F4系列的板子想要开启FPU的话一定要看野火的教程，里面有提到如何开启FPU。
