#!/bin/bash

. function.sh

OUTPUT_JSON="output.json"

# Set JSON Headers if the file does not exist
if [ ! -f $OUTPUT_JSON ]; then
    echo "[" > $OUTPUT_JSON
fi

# Initial Values
category="웹 보안"
code="SRV-044"
riskLevel="상"
diagnosisItem="파일 업로드 및 다운로드 크기 제한 검사"
service="Account Management"
diagnosisResult=""
status=""

BAR

CODE="SRV-044"
diagnosisItem="웹 서비스 파일 업로드 및 다운로드 용량 제한 미설정"

# Write initial values to JSON
TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 웹 서비스에서 파일 업로드 및 다운로드 용량이 적절하게 제한된 경우
[취약]: 웹 서비스에서 파일 업로드 및 다운로드 용량이 제한되지 않은 경우
EOF

BAR

webconf_files=(".htaccess" "httpd.conf" "apache2.conf" "userdir.conf")
file_exists_count=0

for webconf_file in "${webconf_files[@]}"; do
    find_webconf_files=($(find / -name "$webconf_file" -type f 2>/dev/null))
    for file in "${find_webconf_files[@]}"; do
        ((file_exists_count++))
        limit_request_body_count=$(grep -vE '^#|^\s#' "$file" | grep -i 'LimitRequestBody' | wc -l)
        if [ $limit_request_body_count -eq 0 ]; then
            diagnosisResult="Apache 설정 파일에 파일 업로드 및 다운로드 용량을 제한하는 설정이 없습니다: $file"
            status="취약"
            echo "WARN: $diagnosisResult" >> $TMP1
            if [ $(wc -l < $OUTPUT_JSON) -eq 1 ]; then
                echo "{\"category\":\"$category\",\"code\":\"$code\",\"riskLevel\":\"$riskLevel\",\"diagnosisItem\":\"$diagnosisItem\",\"service\":\"$service\",\"diagnosisResult\":\"$diagnosisResult\",\"status\":\"$status\"}" >> $OUTPUT_JSON
            else
                echo ",{\"category\":\"$category\",\"code\":\"$code\",\"riskLevel\":\"$riskLevel\",\"diagnosisItem\":\"$diagnosisItem\",\"service\":\"$service\",\"diagnosisResult\":\"$diagnosisResult\",\"status\":\"$status\"}" >> $OUTPUT_JSON
            fi
            cat $TMP1
            echo ; echo
            exit 0
        fi
    done
done

if [ $file_exists_count -eq 0 ]; then
    diagnosisResult="Apache 설정 파일을 찾을 수 없습니다."
    status="정보 없음"
    echo "INFO: $diagnosisResult" >> $TMP1
    if [ $(wc -l < $OUTPUT_JSON) -eq 1 ]; then
        echo "{\"category\":\"$category\",\"code\":\"$code\",\"riskLevel\":\"$riskLevel\",\"diagnosisItem\":\"$diagnosisItem\",\"service\":\"$service\",\"diagnosisResult\":\"$diagnosisResult\",\"status\":\"$status\"}" >> $OUTPUT_JSON
    else
        echo ",{\"category\":\"$category\",\"code\":\"$code\",\"riskLevel\":\"$riskLevel\",\"diagnosisItem\":\"$diagnosisItem\",\"service\":\"$service\",\"diagnosisResult\":\"$diagnosisResult\",\"status\":\"$status\"}" >> $OUTPUT_JSON
    fi
else
    diagnosisResult="웹 서비스에서 파일 업로드 및 다운로드 용량이 적절하게 제한된 경우"
    status="양호"
    echo "OK: $diagnosisResult" >> $TMP1
    if [ $(wc -l < $OUTPUT_JSON) -eq 1 ]; then
        echo "{\"category\":\"$category\",\"code\":\"$code\",\"riskLevel\":\"$riskLevel\",\"diagnosisItem\":\"$diagnosisItem\",\"service\":\"$service\",\"diagnosisResult\":\"$diagnosisResult\",\"status\":\"$status\"}" >> $OUTPUT_JSON
    else
        echo ",{\"category\":\"$category\",\"code\":\"$code\",\"riskLevel\":\"$riskLevel\",\"diagnosisItem\":\"$diagnosisItem\",\"service\":\"$service\",\"diagnosisResult\":\"$diagnosisResult\",\"status\":\"$status\"}" >> $OUTPUT_JSON
    fi
fi

cat $TMP1

echo ; echo

echo "]" >> $OUTPUT_JSON

cat $OUTPUT_JSON
