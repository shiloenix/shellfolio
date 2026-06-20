#!/usr/bin/env bash
set -u

APP="zfolio"
MIN_BASH=4

if [[ -t 1 ]]; then
  C_GREEN='\033[38;5;120m'
  C_RED='\033[38;5;203m'
  C_CYAN='\033[38;5;80m'
  C_GRAY='\033[38;5;245m'
  C_YELLOW='\033[38;5;221m'
  C_BOLD='\033[1m'
  C_RESET='\033[0m'
else
  C_GREEN=''; C_RED=''; C_CYAN=''; C_GRAY=''; C_YELLOW=''; C_BOLD=''; C_RESET=''
fi

ok()   { printf "${C_GREEN}  ✓${C_RESET}  %s\n" "$1"; }
err()  { printf "${C_RED}  ✗${C_RESET}  %s\n" "$1" >&2; }
info() { printf "${C_CYAN}  →${C_RESET}  %s\n" "$1"; }
warn() { printf "${C_YELLOW}  !${C_RESET}  %s\n" "$1"; }

usage() {
  printf "\n  ${C_BOLD}Usage:${C_RESET} %s [install|uninstall]\n\n" "$0"
  printf "  Default action is ${C_BOLD}install${C_RESET}.\n\n"
}

check_bash() {
  if (( BASH_VERSINFO[0] < MIN_BASH )); then
    err "bash ${MIN_BASH}+ required (you have ${BASH_VERSION})."
    if [[ "$(uname -s)" == "Darwin" ]]; then
      warn "macOS ships bash 3.2. Install a newer version:"
      printf "    brew install bash\n\n"
    fi
    exit 1
  fi
}

detect_install_dir() {
  case "$(uname -s)" in
    Linux*)
      echo "/usr/local/bin"
      ;;
    Darwin*)
      if [[ -d "/opt/homebrew/bin" ]]; then
        echo "/opt/homebrew/bin"
      else
        echo "/usr/local/bin"
      fi
      ;;
    *)
      err "Unsupported operating system: $(uname -s)"
      exit 1
      ;;
  esac
}

run_privileged() {
  if [[ $EUID -eq 0 ]]; then
    "$@"
  else
    info "Requesting sudo for system directory write..."
    if ! sudo "$@"; then
      err "sudo failed — try running as root or check your sudo access."
      exit 1
    fi
  fi
}

do_install() {
  local install_dir="$1"
  local dest="${install_dir}/${APP}"

  if [[ ! -f "$APP" ]]; then
    err "'${APP}' not found in current directory."
    info "Run this installer from the repository root."
    exit 1
  fi

  chmod +x "$APP"

  info "Installing to ${dest} ..."
  run_privileged install -m 755 "$APP" "$dest"

  # Verify
  if [[ -x "$dest" ]]; then
    ok "Installed successfully → ${dest}"
  else
    err "Installation failed — '${dest}' not found after install."
    exit 1
  fi

  if ! command -v "$APP" &>/dev/null; then
    warn "'${install_dir}' may not be in your PATH."
    printf "    Add this to your shell rc:\n"
    printf "    ${C_CYAN}export PATH=\"${install_dir}:\$PATH\"${C_RESET}\n\n"
  else
    printf "\n  ${C_BOLD}Launch anytime with:${C_RESET}\n\n"
    printf "      ${C_GREEN}${APP}${C_RESET}\n\n"
  fi
}

do_uninstall() {
  local install_dir="$1"
  local dest="${install_dir}/${APP}"

  if [[ ! -f "$dest" ]]; then
    warn "'${APP}' not found at ${dest} — nothing to remove."
    exit 0
  fi

  info "Removing ${dest} ..."
  run_privileged rm -f "$dest"

  if [[ ! -f "$dest" ]]; then
    ok "Uninstalled successfully."
  else
    err "Failed to remove '${dest}'."
    exit 1
  fi
}

main() {
  local action="${1:-install}"

  printf "\n"
  printf "  ${C_BOLD}${C_CYAN}SHELLFOLIO INSTALLER${C_RESET}\n"
  printf "  ${C_GRAY}────────────────────────────────────${C_RESET}\n\n"

  check_bash

  local install_dir
  install_dir="$(detect_install_dir)"

  case "$action" in
    install)   do_install   "$install_dir" ;;
    uninstall) do_uninstall "$install_dir" ;;
    -h|--help) usage; exit 0 ;;
    *)
      err "Unknown action: '${action}'"
      usage
      exit 1
      ;;
  esac
}

main "$@"