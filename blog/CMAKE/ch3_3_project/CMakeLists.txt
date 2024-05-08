cmake_minimum_required(VERSION 3.20.0)
project(Animal CXX) #定义项目名称为 Animal，指定编程语言为 C++。

add_subdirectory(animal)  # 添加一个子目录 animal，用于构建 AnimalLib 库。


add_executable(Animal main.cpp) # 添加一个可执行文件 Animal，它的源文件是 main.cpp。

target_link_libraries(Animal PUBLIC AnimalLib)  #  将 Animal 可执行文件链接到 AnimalLib 库。

target_include_directories(Animal PUBLIC "${PROJECT_BINARY_DIR}" "${PROJECT_SOURCE_DIR}/animal") # 将 Animal 可执行文件的包含目录设置为项目的构建目录和 animal 子目录。