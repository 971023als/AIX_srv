#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="웹 보안"
code="SRV-045"
riskLevel="중"
diagnosisItem="웹 서비스 프로세스 권한 제한 미비"
service="Web Service"
diagnosisResult=""
status=""

BAR

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 웹 서비스 프로세스가 root 권한으로 실행되지 않는 경우
[취약]: 웹 서비스 프로세스가 root 권한으로 실행되는 경우
EOF

BAR

webconf_files=(".htaccess" "httpd.conf" "apache2.conf" "userdir.conf")
file_exists_count=0

for webconf_file in "${webconf_files[@]}"; do
    find_webconf_files=($(find / -name "$webconf_file" -type f 2>/dev/null))
    for file in "${find_webconf_files[@]}"; do
        ((file_exists_count++))
        webconf_file_group_root_count=$(grep -vE '^#|^\s#' "$file" | grep -B 1 '^\s*Group' | grep 'root' | wc -l)
        
        if [ $webconf_file_group_root_count -gt 0 ]; then
            diagnosisResult="Apache 데몬이 root 권한으로 구동되도록 설정되어 있습니다: $file"
            status="취약"
            echo "WARN: $diagnosisResult" >> $TMP1
            echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
            cat $TMP1
            echo ; echo
            exit 0
        else
            webconf_file_group=$(grep -vE '^#|^\s#' "$file" | grep '^\s*Group' | awk '{print $2}' | sed 's/{//' | sed 's/}//')
            
            if [ -n "$webconf_file_group" ]; then
                webconf_file_group_root_count=$(echo "$webconf_file_group" | grep 'root' | wc -l)
                
                if [ $webconf_file_group_root_count -gt 0 ]; then
                    diagnosisResult="Apache 데몬이 root 권한으로 구동되도록 설정되어 있습니다: $file"
                    status="취약"
                    echo "WARN: $diagnosisResult" >> $TMP1
                    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
                    cat $TMP1
                    echo ; echo
                    exit 0
                fi
            fi
        fi
    done
done

if [ $file_exists_count -eq 0 ]; then
    diagnosisResult="Apache 설정 파일을 찾을 수 없습니다."
    status="정보 없음"
    echo "INFO: $diagnosisResult" >> $TMP1
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
else
    diagnosisResult="Apache 데몬이 root 권한으로 구동되지 않습니다."
    status="양호"
    echo "OK: $diagnosisResult" >> $TMP1
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

cat $TMP1

echo ; echo

cat $OUTPUT_CSV

exit 0
