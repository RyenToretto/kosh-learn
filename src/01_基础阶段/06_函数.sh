#!/bin/bash

# 基本函数
sayHello() {
    echo "你好，世界"
}

# 带参数的函数
greet() {
    echo "你好，$1"
}

# 带返回值的函数
add() {
    local result=$(($1 + $2))
    return $result
}

# 局部变量
function test() {
    local var1="局部变量"
    echo $var1
}

# 全局变量
global_var="全局变量"
function print_global() {
    echo $global_var
}

# 调用函数
sayHello
greet "小明"
add 5 3
echo $?  # 获取返回值
