# crypto.sh

# 文件加密
encrypt_file() {
    local input_file=$1
    local output_file="$input_file.enc"
    local key_file=$2

    # 使用OpenSSL加密
    openssl enc -aes-256-cbc \
            -salt \
            -in "$input_file" \
            -out "$output_file" \
            -pass file:"$key_file"

    echo "文件已加密: $output_file"
}

# 文件解密
decrypt_file() {
    local input_file=$1
    local output_file="${input_file%.enc}"
    local key_file=$2

    # 使用OpenSSL解密
    openssl enc -aes-256-cbc -d \
            -in "$input_file" \
            -out "$output_file" \
            -pass file:"$key_file"

    echo "文件已解密: $output_file"
}

# 生成密钥
generate_key() {
    local key_file=$1
    local key_size=${2:-256}

    openssl rand -base64 "$key_size" > "$key_file"
    chmod 600 "$key_file"

    echo "密钥已生成: $key_file"
}
