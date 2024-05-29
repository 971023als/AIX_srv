#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="시스템 로깅"
code="SRV-112"
riskLevel="중"
diagnosisItem="Cron 서비스 로깅 미설정"
service="시스템 로깅"
diagnosisResult=""
status=""

BAR

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: Cron 서비스 로깅이 적절하게 설정되어 있는 경우
[취약]: Cron 서비스 로깅이 적절하게 설정되어 있지 않은 경우
EOF

BAR

# Function to append results to CSV file
append_to_csv() {
    local result=$1
    local status=$2
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$result,$status" >> $OUTPUT_CSV
}

# Check syslog.conf for Cron logging configuration
syslog_conf="/etc/syslog.conf"
if [ ! -f "$syslog_conf" ]; then
    append_to_csv "syslog.conf 파일이 존재하지 않습니다." "취약"
else
    if grep -q "cron.*" "$syslog_conf"; then
        append_to_csv "Cron 로깅이 syslog.conf에서 설정되었습니다." "양호"
    else
        append_to_csv "Cron 로깅이 syslog.conf에서 설정되지 않았습니다." "취약"
    fi
fi

# Check for the existence of the Cron log file
cron_log="/var/adm/cron/log"
if [ ! -f "$cron_log" ]; then
    append_to_csv "Cron 로그 파일이 존재하지 않습니다." "취약"
else
    append_to_csv "Cron 로그 파일이 존재합니다." "양호"
fi

cat $TMP1

echo "CSV report generated: $OUTPUT_CSV"
echo ; echo
