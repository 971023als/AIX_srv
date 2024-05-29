#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="시스템 유지 관리"
code="SRV-101"
riskLevel="낮음"
diagnosisItem="불필요한 예약된 작업 존재"
service="시스템 유지 관리"
diagnosisResult=""
status=""

BAR

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 불필요한 cron 작업이 존재하지 않는 경우
[취약]: 불필요한 cron 작업이 존재하는 경우
EOF

BAR

# Function to append results to CSV file
append_to_csv() {
    local result=$1
    local status=$2
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$result,$status" >> $OUTPUT_CSV
}

# Check all cron jobs on the system
check_cron_jobs() {
    local has_unnecessary_cron_jobs=0
    for user in $(cut -f1 -d: /etc/passwd); do
        crontab -l -u $user 2>/dev/null | grep -v '^#' | while read -r cron_job; do
            if [ -n "$cron_job" ]; then
                append_to_csv "불필요한 cron 작업이 존재할 수 있습니다: $cron_job (사용자: $user)" "취약"
                has_unnecessary_cron_jobs=1
            fi
        done
    done
    if [ $has_unnecessary_cron_jobs -eq 0 ]; then
        append_to_csv "불필요한 cron 작업이 존재하지 않습니다." "양호"
    fi
}

# Run the cron job check
check_cron_jobs

cat $TMP1

echo "CSV report generated: $OUTPUT_CSV"
echo ; echo
