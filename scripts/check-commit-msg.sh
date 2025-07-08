#!/usr/bin/env bash
set -eu

COMMIT_MSG_FILE=$1
COMMIT_MSG=$(tr -d '\r' < "$COMMIT_MSG_FILE")     # CR 제거
TITLE=$(printf '%s\n' "$COMMIT_MSG" | head -n 1)  # 제목 추출

# ✅ 예외 커밋 (머지 커밋·README 수정 등)
if grep -Eq "^(Merge pull request|README\.md 업데이트)" <<<"$TITLE"; then
  exit 0
fi

# ✅ 제목 정규식 (Gitmoji + 공백 → Type. → 공백 → 요약)
#    - Gitmoji 블록: 공백 전까지 임의 길이, 전부 비공백
TITLE_REGEX='^([^[:space:]]+\s+)?[A-Z][a-zA-Z]+\.\s+.+'

if ! grep -Eq "$TITLE_REGEX" <<<"$TITLE"; then
  cat <<EOF
❌ 제목 형식 오류:
👉 제목은 '(Gitmoji␠)Type.␠요약' 형식이어야 합니다.
   예) '♻️ Refactor. DateFormatter 인스턴스 개선'
EOF
  exit 1
fi

# ✅ 요약 길이 경고
TITLE_SUMMARY=$(sed -E 's/^([^[:space:]]+\s+)?[A-Z][a-zA-Z]+\.\s+//' <<<"$TITLE")
TITLE_LEN=$(printf '%s' "$TITLE_SUMMARY" | wc -m)
[ "$TITLE_LEN" -gt 30 ] && \
  echo "⚠️ 제목 요약이 ${TITLE_LEN}자입니다 (30자 이내 권장)"

# ✅ 본문 Why / How 존재 여부
if ! grep -q "^Why:" "$COMMIT_MSG_FILE" || \
   ! grep -q "^How:" "$COMMIT_MSG_FILE"; then
  echo "❌ 본문 누락: Why:·How: 섹션이 모두 포함되어야 합니다."
  exit 1
fi

exit 0