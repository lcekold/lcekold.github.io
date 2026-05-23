最近C盘要爆了，遂开始清理C盘，后面仔细一想我的WSL默认路径也在C盘，占用的空间还是比较大的，因此有必要对WSL的磁盘进行迁移。

迁移操作十分简单，步骤如下：
```py
    wsl --shutdown  # 关闭所有 WSL 实例，确保没有正在运行的实例
```
现在执行迁移步骤：

```py
    mkdir E:\WSL    # 创建新的存放目录

    wsl --export Ubuntu E:\WSL\Ubuntu.tar # 导出当前的 WSL 发行版为一个 tar 文件

    wsl --unregister Ubuntu # 注销当前的 WSL 发行版

    wsl --import Ubuntu E:\WSL\Ubuntu E:\WSL\Ubuntu.tar # 从导出的 tar 文件重新导入 WSL 发行版到新的位置

    wsl --list --verbose # 验证迁移是否成功，查看已注册的 WSL 发行版列表
```

迁移操作大致就完成了，现在可以删除备份文件。

```python
Remove-Item E:\WSL\Ubuntu.tar   # 删除导出的 tar 文件
```

注意：导入后默认用户会变成 root。如果你之前有其他用户，需要设置默认用户：
```python
# 启动 Ubuntu 并创建/设置用户
wsl -d Ubuntu

# 在 WSL 中添加用户（如果需要）
useradd -m -s /bin/bash 用户名
passwd 用户名
usermod -aG sudo 用户名
exit

# 设置默认用户（在 PowerShell 中）
ubuntu config --default-user 用户名
```

一切就大功告成了。