#!/bin/bash
# Shell脚本测试框架

# 测试套件
TEST_SUITE=()

# 添加测试用例
add_test() {
    TEST_SUITE+=("$1")
}

# 运行测试
run_tests() {
    local total=${#TEST_SUITE[@]}
    local passed=0
    local failed=0

    echo "开始运行测试..."

    for test in "${TEST_SUITE[@]}"; do
        echo -n "运行测试: $test "
        if $test; then
            echo "[通过]"
            ((passed++))
        else
            echo "[失败]"
            ((failed++))
        fi
    done

    echo "测试完成: $passed 通过, $failed 失败 (共 $total 个测试)"
}
