cmake_minimum_required(VERSION 3.20.0)
project(Animal CXX)

file(GLOB SRC ${PROJECT_SOURCE_DIR}/src/*.cpp)  # 使用 file 命令来查找指定目录下所有以 “.cpp” 结尾的文件，并将它们的路径存储到变量 SRC 中。
include_directories(${PROJECT_SOURCE_DIR}/include) # 指定了项目的包含目录，即告诉编译器在编译时要查找头文件的位置。这里指定了一个名为 “include” 的目录，该目录位于项目的源代码目录下。

# 生成静态库
# set(LIBRARY_OUTPUT_PATH ${PROJECT_SOURCE_DIR}/a) # 设置了生成的静态库文件的输出路径。在这个例子中，静态库文件将被输出到名为 “a” 的子目录下。
# add_library(animal STATIC ${SRC}) # 用于创建一个静态库。add_library 命令用于将源文件添加到项目中，并生成相应的库文件。在这个例子中，创建了一个名为 “animal” 的静态库，其包含了变量 SRC 中列出的所有源文件。

# 生成动态库  (注意：动态库可以直接执行，静态库不可以直接执行）
set(LIBRARY_OUTPUT_PATH ${PROJECT_SOURCE_DIR}/so)  # 设置了生成的共享库文件的输出路径。在这个例子中，共享库文件将被输出到名为 “so” 的子目录下。
add_library(animal SHARED ${SRC})  # 用于创建一个共享库(动态库)。与之前创建静态库的过程类似，add_library 命令将源文件添加到项目中，并生成相应的库文件。在这个例子中，创建了一个名为 “animal” 的共享库，其包含了变量 SRC 中列出的所有源文件。