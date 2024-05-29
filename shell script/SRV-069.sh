#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="네트워크 보안"
code="SRV-069"
riskLevel="중"
diagnosisItem="비밀번호 관리정책 설정 미비"
service="Account Management"
diagnosisResult=""
status=""

BAR

CODE="SRV-069"
diagnosisItem="비밀번호 관리정책 설정 미비"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 비밀번호 관리정책이 적절하게 설정된 경우
[취약]: 비밀번호 관리정책이 설정되지 않은 경우
EOF

BAR

check_password_policy() {
    local file_path=$1
    local setting_type=$2
    local setting_name=$3
    local min_value=$4
    local message=$5

    if [ -f "$file_path" ]; then
        ((file_exists_count++))
        local setting_count
        local setting_value
        case $setting_type in
            "minlen")
                setting_count=$(grep -vE '^#|^\s#' "$file_path" | grep -i "$setting_name" | wc -l)
                if [ $setting_count -gt 0 ]; then
                    setting_value=$(grep -vE '^#|^\s#' "$file_path" | grep -i "$setting_name" | awk '{print $2}')
                    if [ $setting_value -lt $min_value ]; then
                        diagnosisResult="$message"
                        status="취약"
                        echo "WARN: $diagnosisResult" >> $TMP1
                        echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
                    fi
                fi
                ;;
            "mininput")
                setting_count=$(grep -vE '^#|^\s#' "$file_path" | grep -i "$setting_name" | wc -l)
                if [ $setting_count -gt 0 ]; then
                    setting_value=$(grep -vE '^#|^\s#' "$file_path" | grep -i "$setting_name" | awk '{print $2}')
                    if [ $setting_value -lt $min_value ]; then
                        diagnosisResult="$message"
                        status="취약"
                        echo "WARN: $diagnosisResult" >> $TMP1
                        echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
                    fi
                fi
                ;;
        esac
    fi
}

# Check password policies
check_password_policy "/etc/login.defs" "minlen" "PASS_MIN_LEN" 8 "패스워드 최소 길이가 8 미만으로 설정되어 있습니다."

for file in "/etc/pam.d/system-auth" "/etc/pam.d/password-auth"; do
    for module in "pam_pwquality.so" "pam_cracklib.so" "pam_unix.so"; do
        check_password_policy "$file" "minlen" "minlen" 8 "패스워드 최소 길이가 8 미만으로 설정되어 있습니다."
        for option in "lcredit" "ucredit" "dcredit" "ocredit"; do
            check_password_policy "$file" "mininput" "$option" 1 "패스워드의 영문, 숫자, 특수문자의 최소 입력이 1 미만으로 설정되어 있습니다."
        done
    done
done

check_password_policy "/etc/security/pwquality.conf" "minlen" "minlen" 8 "패스워드 최소 길이가 8 미만으로 설정되어 있습니다."
for option in "lcredit" "ucredit" "dcredit" "ocredit"; do
    check_password_policy "/etc/security/pwquality.conf" "mininput" "$option" 1 "패스워드의 영문, 숫자, 특수문자의 최소 입력이 1 미만으로 설정되어 있습니다."
done

# Check password maximum age
if [ -f /etc/login.defs ]; then
    max_days=$(grep -vE '^#|^\s#' /etc/login.defs | grep -i 'PASS_MAX_DAYS' | awk '{print $2}')
    if [ -n "$max_days" ]; then
        if [ "$max_days" -gt 90 ]; then
            diagnosisResult="패스워드 최대 사용 기간이 91일 이상으로 설정되어 있습니다."
            status="취약"
            echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
        else
            diagnosisResult="패스워드 최대 사용 기간이 적절하게 설정되어 있습니다."
            status="양호"
            echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
        fi
    else
        diagnosisResult="패스워드 최대 사용 기간이 설정되어 있지 않습니다."
        status="취약"
        echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    fi
else
    diagnosisResult="/etc/login.defs 파일이 없습니다."
    status="취약"
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

# Check password minimum age
if [ -f /etc/login.defs ]; then
    min_days=$(grep -vE '^#|^\s#' /etc/login.defs | grep -i 'PASS_MIN_DAYS' | awk '{print $2}')
    if [ -n "$min_days" ]; then
        if [ "$min_days" -lt 1 ]; then
            diagnosisResult="패스워드 최소 사용 기간이 1일 미만으로 설정되어 있습니다."
            status="취약"
            echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
        else
            diagnosisResult="패스워드 최소 사용 기간이 적절하게 설정되어 있습니다."
            status="양호"
            echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
        fi
    else
        diagnosisResult="패스워드 최소 사용 기간이 설정되어 있지 않습니다."
        status="취약"
        echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    fi
else
    diagnosisResult="/etc/login.defs 파일이 없습니다."
    status="취약"
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

# Check shadow password usage
if [ $(awk -F : '$2!="x"' /etc/passwd | wc -l) -gt 0 ]; then
    diagnosisResult="쉐도우 패스워드를 사용하고 있지 않습니다."
    status="취약"
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
else
    diagnosisResult="쉐도우 패스워드를 사용하고 있습니다."
    status="양호"
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

cat $TMP1
echo ; echo
cat $OUTPUT_CSV

exit 0
