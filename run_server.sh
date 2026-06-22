#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_ROOT"

# Prefer Homebrew Ruby when it is installed; the macOS system Ruby is too old.
if command -v brew >/dev/null 2>&1 && ruby_prefix="$(brew --prefix ruby 2>/dev/null)"; then
  export PATH="$ruby_prefix/bin:$PATH"
fi

PORT="${PORT:-4000}"
HOST="${HOST:-127.0.0.1}"

if ! command -v bundle >/dev/null 2>&1; then
  echo "未找到 bundle。请先安装 Ruby：brew install ruby"
  exit 1
fi

if ! bundle check >/dev/null 2>&1; then
  echo "正在安装依赖..."
  bundle install
fi

if lsof -nP -iTCP:"$PORT" -sTCP:LISTEN >/dev/null 2>&1; then
  echo "端口 $PORT 已被占用，可能是之前未退出的 Jekyll 服务。"
  echo "可先执行以下命令释放端口，然后重新运行本脚本："
  echo "  lsof -ti:$PORT | xargs kill"
  echo ""
  echo "如果旧服务仍在运行，也可以直接访问："
  echo "  http://$HOST:$PORT"
  exit 1
fi

# Ruby 3.2+ 移除了 String#tainted?，旧版 Liquid 4.0.3 仍会调用
export RUBYOPT="-r${PROJECT_ROOT}/_plugins/ruby_compat ${RUBYOPT:-}"

echo "启动本地预览：http://$HOST:$PORT"
echo "修改文件后请手动刷新浏览器；按 Ctrl+C 停止服务。"
bundle exec jekyll serve --host "$HOST" --port "$PORT"
