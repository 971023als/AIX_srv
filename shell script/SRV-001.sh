#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="보안관리"
code="SRV-001"
riskLevel="상"
diagnosisItem="SNMP Community 스트링 검사"
service="SNMP"
diagnosisResult=""
status=""

BAR

diagnosisItem="SNMP 서비스 Get Community 스트링 설정 오류"

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

# Temporary log file
TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: SNMP Community 스트링이 "public" 또는 "private"이 아닌 경우
[취약]: SNMP Community 스트링이 "public" 또는 "private"인 경우
EOF

BAR

# Check if SNMP service is running
ps_snmp_count=$(ps -ef | grep -i 'snmp' | grep -v 'grep' | wc -l)

if [ $ps_snmp_count -gt 0 ]; then
    # Check SNMP configuration file for Community string
    snmpdconf_file="/etc/snmpdv3.conf" # Default path for AIX; might need adjustment for other OS
    if [ -f "$snmpdconf_file" ]; then
        # Check if "public" or "private" strings are present
        if grep -qiE 'public|private' $snmpdconf_file; then
            diagnosisResult="기본 SNMP Community 스트링(public/private)이 사용됨"
            status="취약"
        else
            diagnosisResult="기본 SNMP Community 스트링(public/private)이 사용되지 않음"
            status="양호"
        fi
    else
        diagnosisResult="SNMP 구성 파일($snmpdconf_file)을 찾을 수 없음"
        status="취약"
    fi
else
    diagnosisResult="SNMP 서비스가 실행 중이지 않습니다."
    status="양호"
fi

# Write the result to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

BAR

cat $TMP1
echo ; echo
cat $OUTPUT_CSV
