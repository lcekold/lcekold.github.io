在编写完 CMakeLists.txt 文件后，需要通过 CMake 生成构建系统，然后使用 编译工具 进行编译和链接。以下是详细的步骤和命令：

# 一、创建构建目录

为了避免污染源代码目录，建议创建一个单独的 build 目录：

```bash
mkdir build
cd build
```

# 二、运行CMake生成构建系统

在 build 目录中执行以下命令，生成对应的构建文件（如 Makefile、Visual Studio 项目等）：

```bash
cmake ..
```

* .. 表示 CMakeLists.txt 位于上一级目录。

* 其他常用选项：
    * 指定生成器（如 Visual Studio）：

    ```bash
    cmake -G Ninja ..              # 使用 Ninja 构建工具
    cmake -G "Visual Studio 17 2022" ..  # 使用 Visual Studio 2022
    ```

    * 指定构建类型（Debug/Release）：

    ```bash
    cmake -DCMAKE_BUILD_TYPE=Release .. # 设置为 Release 模式
    ```

# 三、执行编译

根据生成的构建系统类型，选择以下命令之一进行编译：

（1）使用 Makefile（Linux/macOS 或 MinGW）

```bash
make
```

* 并行编译（加快速度）：

```bash
make -j$(nproc)  # 使用所有可用 CPU 核心
```

（2）使用 Visual Studio（Windows）

* 命令行编译：

```bash
cmake --build . --config Release  # 指定 Release 模式
```

* 或打开生成的 .sln 文件，在 Visual Studio 中手动编译。

（3）使用 Ninja（跨平台，高效）

```bash
ninja
```

# 四、生成的可执行文件位置

编译完成后，可执行文件通常位于：

* 默认路径：

     * build/ 目录下（与 CMakeLists.txt 中 add_executable 设置的名称一致）。

* 自定义输出路径：
在 CMakeLists.txt 中设置：

```cmake
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/bin)
```

可执行文件将输出到项目根目录的 bin/ 文件夹。

# 五、运行可执行文件

根据操作系统执行生成的可执行文件（例如 my_program）：

```bash
./my_program          # Linux/macOS
.\my_program.exe      # Windows (PowerShell)
my_program.exe        # Windows (CMD)
```

# 六、清理构建(可选)

如果需要重新编译，可以清理构建结果：

```bash
# 使用 Makefile
make clean

# 使用 CMake 命令
cmake --build . --target clean

# 彻底删除 build 目录（慎用）
cd .. && rm -rf build
```

# 七、完整流程示例

## 7.1 Linux/macOS 示例

```bash
# 1. 创建构建目录
mkdir -p build && cd build

# 2. 生成 Makefile
cmake -DCMAKE_BUILD_TYPE=Release ..

# 3. 编译（并行）
make -j$(nproc)

# 4. 运行
./my_program
```

## 7.2 Windows 示例（Visual Studio）

```bash
# 1. 创建构建目录
mkdir build && cd build

# 2. 生成 VS 解决方案
cmake -G "Visual Studio 17 2022" ..

# 3. 编译 Release 版本
cmake --build . --config Release

# 4. 运行
.\Release\my_program.exe
```

# 八、常见问题

## 8.1 Q1：CMake 报错找不到依赖库？

* 确保依赖已安装，并通过 find_package 正确配置。

* 手动指定库路径：

    ```bash
    cmake -DOpenCV_DIR=/path/to/opencv ..
    ```

## 8.2 Q2：如何跨平台编译？

* 使用 -G 指定目标平台的生成器：

    ```bash
    cmake -G "Unix Makefiles" ..      # Linux/macOS
    cmake -G "MinGW Makefiles" ..     # Windows (MinGW)
    cmake -G "Xcode" ..               # macOS (Xcode)
    ```

## 8.3 Q3：如何查看详细编译日志？

* 在 make 或 cmake --build 中添加 VERBOSE=1：

    ```bash
    make VERBOSE=1
    cmake --build . --verbose
    ```


# 总结

1. 创建 build 目录 → 隔离生成文件。

2. cmake .. → 生成构建系统（Makefile/MSVC/Ninja）。

3. make 或 cmake --build . → 编译链接。

4. 运行可执行文件 → 验证结果。

通过 CMake 的跨平台特性，同一份 CMakeLists.txt 可在不同操作系统上生成对应的构建文件。