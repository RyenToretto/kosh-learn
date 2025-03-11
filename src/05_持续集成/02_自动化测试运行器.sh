#!/bin/bash
# run_tests.sh - 自动化测试运行器

# 设置错误处理
set -euo pipefail
IFS=$'\n\t'

# 测试环境准备
setup_test_env() {
    echo "准备测试环境..."
    mkdir -p test_output
    export TEST_DIR="$(pwd)/test_output"
    export TEST_DATA="$TEST_DIR/data"

    # 创建测试数据
    cp -r test_fixtures/* "$TEST_DATA"
}

# 清理测试环境
cleanup_test_env() {
    echo "清理测试环境..."
    rm -rf "$TEST_DIR"
}

# 运行所有测试
run_all_tests() {
    echo "开始运行测试..."

    # 查找所有测试文件
    local test_files=($(find . -name "test_*.sh"))

    # 生成JUnit XML报告头部
    cat > test-results.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<testsuites>
EOF

    # 运行每个测试文件
    for test_file in "${test_files[@]}"; do
        echo "运行测试文件: $test_file"

        # 运行测试并捕获输出
        if output=$(bash "$test_file" 2>&1); then
            success="true"
        else
            success="false"
        fi

        # 添加测试结果到XML
        cat >> test-results.xml << EOF
  <testsuite name="$(basename "$test_file")">
    <testcase name="$(basename "$test_file")">
      $([ "$success" = "false" ] && echo "<failure>$output</failure>")
    </testcase>
  </testsuite>
EOF
    done

    # 完成XML报告
    echo "</testsuites>" >> test-results.xml
}

# 生成覆盖率报告
generate_coverage() {
    echo "生成代码覆盖率报告..."

    # 使用 kcov 生成覆盖率报告
    kcov --include-pattern=.sh \
         --exclude-pattern=test_ \
         coverage-report \
         run_all_tests
}

# 主函数
main() {
    trap cleanup_test_env EXIT

    setup_test_env
    run_all_tests
    generate_coverage

    echo "测试完成！"
}

main "$@"
