# 🚀 Saboteur

![배너 이미지 또는 로고](링크)

> Saboteur는 P2P 기반 실시간 보드게임을 위한 iOS 앱입니다.

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)]()
[![Xcode](https://img.shields.io/badge/Xcode-15.0-blue.svg)]()
[![License](https://img.shields.io/badge/license-MIT-green.svg)]()

---

## 🗂 목차
- [🚀 Saboteur](#-saboteur)
  - [🗂 목차](#-목차)
  - [소개](#소개)
  - [🧱 폴더 구조](#-폴더-구조)
  - [🧑‍💻 팀 소개](#-팀-소개)
  - [🔖 브랜치 전략](#-브랜치-전략)
  - [🌀 커밋 메시지 컨벤션](#-커밋-메시지-컨벤션)
    - [커밋 메시지 예시](#커밋-메시지-예시)
  - [🛠️ 프로젝트 환경 세팅](#️-프로젝트-환경-세팅)
  - [📝 License](#-license)

---

## 소개

Saboteur는 SwiftUI 기반의 P2P 보드게임 앱입니다. 주요 기능 및 기술 스택, 프로젝트 기간 등은 추후 업데이트 예정입니다.

## 🧱 폴더 구조

```
📦Saboteur
┣ 📂App           # 앱 진입점 및 코디네이터
┣ 📂Assets.xcassets # 리소스(이미지, 색상 등)
┣ 📂Config         # 환경설정 및 설정 파일
┣ 📂Core           # 핵심 로직(모델, 네트워크, 영속성, 유틸)
┣ 📂Features       # 주요 기능별 모듈(Lobby, GamePlay, Profile)
```

- **App**: 앱 실행, 루트 코디네이터 등 진입점 관리
- **Assets.xcassets**: 앱 리소스(이미지, 색상 등)
- **Config**: 환경설정 및 설정 파일
- **Core**: 공통 모델, 네트워크, 데이터, 유틸리티 등 핵심 로직
- **Features**: Lobby, GamePlay, Profile 등 주요 기능별 화면 및 로직 분리

## 🧑‍💻 팀 소개

| [니케](https://github.com/pngxlols)<br>iOS Developer | [바바](https://github.com/Winnerkorea)<br>iOS Developer | [비에라](https://github.com/photokcw)<br>디자이너 | [스카이](https://github.com/SKY-Choi)<br>디자이너 | [주디제이](https://github.com/JUDYLEE-cloud)<br>iOS Developer | [커비](https://github.com/bisor0627)<br>iOS Developer |
|:---:|:---:|:---:|:---:|:---:|:---:|
| <img src="https://github.com/pngxlols.png" width="100" height="100" alt="니케" style="border-radius:50%"/> | <img src="https://github.com/Winnerkorea.png" width="100" height="100" alt="바바" style="border-radius:50%"/> | <img src="https://github.com/photokcw.png" width="100" height="100" alt="비에라" style="border-radius:50%"/> | <img src="https://github.com/SKY-Choi.png" width="100" height="100" alt="스카이" style="border-radius:50%"/> | <img src="https://github.com/JUDYLEE-cloud.png" width="100" height="100" alt="주디제이" style="border-radius:50%"/> | <img src="https://github.com/bisor0627.png" width="100" height="100" alt="커비" style="border-radius:50%"/> |


## 🔖 브랜치 전략

- `main`, `develop` 브랜치에는 **직접 push 및 강제 push가 금지**되어 있습니다.
- 모든 변경 사항은 **Pull Request(PR)**를 통해서만 병합할 수 있습니다.
- PR은 최소 1인 이상의 리뷰 승인 후 병합 가능합니다.
- 병합 방식은 Merge, Squash, Rebase 모두 허용됩니다.
- 기능 개발, 버그 수정 등은 `feature/`, `bugfix/`, `hotfix/` 등 별도 브랜치에서 자유롭게 작업할 수 있습니다.
- 자세한 정책은 [main/develop 브랜치 직접 push 금지 안내](https://github.com/DeveloperAcademy-POSTECH/2025-C4-M4-Connectivity/wiki/%F0%9F%9A%AB-main---develop-%EB%B8%8C%EB%9E%9C%EC%B9%98%EC%97%90-%EC%A7%81%EC%A0%91-push-%EA%B8%88%EC%A7%80-%EC%95%88%EB%82%B4) 참고

## 🌀 커밋 메시지 컨벤션

- 커밋 메시지는 **Gitmoji + Type + 요약 설명** 형식을 사용합니다.
  - 예시: `✨ Feat. 로그인 화면 UI 구현`
- Type(대문자): `Feat.`, `Fix.`, `Refactor.`, `Docs.`, `Test.`, `Chore.`, `CI.`, `Release.` 등
- 커밋 메시지 템플릿이 자동 적용되며, 커밋 시 자동으로 포맷과 규칙이 검사됩니다.
- 커밋 예시 및 상세 규칙은 [macOS 협업 환경 및 커밋 컨벤션 가이드](https://github.com/DeveloperAcademy-POSTECH/2025-C4-M4-Connectivity/wiki/macOS-%ED%98%91%EC%97%85-%ED%99%98%EA%B2%BD-%EB%B0%8F-%EC%BB%A4%EB%B0%8B-%EC%BB%A8%EB%B2%A4%EC%85%98-%EA%B0%80%EC%9D%B4%EB%93%9C) 참고

### 커밋 메시지 예시

```text
✨ Feat. 로그인 화면 UI 구현
🐛 Fix. 로그인 실패 시 Alert 표시
♻️ Refactor. DateFormatter 인스턴스 개선
```

> 커밋 메시지에 대한 자동 검사 및 템플릿 적용은 프로젝트에 이미 설정되어 있습니다.

## 🛠️ 프로젝트 환경 세팅

최초 클론 후 아래 명령어로 개발 환경을 자동으로 세팅하세요:

```bash
make setup
```

- 스크립트 실행 권한, Homebrew, Lefthook, SwiftLint, SwiftFormat 설치 및 git commit 템플릿 설정이 자동으로 진행됩니다.
- 커밋 시 자동 검사 및 포맷팅이 적용됩니다.

## 📝 License

<!--
This project is licensed under the ~~[CHOOSE A LICENSE](https://choosealicense.com). and update this line~~
-->
