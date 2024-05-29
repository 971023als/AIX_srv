#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="시스템 로깅"
code="SRV-108"
riskLevel="중"
diagnosisItem="로그에 대한 접근통제 및 관리 미흡"
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
[양호]: 로그 파일의 접근 통제 및 관리가 적절하게 설정되어 있는 경우
[취약]: 로그 파일의 접근 통제 및 관리가 적절하게 설정되어 있지 않은 경우
EOF

BAR

# Function to append results to CSV file
append_to_csv() {
    local result=$1
    local status=$2
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$result,$status" >> $OUTPUT_CSV
}

# Check the syslog configuration file
filename="/etc/syslog.conf"

if [ ! -e "$filename" ]; then
  diagnosisResult="$filename 가 존재하지 않습니다"
  status="취약"
  append_to_csv "$diagnosisResult" "$status"
else
  expected_content=(
    "*.info /var/log/messages"
    "auth.info /var/log/authlog"
    "mail.info /var/log/maillog"
    "daemon.info /var/log/daemonlog"
    "kern.info /var/log/kernlog"
    "syslog.info /var/log/syslog"
    "user.info /var/log/userlog"
  )

  match=0
  for content in "${expected_content[@]}"; do
    if grep -q "$content" "$filename"; then
      match=$((match + 1))
    fi
  done

  if [ "$match" -eq "${#expected_content[@]}" ]; then
    diagnosisResult="$filename의 내용이 정확합니다."
    status="양호"
    append_to_csv "$diagnosisResult" "$status"
  else
    diagnosisResult="$filename의 내용이 잘못되었습니다."
    status="취약"
    append_to_csv "$diagnosisResult" "$status"
  fi
fi

cat $TMP1

echo "CSV report generated: $OUTPUT_CSV"
echo ; echo
