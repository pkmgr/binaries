#!/usr/bin/env bash

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# @Author      : Jason
# @Contact     : casjaysdev@casjay.net
# @File        : testing.bash
# @Created     : Wed, Aug 05, 2020, 02:00 EST
# @License     : WTFPL
# @Copyright   : Copyright (c) CasjaysDev
# @Description : functions for installed apps
# @TODO        : Better error handling/refactor code
# @
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
CASJAYSDEVDIR="${CASJAYSDEVDIR:-/usr/local/share/CasjaysDev/scripts}"

# OS Settings
[ -f "$(command -v detectostype)" ] && . "$(command -v detectostype)"

#setup paths
export TMP="${TMP:-/tmp}"
export TEMP="${TEMP:-/tmp}"
export APPNAME="${APPNAME:-testing}"

export TMPPATH="$HOME/.local/share/bash/basher/cellar/bin:$HOME/.local/share/bash/basher/bin:"
export TMPPATH+="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.local/share/gem/bin:/usr/local/bin:"
export TMPPATH+="/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:$PATH:."

export WHOAMI="${USER}"
export PATH="$(echo $TMPPATH | tr ':' '\n' | awk '!seen[$0]++' | tr '\n' ':' | sed 's#::#:.#g')"
export SUDO_PROMPT="$(printf "\t\t\033[1;31m")[sudo]$(printf "\033[1;36m") password for $(printf "\033[1;32m")%p: $(printf "\033[0m\n")"

#fail if git is not installed
if ! command -v "git" >/dev/null 2>&1; then
  echo -e "\n\n\t\t\033[0;31mGit is not installed\033[0m\n"
  exit 1
fi

###################### devnull handling ######################
__devnull() { "$@" >/dev/null 2>&1; }
__devnull1() { "$@" 1>/dev/null >&0; }
__devnull2() { "$@" 2>/dev/null; }
###################### error handling ######################
#err "commands"
__err() {
  local COMMAND="${*:-$(false)}"
  local TMP_FILE="$(mktemp "${TMP:-/tmp}"/error/${APPNAME:-$1}_rr-XXXXX.err)"
  __mkd "${TMP:-/tmp}"/error
  bash -c "${COMMAND}" 2>"$TMP_FILE" >/dev/null && EXIT=0 || EXIT=$?
  [ ! -s "$TMP_FILE" ] || __return_error "$EXIT" "$COMMAND" "$TMP_FILE"
  #rm -rf "$TMP_FILE"
  return $EXIT
}
__return_error() {
  CODE="$1"
  PREV="$2"
  ERRL="$3"
  [ ! -s "$TMP_FILE" ] || printf_red "$PREV has failed with errors"
  cat "$ERRL" | printf_readline "3"
  [ -f "$ERRL" ] && __rm_rf "$ERRL"
}
#runapp "app"
__runapp() {
  local logdir="${LOGDIR:-$HOME/.local/log}/runapp"
  local COMMAND="${*:-$(false)}"
  __mkd "$logdir"
  if [ "$1" = "--bg" ]; then
    local logname="$2"
    shift 2
    echo "#################################" >>"$logdir/$logname.log"
    echo "$(date +'%A, %B %d, %Y')" >>"$logdir/$logname.log"
    echo "#################################" >>"$logdir/$logname.log"
    bash -c "$COMMAND" >>"$logdir/$logname.log" 2>>"$logdir/$logname.err" &
  elif [ "$1" = "--log" ]; then
    local logname="$2"
    shift 2
    echo "#################################" >>"$logdir/$logname.log"
    echo "$(date +'%A, %B %d, %Y')" >>"$logdir/$logname.log"
    echo "#################################" >>"$logdir/$logname.log"
    bash -c "$COMMAND" >>"$logdir/$logname.log" 2>>"$logdir/$logname.err"
  else
    echo "#################################" >>"$logdir/${APPNAME:-$1}.log"
    echo "$(date +'%A, %B %d, %Y')" >>"$logdir/${APPNAME:-$1}.log"
    echo "#################################" >>"$logdir/${APPNAME:-$1}.log"
    bash -c "$COMMAND" >>"$logdir/${APPNAME:-$1}.log" 2>>"$logdir/${APPNAME:-$1}.err"
  fi
}

#runpost "program"
__run_post() {
  local e="$1"
  local m="${e//__devnull//}"
  __execute "$e" "executing: $m"
  __setexitstatus
  set --
}

#macos fix
case "$(uname -s)" in
Darwin) alias dircolors=gdircolors ;;
esac

# Set Main Repo for dotfiles
DOTFILESREPO="https://github.com/dfmgr"

# Set other Repos
DFMGRREPO="https://github.com/dfmgr"
PKMGRREPO="https://github.com/pkmgr"
DEVENVMGRREPO="https://github.com/devenvmgr"
ICONMGRREPO="https://github.com/iconmgr"
FONTMGRREPO="https://github.com/fontmgr"
THEMEMGRREPO="https://github.com/thememgr"
SYSTEMMGRREPO="https://github.com/systemmgr"
WALLPAPERMGRREPO="https://github.com/wallpapermgr"
WHICH_LICENSE_URL="https://github.com/devenvmgr/licenses/raw/master"

scripts_version() { printf_green "scripts version is $(cat ${CASJAYSDEVDIR:-/usr/local/share/CasjaysDev/scripts}/version.txt)\n"; }

#setup colors
NC="$(tput sgr0 2>/dev/null)"
RESET="$(tput sgr0 2>/dev/null)"
BLACK="\033[0;30m"
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
PURPLE="\033[0;35m"
CYAN="\033[0;36m"
WHITE="\033[0;37m"
ORANGE="\033[0;33m"
LIGHTRED='\033[1;31m'
BG_GREEN="\[$(tput setab 2 2>/dev/null)\]"
BG_RED="\[$(tput setab 9 2>/dev/null)\]"
ICON_INFO="[ ℹ️ ]"
ICON_GOOD="[ ✔ ]"
ICON_WARN="[ ❗ ]"
ICON_ERROR="[ ✖ ]"
ICON_QUESTION="[ ❓ ]"

print_wait() { printf_pause; }
printf_newline() { printf "${*:-}\n"; }
printf_color() { printf "%b" "$(tput setaf "$2" 2>/dev/null)" "$1" "$(tput sgr0 2>/dev/null)"; }
printf_normal() { printf_color "\t\t$1\n" "$2"; }
printf_green() { printf_color "\t\t$1\n" 2; }
printf_red() { printf_color "\t\t$1\n" 1; }
printf_purple() { printf_color "\t\t$1\n" 5; }
printf_yellow() { printf_color "\t\t$1\n" 3; }
printf_blue() { printf_color "\t\t$1\n" 4; }
printf_cyan() { printf_color "\t\t$1\n" 6; }
printf_info() { printf_color "\t\t$ICON_INFO $1\n" 3; }
printf_success() { printf_color "\t\t$ICON_GOOD $1\n" 2; }
printf_warning() { printf_color "\t\t$ICON_WARN $1\n" 3; }
printf_error_stream() { while read -r line; do printf_error "↳ ERROR: $line"; done; }
printf_execute_success() { printf_color "\t\t$ICON_GOOD $1\n" 2; }
printf_execute_error() { printf_color "\t\t$ICON_WARN $1 $2\n" 1; }
printf_execute_result() {
  if [ "$1" -eq 0 ]; then printf_execute_success "$2"; else printf_execute_error "${3:-$2}"; fi
  return "$1"
}

printf_not_found() { if ! __cmd_exists "$1"; then printf_exit "The $1 command is not installed"; fi; }
printf_execute_error_stream() { while read -r line; do printf_execute_error "↳ ERROR: $line"; done; }
#used for printing console notifications
printf_console() {
  test -n "$1" && test -z "${1//[0-9]/}" && local color="$1" && shift 1 || local color="1"
  local msg="$*"
  shift
  printf_color "\n\t\t$msg\n\n" "$color"
}

printf_pause() {
  test -n "$1" && test -z "${1//[0-9]/}" && local color="$1" && shift 1 || local color="5"
  local msg="$*"
  printf_color "\t\t$msg\n" "$color"
  read -s -n 1
}

printf_error() {
  test -n "$1" && test -z "${1//[0-9]/}" && local color="$1" && shift 1 || local color="1"
  test -n "$1" && test -z "${1//[0-9]/}" && local exitCode="$1" && shift 1 || local exitCode="1"
  local msg="$*"
  printf_color "\t\t$ICON_ERROR $msg\n" "$color"
  return $exitCode
}

#printf_exit "color" "exitcode" "message"
printf_exit() {
  test -n "$1" && test -z "${1//[0-9]/}" && local color="$1" && shift 1 || local color="1"
  test -n "$1" && test -z "${1//[0-9]/}" && local exitCode="$1" && shift 1 || local exitCode="1"
  local msg="$*"
  shift
  printf_color "\t\t$msg" "$color"
  echo ""
  exit "$exitCode"
}

printf_single() {
  test -n "$1" && test -z "${1//[0-9]/}" && local color="$1" && shift 1 || local color="1"
  local COLUMNS=80
  local TEXT="$*"
  local LEN=${#TEXT}
  local WIDTH=$(($LEN + ($COLUMNS - $LEN) / 2))
  printf "%b" "$(tput setaf "$color" 2>/dev/null)" "$TEXT " "$(tput sgr0 2>/dev/null)" | sed 's#\t# #g'
}

printf_help() {
  test -n "$1" && test -z "${1//[0-9]/}" && local color="$1" && shift 1 || local color="4"
  local msg="$*"
  shift
  echo ""
  printf_color "\t\t$msg\n" "$color"
  echo ""
  exit 0
}

printf_custom() {
  test -n "$1" && test -z "${1//[0-9]/}" && local color="$1" && shift 1 || local color="5"
  local msg="$*"
  shift
  printf_color "\t\t$msg" "$color"
  echo ""
}

printf_read() {
  set -o pipefail
  test -n "$1" && test -z "${1//[0-9]/}" && local color="$1" && shift 1 || local color="6"
  while read line; do
    printf_color "\t\t$line" "$color"
  done
  printf "\n"
  set +o pipefail
}

printf_readline() {
  set -o pipefail
  test -n "$1" && test -z "${1//[0-9]/}" && local color="$1" && shift 1 || local color="6"
  while read line; do
    printf_color "\t\t$line\n" "$color"
  done
  set +o pipefail
}

printf_question() {
  test -n "$1" && test -z "${1//[0-9]/}" && local color="$1" && shift 1 || local color="4"
  local msg="$*"
  shift
  printf_color "\t\t$ICON_QUESTION $msg? " "$color"
}

printf_custom_question() {
  test -n "$1" && test -z "${1//[0-9]/}" && local color="$1" && shift 1 || local color="1"
  local msg="$*"
  shift
  printf_color "\t\t$msg " "$color"
}

#printf_read_question "color" "message" "maxLines" "answerVar" "readopts"
printf_read_question() {
  test -n "$1" && test -z "${1//[0-9]/}" && local color="$1" && shift 1 || local color="4"
  local msg="$1" && shift 1
  test -n "$1" && test -z "${1//[0-9]/}" && local lines="$1" && shift 1 || local lines="120"
  reply="${1:-REPLY}" && shift 1
  readopts=${1:-} && shift 1
  printf_color "\t\t$msg " "$color"
  read -t 20 -er -n $lines $readopts $reply #|| printf "\n"
}

#printf_read_question "color" "message" "maxLines" "answerVar" "readopts"
printf_read_question_nt() {
  local readopts reply
  test -n "$1" && test -z "${1//[0-9]/}" && local color="$1" && shift 1 || local color="1"
  local msg="$1" && shift 1
  test -n "$1" && test -z "${1//[0-9]/}" && local lines="$1" && shift 1 || local lines="120"
  reply="${1:-REPLY}" && shift 1
  readopts=${1:-} && shift 1
  printf_color "\t\t$msg " "$color"
  read -er -n $lines $readopts $reply #|| printf "\n"
}

#printf_answer "Var" "maxNum" "Opts"
printf_answer() {
  read -t 10 -ers -n 1 "${1:-REPLY}" || printf "\n"
  #history -s "$1"
}

#printf_answer_yes "var" "response"
printf_answer_yes() { [[ "${1:-$REPLY}" =~ ${2:-^[Yy]$} ]] && return 0 || return 1; }
printf_answer_no() { [[ "${1:-$REPLY}" =~ ${2:-^[Nn]$} ]] && return 0 || return 1; }

printf_return() { return "${1:-1}"; }

printf_head() {
  test -n "$1" && test -z "${1//[0-9]/}" && local color="$1" && shift 1 || local color="6"
  local msg1="$1" && shift 1
  local msg2="$1" && shift 1 || msg2=
  local msg3="$1" && shift 1 || msg3=
  local msg4="$1" && shift 1 || msg4=
  local msg5="$1" && shift 1 || msg5=
  local msg6="$1" && shift 1 || msg6=
  local msg7="$1" && shift 1 || msg7=
  shift
  [ -z "$msg1" ] || printf_color "\t\t##################################################\n" "$color"
  [ -z "$msg1" ] || printf_color "\t\t$msg1\n" "$color"
  [ -z "$msg2" ] || printf_color "\t\t$msg2\n" "$color"
  [ -z "$msg3" ] || printf_color "\t\t$msg3\n" "$color"
  [ -z "$msg4" ] || printf_color "\t\t$msg4\n" "$color"
  [ -z "$msg5" ] || printf_color "\t\t$msg5\n" "$color"
  [ -z "$msg6" ] || printf_color "\t\t$msg6\n" "$color"
  [ -z "$msg7" ] || printf_color "\t\t$msg7\n" "$color"
  [ -z "$msg1" ] || printf_color "\t\t##################################################\n" "$color"
}

# same as printf_head but no formatting
printf_header() {
  local msg1="$1" && shift 1
  local msg2="$1" && shift 1 || msg2=
  local msg3="$1" && shift 1 || msg3=
  local msg4="$1" && shift 1 || msg4=
  local msg5="$1" && shift 1 || msg5=
  local msg6="$1" && shift 1 || msg6=
  local msg7="$1" && shift 1 || msg7=
  shift
  [ -z "$msg1" ] || printf "##################################################\n"
  [ -z "$msg1" ] || printf "$msg1\n"
  [ -z "$msg2" ] || printf "$msg2\n"
  [ -z "$msg3" ] || printf "$msg3\n"
  [ -z "$msg4" ] || printf "$msg4\n"
  [ -z "$msg5" ] || printf "$msg5\n"
  [ -z "$msg6" ] || printf "$msg6\n"
  [ -z "$msg7" ] || printf "$msg7\n"
  [ -z "$msg1" ] || printf "##################################################\n"
}

printf_result() {
  PREV="$4"
  [ ! -z "$1" ] && EXIT="$1" || EXIT="$?"
  [ ! -z "$2" ] && local OK="$2" || local OK="Command executed successfully"
  [ ! -z "$3" ] && local FAIL="$3" || local FAIL="${PREV:-The previous command} has failed"
  [ ! -z "$4" ] && local FAIL="$3" || local FAIL="$3"
  if [ "$EXIT" -eq 0 ]; then
    printf_success "$OK"
    return 0
  else
    if [ -z "$4" ]; then
      printf_error "$FAIL"
    else
      printf_error "$FAIL: $PREV"
    fi
    return 1
  fi
}
#printf_counter "color" "time" "message"
printf_counter() {
  printf_newline "\n\n"
  test -n "$1" && test -z "${1//[0-9]/}" && local color="$1" && shift 1 || local color="1"
  test -n "$1" && test -z "${1//[0-9]/}" && local wait_time="$1" && shift 1 || local wait_time="5"
  message="$*" && shift
  temp_cnt=${wait_time}
  while [[ ${temp_cnt} -gt 0 ]]; do
    printf "%s\r" "$(printf_custom $color $message: ${temp_cnt})"
    sleep 1
    ((temp_cnt--))
  done
  printf_newline "\n\n"
}
printf_debug() {
  printf_yellow "Running in debug mode "
  local IFS=' '
  arg="$*"
  for d in $arg; do
    printf_blue "$d"
  done
  exit
}
#counter time "color" "message" "seconds(s) "
__counter() {
  wait_time=$1 # seconds
  color="$2"
  msg="$3"
  temp_cnt=${wait_time}
  while [[ ${temp_cnt} -gt 0 ]]; do
    printf "\r%s" "$(printf_custom "$color" "$msg" ${temp_cnt} "$4")"
    sleep 1
    ((temp_cnt--))
  done
}

###################### MyCurDir ######################
#mycurrdir "$*" | returns $MyCurDir
__mycurrdir() {
  # I'm sure there is a better way to do this
  if [ -d "$1" ]; then
    MYCURRDIR="$1"
    shift 1
  elif [ "$1" = "-d" ] || [ "$1" = "-dir" ] || [ "$1" = "--dir" ]; then
    MYCURRDIR="$2"
    shift 2
    [ -d "$MYCURRDIR" ] || printf_exit "$MYCURRDIR doesn't seem to be a directory"
  else
    MYCURRDIR="$PWD"
  fi
  MYCURRDIR="$MYCURRDIR"
  MYARGS="$*"
}
###################### checks ######################
#cmd_exists command
__cmd_exists() {
  [ $# -eq 0 ] && return 1
  local args=$*
  local exitTmp
  local exitCode
  for cmd in $args; do
    if find "$(command -v "$cmd" 2>/dev/null)" >/dev/null 2>&1 || find "$(which --skip-alias --skip-functions "$cmd" 2>/dev/null)" >/dev/null 2>&1; then
      local exitTmp=0
    else
      local exitTmp=1
    fi
    local exitCode+="$exitTmp"
  done
  [ "$exitCode" -eq 0 ] && return 0 || return 1
}
#system_service_active "list of services to check"
__system_service_active() {
  for service in "$@"; do
    if [ "$(systemctl show -p ActiveState $service | cut -d'=' -f2)" == active ]; then
      return 0
    else
      return 1
    fi
  done
}
#system_service_running "list of services to check"
__system_service_running() {
  for service in "$@"; do
    if [[ $(systemctl status $service | grep running >/dev/null) = "yes" ]]; then
      return 0
    else
      return 1
    fi
  done
}
#system_service_exists "servicename"
__system_service_exists() {
  for service in "$@"; do
    if sudo systemctl list-units --full -all | grep -Fq "$service.service" || sudo systemctl list-units --full -all | grep -Fq "$service.socket"; then return 0; else return 1; fi
    __setexitstatus $?
  done
  set --
}
#system_service_enable "servicename"
__system_service_enable() {
  for service in "$@"; do
    if __system_service_exists; then __devnull "sudo systemctl enable -f $service"; fi
    __setexitstatus $?
  done
  set --
}
#system_service_disable "servicename"
__system_service_disable() {
  for service in "$@"; do
    if __system_service_exists; then __devnull "sudo systemctl disable --now $service"; fi
    __setexitstatus $?
  done
  set --
}
#system_service_start "servicename"
__system_service_start() {
  for service in "$@"; do
    if __system_service_exists; then __devnull "sudo systemctl start $service"; fi
    __setexitstatus $?
  done
  set --
}

#perl_exists "perlpackage"
__perl_exists() {
  local package=$1
  if __devnull2 perl -M$package -le 'print $INC{"$package/Version.pm"}'; then return 0; else return 1; fi
}
#python_exists "pythonpackage"
__python_exists() {
  __getpythonver
  local package=$1
  if __devnull2 "$PYTHONVER" -c "import $package"; then return 0; else return 1; fi
}
#gem_exists "gemname"
__gem_exists() {
  local package="$1"
  if __cmd_exists "$package" || devnull gem query -i -n "$package"; then return 0; else return 1; fi
}
#check_app "app"
__check_app() {
  local ARGS="$*"
  local MISSING=""
  for cmd in $ARGS; do __cmd_exists "$cmd" || MISSING+="$cmd "; done
  if [ -n "$MISSING" ]; then
    printf_red "The following apps are missing: $MISSING"
    printf_read_question "2" "Would you like install them? [y/N]" "1" "choice" "-s"
    if printf_answer_yes "$choice"; then
      for miss in $MISSING; do
        __execute "pkmgr silent-install $miss" "Installing $miss" || return 1
      done
    else
      exit 1
    fi
  fi
}
#check_pip "pipname"
__check_pip() {
  local ARGS="$*"
  local MISSING=""
  for cmd in $ARGS; do __cmd_exists $cmd || MISSING+="$cmd "; done
  if [ ! -z "$MISSING" ]; then
    printf_read_question "2" "$1 is not installed Would you like install it? [y/N]" "1" "choice" "-s"
    if printf_answer_yes "$choice"; then
      for miss in $MISSING; do
        __execute "pkmgr pip $miss" "Installing $miss"
      done
    fi
  else
    return 1
  fi
}
#check_cpan "cpanname"
__check_cpan() {
  local MISSING=""
  for cmd in "$@"; do __cmd_exists $cmd || MISSING+="$cmd "; done
  if [ ! -z "$MISSING" ]; then
    printf_question "2" "$1 is not installed Would you like install it? [y/N]" "1" "choice" "-s"
    if printf_answer_yes "$choice"; then
      for miss in $MISSING; do
        __execute "pkmgr cpan $miss" "Installing $miss"
      done
    fi
  else
    return 1
  fi
}
#check_app "app"
__require_app() { __check_app "$@" || exit 1; }
__requires() {
  local CMD
  for cmd in "$@"; do
    __cmd_exists "$cmd " || local CMD+="$cmd "
  done
  if [ -n "$CMD" ]; then __require_app "$CMD"; fi
  [ "$?" -eq 0 ] && return 0 || exit 1
}
###################### get versions ######################
__getpythonver() {
  if [[ "$(python3 -V 2>/dev/null)" =~ "Python 3" ]]; then
    PYTHONVER="python3"
    PIP="pip3"
    PATH="${PATH}:$(python3 -c 'import site; print(site.USER_BASE)')/bin"
  elif [[ "$(python2 -V 2>/dev/null)" =~ "Python 2" ]]; then
    PYTHONVER="python"
    PIP="pip"
    PATH="${PATH}:$(python -c 'import site; print(site.USER_BASE)')/bin"
  fi
  if [ "$(__cmd_exists yay)" ] || [ "$(__cmd_exists pacman)" ]; then PYTHONVER="python" && PIP="pip3"; fi
}

__getphpver() {
  if __cmd_exists php; then
    PHPVER="$(php -v | grep --only-matching --perl-regexp "(PHP )\d+\.\\d+\.\\d+" | cut -c 5-7)"
  else
    PHPVER=""
  fi
  echo $PHPVER
}

###################### tools ######################
#basedir "file"
__basedir() { dirname "${1:-.}"; }
#__basename "file"
__basename() { basename "${1:-.}"; }
#to_lowercase "args"
__to_lowercase() { echo "$@" | tr [A-Z] [a-z]; }
#to_uppercase "args"
__to_uppercase() { echo "$@" | tr [a-z] [A-Z]; }
#strip_ext "Filename"
__strip_ext() { echo "$@" | sed 's#\..*##g'; }
#get_full_file "file"
__get_full_file() { ls -A "$*" 2>/dev/null; }
#cat file | rmcomments
__rmcomments() { sed 's/[[:space:]]*#.*//;/^[[:space:]]*$/d'; }
#countwd file
__countwd() { cat "$@" | wc -l | __rmcomments; }
#getuser "username" "grep options"
__getuser() { if [ -n "${1:-$USER}" ]; then cut -d: -f1 /etc/passwd | grep "${1:-$USER}" | cut -d: -f1 /etc/passwd | grep "${1:-$USER}" ${2:-}; fi; }
#getuser_shell "shellname"
__getuser_shell() {
  local SHELL=${1:-$SHELL} && shift 1
  local USER=${1:-$USER} && shift 1
  grep "$USER" /etc/passwd | cut -d: -f7 | grep -q "$SHELL" && return 0 || return 1
}
__getuser_cur_shell() { grep "$USER" /etc/passwd | tr ':' '\n' | grep bin; }
###################### Apps ######################
#vim "file"
vim="$(command -v /usr/local/bin/vim || command -v vim)"
__vim() { $vim "$@"; }
#mkd dir
__mkd() {
  for d in "$@"; do [ -e "$d" ] || mkdir -p "$d" >/dev/null 2>&1; done
  return 0
}
#netcat
netcat="$(command -v nc 2>/dev/null || command -v netcat 2>/dev/null || return 1)"
__netcat_test() { __cmd_exists "$netcat" || printf_error "The program netcat is not installed"; }
__netcat_pids() { netstat -tupln 2>/dev/null | grep ":$1 " | grep "$(basename ${netcat:-nc})" | awk '{print $7}' | sed 's#'/$(basename ${netcat:-nc})'##g'; }
# kill_netpid "port" "procname"
__kill_netpid() { netstatg "$1" | grep "$(basename $2)" | awk '{print $7}' | sed 's#/'$2'##g' && netstat -taupln | grep -qv "$1" || return 1; }
__netcat_kill() {
  pidof "$netcat" >/dev/null 2>&1 && kill -s KILL "$(__netcat_pids $1)" >/dev/null 2>&1
  netstat -taupln | grep -Fqv ":$1 " || return 1
}
#__kill_server "port required" "print success" "print fail" "success message" "failed message"
__netcat_kill_server() {
  port="${1:?}"
  prints="${2:-printf_green}"
  printf="${3:-printf_red}"
  succ="${4:-Server has been stopped}"
  fail="${5:-Failed to stop}"
  __netcat_kill "${port}" >/dev/null 2>&1 &&
    ${prints} "${succ}" || ${printf} "${fail}"
  sleep 2
}
#sed "commands"
sed="$(command -v gsed 2>/dev/null || command -v sed 2>/dev/null)"
__sed() { "$sed" "$@"; }
#tar "filename dir"
__tar_create() { tar cfvz "$@"; }
#tar filename
__tar_extract() { tar xfvz "$@"; }
#while_true "command"
__while_loop() { while :; do "${@}" && sleep .3; done; }
#for_each "option" "command"
__for_each() { for item in ${1}; do ${2} ${item} && sleep .1; done; }
__readline() { while read -r line; do echo "$line"; done <"$1"; }
#hostname ""
__hostname() { __devnull2 hostname -s "${1:-$HOSTNAME}"; }
#domainname ""
__domainname() { hostname -d "${1:-$HOSTNAME}" 2>/dev/null || hostname -f "${1:-$HOSTNAME}" 2>/dev/null; }
#hostname2ip "hostname"
__hostname2ip() { getent ahostsv4 "$1" | cut -d' ' -f1 | head -n1; }
#ip2hostname
__ip2hostname() { getent hosts "$1" | awk '{print $2}' | head -n1; }
#timeout "time" "command"
__timeout() { timeout ${1} bash -c "${2}"; }
#count_files "dir"
__count_files() { __devnull2 find -L "${1:-./}" -maxdepth 1 -not -path "${1:-./}/.git/*" -type f | wc -l; }
#count_dir "dir"
__count_dir() { __devnull2 find -L "${1:-./}" -mindepth 1 -maxdepth 1 -not -path "${1:-./}/.git/*" -type d | wc -l; }
__touch() { touch "$@" 2>/dev/null || return 0; }
#symlink "file" "dest"
__symlink() { if [ -e "$1" ]; then __devnull __ln_sf "${1}" "${2}" || return 0; fi; }
#mv_f "file" "dest"
__mv_f() { if [ -e "$1" ]; then __devnull mv -f "$1" "$2" || return 0; fi; }
#cp_rf "file" "dest"
__cp_rf() { if [ -e "$1" ]; then __devnull cp -Rfa "$1" "$2" || return 0; fi; }
#rm_rf "file"
__rm_rf() { if [ -e "$1" ]; then __devnull rm -Rf "$@" || return 0; fi; }
#ln_rm "file"
__ln_rm() { if [ -e "$1" ]; then __devnull find $1 -mindepth 1 -maxdepth 1 -xtype l -delete; fi; }
#ln_sf "file"
__ln_sf() {
  [ -L "$2" ] && __rm_rf "$2"
  __devnull ln -sf "$1" "$2"
}
#find_mtime "file/dir" "time minutes"
__find_mtime() { [ "$(find ${1:-.} -type f -cmin ${2:-1} | wc -l)" -ne 0 ] && return 0 || return 1; }
#find "dir" "options"
__find() {
  local DEF_OPTS="-type f,d"
  local opts="${FIND_OPTS:-$DEF_OPTS}"
  __devnull2 find "${*:-.}" -not -path "$dir/.git/*" $opts
}
#find_old "dir" "minutes" "action"
__find_old() {
  [ -d "$1" ] && local dir="$1" && shift 1
  local time="$1" && shift 1
  local action="$1" && shift 1
  find "${dir:-$HOME/.local/tmp}" -type f -mmin +${time:-120} -${action:-delete}
}
#find "dir" - return path relative to dir
__find_rel() {
  #f for file | d for dir
  local DIR="${*:-.}"
  local DEF_TYPE="${FIND_TYPE:-f}"
  local DEF_DEPTH="${FIND_DEPTH:-1}"
  __devnull2 find $DIR/* -maxdepth $DEF_DEPTH -type $DEF_TYPE -not -path "$dir/.git/*" -print | sed 's#'$DIR'/##g'
}
#cd "dir"
__cd() { cd "$1" || return 1; }
# cd into directory with message
__cd_into() {
  if [ $PWD != "$1" ]; then
    cd "$1" && printf_green "Changing the directory to $1" &&
      printf_green "Type exit to return to your previous directory" &&
      exec bash || exit 1
  fi
}
#kill "app"
__kill() { kill -9 "$(pidof "$1")" >/dev/null 2>&1; }
#running "app"
__running() { pidof "$1" >/dev/null 2>&1 && return 1 || return 0; }
#start "app"
__start() {
  sleep 1 && eval "$*" 2>/dev/null &
  disown
}

###################### url functions ######################
__curl() {
  __devnull2 __am_i_online && curl --disable -LSsfk --connect-timeout 3 --retry 0 --fail "$@" || return 1
}
__curl_exit() { EXIT=0 && return 0 || EXIT=1 && return 1; }
#appversion "urlToVersion"
__appversion() { __curl "${1:-$REPORAW/master/version.txt}" || echo 011920210931-git; }
#curl_header "site" "code"
__curl_header() { curl --disable -LSIsk --connect-timeout 3 --retry 0 --max-time 2 "$1" | grep -E "HTTP/[0123456789]" | grep "${2:-200}" -n1 -q; }
#curl_download "url" "file"
__curl_download() { curl --disable --create-dirs -LSsk --connect-timeout 3 --retry 0 "$1" -o "$2"; }
#curl_version "url"
__curl_version() { curl --disable -LSsk --connect-timeout 3 --retry 0 "${1:-$REPORAW/master/version.txt}"; }
#curl_upload "file" "url"
__curl_upload() { curl -disable -LSsk --connect-timeout 3 --retry 0 --upload-file "$1" "$2"; }
#curl_api "API URL"
__curl_api() { curl --disable -LSsk --connect-timeout 3 --retry 0 "https://api.github.com/orgs/$SCRIPTS_PREFIX/repos?per_page=1000"; }
#urlcheck "url"
__urlcheck() { curl --disable -k --connect-timeout 1 --retry 0 --retry-delay 0 --output /dev/null --silent --head --fail "$1" && __curl_exit; }
#urlverify "url"
__urlverify() { __urlcheck "$1" || __urlinvalid "$1"; }
#urlinvalid "url"
__urlinvalid() {
  if [ -z "$1" ]; then
    printf_red "Invalid URL"
  else
    printf_red "Can't find $1"
  fi
  return 1
}
#very simple function to ensure connection and jq exists
__api_test() {
  if __am_i_online && __cmd_exists jq; then
    return 0
  else
    [ -n "$1" ] && printf_red "$1"
    return 1
  fi
}
#do_not_add_a_url "url"
__do_not_add_a_url() {
  regex="(https?|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]"
  string="$1"
  if [[ "$string" =~ $regex ]]; then
    printf_exit "Do not provide the full url: only provide the username/repo"
  fi
}
###################### git commands ######################
#git_globaluser
__git_globaluser() {
  local author="$(git config --get user.name || echo "$USER")"
  echo "$author"
}
#git_globalemail
__git_globalemail() {
  local email="$(git config --get user.email || echo "$USER"@"$(hostname -s)".local)"
  echo "$email"
}
#git_clone "url" "dir"
__git_clone() {
  [ $# -ne 2 ] && printf_exit "Usage: git clone remoteRepo localDir"
  __git_username_repo "$1"
  local repo="$1"
  [ -n "$2" ] && local dir="$2" && shift 1 || local dir="${APPDIR:-.}"
  if [ -d "$dir/.git" ]; then
    __git_update "$dir" || return 1
  else
    [ -d "$dir" ] && __rm_rf "$dir"
    git clone -q --recursive "$repo" "$dir" || return 1
  fi
  if [ "$?" -ne "0" ]; then
    printf_error "Failed to clone the repo"
  fi
}
#git_pull "dir"
__git_update() {
  [ -n "$1" ] && local dir="$1" && shift 1 || local dir="${APPDIR:-.}"
  local repo="$(git -C "$dir" remote -v | grep fetch | head -n 1 | awk '{print $2}')"
  local appname="${APPNAME:-$(basename $dir)}"
  git -C "$dir" reset --hard || return 1
  git -C "$dir" pull --recurse-submodules -fq || return 1
  git -C "$dir" submodule update --init --recursive -q || return 1
  git -C "$dir" reset --hard -q || return 1
  if [ "$?" -ne "0" ]; then
    printf_error "Failed to update the repo"
    #__backupapp "$dir" "$appname" && __rm_rf "$dir" && git clone -q "$repo" "$dir"
  fi
}
#git_commit "dir"
__git_commit() {
  [ -n "$1" ] && local dir="$1" && shift 1 || local dir="${APPDIR:-.}"
  if __cmd_exists gitcommit; then
    if [ -d "$2" ]; then shift 1; fi
    local mess="${*}"
    gitcommit "$dir" "$mess"
  else
    local mess="${1}"
    if [ ! -d "$dir" ]; then
      __mkd "$dir"
      git -C "$dir" init -q
    fi
    touch "$dir/README.md"
    git -C "$dir" add -A .
    if ! __git_porcelain "$dir"; then
      git -C "$dir" commit -q -m "${mess:-🏠🐜❗ Updated Files 🏠🐜❗}" | printf_readline "2"
    else
      return 0
    fi
  fi
}
#git_init "dir"
__git_init() {
  [ -n "$1" ] && local dir="$1" && shift 1 || local dir="${APPDIR:-.}"
  if __cmd_exists gitadmin; then
    if [ -d "$2" ]; then shift 1; fi
    gitadmin "$dir" setup
  else
    set --
    __mkd "$dir"
    git -C "$dir" init -q &>/dev/null
    git -C "$dir" add -A . &>/dev/null
    if ! __git_porcelain "$dir"; then
      git -C "$dir" commit -q -m " 🏠🐜❗ Initial Commit 🏠🐜❗ " | printf_readline "2"
    else
      return 0
    fi
  fi
}
#set folder name based on githost
__git_hostname() {
  echo "$@" | sed -e "s/[^/]*\/\/\([^@]*@\)\?\([^:/]*\).*/\2/" | awk -F. '{print $(NF-1) "." $NF}' | sed 's#\..*##g'
}
#setup directory structure
__git_username_repo() {
  unset protocol separator hostname username userrepo
  local url="$1"
  local re="^(https?|git)(:\/\/|@)([^\/:]+)[\/:]([^\/:]+)\/(.+)$"
  local githostname="$(__git_hostname $url 2>/dev/null)"
  if [[ $url =~ $re ]]; then
    protocol=${BASH_REMATCH[1]}
    separator=${BASH_REMATCH[2]}
    hostname=${BASH_REMATCH[3]}
    username=${BASH_REMATCH[4]}
    userrepo=${BASH_REMATCH[5]}
    folder=${githostname}
    projectdir="${PROJECT_DIR:-$HOME/Projects}/$folder/$username/$userrepo"
  else
    return 1
  fi
}

#usage: git_CMD gitdir
__git_status() { git -C "${1:-.}" status -b -s 2>/dev/null && return 0 || return 1; }
__git_log() { git -C "${1:-.}" log --pretty='%C(magenta)%h%C(red)%d %C(yellow)%ar %C(green)%s %C(yellow)(%an)' 2>/dev/null && return 0 || return 1; }
__git_pull() { git -C "${1:-.}" pull -q 2>/dev/null && return 0 || return 1; }
__git_top_dir() { git -C "${1:-.}" rev-parse --show-toplevel 2>/dev/null && return 0 || echo "$1"; }
__git_top_rel() { __devnull __git_top_dir "${1:-.}" && git -C "${1:-.}" rev-parse --show-cdup 2>/dev/null | sed 's#/$##g' | head -n1 || return 1; }
__git_remote_fetch() { git -C "${1:-.}" remote -v 2>/dev/null | grep fetch | head -n 1 | awk '{print $2}' 2>/dev/null && return 0 || return 1; }
__git_remote_origin() { git -C "${1:-.}" remote show origin 2>/dev/null | grep Push | awk '{print $3}' && return 0 || return 1; }
__git_porcelain_count() { [ -d "$(__git_top_dir ${1:-.})/.git" ] && [ "$(git -C "${1:-.}" status --porcelain 2>/dev/null | wc -l 2>/dev/null)" -eq "0" ] && return 0 || return 1; }
__git_porcelain() { __git_porcelain_count "${1:-.}" && return 0 || return 1; }
__git_repobase() { basename "$(__git_top_dir "${1:-.}")"; }
# __reldir="$(__git_top_rel ${1:-MYCURRDIR} || echo $PWD)"
# __topdir="$(__git_top_dir "${1:-MYCURRDIR}" || echo $PWD)"

###################### crontab functions ######################
__removecrontab() {
  command="$(echo $1 | sed 's#>/dev/null 2>&1##g')"
  crontab -l | grep -Fv "${command}" | crontab -
  return $?
}

__setupcrontab() {
  [ "$1" = "--help" ] && printf_help "setupcrontab "0 0 1 * *" "echo hello""
  local frequency="$1"
  local command="sleep $(expr $RANDOM \% 300) && $2"
  local job="$frequency $command"
  if cat <(grep -Fivq "$2" <(crontab -l)); then
    cat <(grep -Fiv "$2" <(crontab -l)) <(echo "$job") | crontab - >/dev/null 2>&1
  fi
  return $?
}

__addtocrontab() {
  [ "$1" = "--help" ] && printf_help "addtocrontab "0 0 1 * *" "echo hello""
  local frequency="$1"
  local command="am_i_online && sleep $(expr $RANDOM \% 300) && $2"
  local job="$frequency $command"
  cat <(grep -F -i -v "$2" <(crontab -l)) <(echo "$job") | crontab - >/dev/null 2>&1
  return $?
}

__cron_updater() {
  [ "$*" = "--help" ] && printf_help "Usage: $APPNAME updater $APPNAME"
  if [[ "$USER" = "root" ]]; then
    if [ -z "$1" ] && [ -d "$SYSUPDATEDIR" ] && ls "$SYSUPDATEDIR"/* 1>/dev/null 2>&1; then
      for upd in $(ls $SYSUPDATEDIR/); do
        file="$(ls -A $SYSUPDATEDIR/$upd 2>/dev/null)"
        if [ -f "$file" ]; then
          appname="$(basename $file)"
          sudo file=$file bash -c "$file --cron $*"
        fi
      done
    else
      if [ -d "$SYSUPDATEDIR" ] && ls "$SYSUPDATEDIR"/* 1>/dev/null 2>&1; then
        file="$(ls -A $SYSUPDATEDIR/$1 2>/dev/null)"
        if [ -f "$file" ]; then
          appname="$(basename $file)"
          sudo file=$file bash -c "$file --cron $*"
        fi
      fi
    fi
  else
    if [ -z "$1" ] && [ -d "$USRUPDATEDIR" ] && ls "$USRUPDATEDIR"/* 1>/dev/null 2>&1; then
      for upd in $(ls $USRUPDATEDIR/); do
        file="$(ls -A $USRUPDATEDIR/$upd 2>/dev/null)"
        if [ -f "$file" ]; then
          appname="$(basename $file)"
          sudo file=$file bash -c "$file --cron $*"
        fi
      done
    else
      if [ -d "$USRUPDATEDIR" ] && ls "$USRUPDATEDIR"/* 1>/dev/null 2>&1; then
        file="$(ls -A $USRUPDATEDIR/$1 2>/dev/null)"
        if [ -f "$file" ]; then
          appname="$(basename $file)"
          sudo file=$file bash -c "$file --cron $*"
        fi
      fi
    fi
  fi
}

###################### backup functions ######################
#backupapp "directory" "filename"
__backupapp() {
  local filename count backupdir rmpre4vbackup
  [ ! -z "$1" ] && local myappdir="$1" || local myappdir="$APPDIR"
  [ ! -z "$2" ] && local myappname="$2" || local myappname="$APPNAME"
  local logdir="$HOME/.local/log/backups"
  local curdate="$(date +%Y-%m-%d-%H-%M-%S)"
  local filename="$myappname-$curdate.tar.gz"
  local backupdir="${MY_BACKUP_DIR:-$HOME/.local/backups}/${SCRIPTS_PREFIX:-apps}/"
  local count="$(ls $backupdir/$myappname*.tar.gz 2>/dev/null | wc -l 2>/dev/null)"
  local rmpre4vbackup="$(ls $backupdir/$myappname*.tar.gz 2>/dev/null | head -n 1)"
  __mkd "$backupdir" "$logdir"
  if [ -e "$myappdir" ] && [ ! -d $myappdir/.git ]; then
    echo -e "#################################" >>"$logdir/$myappname.log"
    echo -e "# Started on $(date +'%A, %B %d, %Y %H:%M:%S')" >>"$logdir/$myappname.log"
    echo -e "# Backing up $myappdir" >>"$logdir/$myappname.log"
    echo -e "#################################\n" >>"$logdir/$myappname.log"
    tar cfzv "$backupdir/$filename" "$myappdir" >>"$logdir/$myappname.log" 2>&1
    echo -e "\n#################################" >>"$logdir/$myappname.log"
    echo -e "# Ended on $(date +'%A, %B %d, %Y %H:%M:%S')" >>"$logdir/$myappname.log"
    echo -e "#################################\n\n" >>"$logdir/$myappname.log"
    [ -f "$APPDIR/.installed" ] || rm -Rf "$myappdir"
  fi
  if [ "$count" -gt "3" ]; then __rm_rf $rmpre4vbackup; fi
}
###################### menu functions ######################
__run_menu_start() { clear && __running "$1" && __start eval "$@" && return 0 || clear && echo -e "\n\n\n\n" && printf_red "$1 is already running" && sleep 5 && return 1; }
__run_menu_failed() { clear && echo -e "\n\n\n\n\n\n" && printf_red "${1:-An error has occured}" && sleep 3 && return 1; }
#attemp_install_menus "programname"
__attemp_install_menus() {
  local prog="$1"
  if (dialog --timeout 10 --trim --cr-wrap --colors --title "install $1" --yesno "$prog in not installed! \nshould I try to install it?" 15 40 || return 1); then
    sleep 2
    clear
    printf_custom "191" "\n\n\n\n\t\tattempting install of $prog\n\t\tThis could take a bit...\n\n\n"
    __devnull pkmgr silent "$1"
    [ "$?" -ne 0 ] && dialog --timeout 10 --trim --cr-wrap --colors --title "failed" --msgbox "$1 failed to install" 10 41 || clear
  fi
}

__custom_menus() {
  local custom
  # printf_custom_question "6" "Enter your custom program : "
  # read custom
  # printf_custom_question "6" "Enter any additional options [type file to choose] : "
  # read opts
  printf_read_question "6" "Enter your custom program : " "120" "custom"
  printf_read_question "6" "Enter any additional options [type file to choose] : " "120" "opts"
  if [ "$opts" = "file" ]; then opts="$(__open_file_menus $custom)"; fi
  __start $custom "$opts" 2>/dev/null || __run_menu_failed "$custom is an invalid program"
}

#open_file_menus
__open_file_menus() {
  local prog="$1"
  shift 1
  local args="$*"
  shift
  if __cmd_exists "$prog"; then
    local file=$(dialog --title "Play a file" --stdout --title "Please choose a file or url to play" --fselect "$HOME/" 14 48 || return 1)
    if [ -f "$file" ] || [ -d "$file" ]; then
      __run_menu_start "$prog" "$file" || __run_menu_failed
    else
      __run_menu_start "$prog" || __run_menu_failed
    fi
  else
    __attemp_install_menus "$prog" && __run_menu_start "$prog" "$args" || __run_menu_failed
  fi
}
#run_command "full command" - terminal apps
__run_command() {
  "$@" 2>/dev/null
  clear
}
#run_prog_menus - graphical apps
__run_prog_menus() {
  local prog="$1"
  shift 1
  local args="$*"
  shift
  if __cmd_exists "$prog"; then
    __run_menu_start "$prog" "$args"
  else
    __attemp_install_menus "$prog" && __run_menu_start "$prog" "$args"
  fi
}

__edit_menu() {
  local EDITOR="$EDITOR"
  [ -f "$1" ] && local file="$1" && shift 1 || local file="$file"
  [ -d "$1" ] && local dir="$1" && shift 1 || local dir="${WDIR:-$HOME}"
  if __cmd_exists dialog; then
    [ -n "$file" ] || file=$(dialog --title "Play a file" --stdout --title "Please choose a file to edit" --fselect "$dir/" 20 80 || __return 1)
    [ ! -f "$file" ] || __editor "$file" && __return 0 || __return 1 "Can not open file" "$file does not exists"
  else
    [ ! -f "$file" ] || __editor "$file" && __return 0 || __return 1 "Can not open file" "$file does not exists"
  fi
  __returnexitcode $?
}
##################### editor functions ####################
__editor() {
  local EDITOR="$EDITOR"
  if [ -n "$EDITOR" ]; then
    $EDITOR "$@"
  elif __cmd_exists myeditor; then
    myeditor "$@"
  elif __cmd_exists vim; then
    local vimoptions="$vimoptions"
    __vim ${vimoptions:-} "$@"
  elif __cmd_exists nano; then
    local nanooptions="$nanooptions"
    nano ${nanooptions:-} "$@"
  else
    printf_exit 1 1 "Can not open file: Please set the variable EDITOR=myeditor"
  fi
  return $?
}
##################### sudo functions ####################
__sudo() { sudo "$@"; }
sudoif() { (sudo -vn && sudo -ln) 2>&1 | grep -v 'may not' >/dev/null && return 0 || return 1; }
sudorun() { if sudoif; then sudo "$@"; else "$@"; fi; }
sudorerun() {
  local ARGS="$ARGS"
  if [[ $UID != 0 ]]; then if sudoif; then
    sudo "$APPNAME" "$ARGS"
    if [[ $? -ne 0 ]]; then
      exit 1
    fi
  else sudoreq; fi; fi
}

sudoreq() {
  if [[ $UID != 0 ]]; then
    printf_error "Please run this script with sudo\n"
    exit 1
  fi
}

__can_i_sudo() {
  (
    ISINDSUDO=$(sudo grep -Re "$USER" /etc/sudoers* | grep "ALL" >/dev/null)
    sudo -vn && sudo -ln
  ) 2>&1 | grep -v 'may not' >/dev/null
}

__sudoask() {
  if [ ! -f "$HOME/.sudo" ]; then
    sudo true &>/dev/null && return 0 || return 1
    while true; do
      echo "$$" >"$HOME/.sudo"
      sudo -n true
      sleep 10
      rm -Rf "$HOME/.sudo"
      kill -0 "$$" || return
    done &>/dev/null 2>/dev/null &
  fi
}

__sudoexit() {
  if __can_i_sudo; then
    __sudoask || printf_green "Getting privileges successfull continuing"
  else
    printf_red "Failed to get privileges\n"
  fi
}

__requiresudo() {
  if __can_i_sudo; then
    __sudoask && __sudoexit && __devnull2 sudo "$@" 2>/dev/null
  else
    printf_red "You dont have access to sudo\n\t\tPlease contact the syadmin for access"
    return 1
  fi
}

user_is_root() { if [[ $(id -u) -eq 0 ]] || [[ $EUID -eq 0 ]] || [[ "$WHOAMI" = "root" ]]; then return 0; else return 1; fi; }

###################### spinner and execute function ######################
#
__set_trap() { trap -p "$1" | grep "$2" &>/dev/null || trap '$2' "$1"; }
#
__kill_all_subprocesses() {
  local i=""
  for i in $(jobs -p); do
    kill "$i"
    wait "$i" &>/dev/null
  done
}
#
__execute() {
  local -r CMDS="$1"
  local -r MSG="${2:-$1}"
  local -r TMP_FILE="$(mktemp /tmp/XXXXX)"
  local exitCode=0
  local cmdsPID=""
  __set_trap "EXIT" "__kill_all_subprocesses"
  eval "$CMDS" &>/dev/null 2>"$TMP_FILE" &
  cmdsPID=$!
  __show_spinner "$cmdsPID" "$CMDS" "$MSG"
  wait "$cmdsPID" &>/dev/null
  exitCode=$?
  printf_execute_result $exitCode "$MSG"
  if [ $exitCode -ne 0 ]; then
    printf_execute_error_stream <"$TMP_FILE"
  fi
  rm -rf "$TMP_FILE"
  return $exitCode
}
#
__show_spinner() {
  local -r FRAMES='/-\|'
  local -r NUMBER_OR_FRAMES=${#FRAMES}
  local -r CMDS="$2"
  local -r MSG="$3"
  local -r PID="$1"
  local i=0
  local frameText=""
  while kill -0 "$PID" &>/dev/null; do
    frameText="                [${FRAMES:i++%NUMBER_OR_FRAMES:1}] $MSG"
    printf "%s" "$frameText"
    sleep 0.2
    printf "\r"
  done
}

###################### exitcode functions ######################
#setexitstatus || setexitstatus $?
__setexitstatus() {
  local EXIT="$?"
  if [ -z "$EXIT" ] || [ -n "$1" ]; then local EXIT="$1"; fi
  local EXITSTATUS+="$EXIT"
  if [ "$EXITSTATUS" -eq 0 ]; then
    BG_EXIT="${BG_GREEN}"
    unset EXIT
    return 0
  else
    BG_EXIT="${BG_RED}"
    unset EXIT
    return 1
  fi
}

#returnexitcode $?
__returnexitcode() {
  [ -z "$1" ] || EXIT="$1"
  if [ "$EXIT" -eq 0 ]; then
    BG_EXIT="${BG_GREEN}"
    PS_SYMBOL=" 😺 "
    return 0
  elif [ "$EXIT" -gt 2 ]; then
    BG_EXIT="${BG_RED}"
    PS_SYMBOL=" ⁉️ "
    return "$EXIT"
  else
    BG_EXIT="${BG_RED}"
    PS_SYMBOL=" 😟 "
    return "$EXIT"
  fi
}

#getexitcode "OK Message" "Error Message"
__getexitcode() {
  local EXITCODE="$?"
  if [ ! -z "$1" ]; then
    local PSUCCES="$1"
  elif [ ! -z "$SUCCES" ]; then
    local PSUCCES="$SUCCES"
  else
    local PSUCCES="Command successful"
  fi
  if [ ! -z "$2" ]; then
    local PERROR="$2"
  elif [ ! -z "$ERROR" ]; then
    local PERROR="$ERROR"
  else
    local PERROR="Last command failed to complete"
  fi
  if [ "$EXITCODE" -eq 0 ]; then
    printf_cyan "$PSUCCES"
  else
    printf_red "$PERROR"
  fi
  __returnexitcode "$EXITCODE"
  return "$EXITCODE"
}
#return "code" "message 1" "message 2"
__return() {
  #clear
  printf_newline "\n"
  if [ -n "$2" ]; then printf_red "$2"; fi
  if [ -n "$3" ]; then printf_red "$3"; fi
  return "$1"
}
###################### OS Functions ######################
#alternative names
mlocate() { __cmd_exists locate || __cmd_exists mlocate || return 1; }
xfce4() { __cmd_exists xfce4-about || return 1; }
imagemagick() { __cmd_exists convert || return 1; }
fdfind() { __cmd_exists fdfind || __cmd_exists fd || return 1; }
speedtest() { __cmd_exists speedtest-cli || __cmd_exists speedtest || return 1; }
neovim() { __cmd_exists nvim || __cmd_exists neovim || return 1; }
chromium() { __cmd_exists chromium || __cmd_exists chromium-browser || return 1; }
firefox() { __cmd_exists firefox-esr || __cmd_exists firefox || return 1; }
gtk-2.0() { find /lib* /usr* -iname "*libgtk*2*.so*" -type f | grep -q . || return 1; }
gtk-3.0() { find /lib* /usr* -iname "*libgtk*3*.so*" -type f | grep -q . || return 1; }
httpd() { __cmd_exists httpd || __cmd_exists apache2 || return 1; }

#notifications "title" "message"
__notifications() {
  local title="$1"
  shift 1
  local msg="$*"
  shift
  __cmd_exists notify-send && notify-send -u normal -i "notification-message-IM" "$title" "$msg" || return 0
}
#connection test
__am_i_online() {
  local site="1.1.1.1"
  [ -z "$FORCE_CONNECTION" ] || return 0
  return_code() {
    if [ "$1" = 0 ]; then
      return 0
    else
      return 1
    fi
  }
  __test_ping() {
    local site="$1"
    timeout 0.3 ping -c1 $site >/dev/null 2>&1
    local pingExit=$?
    return_code $pingExit
  }
  __test_http() {
    local site="$1"
    curl -LSIs --max-time 1 http://$site" | grep -e "HTTP/[0123456789]" | grep "200 -n1 >/dev/null 2>&1
    local httpExit=$?
    return_code $httpExit
  }
  err() { [ "$1" = "show" ] && printf_error "${3:-1}" "${2:-This requires internet, however, You appear to be offline!}" >&2; }
  __test_ping "$site" || __test_http "$site" || err "$@"
}
#am_i_online_err "Message" "color" "exitCode"
__am_i_online_err() { __am_i_online show "$@"; }
#setup clipboard
if [[ "$OSTYPE" =~ ^darwin ]]; then
  printclip() { __cmd_exists pbpaste && LC_CTYPE=UTF-8 tr -d "\n" | pbpaste || return 1; }
  putclip() { __cmd_exists pbcopy && LC_CTYPE=UTF-8 tr -d "\n" | pbcopy || return 1; }
fi
if [[ "$OSTYPE" =~ ^linux ]]; then
  printclip() { __cmd_exists xclip && xclip -o -s; }
  putclip() { __cmd_exists xclip && xclip -i -sel c || return 1; }
fi
#function to get network device
__getlipaddr() {
  if __cmd_exists route || __cmd_exists ip; then
    if [[ "$OSTYPE" =~ ^darwin ]]; then
      NETDEV="$(route get default | grep interface | awk '{print $2}')"
    else
      NETDEV="$(ip route | grep default | sed -e "s/^.*dev.//" -e "s/.proto.*//" | awk '{print $1}')"
    fi
    if __cmd_exists ifconfig; then
      CURRIP4="$(/sbin/ifconfig $NETDEV | grep -E "venet|inet" | grep -v "127.0.0." | grep 'inet' | grep -v inet6 | awk '{print $2}' | sed s/addr://g | head -n1)"
      CURRIP6="$(/sbin/ifconfig "$NETDEV" | grep -E "venet|inet" | grep 'inet6' | grep -i global | awk '{print $2}' | head -n1)"
    else
      CURRIP4="$(ip addr | grep inet | grep -vE "127|inet6" | tr '/' ' ' | awk '{print $2}' | head -n 1)"
      CURRIP6="$(ip addr | grep inet6 | grep -v "::1/" -v | tr '/' ' ' | awk '{print $2}' | head -n 1)"
    fi
  else
    NETDEV="lo"
    CURRIP4="127.0.0.1"
    CURRIP6="::1"
  fi
}

#os_support oses
__os_support() {
  if [ -n "$1" ]; then
    OSTYPE="$(echo $1 | tr '[:upper:]' '[:lower:]')"
  else
    OSTYPE="$(uname -s | tr '[:upper:]' '[:lower:]')"
  fi
  case "$OSTYPE" in
  linux*) echo "Linux" ;;
  mac* | darwin*) echo "MacOS" ;;
  win* | msys* | mingw* | cygwin*) echo "Windows" ;;
  bsd*) echo "BSD" ;;
  solaris*) echo "Solaris" ;;
  *) echo "Unknown OS" ;;
  esac
}
#supported_oses oses
__supported_oses() {
  if [[ $# -eq 0 ]]; then return 1; fi
  local ARGS="$*"
  for os in $ARGS; do
    UNAME="$(uname -s | tr '[:upper:]' '[:lower:]')"
    case "$os" in
    linux)
      if [[ "$UNAME" =~ ^linux ]]; then
        return 0
      else
        return 1
      fi
      ;;
    mac*)
      if [[ "$UNAME" =~ ^darwin ]]; then
        return 0
      else
        return 1
      fi
      ;;
    win*)
      if [[ "$UNAME" =~ ^ming ]]; then
        return 0
      else
        return 1
      fi
      ;;
    *) return ;;
    esac
  done
}
#unsupported_oses oses
__unsupported_oses() {
  for os in "$@"; do
    if [[ "$(echo $1 | tr '[:upper:]' '[:lower:]')" =~ $(os_support) ]]; then
      printf_red "\t\t$(os_support $os) is not supported\n"
      exit 1
    fi
  done
}
__if_os_id() {
  unset distroname distroversion distro_id distro_version
  if [ -f "/etc/os-release" ]; then
    #local distroname=$(grep "ID_LIKE=" /etc/os-release | sed 's#ID_LIKE=##' | tr '[:upper:]' '[:lower:]' | sed 's#"##g' | awk '{print $1}')
    local distroname=$(cat /etc/os-release | grep '^ID=' | sed 's#ID=##g' | sed 's#"##g' | tr '[:upper:]' '[:lower:]')
    local distroversion=$(cat /etc/os-release | grep '^VERSION="' | sed 's#VERSION="##g;s#"##g')
    local codename="$(grep VERSION_CODENAME /etc/os-release && cat /etc/os-release | grep ^VERSION_CODENAME | sed 's#VERSION_CODENAME="##g;s#"##g' || true)"
  elif [ -f "$(command -v lsb_release 2>/dev/null)" ]; then
    local distroname="$(lsb_release -a 2>/dev/null | grep 'Distributor ID' | awk '{print $3}' | tr '[:upper:]' '[:lower:]' | sed 's#"##g')"
    local distroversion="$(lsb_release -a 2>/dev/null | grep 'Release' | awk '{print $2}')"
  elif [ -f "$(command -v lsb-release 2>/dev/null)" ]; then
    local distroname="$(lsb-release -a 2>/dev/null | grep 'Distributor ID' | awk '{print $3}' | tr '[:upper:]' '[:lower:]' | sed 's#"##g')"
    local distroversion="$(lsb-release -a 2>/dev/null | grep 'Release' | awk '{print $2}')"
  elif [ -f "/etc/redhat-release" ]; then
    local distroname=$(cat /etc/redhat-release | awk '{print $1}' | tr '[:upper:]' '[:lower:]' | sed 's#"##g')
    local distroversion=$(cat /etc/redhat-release | awk '{print $4}' | tr '[:upper:]' '[:lower:]' | sed 's#"##g')
  elif [ -f "$(command -v sw_vers 2>/dev/null)" ]; then
    local distroname="darwin"
    local distroversion="$(sw_vers -productVersion)"
  else
    return 1
  fi
  local in="$*"
  local def="${DISTRO}"
  local args="$(echo "${*:-$def}" | tr '[:upper:]' '[:lower:]')"
  for id_like in $args; do
    case "$id_like" in
    arch* | arco*)
      if [[ $distroname =~ ^arco ]] || [[ "$distroname" =~ ^arch ]]; then
        distro_id=Arch
        distro_version="$(cat /etc/os-release | grep '^BUILD_ID' | sed 's#BUILD_ID=##g')"
        return 0
      else
        return 1
      fi
      ;;
    rhel* | centos* | fedora*)
      if [[ "$distroname" =~ ^scientific ]] || [[ "$distroname" =~ ^redhat ]] || [[ "$distroname" =~ ^centos ]] || [[ "$distroname" =~ ^casjay ]] || [[ "$distroname" =~ ^fedora ]]; then
        distro_id=RHEL
        distro_version="$distroversion"
        return 0
      else
        return 1
      fi
      ;;
    debian* | ubuntu*)
      if [[ "$distroname" =~ ^kali ]] || [[ "$distroname" =~ ^parrot ]] || [[ "$distroname" =~ ^debian ]] || [[ "$distroname" =~ ^raspbian ]] ||
        [[ "$distroname" =~ ^ubuntu ]] || [[ "$distroname" =~ ^linuxmint ]] || [[ "$distroname" =~ ^elementary ]] || [[ "$distroname" =~ ^kde ]]; then
        distro_id=Debian
        distro_version="$distroversion"
        distro_codename="$codename"
        return 0
      else
        return 1
      fi
      ;;
    darwin* | mac*)
      if [[ "$distroname" =~ ^mac ]] || [[ "$distroname" =~ ^darwin ]]; then
        distro_id=MacOS
        distro_version="$distroversion"
        return 0
      else
        return 1
      fi
      ;;
    *)
      return 1
      ;;
    esac
    # else
    #   return 1
    # fi
  done
  # [ -z $distro_id ] || distro_id="Unknown"
  # [ -z $distro_version ] || distro_version="Unknown"
  # [ -n "$codename" ] && distro_codename="$codename" || distro_codename="N/A"
  # echo $id_like $distroname $distroversion $distro_codename
}

###################### setup folders - user ######################
user_installdirs() {
  if [[ $(id -u) -eq 0 ]] || [[ $EUID -eq 0 ]] || [[ "$WHOAMI" = "root" ]]; then
    INSTALL_TYPE=user
    HOME="/usr/local/home/root"
    BIN="$HOME/.local/bin"
    CONF="$HOME/.config"
    SHARE="$HOME/.local/share"
    LOGDIR="$HOME/.local/log"
    STARTUP="$HOME/.config/autostart"
    SYSBIN="/usr/local/bin"
    SYSCONF="/usr/local/etc"
    SYSSHARE="/usr/local/share"
    SYSLOGDIR="/usr/local/log"
    BACKUPDIR="$HOME/.local/backups"
    COMPDIR="$HOME/.local/share/bash-completion/completions"
    THEMEDIR="$SHARE/themes"
    ICONDIR="$SHARE/icons"
    FONTDIR="$SHARE/fonts"
    FONTCONF="$SYSCONF/fontconfig/conf.d"
    CASJAYSDEVSHARE="$SHARE/CasjaysDev"
    CASJAYSDEVSAPPDIR="$CASJAYSDEVSHARE/apps"
    WALLPAPERS="${WALLPAPERS:-$SYSSHARE/wallpapers}"
    USRUPDATEDIR="$SHARE/CasjaysDev/apps/${SCRIPTS_PREFIX:-dfmgr}"
    SYSUPDATEDIR="$SYSSHARE/CasjaysDev/apps/${SCRIPTS_PREFIX:-dfmgr}"
    SYSTEMDDIR="/etc/systemd/system"
  else
    INSTALL_TYPE=user
    HOME="${HOME}"
    BIN="$HOME/.local/bin"
    CONF="$HOME/.config"
    SHARE="$HOME/.local/share"
    LOGDIR="$HOME/.local/log"
    STARTUP="$HOME/.config/autostart"
    SYSBIN="$HOME/.local/bin"
    SYSCONF="$HOME/.config"
    SYSSHARE="$HOME/.local/share"
    SYSLOGDIR="$HOME/.local/log"
    BACKUPDIR="$HOME/.local/backups"
    COMPDIR="$HOME/.local/share/bash-completion/completions"
    THEMEDIR="$SHARE/themes"
    ICONDIR="$SHARE/icons"
    FONTDIR="$SHARE/fonts"
    FONTCONF="$SYSCONF/fontconfig/conf.d"
    CASJAYSDEVSHARE="$SHARE/CasjaysDev"
    CASJAYSDEVSAPPDIR="$CASJAYSDEVSHARE/apps"
    WALLPAPERS="$HOME/.local/share/wallpapers"
    USRUPDATEDIR="$SHARE/CasjaysDev/apps/${SCRIPTS_PREFIX:-dfmgr}"
    SYSUPDATEDIR="$SYSSHARE/CasjaysDev/apps/${SCRIPTS_PREFIX:-dfmgr}"
    SYSTEMDDIR="$HOME/.config/systemd/user"
  fi
  APPDIR=""
  SCRIPTS_PREFIX="${SCRIPTS_PREFIX:-dfmgr}"
  REPORAW="${REPORAW:-$DFMGRREPO/$APPNAME/raw}"
  INSTDIR="${INSTDIR:-$SHARE/CasjaysDev/installed/$SCRIPTS_PREFIX/$APPNAME}"
  export installtype="user_installdirs"
}

###################### setup folders - system ######################
system_installdirs() {
  APPNAME="${APPNAME:-installer}"
  if [[ $(id -u) -eq 0 ]] || [[ $EUID -eq 0 ]] || [[ "$WHOAMI" = "root" ]]; then
    BACKUPDIR="$HOME/.local/backups"
    BIN="/usr/local/bin"
    CONF="/usr/local/etc"
    SHARE="/usr/local/share"
    LOGDIR="/usr/local/log"
    STARTUP="/dev/null"
    SYSBIN="/usr/local/bin"
    SYSCONF="/usr/local/etc"
    SYSSHARE="/usr/local/share"
    SYSLOGDIR="/usr/local/log"
    COMPDIR="/etc/bash_completion.d"
    THEMEDIR="/usr/local/share/themes"
    ICONDIR="/usr/local/share/icons"
    FONTDIR="/usr/local/share/fonts"
    FONTCONF="/usr/local/share/fontconfig/conf.d"
    CASJAYSDEVSHARE="/usr/local/share/CasjaysDev"
    CASJAYSDEVSAPPDIR="/usr/local/share/CasjaysDev/apps"
    WALLPAPERS="/usr/local/share/wallpapers"
    USRUPDATEDIR="/usr/local/share/CasjaysDev/apps/${SCRIPTS_PREFIX:-dfmgr}"
    SYSUPDATEDIR="/usr/local/share/CasjaysDev/apps/${SCRIPTS_PREFIX:-dfmgr}"
    SYSTEMDDIR="/etc/systemd/system"
  else
    INSTALL_TYPE=system
    HOME="${HOME:-/home/$WHOAMI}"
    BACKUPDIR="${BACKUPS:-$HOME/.local/backups}"
    BIN="$HOME/.local/bin"
    CONF="$HOME/.config"
    SHARE="$HOME/.local/share"
    LOGDIR="$HOME/.local/log"
    STARTUP="$HOME/.config/autostart"
    SYSBIN="$HOME/.local/bin"
    SYSCONF="$HOME/.local/etc"
    SYSSHARE="/usr/local/share"
    SYSLOGDIR="$HOME/.local/log"
    COMPDIR="$HOME/.local/share/bash-completion/completions"
    THEMEDIR="$HOME/.local/share/themes"
    ICONDIR="$HOME/.local/share/icons"
    FONTDIR="$HOME/.local/share/fonts"
    FONTCONF="$HOME/.local/share/fontconfig/conf.d"
    CASJAYSDEVSHARE="$HOME/.local/share/CasjaysDev"
    CASJAYSDEVSAPPDIR="$HOME/.local/share/CasjaysDev/apps"
    WALLPAPERS="$HOME/.local/share/wallpapers"
    USRUPDATEDIR="$HOME/.local/share/CasjaysDev/apps/${SCRIPTS_PREFIX:-dfmgr}"
    SYSUPDATEDIR="/usr/local/share/CasjaysDev/apps/${SCRIPTS_PREFIX:-dfmgr}"
    SYSTEMDDIR="$HOME/.config/systemd/user"
  fi
  APPDIR=""
  SCRIPTS_PREFIX="${SCRIPTS_PREFIX:-dfmgr}"
  REPORAW="${REPORAW:-$DFMGRREPO/$APPNAME/raw}"
  INSTDIR="${INSTDIR:-$SHARE/CasjaysDev/installed/$SCRIPTS_PREFIX/$APPNAME}"
  export installtype="system_installdirs"
}

user_install() { user_installdirs; }
system_install() { system_installdirs; }

user_install # default type
###################### dfmgr settings ######################
dfmgr_install() {
  user_installdirs
  SCRIPTS_PREFIX="dfmgr"
  APPDIR="${APPDIR:-$CONF}"
  INSTDIR="$SHARE/CasjaysDev/installed/$SCRIPTS_PREFIX"
  REPO="$DFMGRREPO"
  REPORAW="$REPO/$APPNAME/raw"
  USRUPDATEDIR="$SHARE/CasjaysDev/apps/dfmgr"
  SYSUPDATEDIR="/usr/local/share/CasjaysDev/apps/dfmgr"
  INSTDIR="$SHARE/CasjaysDev/installed/$SCRIPTS_PREFIX"
  ARRAY="$(cat /usr/local/share/CasjaysDev/scripts/helpers/$SCRIPTS_PREFIX/array)"
  LIST="$(cat /usr/local/share/CasjaysDev/scripts/helpers/$SCRIPTS_PREFIX/list)"
  [ "$APPNAME" = "$SCRIPTS_PREFIX" ] && APPDIR="${APPDIR//$APPNAME\/$SCRIPTS_PREFIX/$APPNAME}"
  [ -f "$CASJAYSDEVSAPPDIR/dotfiles/$SCRIPTS_PREFIX-$APPNAME" ] && APPVERSION="$(cat $CASJAYSDEVSAPPDIR/dotfiles/$SCRIPTS_PREFIX-$APPNAME)" || APPVERSION="N/A"
  __mkd "$USRUPDATEDIR"
  user_is_root && __mkd "$SYSUPDATEDIR"
  export installtype="dfmgr_install"

  ######## Installer Functions ########
  dfmgr_run_post() {
    dfmgr_install
    run_postinst_global
    [ -d "$APPDIR" ] && replace "$APPDIR" "replacehome" "$HOME"
    [ -d "$APPDIR" ] && replace "$APPDIR" "/home/jason" "$HOME"
  }

  dfmgr_install_version() {
    dfmgr_install
    install_version
    mkdir -p "$CASJAYSDEVSAPPDIR/dfmgr" "$CASJAYSDEVSAPPDIR/dfmgr"
    if [ -f "$APPDIR/install.sh" ] && [ -f "$APPDIR/version.txt" ]; then
      __ln_sf "$APPDIR/install.sh" "$CASJAYSDEVSAPPDIR/dfmgr/$APPNAME"
    fi
  }
}

###################### devenv settings ######################
devenvmgr_install() {
  user_installdirs
  SCRIPTS_PREFIX="devenv"
  APPDIR="${APPDIR:-$SHARE}"
  INSTDIR="$SHARE/CasjaysDev/installed/$SCRIPTS_PREFIX"
  REPO="$DEVENVMGRREPO"
  REPORAW="$REPO/$APPNAME/raw"
  USRUPDATEDIR="$SHARE/CasjaysDev/apps/devenv"
  SYSUPDATEDIR="/usr/local/share/CasjaysDev/devenv"
  INSTDIR="$SHARE/CasjaysDev/installed/$SCRIPTS_PREFIX"
  ARRAY="$(cat /usr/local/share/CasjaysDev/scripts/helpers/$SCRIPTS_PREFIX/array)"
  LIST="$(cat /usr/local/share/CasjaysDev/scripts/helpers/$SCRIPTS_PREFIX/list)"
  [ "$APPNAME" = "$SCRIPTS_PREFIX" ] && APPDIR="${APPDIR//$APPNAME\/$SCRIPTS_PREFIX/$APPNAME}"
  [ -f "$CASJAYSDEVSAPPDIR/dotfiles/$SCRIPTS_PREFIX-$APPNAME" ] && APPVERSION="$(cat $CASJAYSDEVSAPPDIR/dotfiles/$SCRIPTS_PREFIX-$APPNAME)" || APPVERSION="N/A"
  __mkd "$USRUPDATEDIR"
  user_is_root && __mkd "$SYSUPDATEDIR"
  export installtype="devenvmgr_install"

  ######## Installer Functions ########
  devenvmgr_run_post() {
    devenvmgr_install
    run_postinst_global
    [ -d "$APPDIR" ] && replace "$APPDIR" "/home/jason" "$HOME"
  }

  devenvmgr_install_version() {
    devenvmgr_install
    install_version
    mkdir -p "$CASJAYSDEVSAPPDIR/devenvmgr" "$CASJAYSDEVSAPPDIR/devenvmgr"
    if [ -f "$APPDIR/install.sh" ] && [ -f "$APPDIR/version.txt" ]; then
      __ln_sf "$APPDIR/install.sh" "$CASJAYSDEVSAPPDIR/dockermgr/$APPNAME"
    fi
  }
}

###################### dockermgr settings ######################
dockermgr_install() {
  user_installdirs
  SCRIPTS_PREFIX="dockermgr"
  APPDIR="${APPDIR:-$SHARE}"
  INSTDIR="$SHARE/CasjaysDev/installed/$SCRIPTS_PREFIX"
  REPO="$DFMGRREPO"
  REPORAW="$REPO/$APPNAME/raw"
  USRUPDATEDIR="$SHARE/CasjaysDev/apps/dockermgr"
  SYSUPDATEDIR="/usr/local/share/CasjaysDev/apps/dockermgr"
  INSTDIR="$SHARE/CasjaysDev/installed/$SCRIPTS_PREFIX"
  APPVERSION="$(__appversion ${REPO:-https://github.com/$SCRIPTS_PREFIX}/$APPNAME/raw/master/version.txt)"
  ARRAY="$(cat /usr/local/share/CasjaysDev/scripts/helpers/$SCRIPTS_PREFIX/array)"
  LIST="$(cat /usr/local/share/CasjaysDev/scripts/helpers/$SCRIPTS_PREFIX/list)"
  [ "$APPNAME" = "$SCRIPTS_PREFIX" ] && APPDIR="${APPDIR//$APPNAME\/$SCRIPTS_PREFIX/$APPNAME}"
  [ -f "$CASJAYSDEVSAPPDIR/dotfiles/$SCRIPTS_PREFIX-$APPNAME" ] && APPVERSION="$(cat $CASJAYSDEVSAPPDIR/dotfiles/$SCRIPTS_PREFIX-$APPNAME)" || APPVERSION="N/A"
  __mkd "$USRUPDATEDIR"
  user_is_root && __mkd "$SYSUPDATEDIR"
  export installtype="dockermgr_install"

  ######## Installer Functions ########
  dockermgr_run_post() {
    dockermgr_install
    run_postinst_global
    [ -d "$APPDIR" ] && replace "$APPDIR" "/home/jason" "$HOME"
  }

  dockermgr_install_version() {
    dockermgr_install
    install_version
    mkdir -p "$CASJAYSDEVSAPPDIR/dockermgr" "$CASJAYSDEVSAPPDIR/dockermgr"
    if [ -f "$APPDIR/install.sh" ] && [ -f "$APPDIR/version.txt" ]; then
      __ln_sf "$APPDIR/install.sh" "$CASJAYSDEVSAPPDIR/dockermgr/$APPNAME"
    fi
  }

}

###################### fontmgr settings ######################
fontmgr_install() {
  system_installdirs
  SCRIPTS_PREFIX="fontmgr"
  APPDIR="${APPDIR:-$SHARE/CasjaysDev/$SCRIPTS_PREFIX}"
  INSTDIR="$SHARE/CasjaysDev/installed/$SCRIPTS_PREFIX"
  REPO="$FONTMGRREPO"
  REPORAW="$REPO/$APPNAME/raw"
  USRUPDATEDIR="$SHARE/CasjaysDev/apps/fontmgr"
  SYSUPDATEDIR="/usr/local/share/CasjaysDev/apps/fontmgr"
  FONTDIR="${FONTDIR:-$SHARE/fonts}"
  ARRAY="$(cat /usr/local/share/CasjaysDev/scripts/helpers/$SCRIPTS_PREFIX/array)"
  LIST="$(cat /usr/local/share/CasjaysDev/scripts/helpers/$SCRIPTS_PREFIX/list)"
  [ "$APPNAME" = "$SCRIPTS_PREFIX" ] && APPDIR="${APPDIR//$APPNAME\/$SCRIPTS_PREFIX/$APPNAME}"
  [ -f "$CASJAYSDEVSAPPDIR/dotfiles/$SCRIPTS_PREFIX-$APPNAME" ] && APPVERSION="$(cat $CASJAYSDEVSAPPDIR/dotfiles/$SCRIPTS_PREFIX-$APPNAME)" || APPVERSION="N/A"
  __mkd "$USRUPDATEDIR"
  __mkd "$FONTDIR" "$HOMEDIR"
  user_is_root && __mkd "$SYSUPDATEDIR"
  export installtype="fontmgr_install"

  ######## Installer Functions ########
  generate_font_index() {
    printf_green "Updating the fonts in $FONTDIR"
    FONTDIR="${FONTDIR:-$SHARE/fonts}"
    fc-cache -f "$FONTDIR"
  }
  fontmgr_run_post() {
    fontmgr_install
    run_postinst_global
    if [ -d "$HOME/Library/Fonts" ] && [ -d "$APPDIR/fonts" ]; then
      __ln_sf "$APPDIR/fonts" "$HOME/Library/Fonts"
    fi
    fc-cache -f "$ICONDIR"
  }

  fontmgr_install_version() {
    fontmgr_install
    install_version
    mkdir -p "$CASJAYSDEVSAPPDIR/fontmgr" "$CASJAYSDEVSAPPDIR/fontmgr"
    if [ -f "$APPDIR/install.sh" ] && [ -f "$APPDIR/version.txt" ]; then
      __ln_sf "$APPDIR/install.sh" "$CASJAYSDEVSAPPDIR/fontmgr/$APPNAME"
    fi
  }

}

###################### iconmgr settings ######################
iconmgr_install() {
  system_installdirs
  SCRIPTS_PREFIX="iconmgr"
  APPDIR="${APPDIR:-$SYSSHARE/CasjaysDev/iconmgr}"
  INSTDIR="$SHARE/CasjaysDev/installed/$SCRIPTS_PREFIX"
  REPO="$ICONMGRREPO"
  REPORAW="$REPO/$APPNAME/raw"
  USRUPDATEDIR="$SHARE/CasjaysDev/apps/iconmgr"
  SYSUPDATEDIR="/usr/local/share/CasjaysDev/apps/iconmgr"
  ICONDIR="${ICONDIR:-$SHARE/icons}"
  ARRAY="$(cat /usr/local/share/CasjaysDev/scripts/helpers/$SCRIPTS_PREFIX/array)"
  LIST="$(cat /usr/local/share/CasjaysDev/scripts/helpers/$SCRIPTS_PREFIX/list)"
  [ "$APPNAME" = "$SCRIPTS_PREFIX" ] && APPDIR="${APPDIR//$APPNAME\/$SCRIPTS_PREFIX/$APPNAME}"
  [ -f "$CASJAYSDEVSAPPDIR/dotfiles/$SCRIPTS_PREFIX-$APPNAME" ] && APPVERSION="$(cat $CASJAYSDEVSAPPDIR/dotfiles/$SCRIPTS_PREFIX-$APPNAME)" || APPVERSION="N/A"
  __mkd "$USRUPDATEDIR"
  __mkd "$ICONDIR"
  user_is_root && __mkd "$SYSUPDATEDIR"
  export installtype="iconmgr_install"

  ######## Installer Functions ########
  generate_icon_index() {
    printf_green "Updating the icon cache in $ICONDIR"
    ICONDIR="${ICONDIR:-$SHARE/icons}"
    fc-cache -f "$ICONDIR"
  }

  iconmgr_run_post() {
    iconmgr_install
    run_postinst_global
    [ -d "$ICONDIR/$APPNAME" ] || __ln_sf "$APPDIR" "$ICONDIR/$APPNAME"
    devnull sudo find "$ICONDIR/$APPNAME" -type d -exec chmod 755 {} \;
    devnull sudo find "$ICONDIR/$APPNAME" -type f -exec chmod 644 {} \;
    devnull sudo gtk-update-icon-cache -q -t -f "$ICONDIR/$APPNAME"
  }

  iconmgr_install_version() {
    iconmgr_install
    install_version
    mkdir -p "$CASJAYSDEVSAPPDIR/iconmgr" "$CASJAYSDEVSAPPDIR/apps/iconmgr"
    if [ -f "$APPDIR/install.sh" ] && [ -f "$APPDIR/version.txt" ]; then
      __ln_sf "$APPDIR/install.sh" "$CASJAYSDEVSAPPDIR/iconmgr/$APPNAME"
    fi
  }

}

###################### pkmgr settings ######################
pkmgr_install() {
  system_installdirs
  SCRIPTS_PREFIX="pkmgr"
  APPDIR="${APPDIR:-$SYSSHARE/CasjaysDev/pkmgr}"
  INSTDIR="$SHARE/CasjaysDev/installed/$SCRIPTS_PREFIX"
  REPO="$PKMGRREPO"
  REPORAW="$REPO/$APPNAME/raw"
  USRUPDATEDIR="$SHARE/CasjaysDev/apps/pkmgr"
  SYSUPDATEDIR="/usr/local/share/CasjaysDev/apps/pkmgr"
  REPODF="https://raw.githubusercontent.com/pkmgr/dotfiles/master"
  ARRAY="$(cat /usr/local/share/CasjaysDev/scripts/helpers/$SCRIPTS_PREFIX/array)"
  LIST="$(cat /usr/local/share/CasjaysDev/scripts/helpers/$SCRIPTS_PREFIX/list)"
  [ -f "$CASJAYSDEVSAPPDIR/dotfiles/$SCRIPTS_PREFIX-$APPNAME" ] && APPVERSION="$(cat $CASJAYSDEVSAPPDIR/dotfiles/$SCRIPTS_PREFIX-$APPNAME)" || APPVERSION="N/A"
  __mkd "$USRUPDATEDIR"
  user_is_root && __mkd "$SYSUPDATEDIR"
  export installtype="pkmgr_install"

  ######## Installer Functions ########
  pkmgr_run_postinst() {
    pkmgr_install
    run_postinst_global
  }

  pkmgr_install_version() {
    pkmgr_install
    install_version
    mkdir -p "$CASJAYSDEVSAPPDIR/pkmgr" "$CASJAYSDEVSAPPDIR/pkmgr"
    if [ -f "$APPDIR/install.sh" ] && [ -f "$APPDIR/version.txt" ]; then
      __ln_sf "$APPDIR/install.sh" "$CASJAYSDEVSAPPDIR/pkmgr/$APPNAME"
    fi
  }
}

###################### systemmgr settings ######################
systemmgr_install() {
  __requiresudo "true"
  system_installdirs
  SCRIPTS_PREFIX="systemmgr"
  APPDIR="${APPDIR:-/usr/local/etc/$APPNAME}"
  INSTDIR="$SHARE/CasjaysDev/installed/$SCRIPTS_PREFIX"
  REPO="$SYSTEMMGRREPO"
  REPORAW="$REPO/$APPNAME/raw"
  CONF="/usr/local/etc"
  SHARE="/usr/local/share"
  USRUPDATEDIR="/usr/local/share/CasjaysDev/apps/systemmgr"
  SYSUPDATEDIR="/usr/local/share/CasjaysDev/apps/systemmgr"
  ARRAY="$(cat /usr/local/share/CasjaysDev/scripts/helpers/$SCRIPTS_PREFIX/array)"
  LIST="$(cat /usr/local/share/CasjaysDev/scripts/helpers/$SCRIPTS_PREFIX/list)"
  [ -f "$CASJAYSDEVSAPPDIR/dotfiles/$SCRIPTS_PREFIX-$APPNAME" ] && APPVERSION="$(cat $CASJAYSDEVSAPPDIR/dotfiles/$SCRIPTS_PREFIX-$APPNAME)" || APPVERSION="N/A"
  __mkd "$USRUPDATEDIR"
  user_is_root && __mkd "$SYSUPDATEDIR"
  export installtype="systemmgr_install"

  ######## Installer Functions ########
  systemmgr_run_postinst() {
    systemmgr_install
    run_postinst_global
  }

  systemmgr_install_version() {
    systemmgr_install
    install_version
    __mkd "$SYSUPDATEDIR"
    if [ -f "$APPDIR/install.sh" ] && [ -f "$APPDIR/version.txt" ]; then
      __ln_sf "$APPDIR/install.sh" "$CASJAYSDEVSAPPDIR/systemmgr/$APPNAME"
    fi

  }
}

###################### thememgr settings ######################
thememgr_install() {
  system_installdirs
  SCRIPTS_PREFIX="thememgr"
  APPDIR="${APPDIR:-$SYSSHARE/CasjaysDev/thememgr/$APPNAME}"
  INSTDIR="$SHARE/CasjaysDev/installed/$SCRIPTS_PREFIX"
  REPO="$THEMEMGRREPO"
  REPORAW="$REPO/$APPNAME/raw"
  USRUPDATEDIR="$SHARE/CasjaysDev/apps/thememgr"
  SYSUPDATEDIR="/usr/local/share/CasjaysDev/apps/thememgr"
  THEMEDIR="${THEMEDIR:-$SHARE/themes}"
  ARRAY="$(cat /usr/local/share/CasjaysDev/scripts/helpers/$SCRIPTS_PREFIX/array)"
  LIST="$(cat /usr/local/share/CasjaysDev/scripts/helpers/$SCRIPTS_PREFIX/list)"
  [ "$APPNAME" = "$SCRIPTS_PREFIX" ] && APPDIR="${APPDIR//$APPNAME\/$SCRIPTS_PREFIX/$APPNAME}"
  [ -f "$CASJAYSDEVSAPPDIR/dotfiles/$SCRIPTS_PREFIX-$APPNAME" ] && APPVERSION="$(cat $CASJAYSDEVSAPPDIR/dotfiles/$SCRIPTS_PREFIX-$APPNAME)" || APPVERSION="N/A"
  __mkd "$USRUPDATEDIR"
  user_is_root && __mkd "$SYSUPDATEDIR"
  export installtype="thememgr_install"

  ######## Installer Functions ########
  generate_theme_index() {
    printf_green "Updating the theme index in $THEMEDIR"
    THEMEDIR="${THEMEDIR:-$SHARE/themes}"
    sudo find "$THEMEDIR" -mindepth 1 -maxdepth 2 -type d -not -path "*/.git/*" | while read -r THEME; do
      if [ -f "$THEME/index.theme" ]; then
        __cmd_exists gtk-update-icon-cache && gtk-update-icon-cache -f -q "$THEME"
      fi
    done
  }
  thememgr_run_post() {
    thememgr_install
    run_postinst_global
    [ -d "$THEMEDIR/$APPNAME" ] || __ln_sf "$APPDIR" "$THEMEDIR/$APPNAME"
    generate_theme_index
  }

  thememgr_install_version() {
    thememgr_install
    install_version
    __mkd "$CASJAYSDEVSAPPDIR/thememgr" "$CASJAYSDEVSAPPDIR/thememgr"
    if [ -f "$APPDIR/install.sh" ] && [ -f "$APPDIR/version.txt" ]; then
      __ln_sf "$APPDIR/install.sh" "$CASJAYSDEVSAPPDIR/thememgr/$APPNAME"
    fi
  }

}

###################### wallpapermgr settings ######################
wallpapermgr_install() {
  system_installdirs
  SCRIPTS_PREFIX="wallpapermgr"
  APPDIR="${APPDIR:-$SYSSHARE/CasjaysDev/wallpapers/$APPNAME}"
  INSTDIR="${INSTDIR:-$SHARE/CasjaysDev/installed/$SCRIPTS_PREFIX/$APPNAME}"
  REPO="${WALLPAPERMGRREPO}"
  REPORAW="$REPO/$APPNAME/raw"
  USRUPDATEDIR="$SHARE/CasjaysDev/apps/wallpapermgr"
  SYSUPDATEDIR="/usr/local/share/CasjaysDev/apps/wallpapermgr"
  WALLPAPERS="${WALLPAPERS:-$SHARE/wallpapers}"
  ARRAY="$(cat /usr/local/share/CasjaysDev/scripts/helpers/$SCRIPTS_PREFIX/array)"
  LIST="$(cat /usr/local/share/CasjaysDev/scripts/helpers/$SCRIPTS_PREFIX/list)"
  [ "$APPNAME" = "$SCRIPTS_PREFIX" ] && APPDIR="${APPDIR//$APPNAME\/$SCRIPTS_PREFIX/$APPNAME}"
  [ -f "$CASJAYSDEVSAPPDIR/dotfiles/$SCRIPTS_PREFIX-$APPNAME" ] && APPVERSION="$(cat $CASJAYSDEVSAPPDIR/dotfiles/$SCRIPTS_PREFIX-$APPNAME)" || APPVERSION="N/A"
  __mkd "$WALLPAPERS"
  __mkd "$USRUPDATEDIR"
  user_is_root && __mkd "$SYSUPDATEDIR"
  export installtype="wallpapermgr_install"

  ######## Installer Functions ########
  wallpapermgr_run_postinst() {
    wallpapermgr_install
    run_postinst_global
  }

  wallpaper_install_version() {
    wallpapermgr_install
    __mkd "$CASJAYSDEVSAPPDIR/wallpapermgr" "$CASJAYSDEVSAPPDIR/wallpapermgr"
    if [ -f "$APPDIR/install.sh" ] && [ -f "$APPDIR/version.txt" ]; then
      __ln_sf "$APPDIR/install.sh" "$CASJAYSDEVSAPPDIR/wallpapermgr/$APPNAME"
    fi
  }
}

###################### create directories ######################
ensure_dirs() {
  if [[ $EUID -ne 0 ]] || [[ "$WHOAMI" != "root" ]]; then
    __mkd "$BIN"
    __mkd "$SHARE"
    __mkd "$LOGDIR"
    __mkd "$LOGDIR/dfmgr"
    __mkd "$LOGDIR/fontmg"
    __mkd "$LOGDIR/iconmgr"
    __mkd "$LOGDIR/systemmgr"
    __mkd "$LOGDIR/thememgr"
    __mkd "$LOGDIR/wallpapermgr"
    __mkd "$COMPDIR"
    __mkd "$STARTUP"
    __mkd "$BACKUPDIR"
    __mkd "$FONTDIR"
    __mkd "$ICONDIR"
    __mkd "$THEMEDIR"
    __mkd "$FONTCONF"
    __mkd "$CASJAYSDEVSHARE"
    __mkd "$CASJAYSDEVSAPPDIR"
    __mkd "$USRUPDATEDIR"
    __mkd "$SHARE/applications"
    __mkd "$SHARE/CasjaysDev/functions"
    __mkd "$SHARE/wallpapers/system"
    user_is_root && __mkd "$SYSUPDATEDIR"
  fi
  return 0
}

path_info() { echo "$PATH" | tr ':' '\n' | sort -u; }
###################### debug settings ######################
__debug() {
  printf_info "APPNAME:                   $APPNAME"
  printf_info "App Dir:                   $APPDIR"
  printf_info "Install Dir:               $INSTDIR"
  printf_info "UserHomeDir:               $HOME"
  printf_info "UserBinDir:                $BIN"
  printf_info "UserConfDir:               $CONF"
  printf_info "UserShareDir:              $SHARE"
  printf_info "UserLogDir:                $LOGDIR"
  printf_info "UserStartDir:              $STARTUP"
  printf_info "SysConfDir:                $SYSCONF"
  printf_info "SysBinDir:                 $SYSBIN"
  printf_info "SysConfDir:                $SYSCONF"
  printf_info "SysShareDir:               $SYSSHARE"
  printf_info "SysLogDir:                 $SYSLOGDIR"
  printf_info "SysBackUpDir:              $BACKUPDIR"
  printf_info "ApplicationsDir:           $SHARE/applications"
  printf_info "IconDir:                   $ICONDIR"
  printf_info "ThemeDir                   $THEMEDIR"
  printf_info "FontDir:                   $FONTDIR"
  printf_info "FontConfDir:               $FONTCONF"
  printf_info "CompletionsDir:            $COMPDIR"
  printf_info "CasjaysDevDir:             $CASJAYSDEVSHARE"
  printf_info "CASJAYSDEVSAPPDIR:         $CASJAYSDEVSAPPDIR"
  printf_info "USRUPDATEDIR:              $USRUPDATEDIR"
  printf_info "SYSUPDATEDIR:              $SYSUPDATEDIR"
  printf_info "DOTFILESREPO:              $DOTFILESREPO"
  printf_info "DevEnv Repo:               $DEVENVMGRREPO"
  printf_info "Package Manager Repo:      $PKMGRREPO"
  printf_info "Icon Manager Repo:         $ICONMGRREPO"
  printf_info "Font Manager Repo:         $FONTMGRREPO"
  printf_info "Theme Manager Repo         $THEMEMGRREPO"
  printf_info "System Manager Repo:       $SYSTEMMGRREPO"
  printf_info "Wallpaper Manager Repo:    $WALLPAPERMGRREPO"
  printf_info "InstallType:               $installtype"
  printf_info "Prefix:                    $SCRIPTS_PREFIX"
  printf_info "SystemD dir:               $SYSTEMDDIR"
  if [[ $? -ne 0 ]]; then
    exit 1
  fi
}

###################### get info from app ######################
get_app_info() {
  local APPNAME="${APPNAME:-$(basename $0)}"
  local FILE="$(command -v $APPNAME)"
  if [ -f "$(command -v $FILE)" ]; then
    printf_green ""
    printf_green "Getting info for $APPNAME"
    cat "$FILE" | grep '^# @' | grep '  :' >/dev/null 2>&1 &&
      cat "$FILE" | grep "^# @" | grep '  :' | sed 's/# @//g' | printf_readline "3" &&
      printf_green "$(cat $FILE | grep "##@Version" | sed 's/##@//g')" ||
      printf_red "File was found, however, No information was provided"
  else
    printf_red "File was not found"
  fi
  exit 0
}

###################### get installer versions ######################

get_installer_version() {
  if [ -f "$INSTDIR/version.txt" ]; then
    local version="$(cat "$INSTDIR/version.txt" | grep -v "#" | tail -n 1)"
  else
    local version="0000000"
  fi
  local GITREPO=""$REPO/$APPNAME""
  local APPVERSION="${APPVERSION:-$(__appversion)}"
  [ -n "$WHOAMI" ] && printf_info "WhoamI:                    $WHOAMI"
  [ -n "$INSTALL_TYPE" ] && printf_info "Install Type:              $INSTALL_TYPE"
  [ -n "$APPNAME" ] && printf_info "APP name:                  $APPNAME"
  [ -n "$APPDIR" ] && printf_info "APP dir:                   $APPDIR"
  [ -n "$INSTDIR" ] && printf_info "Downloaded to:             $INSTDIR"
  [ -n "$GITREPO" ] && printf_info "APP repo:                  $REPO/$APPNAME"
  [ -n "$PLUGNAMES" ] && printf_info "Plugins:                   $PLUGNAMES"
  [ -n "$PLUGDIR" ] && printf_info "PluginsDir:                $PLUGDIR"
  [ -n "$version" ] && printf_info "Installed Version:         $version"
  [ -n "$APPVERSION" ] && printf_info "Online Version:            $APPVERSION"
  if [ "$version" = "$APPVERSION" ]; then
    printf_info "Update Available:          No"
  else
    printf_info "Update Available:          Yes"
  fi
}

###################### help ######################

__help() {
  #----------------
  printf_color() { printf "%b" "$(tput setaf "$2" 2>/dev/null)" "$1" "$(tput sgr0 2>/dev/null)"; }
  printf_help() {
    test -n "$1" && test -z "${1//[0-9]/}" && local color="$1" && shift 1 || local color="4"
    local msg="$*"
    shift
    printf_color "\t\t$msg\n" "$color"
  }
  #----------------
  if [ -f "$CASJAYSDEVDIR/helpers/man/$APPNAME" ] && [ -s "$CASJAYSDEVDIR/helpers/man/$APPNAME" ]; then
    source "$CASJAYSDEVDIR/helpers/man/$APPNAME"
  else
    printf_help "4" "There is no man page for this app in: "
    printf_help "4" "$CASJAYSDEVDIR/helpers/man/$APPNAME"
  fi
  printf "\n"
  exit 0
}

###################### more debugging ######################

__vdebug() {
  if [ -f ./applications.debug ]; then . ./applications.debug; fi
  DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
  printf_debug "4" "APP:$APPNAME - ARGS:$*"
  printf_debug "USER:$USER HOME:$HOME PREFIX:$SCRIPTS_PREFIX REPO:$REPO REPORAW:$REPORAW CONF:$CONF SHARE:$SHARE"
  printf_debug "HOMEDIR:$HOMEDIR APPDIR:$APPDIR USRUPDATEDIR:$USRUPDATEDIR SYSUPDATEDIR:$SYSUPDATEDIR"
  printf_custom "4" "FUNCTIONSDir:$DIR"
}

###################### call options ######################
__options() {
  if [ "$1" = "--update" ]; then
    versioncheck
    exit "$?"
  fi

  if [ "$1" = "--vdebug" ]; then
    shift 1
    __vdebug "$@"
  fi

  if [ "$1" = "--debug" ]; then
    shift 1
    __debug "$@"
  fi

  if [ "$1" = "--help" ]; then
    shift 1
    __help
  fi

  if [ "$1" = "--version" ]; then
    shift 1
    get_app_info "$APPNAME"
  fi

  # if [ "$1" = "--cron" ]; then
  #   [ "$1" = "--help" ] && printf_help 'Usage: '$APPNAME' --cron remove | add "command"' && exit 0
  #   [ "$1" = "--add" ] && shift 2 && __setupcrontab "0 0 * * *" "$*"
  #   [ "$1" = "--del" ] && shift 2 && echo $* # && __removecrontab "$*"
  #   shift
  #   exit "$?"
  # fi

  if [ "$1" = "--remove" ] || [ "$1" = "--uninstall" ]; then
    shift 1
    app_uninstall
    if [[ $? -ne 0 ]]; then
      exit 1
    fi
  fi
}

###################### *mgr scripts install/update/version ######################
run_install_init() {
  local -a LISTARRAY="$*"
  for ins in ${LISTARRAY[*]}; do
    if user_is_root; then
      printf_yellow "Initializing the installer from"
      if [ -f "$INSTDIR/$ins/install.sh" ]; then
        printf_purple "$INSTDIR/$ins/install.sh"
        sudo bash -c "$INSTDIR/$ins/install.sh"
      else
        printf_purple "$REPO/$ins"
        __urlcheck "$REPO/$ins/raw/master/install.sh" && sudo bash -c "$(curl -LSs $REPO/$ins/raw/master/install.sh)"
      fi
      __getexitcode "$ins has been installed" "An error has occurred while initiating the installer: Check the URL"
    else
      printf_yellow "Initializing the installer from"
      if [ -f "$INSTDIR/$ins/install.sh" ]; then
        printf_purple "$INSTDIR/$ins/install.sh"
        bash -c "$INSTDIR/$ins/install.sh"
      else
        printf_purple "$REPO/$ins"
        __urlcheck "$REPO/$ins/raw/master/install.sh" && bash -c "$(curl -LSs $REPO/$ins/raw/master/install.sh)"
      fi
      __getexitcode "$ins has been installed" "An error has occurred while initiating the installer: Check the URL"
    fi
  done
  echo ""
}

run_install_update() {
  if [ $# = 0 ]; then
    if [[ -d "$USRUPDATEDIR " && -n "$(ls -A $USRUPDATEDIR)" ]]; then
      for upd in $(ls $USRUPDATEDIR); do
        run_install_init "$upd"
      done
    fi
    if user_is_root && [ "$USRUPDATEDIR" != "$SYSUPDATEDIR" ]; then
      if [[ -d "$SYSUPDATEDIR" && -n "$(ls -A $SYSUPDATEDIR)" ]]; then
        for updadmin in $(ls $SYSUPDATEDIR); do
          run_install_init "$updadmin"
        done
      fi
    fi
  else
    local -a LISTARRAY="$*"
    for ins in ${LISTARRAY[*]}; do
      run_install_init "$ins"
    done
  fi
}

run_install_list() {
  echo ""
  if [ "$#" -ne 0 ]; then
    local args="$*"
    for f in $args; do
      if [ -d "$USRUPDATEDIR" ] && [ -n "$(ls -A "$USRUPDATEDIR/$f" 2>/dev/null)" ]; then
        file="$(ls -A "$USRUPDATEDIR/$f" 2>/dev/null)"
        if [ -f "$file" ]; then
          printf_green "Information about $f:"
          printf_green "$(bash -c "$file --version")"
        fi
      elif [ -d "$SYSUPDATEDIR" ] && [ -n "$(ls -A "$SYSUPDATEDIR/$f" 2>/dev/null)" ] && [ "$USRUPDATEDIR" != "$SYSUPDATEDIR" ]; then
        file="$(ls -A "$SYSUPDATEDIR/$f" 2>/dev/null)"
        if [ -f "$file" ]; then
          printf_green "Information about $f:"
          printf_green "$(bash -c "$file --version")"
        fi
      else
        printf_red "File was not found is it installed?"
      fi
    done
    echo -e "\n"
  else
    if [ "$(__count_dir "$USRUPDATEDIR")" -ne 0 ]; then
      declare -a LSINST="$(ls "$USRUPDATEDIR" 2>/dev/null)"
      if [ -n "$LSINST" ]; then
        for df in ${LSINST[*]}; do
          printf_single "4" "$df"
        done
      fi
    elif [ "$(__count_dir "$SYSUPDATEDIR")" -ne 0 ]; then
      declare -a LSINST="$(ls "$SYSUPDATEDIR" 2>/dev/null)"
      if [ -n "$LSINST" ]; then
        for df in ${LSINST[*]}; do
          printf_single "$df"
        done
      fi
    else
      printf_red "Nothing was found"
    fi
    echo -e "\n"
  fi
}

run_install_search() {
  [ $# = 0 ] && printf_exit "Nothing to search for"
  for search in "$@"; do
    echo -n "$LIST" | tr ' ' '\n' 2>/dev/null | grep -Fi "$search" | printf_read "2" || printf_exit "Your seach produced no results"
  done
  exit
}

run_install_available() { __api_test "Failed to load the API" && __curl_api | jq -r '.[] | .name' 2>/dev/null | printf_readline "4"; }

run_install_version() {
  [ $# = 0 ] && local args="$APPNAME" || local args="$*"
  local EXIT="0"
  for version in $args; do
    if [ -d "$USRUPDATEDIR" ] && [ -n "$(ls -A $USRUPDATEDIR/$version 2>/dev/null)" ]; then
      file="$(ls -A $USRUPDATEDIR/$version 2>/dev/null)"
      if [ -f "$file" ]; then
        printf_green "Information about $version: \n$(bash -c "$file --version" | sed '/^\#/d;/^$/d')"
      fi
    elif [ -d "$SYSUPDATEDIR" ] && [ -n "$(ls -A $SYSUPDATEDIR/$version 2>/dev/null)" ] && [ "$SYSUPDATEDIR" != "$USRUPDATEDIR" ]; then
      file="$(ls -A $SYSUPDATEDIR/$version 2>/dev/null)"
      if [ -f "$file" ]; then
        printf_green "Information about $version: \n$(bash -c "$file --version" | sed '/^\#/d;/^$/d')"
      fi
    elif [ -f "$(command -v $version 2>/dev/null)" ]; then
      printf_green "$(bash -c "$version --version 2>/dev/null" | sed '/^\#/d;/^$/d')"
    else
      printf_red "File was not found is it installed?"
      EXIT+=1
      return 1
    fi
  done
  [ "$EXIT" = 0 ] && scripts_version || exit 1
}

##############

scripts_check() {
  if __am_i_online; then
    if ! __cmd_exists "pkmgr" && [ ! -f ~/.noscripts ]; then
      printf_red "Please install my scripts repo - requires root/sudo"
      printf_question "Would you like to do that now" [y/N]
      read -n 1 -s choice && echo ""
      if [[ $choice == "y" || $choice == "Y" ]]; then
        urlverify $REPO/scripts/raw/master/install.sh &&
          sudo bash -c "$(__curl $REPO/installer/raw/master/install.sh)" && echo
      else
        touch ~/.noscripts
        exit 1
      fi
    fi
  fi
}

installer_versioncheck() {
  if [ -f "$APPDIR/version.txt" ]; then
    printf_green "Checking for updates"
    local NEWVERSION="$(echo $APPVERSION | grep -v "#" | tail -n 1)"
    local OLDVERSION="$(cat $APPDIR/version.txt | grep -v "#" | tail -n 1)"
    if [ "$NEWVERSION" == "$OLDVERSION" ]; then
      printf_green "No updates available current\n\t\tversion is $OLDVERSION"
    else
      printf_blue "There is an update available"
      printf_blue "New version is $NEWVERSION and current\n\t\tversion is $OLDVERSION"
      printf_question "Would you like to update" [y/N]
      read -r -n 1 -s choice
      echo ""
      if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
        [ -f "$APPDIR/install.sh" ] && bash -c "$APPDIR/install.sh" && echo || git -C "$APPDIR" pull -q
        [ "$?" -eq 0 ] && printf_green "Updated to $NEWVERSION" || printf_red "Failed to update"
      else
        printf_cyan "You decided not to update"
      fi
    fi
  fi
  exit "$?"
}

installer_no_update() {
  if [ -f "$APPDIR/.installed" ] || [ -f "$INSTDIR/.installed" ] || [ "$1" = "--force" ]; then
    true
  elif [ "$1" != "--force" ]; then
    if [ -f "$SYSSHARE/CasjaysDev/apps/$SCRIPTS_PREFIX/$APPNAME" ] || [ -d "$APPDIR" ]; then
      __ln_sf "$APPDIR/install.sh" "$SYSUPDATEDIR/$APPNAME"
      printf_warning "Updating of $APPNAME has been disabled"
      exit 0
    fi
  fi
}

installer_version() {
  mkdir -p "$CASJAYSDEVSAPPDIR/dotfiles" "$CASJAYSDEVSAPPDIR/dotfiles"
  if [ -f "$APPDIR/install.sh" ] && [ -f "$APPDIR/version.txt" ]; then
    if [ "$APPNAME" = "installer" ] && [ -d "$CASJAYSDEVSAPPDIR/$SCRIPTS_PREFIX" ]; then
      __ln_sf "$APPDIR/version.txt" "$CASJAYSDEVSAPPDIR/$SCRIPTS_PREFIX/scripts"
      __ln_sf "$APPDIR/version.txt" "$CASJAYSDEVSAPPDIR/dotfiles/$SCRIPTS_PREFIX-scripts"
    fi
    __ln_sf "$APPDIR/version.txt" "$CASJAYSDEVSAPPDIR/dotfiles/$SCRIPTS_PREFIX-$APPNAME"
  fi
  if [ -f "$INSTDIR/install.sh" ] && [ -f "$INSTDIR/version.txt" ]; then
    __ln_sf "$INSTDIR/version.txt" "$CASJAYSDEVSAPPDIR/dotfiles/$SCRIPTS_PREFIX-$APPNAME"
  fi
  if [ -d "$INSTDIR" ] && [ -f "$INSTDIR/install.sh" ] && [ -f "$INSTDIR/version.txt" ]; then
    __ln_sf "$INSTDIR/install.sh" "$CASJAYSDEVSAPPDIR/$SCRIPTS_PREFIX/$APPNAME"
  fi

}

installer_delete() {
  if [ -d "$APPDIR" ]; then
    printf_yellow "Removing $APPNAME from your system"
    [ -d "$INSTDIR" ] && rm_rm "$INSTDIR"
    __rm_rf "$APPDIR" &&
      __rm_rf "$CASJAYSDEVSAPPDIR/$SCRIPTS_PREFIX/$APPNAME" &&
      __rm_rf "$CASJAYSDEVSAPPDIR/dotfiles/$SCRIPTS_PREFIX-$APPNAME" &&
      broken_symlinks $BIN $SHARE $COMPDIR $CONF
    getexitcode "$APPNAME has been removed"
  else
    printf_red "$APPNAME doesn't seem to be installed"
    return 1
  fi
}

###################### global post install ######################

run_postinst_global() {
  if [ ! -d "$INSTDIR" ] || [ ! -L "$INSTDIR" ] || [ "$APPDIR" != "$INSTDIR" ]; then __ln_sf "$APPDIR" "$INSTDIR"; fi
  if [[ "$APPNAME" = "scripts" ]] || [[ "$APPNAME" = "installer" ]]; then
    # Only run on the scripts install
    __ln_rm "$SYSBIN/"
    __ln_rm "$COMPDIR/"

    dfunFiles="$(ls $INSTDIR/completions)"
    for dfun in $dfunFiles; do
      __rm_rf "$COMPDIR/$dfun"
    done

    # myfunctFiles="$(ls $INSTDIR/functions)"
    # for myfunct in $myfunctFiles; do
    #   __ln_sf "$INSTDIR/functions/$myfunct" "$HOME/.local/share/CasjaysDev/functions/$myfunct"
    # done

    compFiles="$(ls $INSTDIR/completions)"
    for comp in $compFiles; do
      __cp_rf "$INSTDIR/completions/$comp" "$COMPDIR/$comp"
    done

    appFiles="$(ls $INSTDIR/bin)"
    for app in $appFiles; do
      chmod -Rf 755 "$INSTDIR/bin/$app"
      __ln_sf "$INSTDIR/bin/$app" "$SYSBIN/$app"
    done
    __cmd_exists updatedb && updatedb || return 0
  else
    # Run on everything else
    if [ "$APPDIR" != "$INSTDIR" ]; then
      [ -d "$APPDIR" ] || mkd "$APPDIR"
      __cp_rf "$INSTDIR/etc/." "$APPDIR/"
      date '+Installed on: %m/%d/%y @ %H:%M:%S' >"$APPDIR/.installed"
    fi

    if [ -d "$INSTDIR/backgrounds" ]; then
      __mkd "$WALLPAPERS/system"
      local wallpapers="$(ls $INSTDIR/backgrounds/ 2>/dev/null | wc -l)"
      if [ "$wallpapers" != "0" ]; then
        wallpaperFiles="$(ls $INSTDIR/backgrounds)"
        for wallpaper in $wallpaperFiles; do
          __cp_rf "$INSTDIR/backgrounds/$wallpaper" "$WALLPAPERS/system/$wallpaper"
        done
      fi
    fi

    if [ -d "$INSTDIR/startup" ]; then
      local autostart="$(ls $INSTDIR/startup/ 2>/dev/null | wc -l)"
      if [ "$autostart" != "0" ]; then
        startFiles="$(ls $INSTDIR/startup)"
        for start in $startFiles; do
          __ln_sf "$INSTDIR/startup/$start" "$STARTUP/$start"
        done
      fi
      __ln_rm "$STARTUP/"
    fi

    if [ -d "$INSTDIR/bin" ]; then
      local bin="$(ls $INSTDIR/bin/ 2>/dev/null | wc -l)"
      if [ "$bin" != "0" ]; then
        bFiles="$(ls $INSTDIR/bin)"
        for b in $bFiles; do
          chmod -Rf 755 "$INSTDIR/bin/$app"
          __ln_sf "$INSTDIR/bin/$b" "$BIN/$b"
        done
      fi
      __ln_rm "$BIN/"
    fi

    if [ -d "$INSTDIR/completions" ]; then
      local comps="$(ls $INSTDIR/completions/ 2>/dev/null | wc -l)"
      if [ "$comps" != "0" ]; then
        compFiles="$(ls $INSTDIR/completions)"
        for comp in $compFiles; do
          __cp_rf "$INSTDIR/completions/$comp" "$COMPDIR/$comp"
        done
      fi
      __ln_rm "$COMPDIR/"
    fi

    if [ -d "$INSTDIR/applications" ]; then
      local apps="$(ls $INSTDIR/applications/ 2>/dev/null | wc -l)"
      if [ "$apps" != "0" ]; then
        aFiles="$(ls $INSTDIR/applications)"
        for a in $aFiles; do
          __ln_sf "$INSTDIR/applications/$a" "$SHARE/applications/$a"
        done
      fi
      __ln_rm "$SHARE/applications/"
    fi

    if [ -d "$INSTDIR/fontconfig" ]; then
      local fontconf="$(ls $INSTDIR/fontconfig 2>/dev/null | wc -l)"
      if [ "$fontconf" != "0" ]; then
        fcFiles="$(ls $INSTDIR/fontconfig)"
        for fc in $fcFiles; do
          __ln_sf "$INSTDIR/fontconfig/$fc" "$FONTCONF/$fc"
        done
      fi
      __ln_rm "$FONTCONF/"
      __cmd_exists fc-cache && fc-cache -f "$FONTCONF"
      return 0
    fi

    if [ -d "$INSTDIR/fonts" ]; then
      local font="$(ls "$INSTDIR/fonts" 2>/dev/null | wc -l)"
      if [ "$font" != "0" ]; then
        fFiles="$(ls $INSTDIR/fonts --ignore='.conf' --ignore='.uuid')"
        for f in $fFiles; do
          __ln_sf "$INSTDIR/fonts/$f" "$FONTDIR/$f"
        done
      fi
      __ln_rm "$FONTDIR/"
      __cmd_exists fc-cache && fc-cache -f "$FONTDIR"
      return 0
    fi

    if [ -d "$INSTDIR/icons" ]; then
      local icons="$(ls "$INSTDIR/icons" 2>/dev/null | wc -l)"
      if [ "$icons" != "0" ]; then
        fFiles="$(ls $INSTDIR/icons --ignore='.uuid')"
        for f in $fFiles; do
          __ln_sf "$INSTDIR/icons/$f" "$ICONDIR/$f"
          find "$ICONDIR/$f" -mindepth 1 -maxdepth 1 -type d | while read -r ICON; do
            if [ -f "$ICON/index.theme" ]; then
              __cmd_exists gtk-update-icon-cache && gtk-update-icon-cache -f -q "$ICON"
            fi
          done
        done
      fi
      __ln_rm "$ICONDIR/"
      return 0
    fi
  fi

  # Permission fix
  ensure_perms

  #  IFS="$OIFS"
}

###################### run exit on installer ######################

run_exit() {
  if [ ! -f "$APPDIR/.installed" ]; then
    date '+Installed on: %m/%d/%y @ %H:%M:%S' >"$APPDIR/.installed" 2>/dev/null
  fi
  if [ -d "$INSTDIR" ] && [ ! -f "$INSTDIR/.installed" ]; then
    date '+Installed on: %m/%d/%y @ %H:%M:%S' >"$INSTDIR/.installed" 2>/dev/null
  fi

  if [ -f "$TEMP/$APPNAME.inst.tmp" ]; then __rm_rf "$TEMP/$APPNAME.inst.tmp"; fi
  if [ -f "/tmp/$SCRIPTSFUNCTFILE" ]; then __rm_rf "/tmp/$SCRIPTSFUNCTFILE"; fi
  if [ -n "$EXIT" ]; then exit "$EXIT"; fi
}

###################### export and call functions ######################
export -f __cd_into
__getpythonver

###################### debugging tool ######################
__load_debug() {
  if [ -f ./applications.debug ]; then . ./applications.debug; fi
  DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
  printf_info "$(dirname $0)/$APPNAME"
  printf_custom "4" "ARGS: $DEBUGARGS"
  printf_custom "4" "FUNCTIONSDir: $DIR"
  for path in USER:$USER HOME:$HOME PREFIX:$SCRIPTS_PREFIX CONF:$CONF SHARE:$SHARE \
    HOMEDIR:$HOMEDIR USRUPDATEDIR:$USRUPDATEDIR SYSUPDATEDIR:$SYSUPDATEDIR; do
    [ -z "$path" ] || printf_custom "4" $path
  done
  __devnull() {
    TMP_FILE="$(mktemp "${TMP:-/tmp}"/_XXXXXXX.err)"
    eval "$@" 2>"$TMP_FILE" >/dev/null && EXIT=0 || EXIT=1
    [ ! -s "$TMP_FILE" ] || return_error "$1" "$TMP_FILE"
    rm -rf "$TMP_FILE"
    return $EXIT
  }
  __devnull1() { __devnull "$@"; }
  __devnull2() { __devnull "$@"; }
  return_error() {
    PREV="$1"
    ERRL="$2"
    printf_red "Command $PREV failed"
    cat "$ERRL" | printf_readline "3"
  }
}

###################### unload variables ######################
# unload_var_path() {
#   unset APPDIR APPVERSION ARRAY BACKUPDIR BIN CASJAYSDEVSAPPDIR CASJAYSDEVSHARE COMPDIR CONF DEVENVMGR
#   unset DFMGRREPO DOCKERMGRREPO FONTCONF FONTDIR FONTMGRREPO HOMEDIR ICONDIR ICONMGRREPO INSTALL_TYPE
#   unset LIST PKMGRREPO SCRIPTS_PREFIX REPO REPODF REPORAW SHARE STARTUP SYSBIN SYSCONF SYSLOGDIR SYSSHARE SYSTEMMGRREPO
#   unset SYSSHARE SYSTEMMGRREPO SYSUPDATEDIR THEMEDIR THEMEMGRREPO USRUPDATEDIR WALLPAPERMGRREPO WALLPAPERS
# }

###################### end application functions ######################
