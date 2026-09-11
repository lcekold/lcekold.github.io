# 场景一：在Windows PC上安装（用于仿真学习）

* 对应产品：CODESYS Control Win V3
* 安装步骤：
  1. 下载并安装CODESYS IDE：从CODESYS Store下载最新的CODESYS Development System V3并安装。
  2. 在安装时勾选组件：在安装过程中，当出现组件选择界面时，务必勾选“CODESYS Control Win V3” 这个选项。
  3. 完成安装：按照指引完成安装，如有提示重启电脑。

* 特点：安装后，你的电脑本身就成了一个“虚拟PLC”。你可以在CODESYS里直接选择CODESYS Control Win V3作为设备来下载和运行程序，非常适合前期学习。

# 场景二：在Windows工业电脑（IPC）上安装（用于硬实时控制）

如果需要在工业电脑上实现真正的“硬实时”控制（如控制伺服电机），就需要安装专用的RTE版本。RTE版本会附带独立实时内核、独占CPU核心、实时网卡驱动等组件，能够提供媲美硬PLC的实时性能。

* 对应产品：CODESYS Control RTE SL。
* 安装步骤：
1. 下载正确的安装包：从CODESYS官网下载CODESYS Control RTE SL安装包。
2. 前期准备：
    * 确保操作系统是64位的Windows 10/11专业版或企业版。
    * 安装前可能需要先安装.NET Framework环境。
    * 为了确保实时性，建议在电脑的BIOS中关闭超线程、节能降频等选项。
3. 安装Runtime：
    * 以管理员身份运行安装包。
    * 在64位系统上，RTE安装后会完全占用一个CPU核心专门用于实时控制，因此建议工控机至少是双核及以上。
    * 根据项目需要，可选择安装带运动控制功能的CODESYS SoftMotion RTE。
    * 按照向导完成安装，完成后重启电脑。
4. 安装实时网卡驱动（关键步骤）：
    * 打开电脑的设备管理器，找到你的网卡。
    * 右键点击网卡，选择“更新驱动程序” -> “浏览我的电脑以查找驱动程序” -> “让我从计算机上的可用驱动程序列表中选取” -> “从磁盘安装”。
    * 浏览到CODESYS Control RTE的安装目录，根据你的网卡型号（如Intel或Realtek）选择对应的驱动（如CmpEt1000MPD）并安装。

* 特点：这个方案能让Windows电脑具备媲美硬PLC的实时性能，但配置也相对复杂。
* 
# PC上和工业电脑IPC针对CODESYS Runtime的区别

|特性|	工业电脑 + CODESYS RTE|	普通PC + CODESYS Control Win V3|
|-----|-----|-----|
|实时性|	硬实时，抖动在微秒(µs)级	|非实时，抖动在毫秒(ms)甚至更高
|操作系统|	Windows + 独立实时内核	|标准Windows
|CPU核心|	独占一个或多个物理核心	|与其他程序共享所有核心
|网卡要求|	必须在官方兼容列表内，并安装专用驱动	|支持绝大多数普通网卡
|硬件设计|	工业级，为7x24小时稳定运行设计	|消费级，为日常办公/家用设计
|主要用途|	真正的工业现场控制、伺服运动控制	|功能测试、学习、非实时仿真

# 场景三：在Linux设备上安装
这是在树莓派、BeagleBone等ARM架构或x86 Linux设备上安装Runtime的通用方法。核心思路是通过CODESYS IDE将Runtime“推送”到目标设备上。

* 对应产品：CODESYS Control for Linux SL等。
* 前提条件：
    * 目标Linux设备（如树莓派）与你的编程电脑在同一局域网内。
    * 目标设备已开启SSH服务，并知道其IP地址、用户名和密码。

* 安装步骤：
  1. 下载Runtime包：从CODESYS Store下载对应你设备CPU架构（如ARM64）的Runtime包（.package文件）。
  2. 在IDE中安装Runtime包：打开CODESYS IDE，通过菜单 Tools -> Package Manager 来安装刚才下载的.package文件。
  3. 部署Runtime到设备：
    * 在CODESYS IDE中，通过菜单 Tools -> Update <你的设备型号>。（对于某些设备，可能需要在项目设备树中右键点击设备选择更新）。
    * 在弹出的对话框中，输入目标设备的IP地址、SSH用户名和密码。
    * 点击 Install 按钮，IDE就会自动将Runtime安装到你的Linux设备上。
4. 启动Runtime：安装完成后，点击 Start 按钮即可在远程设备上启动Runtime服务。

* 特点：这是最常用的远程部署方式。如果目标设备没有包管理器，也可以手动复制文件进行安装