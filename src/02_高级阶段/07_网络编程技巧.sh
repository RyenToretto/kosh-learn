# 使用 awk 处理复杂文本
awk '
BEGIN {
    FS=","    # 设置字段分隔符
    OFS="\t"  # 设置输出字段分隔符
    print "姓名\t年龄\t分数"  # 打印表头
}
{
    if ($3 > 60) {  # 条件过滤
        total_score += $3
        count++
        print $1, $2, $3  # 输出符合条件的行
    }
}
END {
    printf "平均分: %.2f\n", total_score/count
}' data.csv

# 使用 sed 进行高级文本替换
sed -i.bak '
    /^#/!{        # 不处理注释行
        s/foo/bar/g   # 替换foo为bar
        s/\s\+/ /g    # 压缩多个空格为一个
        /^$/d         # 删除空行
    }
' config.txt
