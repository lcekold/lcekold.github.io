# 静态库调用流程：
## 1.引入头文件
## 2.连接静态库
## 3.生成可执行的二进制文件

# 调用动态库流程
## 1.引入头文件
## 2.声明库目录
## 3.生成可执行的二进制文件
## 4.连接动态库


cmake_minimum_required(VERSION 3.20.0)
project(Animal CXX)
# 静态库调用流程
# include_directories(${PROJECT_SOURCE_DIR}/include)  # 指定了项目的包含目录，即告诉编译器在编译时要查找头文件的位置。这里指定了一个名为 “include” 的目录，该目录位于项目的源代码目录下。
# link_directories(${PROJECT_SOURCE_DIR}/a) # 指定了链接器在链接可执行文件时查找库文件的位置。在这个例子中，告诉链接器在名为 “a” 的目录下查找库文件。
# link_libraries(animal)  # 指定链接器应该链接的库文件。在这里，指定链接名为 “animal” 的库文件。
# add_executable(app main.cpp)   # 用于创建一个可执行文件。add_executable 命令指定要生成的可执行文件的名称以及用于编译的源文件列表。在这个例子中，创建了一个名为 “app” 的可执行文件，其中包含了名为 “main.cpp” 的源文件。

# 动态库调用流程 (GCC下可行，VS下会报错LINK : fatal error LNK1104)
include_directories(${PROJECT_SOURCE_DIR}/include)
link_directories(${PROJECT_SOURCE_DIR}/so)
add_executable(app main.cpp)
target_link_libraries(app PUBLIC animal)

