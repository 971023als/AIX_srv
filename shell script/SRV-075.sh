#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="계정 보안"
code="SRV-075"
riskLevel="중"
diagnosisItem="비밀번호 정책 감사"
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
[양호]: 암호 정책이 강력하게 설정되어 있는 경우
[취약]: 암호 정책이 약하게 설정되어 있는 경우
EOF

BAR

# Function to append results to CSV file
append_to_csv() {
    local result=$1
    local status=$2
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$result,$status" >> $OUTPUT_CSV
}

# Variables initialization
file_exists_count=0
minlen_file_exists_count=0
no_settings_in_minlen_file=0
mininput_file_exists_count=0
no_settings_in_mininput_file=0
input_options=("lcredit" "ucredit" "dcredit" "ocredit")
input_modules=("pam_pwquality.so" "pam_cracklib.so" "pam_unix.so")

# Password policy check function
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
                ((minlen_file_exists_count++))
                setting_count=$(grep -vE '^#|^\s#' $file_path | grep -i $setting_name | wc -l)
                if [ $setting_count -gt 0 ]; then
                    setting_value=$(grep -vE '^#|^\s#' $file_path | grep -i $setting_name | awk '{print $2}')
                    if [ $setting_value -lt $min_value ]; then
                        append_to_csv "$file_path 파일에 $message" "취약"
                    fi
                else
                    ((no_settings_in_minlen_file++))
                fi
                ;;
            "mininput")
                ((mininput_file_exists_count++))
                setting_count=$(grep -vE '^#|^\s#' $file_path | grep -i $setting_name | wc -l)
                if [ $setting_count -gt 0 ]; then
                    setting_value=$(grep -vE '^#|^\s#' $file_path | grep -i $setting_name | awk '{print $2}')
                    if [ $setting_value -lt $min_value ]; then
                        append_to_csv "$file_path 파일에 $message" "취약"
                    fi
                else
                    ((no_settings_in_mininput_file++))
                fi
                ;;
        esac
    fi
}

# Check password policy settings
check_password_policy "/etc/security/login.cfg" "minlen" "minalpha" 8 "패스워드 최소 길이가 8 미만으로 설정되어 있습니다."
for file in "/etc/security/user"; do
    for module in "${input_modules[@]}"; do
        check_password_policy "$file" "minlen" "minlen" 8 "패스워드 최소 길이가 8 미만으로 설정되어 있습니다."
        for option in "${input_options[@]}"; do
            check_password_policy "$file" "mininput" "$option" 1 "패스워드의 영문, 숫자, 특수문자의 최소 입력이 1 미만으로 설정되어 있습니다."
        done
    done
done
check_password_policy "/etc/security/pwquality.conf" "minlen" "minlen" 8 "패스워드 최소 길이가 8 미만으로 설정되어 있습니다."
for option in "${input_options[@]}"; do
    check_password_policy "/etc/security/pwquality.conf" "mininput" "$option" 1 "패스워드의 영문, 숫자, 특수문자의 최소 입력이 1 미만으로 설정되어 있습니다."
done

# Check password maximum usage period
if [ -f /etc/security/user ]; then
    etc_security_user_maxdays_count=$(grep -vE '^#|^\s#' /etc/security/user | grep -i 'maxage' | awk '{print $3}' | wc -l)
    if [ $etc_security_user_maxdays_count -gt 0 ]; then
        etc_security_user_maxdays_value=$(grep -vE '^#|^\s#' /etc/security/user | grep -i 'maxage' | awk '{print $3}')
        if [ $etc_security_user_maxdays_value -gt 90 ]; then
            append_to_csv "/etc/security/user 파일에 패스워드 최대 사용 기간이 91일 이상으로 설정되어 있습니다." "취약"
        else
            append_to_csv "패스워드 최대 사용 기간이 적절하게 설정되어 있습니다." "양호"
        fi
    else
        append_to_csv "/etc/security/user 파일에 패스워드 최대 사용 기간이 설정되어 있지 않습니다." "취약"
    fi
else
    append_to_csv "/etc/security/user 파일이 없습니다." "취약"
fi

# Check password minimum usage period
if [ -f /etc/security/user ]; then
    etc_security_user_mindays_count=$(grep -vE '^#|^\s#' /etc/security/user | grep -i 'minage' | awk '{print $3}' | wc -l)
    if [ $etc_security_user_mindays_count -gt 0 ]; then
        etc_security_user_mindays_value=$(grep -vE '^#|^\s#' /etc/security/user | grep -i 'minage' | awk '{print $3}')
        if [ $etc_security_user_mindays_value -lt 1 ]; then
            append_to_csv "/etc/security/user 파일에 패스워드 최소 사용 기간이 1일 미만으로 설정되어 있습니다." "취약"
        else
            append_to_csv "패스워드 최소 사용 기간이 적절하게 설정되어 있습니다." "양호"
        fi
    else
        append_to_csv "/etc/security/user 파일에 패스워드 최소 사용 기간이 설정되어 있지 않습니다." "취약"
    fi
else
    append_to_csv "/etc/security/user 파일이 없습니다." "취약"
fi

# Check for shadow password usage
if [ $(awk -F : '$2!="!"' /etc/passwd | wc -l) -gt 0 ]; then
    append_to_csv "쉐도우 패스워드를 사용하고 있지 않습니다." "취약"
else
    append_to_csv "쉐도우 패스워드를 사용하고 있습니다." "양호"
fi

cat $TMP1

echo "CSV report generated: $OUTPUT_CSV"
echo ; echo
cat $OUTPUT_CSV
