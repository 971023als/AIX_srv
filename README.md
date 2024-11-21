# 전자금융기반시설 인프라 진단 프로젝트

## 프로젝트 개요
전자금융기반시설의 안정성과 보안성을 확보하기 위해 AIX 환경에서 인프라 진단을 수행합니다. 주요 목표는 시스템의 구성 요소를 분석하고 보안 취약점을 식별하며, 개선 권고사항을 제공하여 안정적인 운영 환경을 구축하는 것입니다.

---

## 프로젝트 목표
- 전자금융기반시설의 인프라 구성 진단
- AIX 서버의 보안 취약점 식별
- 성능 최적화 및 안정성 확보
- 개선 사항 및 대응 방안 제시

---

## 진단 범위
1. **운영체제 (AIX)**
   - AIX 버전 및 패치 상태 확인
   - 사용자 계정 및 권한 설정 진단
   - 로그 및 감사 설정 확인

2. **네트워크**
   - 방화벽 설정 점검
   - 주요 포트 및 서비스 상태 진단
   - 네트워크 트래픽 분석

3. **애플리케이션**
   - 주요 애플리케이션 구성 및 설정 확인
   - 데이터베이스 접근 보안 점검

4. **하드웨어**
   - CPU, 메모리, 디스크 사용량 진단
   - 하드웨어 에러 로그 분석

---

## 진단 절차
1. **사전 준비**
   - AIX 서버에 대한 접근 권한 확보
   - 진단 도구 및 스크립트 준비
   - 대상 서버 목록 및 진단 스코프 확정

2. **데이터 수집**
   - 시스템 정보 수집 (`uname`, `oslevel` 명령 등)
   - 계정 및 권한 정보 수집 (`lsuser`, `passwd` 명령 등)
   - 로그 및 설정 파일 수집

3. **분석 및 평가**
   - 수집된 데이터를 바탕으로 구성 및 취약점 분석
   - AIX 보안 가이드라인과 비교하여 격차 분석

4. **결과 보고**
   - 취약점 및 문제점 요약
   - 개선 방안 제안 및 우선순위 설정
   - 최종 보고서 작성

---

## 사용 도구
- **AIX 기본 명령어**: `oslevel`, `lsuser`, `netstat`, `errpt` 등
- **스크립트**: 진단 스크립트 (Shell, Python 기반)
- **분석 도구**: Log 분석 도구, 네트워크 스니퍼 등

---

## 결과물
- **취약점 보고
