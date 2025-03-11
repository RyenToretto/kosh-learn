#!/bin/bash
# 简单防火墙配置

# 配置基本防火墙规则
setup_firewall() {
    # 清除现有规则
    iptables -F

    # 设置默认策略
    iptables -P INPUT DROP
    iptables -P FORWARD DROP
    iptables -P OUTPUT ACCEPT

    # 允许已建立的连接
    iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

    # 允许本地回环
    iptables -A INPUT -i lo -j ACCEPT

    # 允许SSH（根据需要修改端口）
    iptables -A INPUT -p tcp --dport 22 -j ACCEPT
