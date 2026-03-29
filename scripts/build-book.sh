#!/usr/bin/env bash
# 生成静态图书到 ./book（HonKit）。优先 BOOK_SRC，其次 ../zhenyi/...，否则浅克隆 zhenyi 到 .zhenyi-book-src（供 CI / Cloudflare Pages）
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

ZHENYI_REPO="${ZHENYI_REPO:-https://github.com/aiyang-zh/zhenyi.git}"
CLONE_DIR="${ROOT}/.zhenyi-book-src"

resolve_book_src() {
  local c="${BOOK_SRC:-}"
  if [[ -n "$c" && -f "$c/book.json" ]]; then
    printf '%s' "$c"
    return
  fi
  c="$ROOT/../zhenyi/docs/books/go-actor-realtime"
  if [[ -f "$c/book.json" ]]; then
    printf '%s' "$c"
    return
  fi
  echo "未找到本地书稿，正在浅克隆 zhenyi（可设置 BOOK_SRC 或 ZHENYI_REPO）…" >&2
  rm -rf "$CLONE_DIR"
  git clone --depth 1 "$ZHENYI_REPO" "$CLONE_DIR"
  printf '%s' "$CLONE_DIR/docs/books/go-actor-realtime"
}

BOOK_SRC="$(resolve_book_src)"
export BOOK_SRC
exec npx honkit build "$BOOK_SRC" "$ROOT/book"
