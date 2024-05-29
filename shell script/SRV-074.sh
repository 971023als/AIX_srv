#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="네트워크 보안"
code="SRV-074"
riskLevel="중"
diagnosisItem="불필요하거나 관리되지 않는 계정 검사"
service="Account Management"
diagnosisResult=""
status=""

BAR

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 불필요하거나 관리되지 않는 계정이 존재하지 않는 경우
[취약]: 불필요하거나 관리되지 않는 계정이 존재하는 경우
EOF

BAR

# Function to append results to CSV file
append_to_csv() {
    local result=$1
    local status=$2
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$result,$status" >> $OUTPUT_CSV
}

if [ -f /etc/passwd ]; then
    # Check for unnecessary accounts
    if [ $(awk -F : '{print $1}' /etc/passwd | grep -wE 'daemon|bin|sys|adm|listen|nobody|nobody4|noaccess|diag|operator|gopher|games|ftp|apache|httpd|www-data|mysql|mariadb|postgres|mail|postfix|news|lp|uucp|nuucp' | wc -l) -gt 0 ]; then
        diagnosisResult="불필요한 계정이 존재합니다."
        status="취약"
        append_to_csv "$diagnosisResult" "$status"
        echo "WARN: $diagnosisResult" >> $TMP1
    else
        diagnosisResult="불필요한 계정이 존재하지 않습니다."
        status="양호"
        append_to_csv "$diagnosisResult" "$status"
        echo "OK: $diagnosisResult" >> $TMP1
    fi
else
    diagnosisResult="패스워드 파일(/etc/passwd)을 찾을 수 없습니다."
    status="정보 없음"
    append_to_csv "$diagnosisResult" "$status"
    echo "INFO: $diagnosisResult" >> $TMP1
fi

if [ -f /etc/group ]; then
    # Check for unnecessary accounts in the root group
    if [ $(awk -F : '$1=="root" {gsub(" ", "", $0); print $4}' /etc/group | awk '{gsub(",","\n",$0); print}' | grep -wE 'daemon|bin|sys|adm|listen|nobody|nobody4|noaccess|diag|operator|gopher|games|ftp|apache|httpd|www-data|mysql|mariadb|postgres|mail|postfix|news|lp|uucp|nuucp' | wc -l) -gt 0 ]; then
        diagnosisResult="관리자 그룹(root)에 불필요한 계정이 등록되어 있습니다."
        status="취약"
        append_to_csv "$diagnosisResult" "$status"
        echo "WARN: $diagnosisResult" >> $TMP1
    else
        diagnosisResult="관리자 그룹(root)에 불필요한 계정이 없습니다."
        status="양호"
        append_to_csv "$diagnosisResult" "$status"
        echo "OK: $diagnosisResult" >> $TMP1
    fi
else
    diagnosisResult="그룹 파일(/etc/group)을 찾을 수 없습니다."
    status="정보 없음"
    append_to_csv "$diagnosisResult" "$status"
    echo "INFO: $diagnosisResult" >> $TMP1
fi

cat $TMP1

echo "CSV report generated: $OUTPUT_CSV"
echo ; echo
cat $OUTPUT_CSV
