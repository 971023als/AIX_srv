#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="시스템 최적화"
code="SRV-105"
riskLevel="낮음"
diagnosisItem="불필요한 시작프로그램 존재"
service="시스템 최적화"
diagnosisResult=""
status=""

BAR

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 불필요한 시작 프로그램이 존재하지 않는 경우
[취약]: 불필요한 시작 프로그램이 존재하는 경우
EOF

BAR

# Function to append results to CSV file
append_to_csv() {
    local result=$1
    local status=$2
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$result,$status" >> $OUTPUT_CSV
}

# Known safe services (add known safe services to this list)
known_safe_services=("sshd" "cron" "srcmstr" "inetd" "snmpd" "rsct")

# 시스템 시작 시 실행되는 프로그램 목록 확인
startup_programs=$(lsitab -a | awk '{print $1}')

# 불필요하거나 의심스러운 서비스를 확인
has_unnecessary_services=0
for service in $startup_programs; do
    if [[ ! " ${known_safe_services[@]} " =~ " ${service} " ]]; then
        append_to_csv "의심스러운 시작 프로그램: $service" "취약"
        has_unnecessary_services=1
    fi
done

if [ $has_unnecessary_services -eq 0 ]; then
    append_to_csv "시스템에 불필요한 시작 프로그램이 없습니다." "양호"
fi

cat $TMP1

echo "CSV report generated: $OUTPUT_CSV"
echo ; echo
