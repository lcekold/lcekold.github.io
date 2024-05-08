cmake_minimum_required(VERSION 3.20.0)

set(Var1 YZZY)
message(${Var1})

set("My Var" zzz)
message(${My\ Var})
message("...............")

# 设置多个值
set(LISTVALUE a1 a2)
message(${LISTVALUE})

# $PATH
message($ENV{PATH})
set(ENV{CXX} "g++")
message($ENV{CXX})

# unset
unset(ENV{CXX})
message($ENV{CXX})