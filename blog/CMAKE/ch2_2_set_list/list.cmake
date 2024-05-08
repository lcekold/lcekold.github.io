cmake_minimum_required(VERSION 3.20.0)

# 基本操作方式为：list(需要执行的操作名称 执行的对象 参数 用于接收结果的变量)

# 两种方式来创建Var
set(LISTVALUE a1 a2 a3)
message(${LISTVALUE})

list(APPEND port p1 p2 p3)
message(${port})

# 获取长度
list(LENGTH LISTVALUE len)
message(${len})

# 查找指定元素索引
list(FIND LISTVALUE a2 index)
message(${index})

# 删除指定元素
list(REMOVE_ITEM port p1)
message(${port})

# 添加元素
list(APPEND LISTVALUE a5)
message(${LISTVALUE})

# 指定位置添加元素
list(INSERT LISTVALUE 3 a4)
message(${LISTVALUE})

# 反转列表
list(REVERSE LISTVALUE)
message(${LISTVALUE})

# 排序列表(字符串排序的方法)
list(SORT LISTVALUE)
message(${LISTVALUE})