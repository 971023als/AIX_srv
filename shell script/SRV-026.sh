#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="시스템 보안"
code="SRV-026"
riskLevel="높음"
diagnosisItem="SSH를 통한 Administrator 계정의 원격 접속 제한 검사"
service="SSH Service"
diagnosisResult=""
status=""

BAR

CODE="SRV-026"
diagnosisItem="SSH 서비스 root 계정 원격 접속 허용 여부 검사"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: SSH를 통한 root 계정의 원격 접속이 제한된 경우
[취약]: SSH를 통한 root 계정의 원격 접속이 제한되지 않은 경우
EOF

BAR

# Check if SSH service is running
ps_sshd_count=$(ps -ef | grep -i 'sshd' | grep -v 'grep' | wc -l)
if [ $ps_sshd_count -eq 0 ]; then
    diagnosisResult="SSH 서비스가 실행 중이 아닙니다."
    status="정보 없음"
    echo "INFO: $diagnosisResult" >> $TMP1
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    cat $TMP1
    echo ; echo
    cat $OUTPUT_CSV
    exit 0
fi

# Check SSH configuration files
sshd_config_files=($(find / -name 'sshd_config' -type f 2>/dev/null))

if [ ${#sshd_config_files[@]} -eq 0 ]; then
    diagnosisResult="sshd_config 파일을 찾을 수 없습니다."
    status="정보 없음"
    echo "INFO: $diagnosisResult" >> $TMP1
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    cat $TMP1
    echo ; echo
    cat $OUTPUT_CSV
    exit 0
fi

for sshd_config_file in "${sshd_config_files[@]}"; do
    sshd_permitrootlogin_no_count=$(grep -vE '^#|^\s#' "$sshd_config_file" | grep -i 'PermitRootLogin' | grep -i 'no' | wc -l)
    if [ $sshd_permitrootlogin_no_count -eq 0 ]; then
        diagnosisResult="SSH 서비스를 사용하고, sshd_config 파일에서 root 계정의 원격 접속이 허용되어 있습니다."
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
        echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
        cat $TMP1
        echo ; echo
        cat $OUTPUT_CSV
        exit 0
    fi
done

diagnosisResult="SSH를 통한 root 계정의 원격 접속이 제한된 경우"
status="양호"
echo "OK: $diagnosisResult" >> $TMP1
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
