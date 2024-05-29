#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="웹 보안"
code="SRV-047"
riskLevel="상"
diagnosisItem="웹 서비스 경로 내 불필요한 링크 파일 검사"
service="Web Server"
diagnosisResult=""
status=""

BAR

CODE="SRV-047"
diagnosisItem="웹 서비스 경로 내 불필요한 링크 파일 검사"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 웹 서비스 경로 내 불필요한 심볼릭 링크 파일이 존재하지 않는 경우
[취약]: 웹 서비스 경로 내 불필요한 심볼릭 링크 파일이 존재하는 경우
EOF

BAR

webconf_files=(".htaccess" "httpd.conf" "apache2.conf" "userdir.conf")
file_exists_count=0

check_symlinks() {
    local file=$1
    if [[ $file =~ userdir.conf ]]; then
        local userdir_disabled_count=$(grep -vE '^#|^\s#' "$file" | grep -i 'userdir' | grep -i 'disabled' | wc -l)
        if [ $userdir_disabled_count -eq 0 ]; then
            local userdir_followsymlinks_count=$(grep -vE '^#|^\s#' "$file" | grep -i 'Options' | grep -iv '\-FollowSymLinks' | grep -i 'FollowSymLinks' | wc -l)
            if [ $userdir_followsymlinks_count -gt 0 ]; then
                diagnosisResult="Apache 설정 파일 $file 에 심볼릭 링크 사용을 제한하도록 설정하지 않았습니다."
                status="취약"
                echo "WARN: $diagnosisResult" >> $TMP1
                echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
                cat $TMP1
                echo ; echo
                exit 0
            fi
        fi
    else
        local followsymlinks_count=$(grep -vE '^#|^\s#' "$file" | grep -i 'Options' | grep -iv '\-FollowSymLinks' | grep -i 'FollowSymLinks' | wc -l)
        if [ $followsymlinks_count -gt 0 ]; then
            diagnosisResult="Apache 설정 파일 $file 에 심볼릭 링크 사용을 제한하도록 설정하지 않았습니다."
            status="취약"
            echo "WARN: $diagnosisResult" >> $TMP1
            echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
            cat $TMP1
            echo ; echo
            exit 0
        fi
    fi
}

for webconf_file in "${webconf_files[@]}"; do
    find_webconf_files=($(find / -name "$webconf_file" -type f 2>/dev/null))
    for file in "${find_webconf_files[@]}"; do
        ((file_exists_count++))
        check_symlinks "$file"
    done
done

if [ $file_exists_count -eq 0 ]; then
    diagnosisResult="웹 서비스 설정 파일을 찾을 수 없습니다."
    status="정보 없음"
    echo "INFO: $diagnosisResult" >> $TMP1
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
else
    diagnosisResult="웹 서비스 경로 내 불필요한 심볼릭 링크 파일이 존재하지 않는 경우"
    status="양호"
    echo "OK: $diagnosisResult" >> $TMP1
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

cat $TMP1

echo ; echo

cat $OUTPUT_CSV

exit 0
