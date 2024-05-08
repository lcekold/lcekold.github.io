cmake_minimum_required(VERSION 3.20.0)
project(Animal CXX) #定义项目名称为 Animal，指定编程语言为 C++。

# 设置C++的标准
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED True) # 指定 C++ 标准为必需的。

configure_file(config.h.in config.h) # 根据模板文件 config.h.in 生成配置文件 config.h。

add_subdirectory(animal)  # 添加一个子目录 animal，用于构建 AnimalLib 库。

add_executable(Animal main.cpp) # 添加一个可执行文件 Animal，它的源文件是 main.cpp。

target_link_libraries(Animal PUBLIC AnimalLib)  #  将 Animal 可执行文件链接到 AnimalLib 库。

target_include_directories(Animal PUBLIC "${PROJECT_BINARY_DIR}" "${PROJECT_SOURCE_DIR}/animal") # 将 Animal 可执行文件的包含目录设置为项目的构建目录和 animal 子目录。
#解释： ##“${PROJECT_BINARY_DIR}” 表示项目的构建目录，这是编译后生成的文件所在的目录。
        ##“${PROJECT_SOURCE_DIR}/animal” 表示项目源代码目录下的 animal 子目录，用于存放 Animal 库的头文件。
        ##因此，这句话的意思是告诉编译器，在编译 Animal 可执行文件时，应该搜索项目的构建目录以及 animal 子目录，以找到需要包含的头文件。