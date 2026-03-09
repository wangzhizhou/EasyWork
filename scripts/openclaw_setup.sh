#!/usr/bin/env bash
set -euo pipefail

script_name="$(basename "$0")"

log() { printf '%s\n' "$*"; }
die() { printf '%s\n' "$*" >&2; exit 1; }

has_cmd() { command -v "$1" >/dev/null 2>&1; }

usage() {
  cat <<EOF
用法:
  ${script_name} [选项]

选项:
  --cn | --no-cn                 是否启用中国大陆网络优化(默认: 启用)
  --install-url <url>            OpenClaw 官方安装脚本 URL (默认: https://openclaw.ai/install.sh)
  --method <npm|git>             安装方式(默认: npm)
  --version <latest|next|semver> 版本(默认: latest)
  --beta                         使用 beta 版本(等价于 OPENCLAW_BETA=1)
  --git-dir <path>               git 安装目录(仅 method=git)
  --git-update <0|1>             是否更新 git 安装目录(默认: 1)
  --no-prompt                     禁用交互(等价于 OPENCLAW_NO_PROMPT=1)
  --no-onboard                    跳过 onboard(等价于 OPENCLAW_NO_ONBOARD=1)
  --dry-run                       仅打印将要执行的动作(等价于 OPENCLAW_DRY_RUN=1)
  -h | --help                     显示帮助

环境变量(可选):
  OPENCLAW_INSTALL_METHOD, OPENCLAW_VERSION, OPENCLAW_BETA, OPENCLAW_GIT_DIR, OPENCLAW_GIT_UPDATE
  OPENCLAW_NO_PROMPT, OPENCLAW_NO_ONBOARD, OPENCLAW_DRY_RUN, OPENCLAW_NPM_LOGLEVEL
  OPENCLAW_SETUP_CN=1|0           覆盖默认 CN 模式
  OPENCLAW_GITHUB_PROXY_PREFIX    git 方式下替换 https://github.com/ 的代理前缀
EOF
}

cn_mode="${OPENCLAW_SETUP_CN:-1}"
install_url="https://openclaw.ai/install.sh"
method="${OPENCLAW_INSTALL_METHOD:-npm}"
version="${OPENCLAW_VERSION:-latest}"
beta="${OPENCLAW_BETA:-0}"
git_dir="${OPENCLAW_GIT_DIR:-}"
git_update="${OPENCLAW_GIT_UPDATE:-1}"
no_prompt="${OPENCLAW_NO_PROMPT:-0}"
no_onboard="${OPENCLAW_NO_ONBOARD:-0}"
dry_run="${OPENCLAW_DRY_RUN:-0}"

installer_args=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --cn) cn_mode="1"; shift ;;
    --no-cn) cn_mode="0"; shift ;;
    --install-url) install_url="${2:-}"; shift 2 ;;
    --method|--install-method) method="${2:-}"; shift 2 ;;
    --version) version="${2:-}"; shift 2 ;;
    --beta) beta="1"; shift ;;
    --git-dir) git_dir="${2:-}"; shift 2 ;;
    --git-update) git_update="${2:-}"; shift 2 ;;
    --no-prompt) no_prompt="1"; shift ;;
    --no-onboard) no_onboard="1"; shift ;;
    --dry-run) dry_run="1"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) installer_args+=("$1"); shift ;;
  esac
done

case "$method" in
  npm|git) ;;
  *) die "不支持的 --method: ${method} (仅支持: npm|git)" ;;
esac

if [[ -z "${install_url}" ]]; then
  die "--install-url 不能为空"
fi

downloader=""
if has_cmd curl; then
  downloader="curl"
elif has_cmd wget; then
  downloader="wget"
else
  die "缺少依赖: curl 或 wget"
fi

export OPENCLAW_INSTALL_METHOD="$method"
export OPENCLAW_VERSION="$version"
export OPENCLAW_BETA="$beta"
export OPENCLAW_GIT_UPDATE="$git_update"
export OPENCLAW_NO_PROMPT="$no_prompt"
export OPENCLAW_NO_ONBOARD="$no_onboard"
export OPENCLAW_DRY_RUN="$dry_run"

if [[ -n "$git_dir" ]]; then
  export OPENCLAW_GIT_DIR="$git_dir"
fi

if [[ "$cn_mode" == "1" ]]; then
  export npm_config_registry="${npm_config_registry:-https://registry.npmmirror.com}"
  export npm_config_disturl="${npm_config_disturl:-https://npmmirror.com/mirrors/node}"
  export npm_config_electron_mirror="${npm_config_electron_mirror:-https://npmmirror.com/mirrors/electron/}"
  export npm_config_sharp_binary_host="${npm_config_sharp_binary_host:-https://npmmirror.com/mirrors/sharp}"
  export npm_config_sharp_libvips_binary_host="${npm_config_sharp_libvips_binary_host:-https://npmmirror.com/mirrors/sharp-libvips}"
  export PUPPETEER_DOWNLOAD_HOST="${PUPPETEER_DOWNLOAD_HOST:-https://npmmirror.com/mirrors/chromium/}"
  export PLAYWRIGHT_DOWNLOAD_HOST="${PLAYWRIGHT_DOWNLOAD_HOST:-https://npmmirror.com/mirrors/playwright/}"
  export SENTRYCLI_CDNURL="${SENTRYCLI_CDNURL:-https://npmmirror.com/mirrors/sentry-cli}"
  export GOPROXY="${GOPROXY:-https://goproxy.cn,direct}"

  if [[ "$method" == "git" ]]; then
    proxy_prefix="${OPENCLAW_GITHUB_PROXY_PREFIX:-https://ghproxy.com/https://github.com/}"
    export GIT_CONFIG_COUNT=1
    export GIT_CONFIG_KEY_0="url.${proxy_prefix}.insteadOf"
    export GIT_CONFIG_VALUE_0="https://github.com/"
  fi
fi

tmp="$(mktemp)"
cleanup() { rm -f "$tmp" >/dev/null 2>&1 || true; }
trap cleanup EXIT

if [[ "$downloader" == "curl" ]]; then
  curl -fsSL --proto '=https' --tlsv1.2 --retry 3 --retry-delay 1 --retry-connrefused -o "$tmp" "$install_url"
else
  wget -q --https-only --secure-protocol=TLSv1_2 --tries=3 --timeout=30 -O "$tmp" "$install_url"
fi

run_args=()
run_args+=("--install-method" "$method")
run_args+=("--version" "$version")
if [[ "$beta" == "1" ]]; then
  run_args+=("--beta")
fi
if [[ -n "$git_dir" ]]; then
  run_args+=("--git-dir" "$git_dir")
fi
run_args+=("--git-update" "$git_update")
if [[ "$no_prompt" == "1" ]]; then
  run_args+=("--no-prompt")
fi
if [[ "$no_onboard" == "1" ]]; then
  run_args+=("--no-onboard")
fi
if [[ "$dry_run" == "1" ]]; then
  run_args+=("--dry-run")
fi
if [[ ${#installer_args[@]} -gt 0 ]]; then
  run_args+=("${installer_args[@]}")
fi

log "==> OpenClaw installer: ${install_url}"
log "==> method=${method} version=${version} beta=${beta} cn_mode=${cn_mode}"

/bin/bash "$tmp" "${run_args[@]}"

if has_cmd openclaw; then
  log "==> openclaw 已安装: $(openclaw --version 2>/dev/null || echo "version unknown")"
else
  log "==> 未在 PATH 中发现 openclaw，请新开一个终端或检查 PATH 设置后重试"
  if [[ "$method" == "npm" ]]; then
    log "    可尝试: command -v npm >/dev/null && npm root -g"
  fi
fi
