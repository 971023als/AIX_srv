#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
CATEGORY="시스템 보안"
CODE="SRV-116"
RISK_LEVEL="고"
DIAGNOSIS_ITEM="보안 감사를 수행할 수 없는 경우, 즉시 시스템 종료 설정 미흡"
SERVICE="시스템 로깅"
DiagnosisResult=""
Status=""

BAR

# Write initial values to CSV
echo "$CATEGORY,$CODE,$RISK_LEVEL,$DIAGNOSIS_ITEM,$SERVICE,$DiagnosisResult,$Status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 보안 감사 실패 시 시스템이 즉시 종료되도록 설정된 경우
[취약]: 보안 감사 실패 시 시스템이 즉시 종료되지 않도록 설정된 경우
EOF

BAR

# Function to append results to CSV file
append_to_csv() {
    local result=$1
    local status=$2
    echo "$CATEGORY,$CODE,$RISK_LEVEL,$DIAGNOSIS_ITEM,$SERVICE,$result,$status" >> $OUTPUT_CSV
}

# Check auditd configuration for shutdown settings on audit failure
audit_setting=$(grep -i "space_left_action" /etc/security/audit/config)
action_setting=$(grep -i "action_mail_acct" /etc/security/audit/config)
admin_mail=$(grep -i "admin_space_left_action" /etc/security/audit/config)

if [[ "$audit_setting" == *"halt"* ]]; then
  if [[ "$action_setting" == *"root"* ]] && [[ "$admin_mail" == *"halt"* ]]; then
    DiagnosisResult="보안 감사 실패 시 시스템이 즉시 종료되도록 설정됨"
    Status="양호"
  else
    DiagnosisResult="보안 감사 실패 시 시스템이 즉시 종료되지 않도록 설정됨"
    Status="취약"
  fi
else
  DiagnosisResult="보안 감사 실패 시 시스템이 즉시 종료되지 않도록 설정됨"
  Status="취약"
fi

append_to_csv "$DiagnosisResult" "$Status"
echo "INFO: $DiagnosisResult" >> $TMP1

cat $TMP1

echo ; echo

cat $OUTPUT_CSV

echo "CSV report generated: $OUTPUT_CSV"
echo ; echo
