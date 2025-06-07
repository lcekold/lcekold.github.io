我们直接以智能车比赛通用CmakeLists文件进行入手：

目录结构如下图：

<div><img src="https://cdn.jsdelivr.net/gh/lcekold/blogimage@main/Network/Snipaste_2025-06-07_15-25-19.png"></div>

```cmake
# 指定Cmake的最低版本要求,这里是在3.4到3.18之间的任何版本
cmake_minimum_required(VERSION 3.4...3.18)
# 设置项目的名称，这里是"intelligentCar"
project(smatcar)
# 设置C++标准为C++17
set (CMAKE_CXX_STANDARD 17)
#--------------------------------------------------------------------
#           [ Inclued、Lib   :    Define  ] ==> []
#  这部分定义了项目中使用的公共库和头文件的目录
#--------------------------------------------------------------------
# 设置公共库目录的路径，库文件位于lib文件夹下
set(COMMON_LIB_DIR "${PROJECT_SOURCE_DIR}/lib/")

# 设置代码包含文件的目录的路径src
set(COMMON_INCLUDE_DIR "${PROJECT_SOURCE_DIR}/src")

# 链接目录，这里添加了我们定义的公共库目录
link_directories(${COMMON_LIB_DIR})
# 包含目录，这里添加了我们定义得到公共头文件目录
include_directories( ${COMMON_INCLUDE_DIR})

#--------------------------------------------------------------------
#           [ Inclued、Lib   :    PATH  ] ==> [ glib opencv]
#  这部分通过PkgConfig和find_package查找外部库glib和OpenCV，并添加它们的包含目录
#--------------------------------------------------------------------

# 查找并加载PkgConfig,PkgConfig用于帮助查找库
find_package(PkgConfig)
# 使用PkgConfig查找glib-2.0库，并设置REQUIRED表示这是必需的
pkg_search_module(GLIB REQUIRED glib-2.0)
# 添加glib的包含目录
include_directories(${GLIB_INCLUDE_DIRS})
# 查找OpenCV库，并设置REQUIRED表示这是必需的
find_package(OpenCV REQUIRED)
# 添加OpenCV的包含目录
include_directories( ${OpenCV_INCLUDE_DIRS})

#--------------------------------------------------------------------
#           [ bin  ] ==> [ main ]
#  这部分定义了可执行文件及其依赖的源文件
#--------------------------------------------------------------------
# 设置生成的可执行文件的名称，这里是"car"
set(PROJECT_NAME "car")
# 设置源文件路径是src目录下的car.cpp
set(INTELLIGENTCAR_CAR_PROJECT_SOURCES ${PROJECT_SOURCE_DIR}/src/car.cpp)
# 添加一个可执行文件目标，名称为PROJECT_NAME,源文件为INTELLIGENTCAR_CAR_PROJECT_SOURCES
add_executable(${PROJECT_NAME} ${INTELLIGENTCAR_CAR_PROJECT_SOURCES})
# 链接pthread库到可执行文件，这对于多线程程序是必须的
target_link_libraries(${PROJECT_NAME} PRIVATE pthread)
# 链接OpenCV库到可执行文件
target_link_libraries(${PROJECT_NAME} PRIVATE ${OpenCV_LIBS})
```
# 一、疑难解答

直接从示例入手，我们先要研究懂上述CmakeLists文件究竟干了什么事情。但在此之前，我们先大致看懂一些命令。

## 1.1 ${PROJECT_SOURCE_DIR}是什么？

PROJECT_SOURCE_DIR 是 CMake 构建系统中常用的一个变量，用于表示当前项目的根源代码目录（即包含顶层 CMakeLists.txt 的目录）

## 1.2 有关include_directories()添加包含目录和link_directories()添加链接目录的区别 (重中之重!!!!!)：

### 1.2.1 include_directories()—— 头文件搜索路径:

#### 作用
* include_directories()是添加头文件搜索路径,用于指定 头文件（.h、.hpp）的搜索路径，编译器在预处理阶段（#include）会去这些路径查找头文件。
* 影响的是编译阶段

* 当代码中存在#include "xxxx.h"的时候，编译时我们通过写cmake文件指定了include_directories(${PROJECT_SOURCE_DIR}/include)，那么编译器会去 ${PROJECT_SOURCE_DIR}/include 目录下查找 xxxx.h。

#### 示例

```cmake
include_directories(${PROJECT_SOURCE_DIR}/include)
```
* 如果代码中有 #include "utils.h"，编译器会去 ${PROJECT_SOURCE_DIR}/include 目录下查找 utils.h。

#### 底层实现

CMake 会将其转换为编译器的 -I 选项，例如：

```cmd
g++ -I/path/to/include -c main.cpp
```

### 1.2.2 link_directories()—— 库文件搜索路径:

#### 作用
* link_directories():是添加库文件搜索路径，用于指定 库文件（.so、.a、.dll、.lib）的搜索路径，链接器（ld 或 link.exe）在链接阶段会去这些路径查找库文件。
* 影响的是 链接阶段（g++ -L<'path>）。

#### 示例

````cmake
link_directories(${PROJECT_SOURCE_DIR}/lib)
````

* 如果代码依赖 libfoo.so，链接器会去 ${PROJECT_SOURCE_DIR}/lib 目录下查找 libfoo.so。

#### 底层实现

CMake 会将其转换为链接器的 -L 选项，例如：

```cmd
g++ -L/path/to/lib -lfoo -o my_program
```

### 1.2.3 关键区别

|特性|	include_directories()|	link_directories()|
|-----|-----|-----|
|作用阶段	|编译阶段（预处理 #include）	|链接阶段（-l 查找 .so/.a）|
|影响对象|	编译器（g++ / clang）|	链接器（ld / link.exe）|
|对应的编译器选项|	-I<path>（如 -I/usr/local/include）|	-L<path>（如 -L/usr/local/lib）|
|典型用途|	指定头文件路径（如 OpenCV 头文件）|	指定动态库/静态库路径（如 OpenCV 库）|


### 1.2.4 总结

* include_directories() → 告诉编译器去哪里找头文件（-I）。

* link_directories() → 告诉链接器去哪里找库文件（-L）。

* 现代 CMake 推荐使用 target_* 系列命令，更模块化、更安全。

<font color="red">注：之前实验室培训过编译和链接分别是什么，所以这里不做阐述，懂的都懂</font>

### 1.2.5 现代Cmake方式

某些时候从网上查找示例或者AI生成CmakeLists文件会看到以下几个命令：

* target_include_directories()（替代 include_directories）

```cmake
target_include_directories(my_target PRIVATE ${COMMON_INCLUDE_DIR})
```

* target_link_directories()（替代 link_directories）

```cmake
target_link_directories(my_target PRIVATE ${COMMON_LIB_DIR})
```

* target_link_libraries()（直接链接库，避免全局 link_directories）

```cmake
target_link_libraries(my_target PRIVATE foo)
```

采用target方式得到好处:
1. 更精确的作用域控制（PRIVATE、PUBLIC、INTERFACE）。
2. 避免全局污染（旧版 include_directories() 会影响所有目标）。
3. 更清晰的依赖关系。

## 1.3 find_package(PkgConfig)是什么意思？

find_package(PkgConfig) 是一个用于查找和加载 PkgConfig 工具的指令。

* 该命令会在系统中搜索 pkg-config 工具（Unix/Linux 下常用的依赖管理工具），并为其提供 CMake 集成。
* 如果找到 pkg-config，CMake 会定义一个变量 PKG_CONFIG_EXECUTABLE（指向 pkg-config 的路径），并暴露相关功能。

通过pkg-config 可以轻松获取第三方库的编译标志

成功执行该命令后后续通过 pkg_check_modules() 或 pkg_search_module() 就饿可以查找具体库。查找到的库自动的定义为xxxx库名_INCLUDE_DIRS变量，可以在后续其他命令中使用。

### 举例说明：

当调用 find_package(OpenCV REQUIRED) 时，CMake 会搜索系统中安装的 OpenCV，并自动设置以下变量：

* OpenCV_INCLUDE_DIRS：OpenCV 头文件的路径（通常是 opencv2 目录的父路径，如 /usr/include/opencv4）。

* OpenCV_LIBS：OpenCV 的库文件列表（如 opencv_core、opencv_highgui 等）。

作用：通过 ${OpenCV_INCLUDE_DIRS}，编译器可以找到 OpenCV 的头文件（如 #include <opencv2/core.hpp>）。



# 二、一系列核心概念的认知

## 2.1 何为头文件？何为库文件？有什么区别？

### 2.1.1 头文件（Header Files）

#### 作用：

* 声明接口：定义函数、类、变量、宏等的声明（告诉编译器“有什么”），但不包含具体实现。

```c++
// example.h（头文件）
#pragma once
int add(int a, int b);  // 函数声明
```

* 提供编译信息：编译器在编译 .cpp 文件时，通过 #include 头文件来确认类型和接口是否合法。

#### 特点:

* 文件扩展名：.h、.hpp、.hxx。

* 不直接参与最终程序的生成，仅用于编译阶段。

* 可以被多个源文件共享（避免重复声明）。

示例:

```c++
// main.cpp
#include "example.h"  // 包含头文件
int main() {
    int result = add(1, 2);  // 调用声明过的函数
    return 0;
}
```

### 2.1.2 库文件（Library Files）

#### 作用：

* 提供实现：包含函数、类等的实际代码（告诉链接器“怎么做”）。

```c++
// example.cpp（源文件，最终编译到库中）
int add(int a, int b) { 
    return a + b;  // 函数实现
}
```

* 复用代码：将常用功能打包成库，供多个程序共享。

#### 类型：

* 静态库（Static Library）
    * 扩展名：.a（Linux）、.lib（Windows）
    * 特点：编译时直接嵌入到可执行文件中，运行时无需额外文件。

* 动态库（Dynamic Library）
    * 扩展名：.so（Linux）、.dll（Windows）
    * 特点：运行时动态加载，节省磁盘和内存空间。

示例:

```cmdd
# 编译静态库（Linux）
g++ -c example.cpp -o example.o
ar rcs libexample.a example.o

# 编译动态库（Linux）
g++ -shared -fPIC example.cpp -o libexample.so
```

### 2.1.3 头文件和库文件的对比

|特性|	头文件|	库文件|
|----|----|----|
|内容	|声明（函数、类、宏等）|	实现（编译后的二进制代码）|
|文件类型|	文本文件（.h）|	二进制文件（.a/.so）|
|编译阶段|	编译时使用（#include）|	链接时使用（-l 和 -L）|
|作用|	告诉编译器“有什么”|	告诉链接器“怎么做”|


### 2.1.4 实际项目中的协作流程

#### 1.编写代码

* 头文件 math.h 声明函数：

```c++
// math.h
int multiply(int a, int b);
```

* 源文件 math.cpp 实现函数：

```c++
// math.cpp
int multiply(int a, int b) { return a * b; }
```

#### 2.编译为库文件

```cmd
g++ -c math.cpp -o math.o          # 编译为目标文件
ar rcs libmath.a math.o            # 打包为静态库
```

#### 3.其他程序使用

* 包含头文件 + 链接库：
```c++
// main.cpp
#include "math.h"                // 包含头文件
int main() {
    multiply(2, 3);              // 调用函数
    return 0;
}
```

* 编译命令

```cmd
g++ main.cpp -I. -L. -lmath -o main  # -I 指定头文件路径，-L 指定库路径
```

# 三、重新认识上面的CmakeLists文件

这个 CMakeLists.txt 文件主要完成了一个 C++ 项目（智能车程序）的构建配置，我们可以将其工作内容分为以下几个步骤：

## 3.1 基础配置阶段

|步骤|	代码|	作用|
|----|----|----|
|设置CMake最低版本|	cmake_minimum_required(VERSION 3.4...3.18)	|确保CMake版本兼容性|
|定义项目名称|	project(smatcar)|	项目命名为 smatcar|
|指定C++标准|	set(CMAKE_CXX_STANDARD 17)|	强制使用C++17标准编译|

## 3.2 项目内部路径配置

|步骤|	代码|	作用|
|----|----|----|
|设置库文件目录|	set(COMMON_LIB_DIR "${PROJECT_SOURCE_DIR}/lib/")|	指定自定义库文件（.so/.a）的存放路径|
|设置头文件目录|	set(COMMON_INCLUDE_DIR "${PROJECT_SOURCE_DIR}/src")|	指定项目自定义头文件（.h）的路径|
|全局添加库路径|	link_directories(${COMMON_LIB_DIR})	|让链接器能搜索 lib/ 下的库文件|
|全局添加头文件路径|	include_directories(${COMMON_INCLUDE_DIR})|	让编译器能搜索 src/ 下的头文件|

## 3.3 外部依赖配置

|步骤|	代码|	作用|
|----|----|----|
|启用PkgConfig工具|	find_package(PkgConfig)|	为查找系统库提供支持|
|查找GLib库|	pkg_search_module(GLIB REQUIRED glib-2.0)	|通过 pkg-config 查找 glib-2.0 库|
|添加GLib头文件路径|	include_directories(${GLIB_INCLUDE_DIRS})|	让编译器能找到GLib的头文件|
|查找OpenCV库|	find_package(OpenCV REQUIRED)|	查找OpenCV库（通过CMake内置脚本）|
|添加OpenCV头文件路径|	include_directories(${OpenCV_INCLUDE_DIRS})	|让编译器能找到OpenCV的头文件|

## 3.4 构建可执行文件


|步骤|	代码|	作用|
|----|----|----|
|定义可执行文件名称|	set(PROJECT_NAME "car")|	输出程序名为 car|
|指定源文件|	set(INTELLIGENTCAR_CAR_PROJECT_SOURCES ${PROJECT_SOURCE_DIR}/src/car.cpp)|	主源码文件为 src/car.cpp|
|创建可执行目标	|add_executable(${PROJECT_NAME} ${INTELLIGENTCAR_CAR_PROJECT_SOURCES})	|定义从源码生成可执行文件|
|链接Pthread库|	target_link_libraries(${PROJECT_NAME} PRIVATE pthread)|	链接多线程库（-lpthread）|
|链接OpenCV库|	target_link_libraries(${PROJECT_NAME} PRIVATE ${OpenCV_LIBS})|	链接OpenCV的库文件|

## 3.5 关键总结

### 3.5.1 依赖管理

* 内部依赖：通过 link_directories 和 include_directories 管理项目自有的库和头文件。

* 外部依赖：通过 find_package 和 pkg_search_module 自动查找系统安装的库（如OpenCV、GLib）。

### 3.5.2 构建目标

* 最终生成一个名为 car 的可执行文件，依赖多线程库和OpenCV。

### 3.5.3 作用域控制

* 使用 PRIVATE 确保依赖仅作用于当前目标（car），避免污染其他可能的目标。

## 3.6 完整流程图展示

```
[基础配置] → [内部路径设置] → [外部库查找] → [构建可执行文件]
    │           │                  │                  │
    │           ├─ 头文件路径       ├─ GLib/OpenCV     ├─ 链接库
    │           └─ 库文件路径       └─ 头文件路径      └─ 生成可执行文件
    └─ C++标准设定
```