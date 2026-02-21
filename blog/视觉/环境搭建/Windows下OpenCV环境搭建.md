这里推荐两篇文章:

一篇为锦恢大佬的<a href="https://zhuanlan.zhihu.com/p/402378383">如何优雅地在你的Vscode上使用opencv（C++接口，Windows篇，实则踩坑经历）</a>

另一篇为HNU跃鹿战队的<a href="https://blog.csdn.net/NeoZng/article/details/122778711">Windows安装OpenCV——利用MinGW+CMake从源码编译</a>

看完之后基本都可以掌握在Windows下通过MinGW以及CMake使用OpenCV的流程了。

我这里在做一些补充

# 一、针对使用锦恢大佬的编译命令，然后报错opencv2/opencv.hpp: No such file or directory的问题

针对此问题，实际上还是由于opencv头文件无法找到的原因导致的。

这里建议使用以下命令：

    g++ -g .\hello_opencv.cpp -std=c++14 -I "E:\Environment\x86_64-15.2.0-release-posix-seh-ucrt-rt_v13-rev0\mingw64\include" -I "E:\Environment\opencv\build_mingw\install\include" -L "E:\Environment\opencv\build_mingw\install\x64\mingw\lib" -lopencv_core4120 -lopencv_imgcodecs4120 -lopencv_imgproc4120 -lopencv_calib3d4120 -lopencv_dnn4120 -lopencv_features2d4120 -lopencv_flann4120 -lopencv_gapi4120 -lopencv_highgui4120 -lopencv_ml4120 -lopencv_objdetect4120 -lopencv_photo4120 -lopencv_stitching4120 -lopencv_video4120 -lopencv_videoio4120 -o hello_opencv.exe

在opencv中 -I代表编译器指定搜索的头文件路径，-L代表链接器指定搜索的库文件路径。 -l则是指定具体的链接库。

通过这种方式，保证编译器和链接器可以找到opencv的头文件和库文件。

# 二、针对cmakeLists文件的说明

```cmake
cmake_minimum_required(VERSION 3.16)
SET(CMAKE_BUILD_TYPE "Debug")
set(CMAKE_CXX_STANDARD 11)
project(OPENCV_TEST)
set(OpenCV_DIR "E:\\Environment\\opencv\\build_mingw\\install")
FIND_PACKAGE(OpenCV REQUIRED)
INCLUDE_DIRECTORIES(${OpenCV_INCLUDE_DIRS})
file(GLOB sec_lists ${CMAKE_SOURCE_DIR}/*.cpp ${CMAKE_SOURCE_DIR}/*.h)
add_executable(OPENCV_TEST ${sec_lists})
target_link_libraries(OPENCV_TEST ${OpenCV_LIBS})
```

其中FIND_PACKAGE(OpenCV REQUIRED)的作用是寻找OpenCV库，并将其包含路径和库路径存储在变量OpenCV_INCLUDE_DIRS和OpenCV_LIBS中。

OPENCV在编译完成后会生成一个OpenCVConfig.cmake文件，这个文件包含了OpenCV的配置信息，CMake通过这个文件来找到OpenCV的安装路径和相关信息。

其中OpenCV_INCLUDE_DIRS和OpenCV_LIBS都是在OpenCVConfig.cmake文件中定义的变量。因此一般情况不能够修改名称。

    如果担心找不到OpenCVConfig.cmake文件，可以通过设置OpenCV_DIR变量来指定其路径，例如： set(OpenCV_DIR "E:\\Environment\\opencv\\build_mingw\\install")。

    然后是file(GLOB sec_lists ${CMAKE_SOURCE_DIR}/*.cpp ${CMAKE_SOURCE_DIR}/*.h)的说明，这个命令的作用是将指定目录下的所有.cpp和.h文件收集到变量sec_lists中，方便后续添加到可执行文件中。

    ${CMAKE_SOURCE_DIR}/*.cpp和${CMAKE_SOURCE_DIR}/*.h 分别表示当前CMakeLists.txt文件所在目录下的所有.cpp和.h文件。