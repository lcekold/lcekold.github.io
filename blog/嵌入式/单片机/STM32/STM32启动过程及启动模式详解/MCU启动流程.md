<a href="https://blog.csdn.net/weixin_42734533/article/details/131812546">mcu 启动流程</a>

<a href="https://blog.csdn.net/m0_37989557/article/details/149487123">单片机启动流程和启动文件详解</a>

可以观看视频：<a href="https://www.bilibili.com/video/BV1fu4Zz1EJX/?spm_id_from=333.337.search-card.all.click&vd_source=5be5e86b9e7c139662b138b3a67af7cb">全网第一个讲明白MCU单片机启动流程的</a>

<div><img src="https://cdn.jsdelivr.net/gh/lcekold/blogimage@main/Network/5f560cfaa591c6819ee92e82144ac71a.jpg"></div>

## 内存分区：
Flash (ROM)：

* 存储代码（.text）、常量（.rodata）、向量表、.data段的初始值（.idata）。

RAM：

* .data段：存放已初始化的全局变量/静态变量（启动时从Flash复制）。

* .bss段：存放未初始化的全局变量/静态变量（启动时清零）。

* 堆（Heap）：动态内存分配区（malloc/free使用）。

* 栈（Stack）：存放局部变量、函数调用返回地址等（向下增长）。

启动文件（.s文件）：

* 通常由汇编编写（如ARM的startup_stm32f4xx.s）。

* 定义了堆栈大小、向量表、Reset_Handler函数、内存段初始化逻辑。

* 是链接器配置的重要组成部分。

