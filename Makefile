.PHONY: setup

setup:
	@echo "📦 스크립트 실행 권한 부여 중..."
	chmod +x scripts/*.sh

	@echo "📦 Homebrew 확인 중..."
	@if ! command -v brew >/dev/null 2>&1; then \
		echo "[ERROR] Homebrew가 설치되어 있지 않습니다. https://brew.sh/ 를 참고해 설치해 주세요."; \
		exit 1; \
	fi

	@echo "📦 Lefthook 설치 중..."
	brew list lefthook >/dev/null 2>&1 || brew install lefthook
	lefthook install

	@echo "📦 SwiftLint 설치 중..."
	brew list swiftlint >/dev/null 2>&1 || brew install swiftlint

	@echo "📦 SwiftFormat 설치 중..."
	brew list swiftformat >/dev/null 2>&1 || brew install swiftformat

	@echo "📝 git commit 템플릿 설정 중..."
	git config commit.template .gitmessage.txt

	@echo "✅ 설정 완료! 이제 커밋 시 자동으로 검사됩니다."
