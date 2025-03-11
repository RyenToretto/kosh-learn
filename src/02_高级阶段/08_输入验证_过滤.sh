validate_input() {
    local input=$1

    # 检查空输入
    if [ -z "$input" ]; then
        echo "错误: 输入不能为空" >&2
        return 1
    }

    # 检查特殊字符
    if [[ "$input" =~ [^a-zA-Z0-9_-] ]]; then
        echo "错误: 输入包含非法字符" >&2
        return 1
    }

    # 长度限制
    if [ ${#input} -gt 32 ]; then
        echo "错误: 输入超过最大长度" >&2
        return 1
    }

    return 0
}

# 路径验证
validate_path() {
    local path=$1

    # 规范化路径
    path=$(realpath -m "$path")

    # 检查路径注入
    if [[ "$path" =~ \.\. ]]; then
        echo "错误: 检测到路径遍历攻击" >&2
        return 1
    }

    # 检查权限
    if [ ! -w "$path" ]; then
        echo "错误: 无写入权限" >&2
        return 1
    }

    return 0
}
