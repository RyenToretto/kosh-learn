# integration_test.sh

# 集成测试环境设置
setup_integration_env() {
    # 创建测试数据库
    mysql -u root -e "CREATE DATABASE IF NOT EXISTS test_db;"

    # 准备测试数据
    mysql -u root test_db < test_data.sql

    # 启动测试服务
    docker-compose -f docker-compose.test.yml up -d
}

# 集成测试用例
run_integration_test() {
    local test_suite=$1
    local report_file="integration_test_report.html"

    echo "开始集成测试..."

    # 执行API测试
    test_api() {
        local endpoint=$1
        local expected_status=$2

        local response=$(curl -s -w "%{http_code}" "$endpoint")
        local status=${response: -3}
        local body=${response:0:${#response}-3}

        if [ "$status" = "$expected_status" ]; then
            echo "[通过] $endpoint"
            return 0
        else
            echo "[失败] $endpoint (状态码: $status, 期望: $expected_status)"
            return 1
        fi
    }

    # 执行数据库测试
    test_database() {
        local query=$1
        local expected_count=$2

        local result=$(mysql -u root test_db -sN -e "$query")

        if [ "$result" = "$expected_count" ]; then
            echo "[通过] 数据库测试: $query"
            return 0
        else
            echo "[失败] 数据库测试: $query (结果: $result, 期望: $expected_count)"
            return 1
        fi
    }

    # 生成HTML报告
    generate_test_report() {
        cat > "$report_file" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>集成测试报告</title>
    <style>
        .pass { color: green; }
        .fail { color: red; }
    </style>
</head>
<body>
    <h1>集成测试报告</h1>
    <p>执行时间: $(date)</p>
    <h2>测试结果</h2>
    <pre>
$(cat test_output.log)
    </pre>
</body>
</html>
EOF
    }

    # 执行测试并收集结果
    {
        test_api "http://localhost:8080/api/health" "200"
        test_database "SELECT COUNT(*) FROM users" "5"
    } | tee test_output.log

    # 生成报告
    generate_test_report

    echo "测试完成，报告已生成: $report_file"
}
