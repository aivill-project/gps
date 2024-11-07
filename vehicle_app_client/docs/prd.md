# **차량 위치 추적 기능 개발 PRD**

## **1. 프로젝트 개요**

본 프로젝트는 학생들의 안전한 통학을 위한 **차량 위치 추적 및 승하차 관리 시스템**을 개발하는 것입니다. 사용자는 간단하고 직관적인 UI를 통해 차량 등록, 정보 조회 및 수정, 실시간 위치 추적, 학생 승하차 관리 등을 수행할 수 있습니다.

## **2. 유저 플로우**

1. **차량 등록**
    - 관리자가 새로운 차량을 이미지와 함께 등록합니다.
2. **차량 정보 조회 및 관리**
    - 등록된 차량의 정보를 조회, 수정 또는 삭제합니다.
3. **운행 시작**
    - 운전자가 운행을 시작하면 시스템에 알림이 전송됩니다.
    - WebSocket을 통해 차량의 실시간 위치가 업데이트됩니다.
4. **학생 승차 관리**
    - 학생들이 차량에 승차하면 시스템에 등록됩니다.
    - 현재 승차 중인 학생 목록을 조회할 수 있습니다.
5. **운행 종료**
    - 운전자가 운행을 종료하면 시스템에 알림이 전송되고, 해당 운행에 대한 데이터가 저장됩니다.

## **3. 핵심 기능**

### **3.1 차량 관리**

- **차량 등록**
    - 이미지 업로드 기능 포함.
    - 차량 번호, 모델명, 좌석 수 등의 정보 입력.
- **차량 정보 조회**
    - 등록된 차량 목록 및 상세 정보 조회.
- **차량 정보 수정 및 삭제**
    - 기존 차량의 정보 수정 및 삭제 기능.

### **3.2 운행 관리**

- **운행 시작 및 종료 알림**
    - 운전자가 운행 시작/종료 시 시스템에 알림 전송.
- **실시간 위치 추적**
    - WebSocket을 이용하여 차량의 위치를 실시간으로 업데이트 및 표시.

### **3.3 학생 승하차 관리**

- **승차 처리**
    - 학생의 승차 시 태그 또는 앱을 통해 승차 처리.
- **하차 처리**
    - 학생의 하차 시 태그 또는 앱을 통해 하차 처리.
- **현재 승차 중인 학생 목록 조회**
    - 실시간으로 현재 차량에 승차 중인 학생들의 목록 조회.

## **4. 기술 스택**

### **프론트엔드**

- **Flutter**
    - 단일 코드베이스로 iOS와 Android 지원.
    - 직관적이고 심플한 UI 구현에 적합.
- **추가 라이브러리**
    - **Provider** 또는 **Bloc**: 상태 관리.
    - **WebSocket 통신 라이브러리**: 실시간 통신 구현.

### **백엔드**

- **Node.js (Express)**
    - RESTful API 구축.
    - WebSocket 통신을 위한 **Socket.IO** 활용.
- **데이터베이스**
    - **MySQL**
        - 관계형 데이터 관리.
- **추가 기술**
    - **Sequelize**: ORM(Object-Relational Mapping)으로 MySQL 연동.
    - **Multer**: 이미지 업로드 기능 구현.
    - **JWT(Json Web Token)**: 인증 및 보안.

### **기타**

- **실시간 위치 추적**
    - **Google Maps API** 또는 **Mapbox**: 지도 서비스 제공.
- **학생 승하차 관리**
    - **QR 코드 스캐닝** 또는 **NFC**: 승하차 시 편의성 제공.

## **5. 개발 이후 추가 개선사항**

- **알림 기능 강화**
    - 학부모에게 푸시 알림으로 학생의 승하차 정보 제공.
- **AI 분석**
    - 운행 데이터 분석을 통한 최적 경로 추천.
- **관리자 대시보드**
    - 운행 통계, 차량 및 학생 관리의 효율성 증대.
- **다국어 지원**
    - 다양한 언어로의 서비스 확장.
- **오프라인 모드**
    - 네트워크 불안정 시에도 데이터 저장 및 동기화 기능.