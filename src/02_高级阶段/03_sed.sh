#!/bin/bash

# 替换文本
sed 's/old/new/' file.txt      # 替换每行第一次匹配
sed 's/old/new/g' file.txt     # 替换所有匹配

# 删除行
sed '/pattern/d' file.txt      # 删除匹配行
sed '1,5d' file.txt           # 删除1-5行

# 插入和追加
sed '2i\新行' file.txt         # 在第2行前插入
sed '2a\新行' file.txt         # 在第2行后追加
