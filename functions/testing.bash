#!/usr/bin/env bash

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
APPNAME="${APPNAME:-testing}"
FUNCFILE="testing.bash"
USER="${SUDO_USER:-${USER}}"
HOME="${USER_HOME:-${HOME}}"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#set opts

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
##@Version       : 020920211625-git
# @Author        : Jason Hempstead
# @Contact       : jason@casjaysdev.com
# @License       : LICENSE.md
# @ReadME        : README.md
# @Copyright     : Copyright: (c) 2021 Jason Hempstead, CasjaysDev
# @Created       : Tuesday, Feb 09, 2021 17:17 EST
# @File          : testing.bash
# @Description   : Functions for apps
# @TODO          : Refactor code - It is a mess
# @Other         :
# @Resource      :
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Main scripts location
CASJAYSDEVDIR="/usr/local/share/CasjaysDev/scripts"

# Fail if git, curl, wget are not installed
for check in git curl wget; do
  if ! command -v "$check" >/dev/null 2>&1; then
    echo -e "\n\n\t\t\033[0;31m$check is not installed\033[0m\n"
    exit 1
  fi
done

# Versioning Info - __required_version "VersionNumber"
localVersion="${localVersion:-020920211703-git}"
requiredVersion="${requiredVersion:-020920211703-git}"
currentVersion="${currentVersion:-$(<$CASJAYSDEVDIR/version.txt)}"

# Set Main Repo for dotfiles
DOTFILESREPO="https://github.com/dfmgr"

# Set other Repos
DFMGRREPO="https://github.com/dfmgr"
PKMGRREPO="https://github.com/pkmgr"
DEVENVMGRREPO="https://github.com/devenvmgr"
DOCKERMGRREPO="https://github.com/dockermgr"
ICONMGRREPO="https://github.com/iconmgr"
FONTMGRREPO="https://github.com/fontmgr"
THEMEMGRREPO="https://github.com/thememgr"
SYSTEMMGRREPO="https://github.com/systemmgr"
WALLPAPERMGRREPO="https://github.com/wallpapermgr"
WHICH_LICENSE_URL="https://github.com/devenvmgr/licenses/raw/master"
WHICH_LICENSE_DEF="$CASJAYSDEVDIR/templates/wtfpl.md"

# OS Settings
if [ -f "$CASJAYSDEVDIR/bin/detectostype" ]; then
  . "$CASJAYSDEVDIR/bin/detectostype"
fi

# Setup temp folders
TMP="${TMP:-/tmp}"
TEMP="${TMP:-/tmp}"
TMPDIR="${TMP:-/tmp}"

# Setup path
TMPPATH="$HOME/.local/share/bash/basher/cellar/bin:$HOME/.local/share/bash/basher/bin:"
TMPPATH+="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.local/share/gem/bin:/usr/local/bin:"
TMPPATH+="/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:$PATH:."
PATH="$(echo "$TMPPATH" | tr ':' '\n' | awk '!seen[$0]++' | tr '\n' ':' | sed 's#::#:.#g')"
unset TMPPATH

# Setup sudo and user
WHOAMI="${USER}"
SUDO_PROMPT="$(printf "\t\t\033[1;31m")[sudo]$(printf "\033[1;36m") password for $(printf "\033[1;32m")%p: $(printf "\033[0m\n")"

###################### devnull/logging/error handling ######################
# send all output to /dev/null
__devnull() {
  local CMD="$1" && shift 1
  local ARGS="$*" && shift
  $CMD $ARGS &>/dev/null
}
# only send stdout to display
__devnull1() {
  local CMD="$1" && shift 1
  local ARGS="$*" && shift
  $CMD $ARGS 1>/dev/null >&0
}
# send stderr to /dev/null
__devnull2() {
  local CMD="$1" && shift 1
  local ARGS="$*" && shift
  $CMD $ARGS 2>/dev/null
}
# log all app out to file
__runapp() {
  local logdir="${LOGDIR:-$HOME/.local/log}/runapp"
  __mkd "$logdir"
  if [ "$1" = "--bg" ]; then
    local logname="$2"
    shift 2
    echo "#################################" >>"$logdir/$logname.log"
    echo "$(date +'%A, %B %d, %Y')" >>"$logdir/$logname.log"
    echo "#################################" >>"$logdir/$logname.log"
    bash -c "${@:-$(false)}" >>"$logdir/$logname.log" 2>>"$logdir/$logname.err" &
  elif [ "$1" = "--log" ]; then
    local logname="$2"
    shift 2
    echo "#################################" >>"$logdir/$logname.log"
    echo "$(date +'%A, %B %d, %Y')" >>"$logdir/$logname.log"
    echo "#################################" >>"$logdir/$logname.log"
    bash -c "${@:-$(false)}" >>"$logdir/$logname.log" 2>>"$logdir/$logname.err"
  else
    echo "#################################" >>"$logdir/${APPNAME:-$1}.log"
    echo "$(date +'%A, %B %d, %Y')" >>"$logdir/${APPNAME:-$1}.log"
    echo "#################################" >>"$logdir/${APPNAME:-$1}.log"
    bash -c "${@:-$(false)}" >>"$logdir/${APPNAME:-$1}.log" 2>>"$logdir/${APPNAME:-$1}.err"
  fi
}

#macos fixes
case "$(uname -s)" in
Darwin) alias dircolors=gdircolors ;;
esac

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

print_wait() { printf_pause; }

#printf_error "color" "exitcode" "message"
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

printf_column() {
  set -o pipefail
  test -n "$1" && test -z "${1//[0-9]/}" && local color="$1" && shift 1 || local color="6"
  while read line; do
    printf_color "\t\t$line\n" "$color"
  done | column
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
  read -t 20 -r $readopts -n $lines $reply
  echo ""
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
  read -r $readopts -n $lines $reply
  echo ""
}

printf_read_error() {
  export "$1"
  printf_newline
}

#printf_answer "Var" "maxNum" "Opts"
printf_answer() {
  read -t 10 -ers -n 1 "${1:-REPLY}" || echo ""
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
  for d in "$@"; do
    echo "$d" | printf_readline "5"
  done
  exit 1
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
  local args="$*"
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
    if systemctl status $service 2>/dev/null | grep -Fq running; then
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
    if __system_service_exists "$service"; then __devnull "sudo systemctl enable --now -f $service"; fi
    __setexitstatus $?
  done
  set --
}
#system_service_disable "servicename"
__system_service_disable() {
  for service in "$@"; do
    if __system_service_exists "$service"; then __devnull "sudo systemctl disable --now -f $service"; fi
    __setexitstatus $?
  done
  set --
}
#system_service_start "servicename"
__system_service_start() {
  for service in "$@"; do
    if __system_service_exists "$service"; then __devnull "sudo systemctl start $service"; fi
    __setexitstatus $?
  done
  set --
}
#system_service_stop "servicename"
__system_service_stop() {
  for service in "$@"; do
    if __system_service_exists "$service"; then __devnull "sudo systemctl stop $service"; fi
    __setexitstatus $?
  done
  set --
}
#system_service_restart "servicename"
__system_service_restart() {
  for service in "$@"; do
    if __system_service_exists "$service"; then __devnull "sudo systemctl restart $service"; fi
    __setexitstatus $?
  done
  set --
}

#perl_exists "perlpackage"
__perl_exists() {
  local package="$1"
  if __devnull2 perl -M$package -le 'print $INC{"$package/Version.pm"}'; then exitTmp=0; else exitTmp=1; fi
  set --
}
#python_exists "pythonpackage"
__python_exists() {
  __getpythonver
  local package="$1"
  if __devnull2 "$PYTHONVER" -c "import $package"; then return 0; else return 1; fi
  set --
}
#gem_exists "gemname"
__gem_exists() {
  local package="$1"
  if __cmd_exists "$package" || devnull gem query -i -n "$package"; then return 0; else return 1; fi
  set --
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
      exit $?
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
    return $?
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
    return $?
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
###################### macos fixes#################
case "$(uname -s)" in
Darwin)
  [ -f "$(command -v gls 2>/dev/null)" ] && ls="$(command -v gls)" || ls="$(command -v ls)"
  [ -f "$(command -v gdate 2>/dev/null)" ] && date="$(command -v gdate)" || date="$(command -v date)"
  [ -f "$(command -v greadlink 2>/dev/null)" ] && readlink="$(command -v greadlink)" || readlink="$(command -v readlink)"
  [ -f "$(command -v gbasename 2>/dev/null)" ] && basename="$(command -v gbasename)" || basename="$(command -v basename)"
  [ -f "$(command -v gdircolors 2>/dev/null)" ] && dircolors="$(command -v gdircolors)" || dircolors="$(command -v dircolors)"
  [ -f "$(command -v grealpath 2>/dev/null)" ] && realpath="$(command -v grealpath)" || realpath="$(command -v realpath)"
  ls() { $ls "$@"; }
  date() { $date "$@"; }
  readlink() { $readlink "$@"; }
  basename() { $basename "$@"; }
  dircolors() { $dircolors "$@"; }
  realpath() { $realpath "$@"; }
  ;;
esac
###################### tools ######################
__get_status_pid() { ps -aux 2>/dev/null | grep -v grep | grep -q "$1" 2>/dev/null && return 0 || return 1; }
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
  local PATH="/usr/local/bin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/games"
  local CURSHELL=${1:-$(grep "$USER" /etc/passwd | tr ':' '\n' | tail -n1)} && shift 1
  local USER=${1:-$USER} && shift 1
  grep "$USER" /etc/passwd | cut -d: -f7 | grep -q "${CURSHELL:-$SHELL}" && return 0 || return 1
}
__getuser_cur_shell() {
  local PATH="/usr/local/bin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/games"
  local CURSHELL="$(grep "$USER" /etc/passwd | tr ':' '\n' | tail -n1)"
  grep "$USER" /etc/passwd | tr ':' '\n' | grep "${CURSHELL:-$SHELL}"
}
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
#Sets the title
#__title_info() { echo -n "$USER@$HOSTNAME:$APPNAME"; }
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
__hostname2ip() { getent ahosts "$1" | grep -v ':*:*:' | cut -d' ' -f1 | head -n1 || nslookup "$1" 2>/dev/null | grep -v '#|:*:*:' | grep Address: | awk '{print $2}' | grep ^ || return 1; }
#ip2hostname "ipaddr"
__ip2hostname() { nslookup "$1" 2>/dev/null | grep -v ':*:*:' | grep Name: | awk '{print $2}' | head -n1 | grep ^ || return 1; }
#timeout "time" "command"
__timeout() { timeout ${1} bash -c "${2}"; }
#count_files "dir"
__count_files() { __devnull2 find "${1:-./}" -maxdepth "${2:-1}" -not -path "${1:-./}/.git/*" -type l,f | wc -l; }
#count_dir "dir"
__count_dir() { __devnull2 find -L "${1:-./}" -mindepth 1 -maxdepth "${2:-1}" -not -path "${1:-./}/.git/*" -type d | wc -l; }
__touch() { touch "$@" 2>/dev/null || return 0; }
#symlink "file" "dest"
__symlink() { if [ -e "$1" ]; then __devnull __ln_sf "${1}" "${2}" || return 0; fi; }
#mv_f "file" "dest"
__mv_f() { if [ -e "$1" ]; then __devnull mv -f "$1" "$2" || return 0; fi; }
#cp_rf "file" "dest"
__cp_rf() { if [ -e "$1" ]; then __devnull cp -Rf "$1" "$2" || return 0; fi; }
#rm_rf "file"
__rm_rf() { if [ -e "$1" ]; then __devnull rm -Rf "$@" || return 0; fi; }
#ln_rm "file"
__ln_rm() { if [ -e "$1" ]; then __devnull find -L $1 -mindepth 1 -maxdepth 1 -type l -exec rm -f {} \;; fi; }
__broken_symlinks() { __devnull find -L "$@" -type l -exec rm -f {} \;; }
#ln_sf "file"
__ln_sf() {
  [ -L "$2" ] && __rm_rf "$2" || true
  __devnull ln -sf "$1" "$2"
}
#find_mtime "file/dir" "time minutes"
__find_mtime() { [ "$(find ${1:-.} -type l,f -cmin ${2:-1} | wc -l)" -ne 0 ] && return 0 || return 1; }
#find "dir" "options"
__find() {
  local DEF_OPTS="-type l,f,d"
  local opts="${FIND_OPTS:-$DEF_OPTS}"
  __devnull2 find "${*:-.}" -not -path "$dir/.git/*" $opts
}
#find_old "dir" "minutes" "action"
__find_old() {
  [ -d "$1" ] && local dir="$1" && shift 1
  local time="$1" && shift 1
  local action="$1" && shift 1
  find "${dir:-$HOME/.local/tmp}" -type l,f -mmin +${time:-120} -${action:-delete}
}
#find "dir" - return path relative to dir
__find_rel() {
  #f for file | d for dir
  local DIR="${*:-.}"
  local DEF_TYPE="${FIND_TYPE:-f,l}"
  local DEF_DEPTH="${FIND_DEPTH:-1}"
  local DEF_OPTS="${FIND_OPTS:-}"
  __devnull2 find $DIR/* -maxdepth $DEF_DEPTH -type $DEF_TYPE $DEF_OPTS -not -path "$dir/.git/*" -print | sed 's#'$DIR'/##g'
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
__kill() { kill -s KILL "$(pidof "$1")" >/dev/null 2>&1; }
#running "app"
__running() { pidof "$1" >/dev/null 2>&1 && return 1 || return 0; }
#start "app"
__start() {
  sleep 1 && "$@" 2>/dev/null &
  disown
}
path_info() { echo "$PATH" | tr ':' '\n' | sort -u; }
###################### url functions ######################
__curl() {
  __am_i_online && curl --disable -LSsfk --connect-timeout 3 --retry 0 --fail "$@" || return 1
}
__curl_exit() { EXIT=0 && return 0 || EXIT=1 && return 1; }
#curl_header "site" "code"
__curl_header() { curl --disable -LSIsk --connect-timeout 3 --retry 0 --max-time 2 "$1" | grep -E "HTTP/[0123456789]" | grep "${2:-200}" -n1 -q; }
#curl_download "url" "file"
__curl_download() { curl --disable --create-dirs -LSsk --connect-timeout 3 --retry 0 "$1" -o "$2"; }
#curl_version "url"
__curl_version() { curl --disable -LSsk --connect-timeout 3 --retry 0 "${1:-$REPORAW/master/version.txt}"; }
#curl_upload "file" "url"
__curl_upload() { curl -disable -LSsk --connect-timeout 3 --retry 0 --upload-file "$1" "$2"; }
#curl_api "API URL"
__curl_api() { curl --disable -LSsk --connect-timeout 3 --retry 0 "https://api.github.com/orgs/${1:-SCRIPTS_PREFIX}/repos?per_page=1000"; }
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
    if [ -n "$1" ]; then printf_error "$1"; fi
    exit 1
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
  local gitrepo="$(dirname $dir/.git)"
  local reponame="${APPNAME:-$gitrepo}"
  git -C "$dir" reset --hard || return 1
  git -C "$dir" pull --recurse-submodules -fq || return 1
  git -C "$dir" submodule update --init --recursive -q || return 1
  git -C "$dir" reset --hard -q || return 1
  if [ "$?" -ne "0" ]; then
    printf_error "Failed to update the repo"
    #__backupapp "$dir" "$reponame" && __rm_rf "$dir" && git clone -q "$repo" "$dir"
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
__git_top_dir() { git -C "${1:-.}" rev-parse --show-toplevel 2>/dev/null | grep -v fatal && return 0 || echo "${1:-$PWD}"; }
__git_top_rel() { __devnull __git_top_dir "${1:-.}" && git -C "${1:-.}" rev-parse --show-cdup 2>/dev/null | sed 's#/$##g' | head -n1 || return 1; }
__git_remote_fetch() { git -C "${1:-.}" remote -v 2>/dev/null | grep fetch | head -n 1 | awk '{print $2}' 2>/dev/null && return 0 || return 1; }
__git_remote_origin() { git -C "${1:-.}" remote show origin 2>/dev/null | grep Push | awk '{print $3}' && return 0 || return 1; }
__git_porcelain_count() { [ -d "$(__git_top_dir ${1:-.})/.git" ] && [ "$(git -C "${1:-.}" status --porcelain 2>/dev/null | wc -l 2>/dev/null)" -eq "0" ] && return 0 || return 1; }
__git_porcelain() { __git_porcelain_count "${1:-.}" && return 0 || return 1; }
__git_repobase() { basename "$(__git_top_dir "${1:-$PWD}")"; }
# __reldir="$(__git_top_rel ${1:-$PWD} || echo $PWD)"
# __topdir="$(__git_top_dir "${1:-$PWD}" || echo $PWD)"

###################### crontab functions ######################
__removecrontab() {
  command="$(echo $* | sed 's#>/dev/null 2>&1##g')"
  crontab -l | grep -v "${command}" | crontab -
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
  [ "$*" = "--help" ] && shift 1 && printf_help "Usage: ${PROG:-$APPNAME} updater $APPNAME"
  if user_is_root; then
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
          file=$file bash -c "$file --cron $*"
        fi
      done
    else
      if [ -d "$USRUPDATEDIR" ] && ls "$USRUPDATEDIR"/* 1>/dev/null 2>&1; then
        file="$(ls -A $USRUPDATEDIR/$1 2>/dev/null)"
        if [ -f "$file" ]; then
          appname="$(basename $file)"
          file=$file bash -c "$file --cron $*"
        fi
      fi
    fi
  fi
}

###################### backup functions ######################
#backupapp "directory" "filename"
__backupapp() {
  local filename count backupdir rmpre4vbackup
  [ -n "$1" ] && local myappdir="$1" || local myappdir="$APPDIR"
  [ -n "$2" ] && local myappname="$2" || local myappname="$APPNAME"
  local downloaddir="$INSTDIR"
  local logdir="${LOGDIR:-$HOME/.local/log}/backups/${SCRIPTS_PREFIX:-apps}"
  local curdate="$(date +%Y-%m-%d-%H-%M-%S)"
  local filename="$myappname-$curdate.tar.gz"
  local backupdir="${MY_BACKUP_DIR:-$HOME/.local}/backups/${SCRIPTS_PREFIX:-apps}/"
  local count="$(ls $backupdir/$myappname*.tar.gz 2>/dev/null | wc -l 2>/dev/null)"
  local rmpre4vbackup="$(ls $backupdir/$myappname*.tar.gz 2>/dev/null | head -n 1)"
  mkdir -p "$backupdir" "$logdir"
  if [ -d "$myappdir" ] && [ "$myappdir" != "$downloaddir" ] && [ ! -f "$APPDIR/.installed" ]; then
    echo -e " #################################" >>"$logdir/$myappname.log"
    echo -e "# Started on $(date +'%A, %B %d, %Y %H:%M:%S')" >>"$logdir/$myappname.log"
    echo -e "# Backing up $myappdir" >>"$logdir/$myappname.log"
    echo -e "#################################" >>"$logdir/$myappname.log"
    tar cfzv "$backupdir/$filename" "$myappdir" >>"$logdir/$myappname.log" 2>>"$logdir/$myappname.log"
    echo -e "#################################" >>"$logdir/$myappname.log"
    echo -e "# Ended on $(date +'%A, %B %d, %Y %H:%M:%S')" >>"$logdir/$myappname.log"
    echo -e "#################################" >>"$logdir/$myappname.log"
    [ -f "$APPDIR/.installed" ] || rm_rf "$myappdir"
  fi
  if [ "$count" -gt "3" ]; then rm_rf $rmpre4vbackup; fi
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
    printf_newline
    printf_error "Please run this script with sudo/root\n"
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
__execute() {
  __set_trap() { trap -p "$1" | grep "$2" &>/dev/null || trap '$2' "$1"; }
  __kill_all_subprocesses() {
    local i=""
    for i in $(jobs -p); do
      kill "$i"
      wait "$i" &>/dev/null
    done
  }
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
#runpost "program"
__run_post() {
  local e="$1"
  local m="${e//__devnull//}"
  __execute "$e" "executing: $m"
  __setexitstatus
  set --
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
  test -n "$1" && test -z "${1//[0-9]/}" && local EXITCODE="$1" && shift 1
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
  err() { [ "$1" = "show" ] && printf_error "${3:-1}" "${2:-This requires internet, however, You appear to be offline!}" 1>&2; }
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
      NETDEV="$(route get default 2>/dev/null| grep interface | awk '{print $2}')"
    else
      NETDEV="$(ip route 2>/dev/null| grep default | sed -e "s/^.*dev.//" -e "s/.proto.*//" | awk '{print $1}')"
    fi
    if __cmd_exists ifconfig; then
      CURRIP4="$(/sbin/ifconfig $NETDEV 2>/dev/null | grep -E "venet|inet" | grep -v "127.0.0." | grep 'inet' | grep -v inet6 | awk '{print $2}' | sed s/addr://g | head -n1)"
      CURRIP6="$(/sbin/ifconfig "$NETDEV" 2>/dev/null | grep -E "venet|inet" | grep 'inet6' | grep -i global | awk '{print $2}' | head -n1)"
    else
      CURRIP4="$(ip addr | grep inet 2>/dev/null | grep -vE "127|inet6" | tr '/' ' ' | awk '{print $2}' | head -n 1)"
      CURRIP6="$(ip addr | grep inet6 2>/dev/null | grep -v "::1/" -v | tr '/' ' ' | awk '{print $2}' | head -n 1)"
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
    if [[ $(uname -s) =~ Darwin ]]; then HOME="/usr/local/home/root"; else HOME="${HOME}"; fi
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
    if [[ $(uname -s) =~ Darwin ]]; then FONTDIR="/Library/Fonts"; else FONTDIR="$SHARE/fonts"; fi
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
    if [[ $(uname -s) =~ Darwin ]]; then FONTDIR="$HOME/Library/Fonts"; else FONTDIR="$SHARE/fonts"; fi
    FONTCONF="$SYSCONF/fontconfig/conf.d"
    CASJAYSDEVSHARE="$SHARE/CasjaysDev"
    CASJAYSDEVSAPPDIR="$CASJAYSDEVSHARE/apps"
    WALLPAPERS="$HOME/.local/share/wallpapers"
    USRUPDATEDIR="$SHARE/CasjaysDev/apps/${SCRIPTS_PREFIX:-dfmgr}"
    SYSUPDATEDIR="$SYSSHARE/CasjaysDev/apps/${SCRIPTS_PREFIX:-dfmgr}"
    SYSTEMDDIR="$HOME/.config/systemd/user"
  fi
  APPNAME="$(basename $0)"
  APPDIR="$(dirname $0)"
  INSTDIR="$(dirname $0)"
  SCRIPTS_PREFIX="${SCRIPTS_PREFIX:-dfmgr}"
  REPORAW="${REPORAW:-$DFMGRREPO/$APPNAME/raw}"
  INSTDIR="${INSTDIR:-$SHARE/CasjaysDev/$SCRIPTS_PREFIX/$APPNAME}"
  installtype="user_installdirs"
}

###################### setup folders - system ######################
system_installdirs() {
  if [[ $(id -u) -eq 0 ]] || [[ $EUID -eq 0 ]] || [[ "$WHOAMI" = "root" ]]; then
    if [[ $(uname -s) =~ Darwin ]]; then HOME="/usr/local/home/root"; else HOME="${HOME}"; fi
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
    if [[ $(uname -s) =~ Darwin ]]; then FONTDIR="/Library/Fonts"; else FONTDIR="/usr/local/share/fonts"; fi
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
    SYSCONF="$HOME/.config"
    SYSSHARE="$HOME/.local/share"
    SYSLOGDIR="$HOME/.local/log"
    COMPDIR="$HOME/.local/share/bash-completion/completions"
    THEMEDIR="$HOME/.local/share/themes"
    ICONDIR="$HOME/.local/share/icons"
    if [[ $(uname -s) =~ Darwin ]]; then FONTDIR="$HOME/Library/Fonts"; else FONTDIR="$HOME/.local/share/fonts"; fi
    FONTCONF="$HOME/.local/share/fontconfig/conf.d"
    CASJAYSDEVSHARE="$HOME/.local/share/CasjaysDev"
    CASJAYSDEVSAPPDIR="$HOME/.local/share/CasjaysDev/apps"
    WALLPAPERS="$HOME/.local/share/wallpapers"
    USRUPDATEDIR="$HOME/.local/share/CasjaysDev/apps/${SCRIPTS_PREFIX:-dfmgr}"
    SYSUPDATEDIR="$HOME/.local/share/CasjaysDev/apps/${SCRIPTS_PREFIX:-dfmgr}"
    SYSTEMDDIR="$HOME/.config/systemd/user"
  fi
  APPNAME="$(basename $0)"
  APPDIR="$(dirname $0)"
  INSTDIR="$(dirname $0)"
  SCRIPTS_PREFIX="${SCRIPTS_PREFIX:-dfmgr}"
  REPORAW="${REPORAW:-$DFMGRREPO/$APPNAME/raw}"
  INSTDIR="${INSTDIR:-$SHARE/CasjaysDev/$SCRIPTS_PREFIX/$APPNAME}"
  installtype="system_installdirs"
}

user_install() { user_installdirs; }
system_install() { system_installdirs; }

###################### devenv settings ######################
devenvmgr_install() {
  user_installdirs
  SCRIPTS_PREFIX="devenv"
  APPDIR="$SHARE/$SCRIPTS_PREFIX"
  INSTDIR="$SHARE/CasjaysDev/$SCRIPTS_PREFIX"
  REPO="$DEVENVMGRREPO"
  REPORAW="$REPO/$APPNAME/raw"
  USRUPDATEDIR="$SHARE/CasjaysDev/apps/$SCRIPTS_PREFIX"
  SYSUPDATEDIR="$SYSSHARE/CasjaysDev/apps/$SCRIPTS_PREFIX"
  ARRAY="$(<$CASJAYSDEVDIR/helpers/$SCRIPTS_PREFIX/array)"
  LIST="$(<$CASJAYSDEVDIR/helpers/$SCRIPTS_PREFIX/list)"
  [ "$APPNAME" = "$SCRIPTS_PREFIX" ] && APPDIR="${APPDIR//$APPNAME\/$SCRIPTS_PREFIX/$APPNAME}"
  if [ -f "$CASJAYSDEVSAPPDIR/dotfiles/$SCRIPTS_PREFIX-$APPNAME" ]; then
    APPVERSION="$(cat $CASJAYSDEVSAPPDIR/dotfiles/$SCRIPTS_PREFIX-$APPNAME)"
  else
    APPVERSION="$currentVersion"
  fi
  __main_installer_info
  __mkd "$USRUPDATEDIR"
  user_is_root && __mkd "$SYSUPDATEDIR"
  installtype="devenvmgr_install"
}

###################### dfmgr settings ######################
dfmgr_install() {
  user_installdirs
  SCRIPTS_PREFIX="dfmgr"
  REPO="$DFMGRREPO"
  REPORAW="$REPO/$APPNAME/raw"
  APPDIR="$CONF"
  INSTDIR="$SHARE/CasjaysDev/$SCRIPTS_PREFIX"
  USRUPDATEDIR="$SHARE/CasjaysDev/apps/$SCRIPTS_PREFIX"
  SYSUPDATEDIR="$SYSSHARE/CasjaysDev/apps/$SCRIPTS_PREFIX"
  APPVERSION="$(__appversion ${REPO:-https://github.com/$SCRIPTS_PREFIX}/$APPNAME/raw/master/version.txt)"
  ARRAY="$(<$CASJAYSDEVDIR/helpers/$SCRIPTS_PREFIX/array)"
  LIST="$(<$CASJAYSDEVDIR/helpers/$SCRIPTS_PREFIX/list)"
  [ "$APPNAME" = "$SCRIPTS_PREFIX" ] && APPDIR="${APPDIR//$APPNAME\/$SCRIPTS_PREFIX/$APPNAME}"
  if [ -f "$CASJAYSDEVSAPPDIR/dotfiles/$SCRIPTS_PREFIX-$APPNAME" ]; then
    APPVERSION="$(cat $CASJAYSDEVSAPPDIR/dotfiles/$SCRIPTS_PREFIX-$APPNAME)"
  else
    APPVERSION="$currentVersion"
  fi
  __main_installer_info
  __mkd "$USRUPDATEDIR"
  user_is_root && __mkd "$SYSUPDATEDIR"
  installtype="dfmgr_install"
}

###################### dockermgr settings ######################
dockermgr_install() {
  user_installdirs
  SCRIPTS_PREFIX="dockermgr"
  REPO="$DOCKERMGRREPO"
  REPORAW="$REPO/$APPNAME/raw"
  APPDIR="$SHARE"
  INSTDIR="$SHARE/CasjaysDev/$SCRIPTS_PREFIX"
  DATADIR="${APPDIR:-/srv/docker/$APPNAME}"
  USRUPDATEDIR="$SHARE/CasjaysDev/apps/$SCRIPTS_PREFIX"
  SYSUPDATEDIR="$SYSSHARE/CasjaysDev/apps/$SCRIPTS_PREFIX"
  APPVERSION="$(__appversion ${REPO:-https://github.com/$SCRIPTS_PREFIX}/$APPNAME/raw/master/version.txt)"
  ARRAY="$(<$CASJAYSDEVDIR/helpers/$SCRIPTS_PREFIX/array)"
  LIST="$(<$CASJAYSDEVDIR/helpers/$SCRIPTS_PREFIX/list)"
  [ "$APPNAME" = "$SCRIPTS_PREFIX" ] && APPDIR="${APPDIR//$APPNAME\/$SCRIPTS_PREFIX/$APPNAME}"
  if [ -f "$CASJAYSDEVSAPPDIR/dotfiles/$SCRIPTS_PREFIX-$APPNAME" ]; then
    APPVERSION="$(cat $CASJAYSDEVSAPPDIR/dotfiles/$SCRIPTS_PREFIX-$APPNAME)"
  else
    APPVERSION="$currentVersion"
  fi
  __main_installer_info
  __mkd "$USRUPDATEDIR"
  user_is_root && __mkd "$SYSUPDATEDIR"
  installtype="dockermgr_install"
}

###################### fontmgr settings ######################
fontmgr_install() {
  system_installdirs
  SCRIPTS_PREFIX="fontmgr"
  REPO="$FONTMGRREPO"
  REPORAW="$REPO/$APPNAME/raw"
  APPDIR="$SHARE/CasjaysDev/$SCRIPTS_PREFIX"
  INSTDIR="$SHARE/CasjaysDev/$SCRIPTS_PREFIX"
  USRUPDATEDIR="$SHARE/CasjaysDev/apps/$SCRIPTS_PREFIX"
  SYSUPDATEDIR="$SYSSHARE/CasjaysDev/apps/$SCRIPTS_PREFIX"
  FONTDIR="${FONTDIR:-$SHARE/fonts}"
  APPVERSION="$(__appversion ${REPO:-https://github.com/$SCRIPTS_PREFIX}/$APPNAME/raw/master/version.txt)"
  ARRAY="$(<$CASJAYSDEVDIR/helpers/$SCRIPTS_PREFIX/array)"
  LIST="$(<$CASJAYSDEVDIR/helpers/$SCRIPTS_PREFIX/list)"
  [ "$APPNAME" = "$SCRIPTS_PREFIX" ] && APPDIR="${APPDIR//$APPNAME\/$SCRIPTS_PREFIX/$APPNAME}"
  if [ -f "$CASJAYSDEVSAPPDIR/dotfiles/$SCRIPTS_PREFIX-$APPNAME" ]; then
    APPVERSION="$(cat $CASJAYSDEVSAPPDIR/dotfiles/$SCRIPTS_PREFIX-$APPNAME)"
  else
    APPVERSION="$currentVersion"
  fi
  __main_installer_info
  __mkd "$USRUPDATEDIR"
  __mkd "$FONTDIR" "$HOMEDIR"
  user_is_root && __mkd "$SYSUPDATEDIR"
  installtype="fontmgr_install"

  ######## Installer Functions ########
  generate_font_index() {
    printf_green "Updating the fonts in $FONTDIR"
    FONTDIR="${FONTDIR:-$SHARE/fonts}"
    fc-cache -f "$FONTDIR"
  }
}

###################### iconmgr settings ######################
iconmgr_install() {
  system_installdirs
  SCRIPTS_PREFIX="iconmgr"
  REPO="$ICONMGRREPO"
  REPORAW="$REPO/$APPNAME/raw"
  APPDIR="$SYSSHARE/CasjaysDev/$SCRIPTS_PREFIX"
  INSTDIR="$SYSSHARE/CasjaysDev/$SCRIPTS_PREFIX"
  USRUPDATEDIR="$SHARE/CasjaysDev/apps/$SCRIPTS_PREFIX"
  SYSUPDATEDIR="$SYSSHARE/CasjaysDev/apps/$SCRIPTS_PREFIX"
  ICONDIR="${ICONDIR:-$SHARE/icons}"
  APPVERSION="$(__appversion ${REPO:-https://github.com/$SCRIPTS_PREFIX}/$APPNAME/raw/master/version.txt)"
  ARRAY="$(<$CASJAYSDEVDIR/helpers/$SCRIPTS_PREFIX/array)"
  LIST="$(<$CASJAYSDEVDIR/helpers/$SCRIPTS_PREFIX/list)"
  [ "$APPNAME" = "$SCRIPTS_PREFIX" ] && APPDIR="${APPDIR//$APPNAME\/$SCRIPTS_PREFIX/$APPNAME}"
  if [ -f "$CASJAYSDEVSAPPDIR/dotfiles/$SCRIPTS_PREFIX-$APPNAME" ]; then
    APPVERSION="$(cat $CASJAYSDEVSAPPDIR/dotfiles/$SCRIPTS_PREFIX-$APPNAME)"
  else
    APPVERSION="$currentVersion"
  fi
  __main_installer_info
  __mkd "$USRUPDATEDIR"
  __mkd "$ICONDIR"
  user_is_root && __mkd "$SYSUPDATEDIR"
  installtype="iconmgr_install"

  ######## Installer Functions ########
  generate_icon_index() {
    printf_green "Updating the icon cache in $ICONDIR"
    ICONDIR="${ICONDIR:-$SHARE/icons}"
    fc-cache -f "$ICONDIR"
    gtk-update-icon-cache -q -t -f "$ICONDIR/$APPNAME"
  }
}

###################### pkmgr settings ######################
pkmgr_install() {
  system_installdirs
  SCRIPTS_PREFIX="pkmgr"
  REPO="$PKMGRREPO"
  REPORAW="$REPO/$APPNAME/raw"
  APPDIR="$SYSSHARE/CasjaysDev/$SCRIPTS_PREFIX"
  INSTDIR="$SHARE/CasjaysDev/$SCRIPTS_PREFIX"
  USRUPDATEDIR="$SHARE/CasjaysDev/apps/$SCRIPTS_PREFIX"
  SYSUPDATEDIR="$SYSSHARE/CasjaysDev/apps/$SCRIPTS_PREFIX"
  REPODF="https://raw.githubusercontent.com/pkmgr/dotfiles/master"
  APPVERSION="$(__appversion ${REPO:-https://github.com/$SCRIPTS_PREFIX}/$APPNAME/raw/master/version.txt)"
  ARRAY="$(<$CASJAYSDEVDIR/helpers/$SCRIPTS_PREFIX/array)"
  LIST="$(<$CASJAYSDEVDIR/helpers/$SCRIPTS_PREFIX/list)"
  if [ -f "$CASJAYSDEVSAPPDIR/dotfiles/$SCRIPTS_PREFIX-$APPNAME" ]; then
    APPVERSION="$(cat $CASJAYSDEVSAPPDIR/dotfiles/$SCRIPTS_PREFIX-$APPNAME)"
  else
    APPVERSION="$currentVersion"
  fi
  __main_installer_info
  __mkd "$USRUPDATEDIR"
  user_is_root && __mkd "$SYSUPDATEDIR"
  installtype="pkmgr_install"
}

###################### systemmgr settings ######################
systemmgr_install() {
  __requiresudo "true"
  system_installdirs
  SCRIPTS_PREFIX="systemmgr"
  REPO="$SYSTEMMGRREPO"
  REPORAW="$REPO/$APPNAME/raw"
  CONF="/usr/local/etc"
  SHARE="/usr/local/share"
  APPDIR="/usr/local/etc"
  INSTDIR="$SYSSHARE/CasjaysDev/$SCRIPTS_PREFIX"
  USRUPDATEDIR="/usr/local/share/CasjaysDev/apps/$SCRIPTS_PREFIX"
  SYSUPDATEDIR="/usr/local/share/CasjaysDev/apps/$SCRIPTS_PREFIX"
  APPVERSION="$(__appversion ${REPO:-https://github.com/$SCRIPTS_PREFIX}/$APPNAME/raw/master/version.txt)"
  ARRAY="$(<$CASJAYSDEVDIR/helpers/$SCRIPTS_PREFIX/array)"
  LIST="$(<$CASJAYSDEVDIR/helpers/$SCRIPTS_PREFIX/list)"
  if [ -f "$CASJAYSDEVSAPPDIR/dotfiles/$SCRIPTS_PREFIX-$APPNAME" ]; then
    APPVERSION="$(<$CASJAYSDEVSAPPDIR/dotfiles/$SCRIPTS_PREFIX-$APPNAME)"
  else
    APPVERSION="$currentVersion"
  fi
  __main_installer_info
  __mkd "$USRUPDATEDIR"
  user_is_root && __mkd "$SYSUPDATEDIR"
  installtype="systemmgr_install"
}

###################### thememgr settings ######################
thememgr_install() {
  system_installdirs
  SCRIPTS_PREFIX="thememgr"
  REPO="$THEMEMGRREPO"
  REPORAW="$REPO/$APPNAME/raw"
  APPDIR="${THEMEDIR:-$SYSSHARE/themes/$APPNAME}"
  INSTDIR="$SHARE/CasjaysDev/$SCRIPTS_PREFIX"
  USRUPDATEDIR="$SHARE/CasjaysDev/apps/$SCRIPTS_PREFIX"
  SYSUPDATEDIR="$SYSSHARE/CasjaysDev/apps/$SCRIPTS_PREFIX"
  THEMEDIR="${THEMEDIR:-$SHARE/themes}"
  APPVERSION="$(__appversion ${REPO:-https://github.com/$SCRIPTS_PREFIX}/$APPNAME/raw/master/version.txt)"
  ARRAY="$(<$CASJAYSDEVDIR/helpers/$SCRIPTS_PREFIX/array)"
  LIST="$(<$CASJAYSDEVDIR/helpers/$SCRIPTS_PREFIX/list)"
  __main_installer_info
  __mkd "$USRUPDATEDIR"
  user_is_root && __mkd "$SYSUPDATEDIR"
  installtype="thememgr_install"

  ######## Installer Functions ########
  generate_theme_index() {
    printf_green "Updating the theme index in $THEMEDIR"
    local -a LISTARRAY="${*:-$APPNAME}"
    for index in ${LISTARRAY[*]}; do
      THEMEDIR="${THEMEDIR:-$SHARE/themes}/${index:-}"
      if [ -d "$THEMEDIR" ]; then
        find "$THEMEDIR" -mindepth 0 -maxdepth 2 -type f,l,d -not -path "*/.git/*" | while read -r THEME; do
          if [ -f "$THEME/index.theme" ]; then
            __cmd_exists gtk-update-icon-cache && gtk-update-icon-cache -qf "$THEME"
          fi
        done
      fi
    done
  }
}

###################### wallpapermgr settings ######################
wallpapermgr_install() {
  system_installdirs
  SCRIPTS_PREFIX="wallpapermgr"
  REPO="${WALLPAPERMGRREPO}"
  REPORAW="$REPO/$APPNAME/raw"
  APPDIR="${WALLPAPERS:-$SHARE/wallpapers/$APPNAME}"
  INSTDIR="$SHARE/CasjaysDev/$SCRIPTS_PREFIX"
  USRUPDATEDIR="$SHARE/CasjaysDev/apps/$SCRIPTS_PREFIX"
  SYSUPDATEDIR="$SYSSHARE/CasjaysDev/apps/$SCRIPTS_PREFIX"
  APPVERSION="$(__appversion ${REPO:-https://github.com/$SCRIPTS_PREFIX}/$APPNAME/raw/master/version.txt)"
  ARRAY="$(<$CASJAYSDEVDIR/helpers/$SCRIPTS_PREFIX/array)"
  LIST="$(<$CASJAYSDEVDIR/helpers/$SCRIPTS_PREFIX/list)"
  __main_installer_info
  __mkd "$WALLPAPERS"
  __mkd "$USRUPDATEDIR"
  user_is_root && __mkd "$SYSUPDATEDIR"
  installtype="wallpapermgr_install"
}

###################### create directories ######################
ensure_dirs() {
  $installtype
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

##
__main_installer_info() {
  if [ "$APPNAME" = "scripts" ] || [ "$APPNAME" = "installer" ]; then
    APPDIR="/usr/local/share/CasjaysDev/scripts"
    INSTDIR="/usr/local/share/CasjaysDev/scripts"
  fi
}
###################### get installer versions ######################

get_installer_version() {
  $installtype
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

###################### call options ######################
__options() {
  $installtype
  case $1 in
  --update) ###################### Update check ######################
    shift 1
    printf_error "Not enabled in apps: See the installer"
    exit
    ;;

  --vdebug) ###################### basic debug ######################
    shift 1
    if [ -f ./applications.debug ]; then . ./applications.debug; fi
    DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
    printf_debug 'APP:'$APPNAME' - ARGS:'$*''
    printf_debug "USER:$USER HOME:$HOME PREFIX:$SCRIPTS_PREFIX REPO:$REPO REPORAW:$REPORAW CONF:$CONF SHARE:$SHARE"
    printf_debug "HOMEDIR:$HOMEDIR APPDIR:$APPDIR USRUPDATEDIR:$USRUPDATEDIR SYSUPDATEDIR:$SYSUPDATEDIR"
    printf_custom "4" "FUNCTIONSDir:$DIR"
    exit
    ;;

  --full) ###################### debug settings ######################
    shift 1
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
    printf_info "FunctionsDir:              $SCRIPTSFUNCTDIR"
    printf_info "FunctionsFile              $SCRIPTSFUNCTFILE"
    exit
    ;;

  --help) ###################### help ######################
    shift 1
    __help
    exit
    ;;

  --version) ###################### get info from app ######################
    shift 1
    local prog="${APPNAME:-$PROG}"            # get from file
    local name="$(basename $0)"               # get from os
    local appname="${prog:-$name}"            # figure out wich one
    filename="$(command -v $appname)"         # get filename
    if [ -f "$(command -v $filename)" ]; then # check for file
      printf_newline
      printf_green "Getting info for $appname"
      cat "$filename" | grep '^# @' | grep '  :' >/dev/null 2>&1 &&
        cat "$filename" | grep '^# @' | grep -v '\$' | grep '  :' | sed 's/# @//g' | printf_readline "3" &&
        printf_green "$(cat $filename | grep -v '\$' | grep "##@Version" | sed 's/##@//g')" &&
        printf_blue "Required ver  : $requiredVersion" ||
        printf_red "File was found, however, No information was provided"
    else
      printf_red "${1:-$appname} was not found"
    fi
    exit
    ;;

    # if [ "$1" = "--cron" ]; then
    #   [ "$1" = "--help" ] && printf_help 'Usage: '$APPNAME' --cron remove | add "command"' && exit 0
    #   [ "$1" = "--add" ] && shift 2 && __setupcrontab "0 0 * * *" "$*"
    #   [ "$1" = "--del" ] && shift 2 && echo $* # && __removecrontab "$*"
    #   shift
    #   exit "$?"
    # fi

  --remove | --uninstall)
    shift 1
    installer_delete "$@"
    if [[ $? -ne 0 ]]; then
      exit 1
    else
      exit 0
    fi
    ;;
  esac
}

###################### *mgr scripts install/update/version ######################
export mgr_init="${mgr_init:-true}"
run_install_init() {
  local exitCode
  local -a LISTARRAY="$*"
  for ins in ${LISTARRAY[*]}; do
    if user_is_root; then
      if [ -f "$INSTDIR/$ins/install.sh" ]; then
        sudo bash -c "$INSTDIR/$ins/install.sh"
      else
        __urlcheck "$REPO/$ins/raw/master/install.sh" &&
          sudo bash -c "$(curl -LSs $REPO/$ins/raw/master/install.sh)" ||
          printf_exit "Failed to initialize the installer"
      fi
      local exitCode+=$?
    else
      if [ -f "$INSTDIR/$ins/install.sh" ]; then
        bash -c "$INSTDIR/$ins/install.sh"
      else
        __urlcheck "$REPO/$ins/raw/master/install.sh" &&
          bash -c "$(curl -LSs $REPO/$ins/raw/master/install.sh)" ||
          printf_exit "Failed to initialize the installer\n\t\t$REPO/$ins/raw/master/install.sh"
      fi
      local exitCode+=$?
    fi
  done
  unset ins
  return $exitCode
}

run_install_update() {
  local exitCode
  export mgr_init="${mgr_init:-true}"
  if [ $# = 0 ]; then
    if [[ -d "$USRUPDATEDIR " && -n "$(ls -A $USRUPDATEDIR)" ]]; then
      for upd in $(ls $USRUPDATEDIR); do
        run_install_init "$upd"
        local exitCode+=$?
      done
    fi
    if user_is_root && [ "$USRUPDATEDIR" != "$SYSUPDATEDIR" ]; then
      if [[ -d "$SYSUPDATEDIR" && -n "$(ls -A $SYSUPDATEDIR)" ]]; then
        for updadmin in $(ls $SYSUPDATEDIR); do
          run_install_init "$updadmin"
          local exitCode+=$?
        done
      fi
    fi
  else
    local -a LISTARRAY="$*"
    for ins in ${LISTARRAY[*]}; do
      run_install_init "$ins"
      local exitCode+=$?
    done
  fi
  unset upd updadmin ins
  return $exitCode
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
  fi
  unset args file df
  return $?
}

run_install_search() {
  [ $# = 0 ] && printf_exit "Nothing to search for"
  declare -a LSINST="$*"
  for search in ${LSINST[*]}; do
    echo -n "$LIST" | grep -Fiq "$search" || printf_exit "Your seach produced no results"
    echo -n "$LIST" | tr ' ' '\n' | grep -Fi "$search" 2>/dev/null | printf_read "2"
  done
  unset search
  exit $?
}

run_install_available() {
  __api_test "Failed to load the API for $APPNAME" && __curl_api ${1:-$APPNAME} | jq -r '.[] | .name' 2>/dev/null | printf_readline "4"
}

run_install_version() {
  [ $# = 0 ] && local args="${PROG:-$APPNAME}" || local args="$*"
  local exitCode="0"
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
      echo $USRUPDATEDIR/$version
      printf_red "File was not found is it installed?"
      exitCode+=1
      return 1
    fi
  done
  unset args version
  [ "$exitCode" = 0 ] && scripts_version || exit 1
}

installer_delete() {
  local rmf
  local exitCode=0
  declare -a LISTARRAY="$*"
  for rmf in ${LISTARRAY[*]}; do
    if [ -d "$APPDIR/$rmf" ] || [ -d "$INSTDIR/$rmf" ]; then
      printf_yellow "Removing $rmf from your system"
      [ -d "$INSTDIR/$rmf" ] && __rm_rf "$INSTDIR/$rmf"
      __rm_rf "$APPDIR/$rmf" "$INSTDIR/$rmf" || exitCode+=1
      __rm_rf "$CASJAYSDEVSAPPDIR/$SCRIPTS_PREFIX/$rmf" || exitCode+=1
      __rm_rf "$CASJAYSDEVSAPPDIR/dotfiles/$SCRIPTS_PREFIX-$rmf" || exitCode+=1
      __broken_symlinks $BIN $SHARE $COMPDIR $CONF || exitCode+=1
      __getexitcode $exitCode "$rmf has been removed" " "
      return $exitCode
    else
      printf_error "1" "$exitCode" "$rmf doesn't seem to be installed"
    fi
  done
  unset rmf
}

##################################################################################################
# Versioning
__appversion() {
  if [ -f "$INSTDIR/version.txt" ]; then
    localVersion="$(<$INSTDIR/version.txt)"
  else
    localVersion="$localVersion"
  fi
  __curl "${1:-$REPORAW/master/version.txt}" || echo "$localVersion"
}

__required_version() {
  if [ -f "$CASJAYSDEVDIR/version.txt" ]; then
    local requiredVersion="${1:-$requiredVersion}"
    local currentVersion="${APPVERSION:-$currentVersion}"
    local rVersion="${requiredVersion//-git/}"
    local cVersion="${currentVersion//-git/}"
    if [ "$cVersion" -lt "$rVersion" ]; then
      set -Ee
      printf_exit 1 2 "Requires version higher than $rVersion\n"
      exit 1
    fi
  fi
}
__required_version "$requiredVersion"
#[ "$installtype" = "devenvmgr_install" ] &&
devenvmgr_req_version() { __required_version "$1"; }
#[ "$installtype" = "dfmgr_install" ] &&
dfmgr_req_version() { __required_version "$1"; }
#[ "$installtype" = "dockermgr_install" ] &&
dockermgr_req_version() { __required_version "$1"; }
#[ "$installtype" = "fontmgr_install" ] &&
fontmgr_req_version() { __required_version "$1"; }
#[ "$installtype" = "iconmgr_install" ] &&
iconmgr_req_version() { __required_version "$1"; }
#[ "$installtype" = "pkmgr_install" ] &&
pkmgr_req_version() { __required_version "$1"; }
#[ "$installtype" = "systemmgr_install" ] &&
systemmgr_req_version() { __required_version "$1"; }
#[ "$installtype" = "thememgr_install" ] &&
thememgr_req_version() { __required_version "$1"; }
#[ "$installtype" = "wallpapermgr_install" ] &&
wallpapermgr_req_version() { __required_version "$1"; }

###################### export and call functions ######################
export -f __cd_into
__getpythonver

###################### debugging tool ######################
# __load_debug() {
#   if [ -f ./applications.debug ]; then . ./applications.debug; fi
#   DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
#   printf_info "$(dirname $0)/$APPNAME"
#   printf_custom "4" "ARGS: $DEBUGARGS"
#   printf_custom "4" "FUNCTIONSDir: $DIR"
#   for path in USER:$USER HOME:$HOME PREFIX:$SCRIPTS_PREFIX CONF:$CONF SHARE:$SHARE \
#     HOMEDIR:$HOMEDIR USRUPDATEDIR:$USRUPDATEDIR SYSUPDATEDIR:$SYSUPDATEDIR; do
#     [ -z "$path" ] || printf_custom "4" $path
#   done
#   __devnull() {
#     TMP_FILE="$(mktemp "${TMP:-/tmp}"/_XXXXXXX.err)"
#     eval "$@" 2>"$TMP_FILE" >/dev/null && EXIT=0 || EXIT=1
#     [ ! -s "$TMP_FILE" ] || return_error "$1" "$TMP_FILE"
#     rm -rf "$TMP_FILE"
#     return $EXIT
#   }
#   __devnull1() { __devnull "$@"; }
#   __devnull2() { __devnull "$@"; }
#   return_error() {
#     PREV="$1"
#     ERRL="$2"
#     printf_red "Command $PREV failed"
#     cat "$ERRL" | printf_readline "3"
#   }
# }
###################### unload variables ######################
# unload_var_path() {
#   unset APPDIR APPVERSION ARRAY BACKUPDIR BIN CASJAYSDEVSAPPDIR CASJAYSDEVSHARE COMPDIR CONF DEVENVMGR
#   unset DFMGRREPO DOCKERMGRREPO FONTCONF FONTDIR FONTMGRREPO HOMEDIR ICONDIR ICONMGRREPO INSTALL_TYPE
#   unset LIST PKMGRREPO SCRIPTS_PREFIX REPO REPODF REPORAW SHARE STARTUP SYSBIN SYSCONF SYSLOGDIR SYSSHARE SYSTEMMGRREPO
#   unset SYSSHARE SYSTEMMGRREPO SYSUPDATEDIR THEMEDIR THEMEMGRREPO USRUPDATEDIR WALLPAPERMGRREPO WALLPAPERS
# }

user_install # default type
###################### end application functions ######################
return
