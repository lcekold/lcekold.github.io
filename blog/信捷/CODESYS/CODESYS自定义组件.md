# 为Runtime（运行时系统）扩展C/C++功能

这是最核心、最强大的“自定义组件”，属于系统级的扩展。通过这种方式，你可以用C或C++编写高性能的代码，并将其作为Runtime的一部分来执行。这类组件通常被称为动态组件或扩展模块。

开发这类组件主要分为两步：

## 创建IEC库（在CODESYS IDE中）

1. 新建一个CODESYS库项目。
2. 在库中声明你需要的函数（Function）或功能块（Function Block）。
3. 在函数的属性中，勾选 “External implementation”（外部实现）。这表示该函数的实际代码将由你在Runtime中提供。
4. 生成接口文件：通过菜单 Build -> Generate runtime system files，生成 *.c 和 *.m4 文件。这些文件定义了C代码与IEC代码之间的接口。