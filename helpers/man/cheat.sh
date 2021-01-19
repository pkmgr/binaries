#!/usr/bin/env bash
#----------------
printf_color() { printf "%b" "$(tput setaf "$2" 2>/dev/null)" "$1" "$(tput sgr0 2>/dev/null)"; }
printf_help() {
  test -n "$1" && test -z "${1//[0-9]/}" && local color="$1" && shift 1 || local color="4"
  local msg="$*"
  shift
  printf_color "\t\t$msg\n" "$color"
}
#----------------
printf_help "2" "Lookup utitilies"
printf_help "4" "cheat.sh QUERY                            |  process QUERY and exit"
printf_help "4" "cheat.sh --help                           |  show this help"
printf_help "4" "cheat.sh --shell [LANG]                   |  shell mode (open LANG if specified)"
printf_help "4" "cheat.sh --standalone-install [DIR|help]  |  install cheat.sh in the standalone mode"
printf_help "4" "cheat.sh --mode [auto|lite]               |  set (or display) mode of operation"
