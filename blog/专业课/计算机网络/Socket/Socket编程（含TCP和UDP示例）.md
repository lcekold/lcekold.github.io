# 一、什么是Socket？为什么需要Socket?

Socket（套接字）是计算机网络编程中用于进程间通信的接口，允许不同主机上的程序通过网络发送和接收数据。

你可以把它类比成一根“数据管道”，程序通过这根管道与远程设备进行交流。Socket是应用层与传输层之间的一个产物，它把传输层的很多复杂操作封装成一些简单的接口，来让应用层调用以此来实现进程在网络中的通信。

举个例子，Socket就像是一个扫地机器人，在没有扫地机器人的时候，我们需要去使用自己得到双手进行扫地，比如使用扫帚、拖把等工具（手动调用传输层、应用层之间的各个 api）。而有了扫地机器人之后（封装为api），我们只需要告诉它去哪里扫地，它就会自动完成扫地的任务。Socket也是类似的道理，它封装了底层的网络协议细节，让开发者可以更方便地进行网络编程。


# 二、Socket的相关基本概念

## 1. 套接字类型
Socket主要有两种类型：

- 流式套接字（SOCK_STREAM）：基于TCP协议，提供可靠的、面向连接的通信。适用于需要保证数据完整性和顺序的应用，如文件传输、电子邮件等。
- 数据报套接字（SOCK_DGRAM）：基于UDP协议，提供无连接的通信。适用于对速度要求高且可以容忍数据丢失的应用，如视频流、在线游戏等。

## 2. 套接字地址

 每个Socket都有一个唯一的地址，由IP地址和端口号组成。IP地址标识主机的位置，端口号标识主机上的特定应用程序。例如，IP地址为192.168.1.1，端口号为8080的Socket地址表示在192.168.1.1这台主机上，监听8080端口的应用程序。

## 3. 套接字操作
Socket编程中常用的操作包括：
- 创建Socket：使用socket()函数创建一个新的Socket。
- 绑定地址：使用bind()函数将Socket绑定到特定的IP地址和端口号。
- 监听连接：对于流式套接字，使用listen()函数监听传入的连接请求。
- 接受连接：使用accept()函数接受传入的连接请求，返回一个新Socket用于与客户端通信。
- 发送和接收数据：使用send()和recv()函数发送和接收数据。
- 关闭Socket：使用close()函数关闭Socket，释放资源。

# 三、信息是如何无线传输的？

## 3.1 无线的情况下如何传输出信息？

部分同学在学习网络通信的时候，常常好奇信息的传输形式，一般来讲通过网线进行连接的方式还暂且能够搞懂，毕竟有一根线作为媒介，但一旦变为无线传输的情景，很多学生就会感到迷惑，信息没有线缆作为媒介，信息是如何传输的呢？下面我们来简单介绍一下无线传输的基本原理。

**首先任何复杂的数据都是通过0和1表达出来的，而0和1对于物理层来说就是两种状态，所以理论上，任何能表示两种状态的物理现象并且可以传播的都可以用于传输数据，包括光、电、电磁波等。**

 而我们日常用到的无线传输采用的时代的电磁波的方式进行传输的，电磁波是一种横波，可以在真空中传播，不需要任何介质作为媒介，这就使得无线传输成为可能。

    电磁波是如何产生的？  电流流过导体时，会对周围产生电磁波 而导体在电磁波环境中，会产生电流。这样我们用一根铁棍，两边接上电然后控制铁棍中的电流就会产生一定规律的电磁波；在另一边我产生电磁波的范围内放另一根铁棍，这根铁棍就会产生有规律的电流。这个铁棍就叫做天线。  天线的作用就是把电信号转换为电磁波，或者把电磁波转换为电信号。

而这样有规律的电流就完成了物理层面上最基本的两种状态的表达，从而传输了数据。

## 3.2 无线传输的基本过程

信息的无线传输主要依赖于电磁波的传播原理。以下是无线传输的基本过程：

1. 信号调制：发送端将数字信号转换为适合无线传输的模拟信号，这个过程称为调制。常见的调制方式包括幅度调制（AM）、频率调制（FM）和相位调制（PM）。

2. 天线发射：调制后的信号通过天线转换为电磁波，并以无线电波的形式向外传播。

3. 信号接收：接收端的天线捕获到电磁波，并将其转换为电信号。

4. 解调：接收端将电信号转换为数字信号，这个过程称为解调。解调后的信号可以被应用程序处理。

5. 数据处理：接收端对解调后的数字信号进行处理，提取出有用的信息。

通过以上过程，信息可以在没有物理连接的情况下实现无线传输。无线传输技术广泛应用于移动通信、Wi-Fi、蓝牙等领域。

## 3.3 相关过程解释

**调频**：就是通过改变电磁场频率携带信息，具体实施起来，就是通过变化天线中电流改变的频率用于携带信息。比如说1秒内，改变天线内的电流1次表示0，改变2次表示1（当然实际应用中比这个快得多）

**调幅**：就是通过改变电磁场的幅度携带信息，具体实施起来，就是通过变化天线中电流的强弱用于携带信息。比如说1秒内，电流强表示1，电流弱表示0（当然实际应用中比这个快得多）

**调相**：就是通过改变电磁场的相位携带信息，具体实施起来，就是通过变化天线中电流的相位用于携带信息。比如说1秒内，电流相位为0度表示0，电流相位为180度表示1（当然实际应用中比这个快得多）

# 四、Socket通信模型

Socket通信基于客户端-服务器（Client-Server）模型。

## 4.1 什么是客户端和服务器？

客户端和服务器是网络通信中的两个基本概念。

- 服务器（Server）：服务器是提供服务的计算机或程序，负责监听客户端的请求并进行处理。服务器通常运行在固定的IP地址和端口上，等待客户端的连接。

- 客户端（Client）：客户端是发起请求的计算机或程序，负责向服务器发送请求并接收响应。客户端通常运行在用户的设备上，可以动态连接到不同的服务器。

## 4.2 Socket通信的基本流程
主要包括以下几个步骤：

* 服务器端：
    1. 创建Socket：使用socket()函数创建一个Socket。
    2. 绑定地址：使用bind()函数将Socket绑定到特定的IP地址和端口号。
    3. 监听连接：使用listen()函数监听传入的连接请求。
    4. 接受连接：使用accept()函数接受传入的连接请求，返回一个新Socket用于与客户端通信。
    5. 发送和接收数据：使用send()和recv()函数发送和接收数据。
    6. 关闭Socket：使用close()函数关闭Socket，释放资源。

* 客户端：
    1. 创建Socket：使用socket()函数创建一个Socket。
    2. 连接服务器：使用connect()函数连接到服务器的Socket地址。
    3. 发送和接收数据：使用send()和recv()函数发送和接收数据。
    4. 关闭Socket：使用close()函数关闭Socket，释放资源。

# 五、TCP Socket编程示例（C++）

下面是一个简单的TCP Socket编程示例，展示了如何创建一个服务器和客户端进行通信。

## 5.1 TCP通信流程概述

### TCP服务器端流程：
1. `socket()` - 创建Socket
2. `bind()` - 绑定IP地址和端口
3. `listen()` - 监听连接请求
4. `accept()` - 接受客户端连接（阻塞等待）
5. `recv()/send()` - 接收和发送数据
6. `close()` - 关闭连接

### TCP客户端流程：
1. `socket()` - 创建Socket
2. `connect()` - 连接到服务器
3. `send()/recv()` - 发送和接收数据
4. `close()` - 关闭连接

## 5.2 TCP服务器端示例

```cpp
#include <iostream>
#include <cstring>
#include <sys/socket.h>  // socket相关函数
#include <netinet/in.h>  // sockaddr_in结构体
#include <arpa/inet.h>   // inet_addr函数
#include <unistd.h>      // close函数

#define PORT 8080        // 定义服务器监听的端口号
#define BUFFER_SIZE 1024 // 定义缓冲区大小

int main() {
    int server_fd;              // 服务器socket文件描述符
    int client_fd;              // 客户端socket文件描述符
    struct sockaddr_in address; // 服务器地址结构体
    struct sockaddr_in client_address; // 客户端地址结构体
    int addrlen = sizeof(address);
    char buffer[BUFFER_SIZE] = {0}; // 接收数据的缓冲区
    
    // 步骤1: 创建socket
    // AF_INET: 使用IPv4协议
    // SOCK_STREAM: 使用TCP协议（面向连接的流式套接字）
    // 0: 自动选择协议（对于SOCK_STREAM，默认是TCP）
    server_fd = socket(AF_INET, SOCK_STREAM, 0);
    if (server_fd == -1) {
        std::cerr << "创建socket失败" << std::endl;
        return -1;
    }
    std::cout << "Socket创建成功" << std::endl;
    
    // 设置socket选项，允许地址重用
    // 这样可以避免"Address already in use"错误
    int opt = 1;
    if (setsockopt(server_fd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt)) < 0) {
        std::cerr << "设置socket选项失败" << std::endl;
        close(server_fd);
        return -1;
    }
    
    // 步骤2: 绑定地址和端口
    // 初始化地址结构体
    address.sin_family = AF_INET;           // 使用IPv4协议
    address.sin_addr.s_addr = INADDR_ANY;   // 绑定到所有可用的网络接口（0.0.0.0）
    address.sin_port = htons(PORT);         // 设置端口号，htons用于主机字节序到网络字节序的转换
    
    // 将socket绑定到指定的IP地址和端口
    if (bind(server_fd, (struct sockaddr *)&address, sizeof(address)) < 0) {
        std::cerr << "绑定失败" << std::endl;
        close(server_fd);
        return -1;
    }
    std::cout << "绑定到端口 " << PORT << " 成功" << std::endl;
    
    // 步骤3: 监听连接
    // 第二个参数是等待连接队列的最大长度
    // 当多个客户端同时连接时，未处理的连接会在这个队列中等待
    if (listen(server_fd, 3) < 0) {
        std::cerr << "监听失败" << std::endl;
        close(server_fd);
        return -1;
    }
    std::cout << "开始监听连接..." << std::endl;
    
    // 步骤4: 接受客户端连接
    // accept()会阻塞，直到有客户端连接
    // 返回一个新的socket文件描述符，用于与该客户端通信
    socklen_t client_addrlen = sizeof(client_address);
    client_fd = accept(server_fd, (struct sockaddr *)&client_address, &client_addrlen);
    if (client_fd < 0) {
        std::cerr << "接受连接失败" << std::endl;
        close(server_fd);
        return -1;
    }
    
    // 获取客户端的IP地址和端口号
    char client_ip[INET_ADDRSTRLEN];
    inet_ntop(AF_INET, &client_address.sin_addr, client_ip, INET_ADDRSTRLEN);
    int client_port = ntohs(client_address.sin_port);
    std::cout << "客户端连接成功！来自 " << client_ip << ":" << client_port << std::endl;
    
    // 步骤5: 接收和发送数据
    while (true) {
        // 清空缓冲区
        memset(buffer, 0, BUFFER_SIZE);
        
        // 接收客户端发送的数据
        // recv()会阻塞，直到接收到数据或连接关闭
        int valread = recv(client_fd, buffer, BUFFER_SIZE, 0);
        if (valread <= 0) {
            if (valread == 0) {
                std::cout << "客户端断开连接" << std::endl;
            } else {
                std::cerr << "接收数据失败" << std::endl;
            }
            break;
        }
        
        std::cout << "收到消息: " << buffer << std::endl;
        
        // 检查是否收到退出命令
        if (strcmp(buffer, "exit") == 0) {
            std::cout << "收到退出命令，关闭连接" << std::endl;
            break;
        }
        
        // 发送响应消息给客户端
        const char *response = "服务器已收到你的消息";
        send(client_fd, response, strlen(response), 0);
        std::cout << "响应已发送" << std::endl;
    }
    
    // 步骤6: 关闭socket，释放资源
    close(client_fd);    // 关闭客户端连接
    close(server_fd);    // 关闭服务器socket
    std::cout << "服务器关闭" << std::endl;
    
    return 0;
}
```

## 5.3 TCP客户端示例

```cpp
#include <iostream>
#include <cstring>
#include <sys/socket.h>  // socket相关函数
#include <netinet/in.h>  // sockaddr_in结构体
#include <arpa/inet.h>   // inet_addr函数
#include <unistd.h>      // close函数

#define PORT 8080        // 服务器端口号
#define BUFFER_SIZE 1024 // 缓冲区大小

int main() {
    int sock = 0;                   // 客户端socket文件描述符
    struct sockaddr_in serv_addr;   // 服务器地址结构体
    char buffer[BUFFER_SIZE] = {0}; // 接收数据的缓冲区
    
    // 步骤1: 创建socket
    // AF_INET: 使用IPv4协议
    // SOCK_STREAM: 使用TCP协议（面向连接的流式套接字）
    // 0: 自动选择协议
    sock = socket(AF_INET, SOCK_STREAM, 0);
    if (sock < 0) {
        std::cerr << "创建socket失败" << std::endl;
        return -1;
    }
    std::cout << "Socket创建成功" << std::endl;
    
    // 步骤2: 设置服务器地址信息
    serv_addr.sin_family = AF_INET;    // 使用IPv4协议
    serv_addr.sin_port = htons(PORT);  // 设置端口号，转换为网络字节序
    
    // 将IP地址从字符串转换为网络字节序的二进制形式
    // "127.0.0.1"表示本地回环地址（localhost）
    // 如果服务器在其他机器上，需要改为服务器的实际IP地址
    if (inet_pton(AF_INET, "127.0.0.1", &serv_addr.sin_addr) <= 0) {
        std::cerr << "无效的地址或地址不支持" << std::endl;
        close(sock);
        return -1;
    }
    
    // 步骤3: 连接到服务器
    // connect()会阻塞，直到连接成功或失败
    if (connect(sock, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) < 0) {
        std::cerr << "连接失败" << std::endl;
        close(sock);
        return -1;
    }
    std::cout << "成功连接到服务器 127.0.0.1:" << PORT << std::endl;
    
    // 步骤4: 发送和接收数据
    while (true) {
        // 获取用户输入
        std::cout << "\n请输入要发送的消息 (输入'exit'退出): ";
        std::string message;
        std::getline(std::cin, message);
        
        // 发送消息到服务器
        send(sock, message.c_str(), message.length(), 0);
        std::cout << "消息已发送: " << message << std::endl;
        
        // 如果发送的是退出命令，则退出循环
        if (message == "exit") {
            std::cout << "退出客户端" << std::endl;
            break;
        }
        
        // 清空缓冲区
        memset(buffer, 0, BUFFER_SIZE);
        
        // 接收服务器的响应
        // recv()会阻塞，直到接收到数据或连接关闭
        int valread = recv(sock, buffer, BUFFER_SIZE, 0);
        if (valread <= 0) {
            if (valread == 0) {
                std::cout << "服务器关闭了连接" << std::endl;
            } else {
                std::cerr << "接收数据失败" << std::endl;
            }
            break;
        }
        
        std::cout << "收到服务器响应: " << buffer << std::endl;
    }
    
    // 步骤5: 关闭socket，释放资源
    close(sock);
    std::cout << "客户端关闭" << std::endl;
    
    return 0;
}
```

## 5.4 编译和运行

**编译服务器端：**
```bash
g++ tcp_server.cpp -o tcp_server
```

**编译客户端：**
```bash
g++ tcp_client.cpp -o tcp_client
```

**运行步骤：**

1. 先运行服务器：
   ```bash
   ./tcp_server
   ```

2. 再运行客户端（在另一个终端）：
   ```bash
   ./tcp_client
   ```

3. 在客户端输入消息，服务器会接收并响应

## 5.5 注意事项

1. **头文件差异**：Windows系统需要使用不同的头文件和函数：
   - 使用 `<winsock2.h>` 代替 `<sys/socket.h>`
   - 需要调用 `WSAStartup()` 初始化Winsock库
   - 使用 `closesocket()` 代替 `close()`

2. **字节序转换**：网络传输使用大端字节序（网络字节序），而主机可能使用小端字节序，因此需要使用 `htons()`、`ntohs()`、`htonl()`、`ntohl()` 进行转换

3. **错误处理**：实际应用中应该添加更完善的错误处理机制

4. **并发处理**：这个示例只能处理一个客户端连接，要支持多个客户端需要使用多线程或IO多路复用（select、poll、epoll等）

# 六、UDP Socket编程示例（C++）

UDP是无连接的协议，不需要建立连接就可以发送数据，适用于对实时性要求高、可以容忍少量数据丢失的场景。

## 6.1 UDP通信流程概述

### UDP服务器端流程：
1. `socket()` - 创建Socket（SOCK_DGRAM）
2. `bind()` - 绑定IP地址和端口
3. `recvfrom()/sendto()` - 接收和发送数据（无需连接）
4. `close()` - 关闭Socket

### UDP客户端流程：
1. `socket()` - 创建Socket（SOCK_DGRAM）
2. `sendto()/recvfrom()` - 发送和接收数据（无需连接）
3. `close()` - 关闭Socket

**与TCP的主要区别：**
- UDP不需要 `listen()` 和 `accept()`
- UDP不需要 `connect()`
- UDP使用 `recvfrom()` 和 `sendto()` 代替 `recv()` 和 `send()`

## 6.2 UDP服务器端示例

```cpp
#include <iostream>
#include <cstring>
#include <sys/socket.h>  // socket相关函数
#include <netinet/in.h>  // sockaddr_in结构体
#include <arpa/inet.h>   // inet_addr函数
#include <unistd.h>      // close函数

#define PORT 8080        // 定义服务器监听的端口号
#define BUFFER_SIZE 1024 // 定义缓冲区大小

int main() {
    int sockfd;                     // socket文件描述符
    char buffer[BUFFER_SIZE];       // 接收数据的缓冲区
    struct sockaddr_in servaddr;    // 服务器地址结构体
    struct sockaddr_in cliaddr;     // 客户端地址结构体
    
    // 步骤1: 创建socket
    // AF_INET: 使用IPv4协议
    // SOCK_DGRAM: 使用UDP协议（数据报套接字）
    // 0: 自动选择协议（对于SOCK_DGRAM，默认是UDP）
    sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    if (sockfd < 0) {
        std::cerr << "创建socket失败" << std::endl;
        return -1;
    }
    std::cout << "UDP Socket创建成功" << std::endl;
    
    // 清空地址结构体
    memset(&servaddr, 0, sizeof(servaddr));
    memset(&cliaddr, 0, sizeof(cliaddr));
    
    // 步骤2: 配置服务器地址
    servaddr.sin_family = AF_INET;          // 使用IPv4协议
    servaddr.sin_addr.s_addr = INADDR_ANY;  // 绑定到所有可用的网络接口
    servaddr.sin_port = htons(PORT);        // 设置端口号，转换为网络字节序
    
    // 步骤3: 绑定socket到指定的IP地址和端口
    // UDP不需要listen()和accept()，直接绑定后就可以接收数据
    if (bind(sockfd, (const struct sockaddr *)&servaddr, sizeof(servaddr)) < 0) {
        std::cerr << "绑定失败" << std::endl;
        close(sockfd);
        return -1;
    }
    std::cout << "绑定到端口 " << PORT << " 成功" << std::endl;
    std::cout << "等待接收数据..." << std::endl;
    
    // 步骤4: 接收和发送数据
    while (true) {
        // 清空缓冲区
        memset(buffer, 0, BUFFER_SIZE);
        
        // recvfrom()接收数据，同时获取发送方的地址信息
        // UDP是无连接的，所以需要知道数据来自哪里，以便回复
        socklen_t len = sizeof(cliaddr);
        int n = recvfrom(sockfd, buffer, BUFFER_SIZE, 0,
                        (struct sockaddr *)&cliaddr, &len);
        
        if (n < 0) {
            std::cerr << "接收数据失败" << std::endl;
            continue;
        }
        
        // 获取客户端的IP地址和端口号
        char client_ip[INET_ADDRSTRLEN];
        inet_ntop(AF_INET, &cliaddr.sin_addr, client_ip, INET_ADDRSTRLEN);
        int client_port = ntohs(cliaddr.sin_port);
        
        // 显示接收到的数据
        buffer[n] = '\0';  // 确保字符串结束
        std::cout << "\n收到来自 " << client_ip << ":" << client_port 
                  << " 的消息: " << buffer << std::endl;
        
        // 检查是否收到退出命令
        if (strcmp(buffer, "exit") == 0) {
            std::cout << "收到退出命令" << std::endl;
            break;
        }
        
        // 发送响应数据给客户端
        // sendto()需要指定目标地址，因为UDP是无连接的
        const char *response = "服务器已收到你的UDP消息";
        sendto(sockfd, response, strlen(response), 0,
               (const struct sockaddr *)&cliaddr, len);
        std::cout << "响应已发送" << std::endl;
    }
    
    // 步骤5: 关闭socket
    close(sockfd);
    std::cout << "服务器关闭" << std::endl;
    
    return 0;
}
```

## 6.3 UDP客户端示例

```cpp
#include <iostream>
#include <cstring>
#include <sys/socket.h>  // socket相关函数
#include <netinet/in.h>  // sockaddr_in结构体
#include <arpa/inet.h>   // inet_addr函数
#include <unistd.h>      // close函数

#define PORT 8080        // 服务器端口号
#define BUFFER_SIZE 1024 // 缓冲区大小

int main() {
    int sockfd;                     // socket文件描述符
    char buffer[BUFFER_SIZE];       // 接收数据的缓冲区
    struct sockaddr_in servaddr;    // 服务器地址结构体
    
    // 步骤1: 创建socket
    // AF_INET: 使用IPv4协议
    // SOCK_DGRAM: 使用UDP协议（数据报套接字）
    // 0: 自动选择协议
    sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    if (sockfd < 0) {
        std::cerr << "创建socket失败" << std::endl;
        return -1;
    }
    std::cout << "UDP Socket创建成功" << std::endl;
    
    // 清空地址结构体
    memset(&servaddr, 0, sizeof(servaddr));
    
    // 步骤2: 配置服务器地址
    servaddr.sin_family = AF_INET;         // 使用IPv4协议
    servaddr.sin_port = htons(PORT);       // 设置端口号，转换为网络字节序
    
    // 将IP地址从字符串转换为网络字节序的二进制形式
    // "127.0.0.1"表示本地回环地址
    if (inet_pton(AF_INET, "127.0.0.1", &servaddr.sin_addr) <= 0) {
        std::cerr << "无效的地址" << std::endl;
        close(sockfd);
        return -1;
    }
    
    std::cout << "准备向服务器 127.0.0.1:" << PORT << " 发送数据" << std::endl;
    
    // 步骤3: 发送和接收数据
    // UDP客户端不需要调用connect()，直接发送数据即可
    while (true) {
        // 获取用户输入
        std::cout << "\n请输入要发送的消息 (输入'exit'退出): ";
        std::string message;
        std::getline(std::cin, message);
        
        // 发送数据到服务器
        // sendto()需要指定目标地址
        sendto(sockfd, message.c_str(), message.length(), 0,
               (const struct sockaddr *)&servaddr, sizeof(servaddr));
        std::cout << "消息已发送: " << message << std::endl;
        
        // 如果发送的是退出命令，则退出循环
        if (message == "exit") {
            std::cout << "退出客户端" << std::endl;
            break;
        }
        
        // 清空缓冲区
        memset(buffer, 0, BUFFER_SIZE);
        
        // 接收服务器的响应
        // recvfrom()接收数据，UDP可能从任何地址接收数据
        socklen_t len = sizeof(servaddr);
        int n = recvfrom(sockfd, buffer, BUFFER_SIZE, 0,
                        (struct sockaddr *)&servaddr, &len);
        
        if (n < 0) {
            std::cerr << "接收数据失败" << std::endl;
            continue;
        }
        
        buffer[n] = '\0';  // 确保字符串结束
        std::cout << "收到服务器响应: " << buffer << std::endl;
    }
    
    // 步骤4: 关闭socket
    close(sockfd);
    std::cout << "客户端关闭" << std::endl;
    
    return 0;
}
```

## 6.4 编译和运行

**编译服务器端：**
```bash
g++ udp_server.cpp -o udp_server
```

**编译客户端：**
```bash
g++ udp_client.cpp -o udp_client
```

**运行步骤：**

1. 先运行服务器：
   ```bash
   ./udp_server
   ```

2. 再运行客户端（在另一个终端）：
   ```bash
   ./udp_client
   ```

3. 在客户端输入消息，服务器会接收并响应

## 6.5 TCP与UDP对比总结

| 特性 | TCP | UDP |
|------|-----|-----|
| **连接方式** | 面向连接（需要三次握手建立连接） | 无连接（直接发送数据） |
| **可靠性** | 可靠传输（保证数据完整性和顺序） | 不可靠传输（可能丢包、乱序） |
| **速度** | 较慢（需要建立连接、确认机制） | 较快（无连接建立和确认） |
| **socket类型** | SOCK_STREAM | SOCK_DGRAM |
| **服务器函数** | socket → bind → listen → accept → recv/send → close | socket → bind → recvfrom/sendto → close |
| **客户端函数** | socket → connect → send/recv → close | socket → sendto/recvfrom → close |
| **数据边界** | 流式传输，无边界 | 有数据边界，每个数据报独立 |
| **应用场景** | 文件传输、网页浏览、邮件传输等需要可靠性的场景 | 视频流、在线游戏、DNS查询等对实时性要求高的场景 |

## 6.6 注意事项

1. **数据报大小限制**：UDP数据报有大小限制，通常建议不超过1472字节（以太网MTU 1500字节 - IP头20字节 - UDP头8字节）

2. **无连接特性**：UDP不保证数据到达，也不保证数据顺序，应用层需要自己处理这些问题

3. **广播和组播**：UDP支持广播和组播，TCP不支持

4. **性能考虑**：UDP适合对实时性要求高、可以容忍少量数据丢失的场景，如视频直播、语音通话等

5. **防火墙**：某些防火墙可能会阻止UDP数据包，需要配置相应的规则

# 七、总结

本文介绍了Socket编程的基本概念和使用方法，包括：

1. Socket的定义和作用
2. Socket的基本概念（套接字类型、地址、操作）
3. 无线传输的原理
4. Socket通信模型（客户端-服务器模型）
5. TCP Socket编程示例（面向连接、可靠传输）
6. UDP Socket编程示例（无连接、快速传输）

通过对比TCP和UDP的特点，我们可以根据不同的应用场景选择合适的协议：

- **选择TCP**：需要保证数据完整性和顺序的场景，如文件传输、网页浏览
- **选择UDP**：对实时性要求高、可以容忍少量数据丢失的场景，如视频流、在线游戏

掌握Socket编程是网络编程的基础，希望本文能帮助你更好地理解和使用Socket进行网络通信开发。
