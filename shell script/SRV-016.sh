#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="시스템 보안"
code="SRV-016"
riskLevel="높음"
diagnosisItem="불필요한 RPC 서비스 활성화 상태 검사"
service="RPC"
diagnosisResult=""
status=""

BAR

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 불필요한 RPC 서비스가 비활성화 되어 있는 경우
[취약]: 불필요한 RPC 서비스가 활성화 되어 있는 경우
EOF

BAR

# RPC 관련 서비스 목록
rpc_services=("rpc.cmsd" "rpc.ttdbserverd" "sadmind" "rusersd" "walld" "sprayd" "rstatd" "rpc.nisd" "rexd" "rpc.pcnfsd" "rpc.statd" "rpc.ypupdated" "rpc.rquotad" "kcms_server" "cachefsd")

# Check in /etc/inetd.conf
if [ -f /etc/inetd.conf ]; then
    for service in "${rpc_services[@]}"; do
        etc_inetdconf_rpcservice_enable_count=$(grep -vE '^#|^\s#' /etc/inetd.conf | grep -w $service | wc -l)
        if [ $etc_inetdconf_rpcservice_enable_count -gt 0 ]; then
            diagnosisResult="불필요한 RPC 서비스가 /etc/inetd.conf 파일에서 실행 중입니다. ($service)"
            status="취약"
            echo "WARN: $diagnosisResult" >> $TMP1
            echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
            cat $TMP1
            echo ; echo
            exit 0
        fi
    done
fi

# Check if rpcinfo command is available
if command -v rpcinfo > /dev/null 2>&1; then
    for service in "${rpc_services[@]}"; do
        rpcinfo -p | grep -q $service
        if [ $? -eq 0 ]; then
            diagnosisResult="불필요한 RPC 서비스가 rpcinfo 명령어 결과에서 활성화 되어 있습니다. ($service)"
            status="취약"
            echo "WARN: $diagnosisResult" >> $TMP1
            echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
            cat $TMP1
            echo ; echo
            exit 0
        fi
    done
fi

diagnosisResult="불필요한 RPC 서비스가 비활성화 되어 있는 경우"
status="양호"
echo "OK: $diagnosisResult" >> $TMP1
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

cat $TMP1
echo ; echo

cat $OUTPUT_CSV
