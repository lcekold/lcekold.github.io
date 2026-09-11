# 一、EtherCAT是什么？

EtherCAT（Ethernet for Control Automation Technology，以太网控制自动化技术）是一种**高性能、硬实时**的工业以太网现场总线协议，由德国倍福（Beckhoff）公司于2003年提出，并发布为开放的（IEC 61158）标准。

EtherCAT 的本质可以概括为：

> **EtherCAT = 标准以太网物理层 + 高速实时“飞传”处理**

* 标准以太网物理层：依然使用普通网线（超五类及以上）和 RJ45 水晶头，这也是它“以太网”名字的由来。
* 高速实时处理：在帧传输的过程中，一路“飞读飞写”完成所有从站的数据交换，几乎不引入延迟。

EtherCAT消除了很多协议栈，如UDP/IP或TCP/IP，这意味着EtherCAT不是一个基于IP的协议，更类似于第2层或数据链路层协议

EtherCAT帧或电报由以太网标头组成，后跟EtherCAT数据，并以帧检查序列（FCS）结束。EtherCAT协议通过使用以太网头中EtherType字段中的0x88A4标识符进行识别。

* EtherCAT数据包含一个EtherCAT特定的头，后面跟着EtherCAT Datagram。
* EtherCAT标头指定后续EtherCAT数据报文的总长度和类型。EtherCAT头之后是
* EtherCAT数据报文，它包含将在网络中读取或写入的实际数据。这些数据包括地址规范、主机想要执行的命令类型（即读取、写入或读写）以及循环过程数据（PDO）。

<img src="https://cdn.jsdelivr.net/gh/lcekold/lcekold.github.io/img/ethercat/ethercat1.png" alt="ethercat数据">

<img src="https://cdn.jsdelivr.net/gh/lcekold/lcekold.github.io/img/ethercat/wiresharp4.jpg" alt="wiresharp4">

单个EtherCAT帧最多可包含1498个字节。如果需要超过1498个字节，则主设备将发送多个数据帧，并且每个帧将包含标识符，该标识符用信号通知网络上的设备是否应该期望在当前帧之后的另一帧。

EtherCAT主机负责组装EtherCAT帧并通过网络发送。主机发送的每一帧都会通过网络中的每个节点（逻辑环）。此外，由于灵活的拓扑选择，不需要网络交换机或路由器，进一步降低了定时延迟和硬件成本。

---

# 二、EtherCAT是如何工作的？

它和 Ethernet/IP 最大的不同，在于它采用 **主从（Master/Slave）+ 环状（线型）拓扑 + 帧逐步处理** 的方式。

控制器EtherCAT通讯口和EtherCAT从站之间通过COE（CANopen over EtherCAT）协议进行数据交换。

EtherCAT系统由主站、从站组成。主站实现只需要一张普通的网卡，从站需专用的从站控制芯片，如:ET1100、ET1200、FPGA等。

## 2.1 主从结构

* **Master（主站）**：通常是 PLC 或运动控制器，是唯一发起通信的设备，负责产生数据帧。
* **Slave（从站）**：伺服、变频器、远程 IO、传感器等，是“被动处理”帧的设备。Ethercat从站的实现通常是一个小芯片（EtherCAT Slave Controller, ESC），它负责解析帧、读写数据、更新工作计数器（Working Counter, WKC）。

## 2.2 EtherCAT的拓扑结构与物理层

EtherCAT支持线型、树型和星型（通过EtherCAT交换机）拓扑，但线型是最常用、性能最可预测的。每个从站有两个RJ45端口（IN和OUT），设备简单地串联起来。最后一个从站的OUT端口需要连接回主站的第二个以太网口（如果主站只有一个口，则需在末站启用“环回”功能，形成逻辑上的环网以提供链路冗余）。

EtherCAT的主站网卡必须禁用TCP/IP协议栈，并设置为100M全双工模式。

```bash
# 检查网卡eth0状态
$ sudo ethtool eth0
Settings for eth0:
    Supported ports: [ TP ]
    Supported link modes:   10baseT/Half 10baseT/Full
                           100baseT/Half 100baseT/Full
    Speed: 100Mb/s          // 必须为100Mb/s
    Duplex: Full            // 必须为全双工
    Auto-negotiation: off   // 建议关闭自协商
    ...

# 设置网卡为100M全双工，关闭自协商
$ sudo ethtool -s eth0 speed 100 duplex full autoneg off
```

## 2.3 核心机制：飞驰处理（Processing on the Fly）

传统通信多采用邮局模型（主站打包，网络传输，从站拆包），而EtherCAT快速的原因就是其采用的是“飞驰处理”模型。

1. 主站发出一帧数据，里面为**每一个从站预留了一小段数据位**。
2. 帧在网线上传输，**到达某个从站时，这个从站在极短的时间内“顺带”处理**：把发给自己的数据读出来，再把自己的数据填进预留的位置。
3. 该从站几乎**不做缓冲、不等待**，只是“边传边读写”，然后把帧转发给下一个从站。
4. 当帧绕完一整圈回到主站时，主站拿到的已经是一份**包含所有从站最新数据**的完整帧。

整个过程 帧在“飞”的路上就完成了所有数据交换，所以叫“飞读飞写”（Processing on the Fly）。

## 2.4 EtherCAT同步性——分布式时钟（Distributed Clocks, DC）

想象一下交响乐团，如果每位乐手都看着自己的手表演奏，节奏必然混乱。指挥家就是“参考时钟”，他挥动指挥棒，所有乐手基于这个统一节拍演奏，才能和谐。在EtherCAT网络中，分布式时钟（Distributed Clocks, DC）就是这位“指挥家”，它确保网络中所有从站设备（伺服驱动器、IO模块等）的本地时钟高度同步，误差通常在纳秒级别。

每个从站自己带一个高精度时钟，主站统一对这些时钟做同步（补偿并锁定）。这样所有从站的 I/O 采集与输出能做到**纳秒级同步**，对多轴运动控制尤其重要。

<img src="https://cdn.jsdelivr.net/gh/lcekold/lcekold.github.io/img/ethercat/ethercat分布式时钟.jpg" alt="ethercat分布式时钟">

在EtherCAT链中，有一个选定的EtherCAT从站，代表参考时钟（M），其他设备和控制器的从机时钟（S）与之同步。因此，参考时钟即是系统时间。如果EtherCAT主机支持分布式时钟功能，例如Beckhoff TwinCAT EtherCAT主站，则其可自动连续处理调整和同步。为此，EtherCAT主机以短时间间隔发送一个特殊EtherCAT数据报文（具有足够的频率以确保从站时钟在指定的限制内保持同步），其中EtherCAT从站与参考时钟进入其当前时间。然后，所有其他具有从时钟的EtherCAT从站从同一数据报中读取该信息。

由于EtherCAT的环形结构，如果参考时钟在拓扑上位于所有其他从站时钟之前，这是可能的。因此，EtherCAT主设备选择第一个具有分布式时钟功能的EtherCAT从站作为参考时钟。

因此，EtherCAT配置的特点是EtherCAT主机操作和管理与连接的EtherCAT从站的总线。其中一个EtherCAT从站包含参考时钟(M)，所有其他EtherCAT设备（即包括EtherCAT主站）代表从站时钟（S)。

## 2.5 EtherCAT从站控制器(ESC)

EtherCAT从站控制器（ESC）处理EtherCAT通信，尤其是EtherCAT从站中的分布式时钟功能。这是诸如ASIC或可重编程FPGA或类似物的电子部件（芯片）。

每个EtherCAT从设备都有这样一个ESC，以确保通过EtherCAT现场总线在主设备和从设备之间交换循环和非循环过程数据。该ESC可以直接处理数字输入和输出等简单功能，也可以通过串行/并行接口连接到EtherCAT从机中的另一个处理器，以处理更复杂的任务，如驱动控制。特别是，如果EtherCAT从站需要支持此功能，ESC会管理本地分布式时钟功能和相关任务。

<img src="https://cdn.jsdelivr.net/gh/lcekold/lcekold.github.io/img/ethercat/ethercat从站控制器.png" alt="ethercat从站控制器">

信号通过转变器从RJ45插座传输到PHY（物理接口）。它从编码的以太网信号中提取用户数据，并将其传输到ESC进行处理。然后，EtherCAT电报以最小延迟（由于动态处理）通过PHY和套接字中继到下一个EtherCAT从机。当从设备启动时，ESC自动通过EEPROM中的配置数据对自身进行参数化。如果从设备中存在另一个CPU，则从站可以通过接口与其通信。

ESC的分布式时钟单元在完整配置中提供以下功能（取决于设备实现）：
* EtherCAT从设备和主设备之间的时钟
* 同步同步生成输出信号（同步信号）
* 同步读取
* 输入信号输入信号（锁存信号）的精确时间戳
* 同步中断的生成

## 2.6 控制器和从站之间数据传输的两种方式：PDO和SDO

* ①按指定时间周期性交换数据，称为PDO。
* ②请求应答式交换数据，称为SDO。

EtherCAT总线通信过程如下：

<img src="https://cdn.jsdelivr.net/gh/lcekold/lcekold.github.io/img/ethercat/PDO和SDO.png" alt="ethercatPOD和SDO">

### 2.6.1 PDO过程数据对象
PDO（Process Data Object，过程数据对象）是EtherCAT中用于实时数据交换的主要机制。它允许主站和从站之间以固定的时间间隔进行数据传输，适用于需要快速响应的控制任务。

主站和从站通过PDO进行数据交换时，一方发送数据后，另一方不需要应答。

控制器通过指令控制EtherCAT从站时，控制器和从站之间通过PDO方式进行数据交换。

PDO列表可以看作一个数组空间，每个数组元素存放了不同的功能码，PDO在一个周期中执行这些功能码对应的操作，这些功能码就叫做数据字典。

PDO分为两种：
* 从站传送数据给主站用的TxPDO
* 主站传送数据给从站用的RxPDO

<img src="https://cdn.jsdelivr.net/gh/lcekold/lcekold.github.io/img/ethercat/pdo数据.jpg" alt="pdo数据">

其中EtherCAT总线上控制器为主站，伺服驱动器或其他总线模块为从站。

一个节点的TxPDO是将数据由此节点传输到其他节点，而RxPDO则是接收由其他节点传输的数据。

PDO报文数据域中每个字节都用作数据传输，因此报文利用率高。

<img src="https://cdn.jsdelivr.net/gh/lcekold/lcekold.github.io/img/ethercat/SDO数据.jpg" alt="SDO数据">

### 2.6.2 SDO服务数据对象

SDO（Service Data Object，服务数据对象）用于配置和访问从站的参数。它提供了一种请求-响应机制，使主站能够读取或写入从站的对象字典中的数据。这种方式适用于非实时的数据交换，如设备配置、状态查询等。



## 2.6 EtherCAT如何寻址？——不用IP，靠什么知道“数据是自己的”

上面讲过 EtherCAT“不需要 IP 地址”。这容易让人疑惑：**那从站怎么知道数据是发给自己的？**

关键在于：EtherCAT 不是“不用寻址”，而是**不用 IP 寻址**。它的寻址是**基于“帧穿过每一台从站”**这一事实的——帧会逐个经过环上的所有从站，每台从站都能看到整帧，只要认出属于自己那一段就行了。具体有三种方式：

* **按位置（Auto-increment，位置寻址）**：帧里带一个“位置号”，每经过一台从站就减 1，减到 **0** 的那台就是目标。主站按物理顺序就能依次点名。
* **按站号（Configured Station Address，配置站地址）**：配置阶段主站给每台从站分配一个唯一的站号（存在从站的 ESC 里）。帧里带的就是这个站号，从站用自己的站号比对，**相同就处理**。这其实是“显式寻址”，和 IP/MAC 思路类似，只不过是在 EtherCAT 这一层做，用的不是 IP。
* **逻辑映射（FMMU，Fieldbus Memory Management Unit，现场总线内存管理单元）**：这是实时 I/O 数据最常用的方式。配置时，主站在每个从站 ESC 里设置一块 FMMU，告诉它：**“整帧里的第 20~35 字节就是你的输入/输出区域。”** 当逻辑寻址的帧经过时，从站的 FMMU 检查这段地址范围是否落在自己映射的位置——**是就读写，不是就直接放过去**。帧绕回主站时，就凑成了一帧“每个从站都填好自己那一格”的完整数据。

> 用一个比喻理解：把一帧想成传送带上的一个长包装箱，里面分了好几个格子，每台从站像一个工位。主站提前告诉每个工位“你的东西在第 3 格”。箱子经过时，每个工位只伸手拿自己那格，顺手把自己的数据写进去，再放行给下一站。所以从站要回答的是“**这一格是不是我的**”，而不是“**这是不是给我的 IP**”。

> 顺带一提**工作计数器（Working Counter，WKC）**：每台从站成功处理属于自己的数据段，就把帧里的 WKC 加 1。主站发完帧后检查回来的 WKC 是否等于预期的从站数——**对上了就说明所有从站都收到了；对不上则说明有从站离线或没配置好**，这也是排查断站的手段。

---

# 三、EtherCAT在网络七层模型的位置

| 层级 | 层级名称 | EtherCAT 在这一层的内容 | 谁在负责？ |
| :--- | :--- | :--- | :--- |
| **第7层** | **应用层** | 过程数据对象（PDO）和邮箱数据（SDO/参数）的映射与解释。 | EtherCAT 应用层 |
| **第6层** | **表示层** | 数据编码（字节序、数据类型）等。 | EtherCAT 应用层 |
| **第5层** | **会话层** | 连接/会话管理（邮箱通信的建立与关闭）。 | EtherCAT 应用层 |
| **第4层** | **传输层** | **不单独使用**。EtherCAT 不依赖 TCP/UDP，直接走数据链路层。 | — |
| **第3层** | **网络层** | **不单独使用**。不用 IP 地址，不经过 IP 路由。 | — |
| **第2层** | **数据链路层** | **EtherCAT 的核心**。数据封装成以太网帧（0x88A4），靠“飞传 + 从站逐级处理”完成寻址和数据交换。 | **EtherCAT 独有的灵魂** |
| **第1层** | **物理层** | **标准以太网物理层**。网线、水晶头、电信号的传输。 | 借用了标准以太网 |

可以看到，EtherCAT 把“核心能力”直接放到了**数据链路层（第2层）**，绕开了 IP/TCP/UDP，所以它比 Ethernet/IP 更快、更硬实时；代价是它更像一条“独占的专用总线”，互连互通依赖专门的协议栈。

---

# 四、EtherCAT 与 Ethernet/IP 的简单对比

| 对比项 | EtherCAT | Ethernet/IP |
| ---- | ---- | ---- |
| 定位 | 硬实时现场总线 | 通用工业以太网协议 |
| 工作层级 | 数据链路层（第2层） | 应用层（第7层，CIP） |
| 通信模型 | 主从（Master/Slave） | 生产者/消费者（Scanner/Adapter） |
| 拓扑 | 线型/环状，从站双网口直连，**免交换机**；要分叉用 EtherCAT 分站 | 星型，设备单网口，**需交换机汇聚** |
| 寻址 | 按从站位置，基本不用 IP | 用 IP 地址 + CIP 对象 |
| 数据帧 | 一帧“飞传”处理全部从站 | 标准以太网报文（TCP/UDP） |
| 实时性 | 极强，周期可到亚毫秒/微秒量级 | 相对较弱，通常毫秒量级 |
| 典型场景 | 多轴运动控制、伺服 | 设备状态监控、跨品牌互联 |

---

