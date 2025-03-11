#!/bin/bash
# 数据库操作封装

# MySQL操作
mysql_query() {
    local query=$1
    mysql -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "$query"
}

# PostgreSQL操作
pg_query() {
    local query=$1
    PGPASSWORD=$DB_PASS psql -U "$DB_USER" -d "$DB_NAME" -c "$query"
}

# 数据库备份
backup_database() {
    local backup_file="backup_$(date +%Y%m%d_%H%M%S).sql"
    mysqldump -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" > "$backup_file"
    gzip "$backup_file"
}
