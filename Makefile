.PHONY: setup

setup:
	@echo "📦 스크립트 실행 권한 부여 중..."
	chmod +x scripts/*.sh

	@echo "📦 Lefthook 설치 중..."
	brew list lefthook >/dev/null 2>&1 || brew install lefthook
	lefthook install

	@echo "📝 git commit 템플릿 설정 중..."
	git config commit.template .gitmessage.txt

	@echo "✅ 설정 완료! 이제 커밋 시 자동으로 검사됩니다."
