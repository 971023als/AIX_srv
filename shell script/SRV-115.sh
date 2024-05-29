#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="로그 관리"
code="SRV-115"
riskLevel="중"
diagnosisItem="로그의 정기적 검토 및 보고 미수행"
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
[양호]: 로그가 정기적으로 검토 및 보고되고 있는 경우
[취약]: 로그가 정기적으로 검토 및 보고되지 않는 경우
EOF

BAR

# Function to append results to CSV file
append_to_csv() {
    local result=$1
    local status=$2
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$result,$status" >> $OUTPUT_CSV
}

# Check for the existence of the log review and reporting script
log_review_script="/path/to/log/review/script"
if [ ! -f "$log_review_script" ]; then
    diagnosisResult="로그 검토 및 보고 스크립트가 존재하지 않습니다."
    status="취약"
    append_to_csv "$diagnosisResult" "$status"
    echo "WARN: $diagnosisResult" >> $TMP1
else
    diagnosisResult="로그 검토 및 보고 스크립트가 존재합니다."
    status="양호"
    append_to_csv "$diagnosisResult" "$status"
    echo "OK: $diagnosisResult" >> $TMP1
fi

# Check for the existence of the log report
log_report="/path/to/log/report"
if [ ! -f "$log_report" ]; then
    diagnosisResult="로그 보고서가 존재하지 않습니다."
    status="취약"
    append_to_csv "$diagnosisResult" "$status"
    echo "WARN: $diagnosisResult" >> $TMP1
else
    diagnosisResult="로그 보고서가 존재합니다."
    status="양호"
    append_to_csv "$diagnosisResult" "$status"
    echo "OK: $diagnosisResult" >> $TMP1
fi

cat $TMP1

echo ; echo

cat $OUTPUT_CSV

echo "CSV report generated: $OUTPUT_CSV"
echo ; echo
