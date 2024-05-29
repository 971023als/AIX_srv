#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="웹 보안"
code="SRV-058"
riskLevel="상"
diagnosisItem="웹 서비스의 불필요한 스크립트 매핑 존재"
diagnosisResult=""
status=""

BAR

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 웹 서비스에서 불필요한 스크립트 매핑이 존재하지 않는 경우
[취약]: 웹 서비스에서 불필요한 스크립트 매핑이 존재하는 경우
EOF

BAR

# Apache 또는 Nginx 웹 서비스의 스크립트 매핑 설정 확인
APACHE_CONFIG_FILE="/etc/apache2/apache2.conf"
NGINX_CONFIG_FILE="/etc/nginx/nginx.conf"

# Function to check script mapping
check_script_mapping() {
  local file=$1
  local service=$2
  local pattern=$3

  if [ -f "$file" ]; then
    if grep -qE "$pattern" "$file"; then
      diagnosisResult="$service에서 불필요한 스크립트 매핑이 발견됨: $file"
      status="취약"
      echo "WARN: $diagnosisResult" >> $TMP1
    else
      diagnosisResult="$service에서 불필요한 스크립트 매핑이 발견되지 않음: $file"
      status="양호"
      echo "OK: $diagnosisResult" >> $TMP1
    fi
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
  else
    diagnosisResult="$service 설정 파일이 존재하지 않습니다: $file"
    status="정보 없음"
    echo "INFO: $diagnosisResult" >> $TMP1
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
  fi
}

# Apache에서 스크립트 매핑 설정 확인
check_script_mapping "$APACHE_CONFIG_FILE" "Apache" "AddHandler|AddType"

# Nginx에서 스크립트 매핑 설정 확인
check_script_mapping "$NGINX_CONFIG_FILE" "Nginx" "location ~ \.php$"

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
