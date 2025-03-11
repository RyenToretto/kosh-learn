#!/bin/bash
# test_framework.sh - 简单的测试框架

# 测试计数器
TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# 断言函数
assert_equals() {
    local expected=$1
    local actual=$2
    local message=${3:-"测试失败"}

    ((TESTS_TOTAL++))

    if [ "$expected" = "$actual" ]; then
        echo -e "${GREEN}✓ 通过${NC}: $message"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗ 失败${NC}: $message"
        echo "  期望值: $expected"
        echo "  实际值: $actual"
        ((TESTS_FAILED++))
        return 1
    fi
}

assert_true() {
    local condition=$1
    local message=${2:-"条件应为真"}

    if eval "$condition"; then
        assert_equals "true" "true" "$message"
    else
        assert_equals "true" "false" "$message"
    fi
}

# 测试套件
run_test_suite() {
    local suite_name=$1
    echo "=== 运行测试套件: $suite_name ==="

    # 运行所有test_开头的函数
    for test_func in $(declare -F | cut -d' ' -f3 | grep '^test_'); do
        echo -n "测试: ${test_func#test_} ... "
        $test_func
    done

    # 打印测试结果
    echo "=== 测试结果 ==="
    echo "总计: $TESTS_TOTAL"
    echo -e "${GREEN}通过: $TESTS_PASSED${NC}"
    echo -e "${RED}失败: $TESTS_FAILED${NC}"
}
