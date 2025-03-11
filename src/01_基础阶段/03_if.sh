#!/bin/bash

# 基本if语句
if [ $age -gt 18 ]; then
    echo "成年人"
fi

# if-else语句
if [ $score -ge 60 ]; then
    echo "及格"
else
    echo "不及格"
fi

# if-elif-else语句
if [ $score -ge 90 ]; then
    echo "优秀"
elif [ $score -ge 60 ]; then
    echo "及格"
else
    echo "不及格"
fi
