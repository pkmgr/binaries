#!/bin/bash

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# @Author      : Jason
# @Contact     : casjaysdev@casjay.net
# @File        : applications.bash
# @Created     : Wed, Aug 05, 2020, 02:00 EST
# @License     : WTFPL
# @Copyright   : Copyright (c) CasjaysDev
# @Description : functions for installed apps
# @TODO        : Better error handling/refactor code
# @
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#setup paths
TMP="${TMP:-/tmp}"
TEMP="${TEMP:-/tmp}"
APPNAME="${APPNAME:-applications}"

TMPPATH+="$HOME/.local/share/bash/basher/cellar/bin:$HOME/.local/share/bash/basher/bin:"
TMPPATH+="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.local/share/gem/bin:/usr/local/bin:"
TMPPATH+="/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:$PATH:."

export WHOAMI="${USER}"
export PATH="$(echo $TMPPATH | tr ':' '\n' | awk '!seen[$0]++' | tr '\n' ':' | sed 's#::#:.#g')"
export SUDO_PROMPT="$(printf "\n\t\t\033[1;31m")[sudo]$(printf "\033[1;36m") password for $(printf "\033[1;32m")%p: $(printf "\033[0m" && echo)"

#fail if git is not installed
if ! command -v "git" >/dev/null 2>&1; then
  echo -e "\n\n\t\t\033[0;31mGit is not installed\033[0m\n"
  exit 1
fi

###################### error handling ######################
#used for debugging
[ "$1" = "vdebug" ] && export DEBUGARGS="$*"
#no output
__devnull() {
  args="$*"
  bash -c "$args" >/dev/null 2>&1
}
#error output
__devnull1() {
  args="$*"
  bash -c "$args" 1>/dev/null 2>&0
}
#standart output
__devnull2() {
  args="$*"
  bash -c "$args" 2>/dev/null
}
#err "commands"
_err() {
  local COMMAND="${*:-$(false)}"
  local TMP_FILE="$(mktemp "${TMP:-/tmp}"/error/_rr-XXXXX.err)"
  __mkd "${TMP:-/tmp}"/error
  bash -c "${COMMAND}" 2>"$TMP_FILE" >/dev/null && EXIT=0 || EXIT=$?
  [ ! -s "$TMP_FILE" ] || return_error "$EXIT" "$COMMAND" "$TMP_FILE"
  #rm -rf "$TMP_FILE"
  return $EXIT
}
return_error() {
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
  execute "$e" "executing: $m"
  __setexitstatus
  set --
}

#macos fix
case "$(uname -s)" in
Darwin) alias dircolors=gdircolors ;;
esac

#Set Main Repo for dotfiles
DOTFILESREPO="${DOTFILESREPO:-https://github.com/dfmgr}"
DFMGRREPO="${DFMGRREPO:-https://github.com/dfmgr}"
PKMGRREPO="${PKMGRREPO:-https://github.com/pkmgr}"
DEVENVMGR="${DEVENVMGR:-https://github.com/devenvmgr}"
ICONMGRREPO="${ICONMGRREPO:-https://github.com/iconmgr}"
FONTMGRREPO="${FONTMGRREPO:-https://github.com/fontmgr}"
THEMEMGRREPO="${THEMEMGRREPO:-https://github.com/thememgr}"
DOCKERMGRREPO="${DOCKERMGRREPO:-https://github.com/dockermgr}"
SYSTEMMGRREPO="${SYSTEMMGRREPO:-https://github.com/systemmgr}"
WALLPAPERMGRREPO="${WALLPAPERMGRREPO:-https://github.com/wallpapermgr}"

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
printf_error() { printf_color "\n\t\t$ICON_ERROR $1 $2\n" 1; }
printf_warning() { printf_color "\t\t$ICON_WARN $1\n" 3; }
printf_error_stream() { while read -r line; do printf_error "↳ ERROR: $line"; done; }
printf_execute_success() { printf_color "\t\t$ICON_GOOD $1\n" 2; }
printf_execute_error() { printf_color "\t\t$ICON_WARN $1 $2\n" 1; }
printf_execute_result() {
  if [ "$1" -eq 0 ]; then printf_execute_success "$2"; else printf_execute_error "${3:-$2}"; fi
  return "$1"
}

printf_not_found() { if ! cmd_exists "$1"; then printf_exit "The $1 command is not installed"; fi; }
printf_execute_error_stream() { while read -r line; do printf_execute_error "↳ ERROR: $line"; done; }
#used for printing console notifications
printf_console() {
  test -n "$1" && test -z "${1//[0-9]/}" && local color="$1" && shift 1 || local color="1"
  local msg="$*"
  shift
  printf_color "\n\n\t\t$msg\n\n" "$color"
}

printf_exit() {
  test -n "$1" && test -z "${1//[0-9]/}" && local color="$1" && shift 1 || local color="1"
  local msg="$*"
  shift
  printf_color "\t\t$msg" "$color"
  echo ""
  exit 1
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

printf_newline() {
  test -n "$1" && test -z "${1//[0-9]/}" && local color="$1" && shift 1 || local color="3"
  set -o pipefail
  while read line; do
    printf_color "\t\t$line\n" "$color"
  done
  set +o pipefail
}

printf_question() {
  test -n "$1" && test -z "${1//[0-9]/}" && local color="$1" && shift 1 || local color="4"
  local msg="$*"
  shift
  printf_color "\t\t$ICON_QUESTION $msg " "$color"
}
printf_answer() {
  read -r -n ${2:-1} ${1:-__QUESTION_REPLY}
}

printf_answer_yes() { [[ "${1:-__QUESTION_REPLY}" =~ ${2:-^[Yy]$} ]] && return 0 || return 1; }

printf_custom_question() {
  test -n "$1" && test -z "${1//[0-9]/}" && local color="$1" && shift 1 || local color="1"
  local msg="$*"
  shift
  printf_color "\t\t$msg " "$color"
}

printf_read_question() {
  test -n "$1" && test -z "${1//[0-9]/}" && local color="$1" && shift 1 || local color="6"
  local msg="$*"
  shift
  printf_custom_question "$1" "$color"
  read -r -n 1 __QUESTION_REPLY
}

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
  [ ! -z "$3" ] && local FAIL="$3" || local FAIL="The previous command has failed"
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

###################### checks ######################
#__cmd_exists command
__cmd_exists() {
  [ $# -eq 0 ] && return 1
  local args=$*
  local exitCode
  for cmd in $args; do
    if find "$(command -v $cmd 2>/dev/null)" >/dev/null 2>&1 || find "$(which --skip-alias --skip-functions $cmd 2>/dev/null)" >/dev/null 2>&1; then exitCode=0; else exitCode=1; fi
    local exitCode+="$exitCode"
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
  if sudo systemctl list-units --full -all | grep -Fq "$1.service" || sudo systemctl list-units --full -all | grep -Fq "$1.socket"; then return 0; else return 1; fi
  setexitstatus
  set --
}
#system_service_enable "servicename"
__system_service_enable() {
  if __system_service_exists; then __devnull "sudo systemctl enable -f $1"; fi
  setexitstatus
  set --
}
#system_service_disable "servicename"
__system_service_disable() {
  if __system_service_exists; then __devnull "sudo systemctl disable --now $1"; fi
  setexitstatus
  set --
}
#perl_exists "perlpackage"
__perl_exists() {
  local package=$1
  if devnull2 perl -M$package -le 'print $INC{"$package/Version.pm"}'; then return 0; else return 1; fi
}
#python_exists "pythonpackage"
__python_exists() {
  __getpythonver
  local package=$1
  if devnull2 "$PYTHONVER" -c "import $package"; then return 0; else return 1; fi
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
    printf_question "$cmd is not installed Would you like install it" [y/N]
    read -n 1 -s choice && echo
    if [[ $choice == "y" || $choice == "Y" ]]; then
      for miss in $MISSING; do
        execute "pkmgr silent-install $miss" "Installing $miss" || return 1
      done
    else
      return 1
    fi
  fi
}
#check_pip "pipname"
__check_pip() {
  local ARGS="$*"
  local MISSING=""
  for cmd in $ARGS; do __cmd_exists $cmd || MISSING+="$cmd "; done
  if [ ! -z "$MISSING" ]; then
    printf_question "$1 is not installed Would you like install it" [y/N]
    read -n 1 -s choice
    if [[ $choice == "y" || $choice == "Y" ]]; then
      for miss in $MISSING; do
        execute "pkmgr pip $miss" "Installing $miss"
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
    printf_question "$1 is not installed Would you like install it" [y/N]
    read -n 1 -s choice
    if [[ $choice == "y" || $choice == "Y" ]]; then
      for miss in $MISSING; do
        execute "pkmgr cpan $miss" "Installing $miss"
      done
    fi
  else
    return 1
  fi
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
#cat file | rmcomments
__rmcomments() { sed 's/[[:space:]]*#.*//;/^[[:space:]]*$/d'; }
#countwd file
__countwd() { cat "$@" | wc -l | __rmcomments; }
#getuser "username" "grep options"
__getuser() { if [ -n "$1" ]; then cut -d: -f1 /etc/passwd | grep "${1:-USER}" | cut -d: -f1 /etc/passwd | grep "${1:-USER}" ${2:-}; fi; }
#countdir "dir"
__countdir() { ls "$@" | wc -l; }

###################### Apps ######################
#mkd dir
__mkd() { if [ ! -e "$1" ]; then mkdir -p "$@"; else return 0; fi; }
#tar "filename dir"
__tar_create() { tar cfvz "$@"; }
#tar filename
__tar_extract() { tar xfvz "$@"; }
#while_true "command"
__while_true() { while true; do "${@}" && sleep .3; done; }
#for_each "option" "command"
__for_each() { for item in ${1}; do ${2} ${item} && sleep .1; done; }
#hostname ""
__hostname() { __devnull2 hostname "$@"; }
#domainname ""
__domainname() { hostname -d "$@" 2>/dev/null || hostname -f "$@" 2>/dev/null; }
#hostname2ip "hostname"
__hostname2ip() { getent ahostsv4 "$1" | cut -d' ' -f1 | head -n1; }
#timeout "time" "command"
__timeout() { timeout ${1} bash -c "${2}"; }
#count_files "dir"
__count_files() { __devnull2 find "${1:-.}" -maxdepth 1 | wc -l; }
#symlink "file" "dest"
__symlink() { if [ -e "$1" ]; then __devnull ln -sf "${1}" "${2}"; fi; }
#mv_f "file" "dest"
__mv_f() { if [ -e "$1" ]; then __devnull mv -f "$@"; fi; }
#cp_rf "file" "dest"
__cp_rf() { if [ -e "$1" ]; then __devnull cp -Rfa "$1" "$2"; fi; }
#rm_rf "file"
__rm_rf() { if [ -e "$1" ]; then __devnull rm -Rf "$*"; fi; }
#ln_rm "file"
__ln_rm() { if [ -e "$1" ]; then __devnull find "${1:-.}" -maxdepth 1 -xtype l -delete; fi; }
#ln_sf "file"
__ln_sf() {
  if [ -L "$2" ]; then
    rm_rf "$2"
  fi
  __devnull ln -sf "$@"
}
#find "dir" "options"
__find() {
  local dir="$1"
  shift 1
  find "$dir" -not -path "$dir/.git/*" "$@"
}
#cd "dir"
__cd() { cd "$1" || return 1; }
# cd into directory with message
__cd_into() {
  if [ $PWD != $1 ]; then
    cd "$1" && printf_green "Changing the directory to $1" &&
      printf_green "Type exit to return to your previous directory" &&
      exec bash || exit 1
  fi
}

###################### url functions ######################
__curl() {
  __devnull2 curl --disable -LSs --connect-timeout 3 --retry 0 "$@"
  __setexitstatus
}
#curl_header "site" "code"
__curl_header() { __curl --disable -LSIs --max-time 2 "$1" | grep -E "HTTP/[0123456789]" | grep "${2:-200}" -n1 -q; }
#curl_download "url" "file"
__curl_download() { __curl --disable -LSs "$1" -o "$2"; }
#curl_version "url"
__curl_version() { __curl --disable -LSs "$REPORAW/master/version.txt"; }
#curl_upload "file" "url"
__curl_upload() { __curl --upload-file "$1" "$2"; }
#urlcheck "url"
__urlcheck() { __curl --disable --connect-timeout 1 --retry 1 --retry-delay 1 --output /dev/null --silent --head --fail "$1"; }
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
#very simple function to ensure connection
__api_test() {
  if __am_i_online; then
    return 0
  else
    printf "\n"
    printf_exit "1" "Unable to connect to the server\n"
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
#git "commands"
__git() {
  __devnull1 git "$@"
  __setexitstatus "$?"
}
#git_clone "url" "dir"
__git_clone() {
  __git_username_repo "$1"
  local repo="$1"
  [ ! -z "$2" ] && local myappdir="$2" || local myappdir="$APPDIR"
  [ ! -d "$myappdir" ] || rm_rf "$myappdir"
  __git -C "$myappdir" clone -q --recursive "$1" "${2}"
}
#git_pull "dir"
__git_update() {
  [ ! -z "$1" ] && local myappdir="$1" || local myappdir="$APPDIR"
  local repo="$(git -C "$myappdir" remote -v | grep fetch | head -n 1 | awk '{print $2}')"
  __git -C "$myappdir" reset --hard &&
    __git -C "$myappdir" pull --recurse-submodules -fq &&
    __git -C "$myappdir" submodule update --init --recursive -q &&
    __git -C "$myappdir" reset --hard -q
  if [ "$?" -ne "0" ]; then
    __backupapp "$myappdir" "$myappdir" &&
      rm_rf "$myappdir" &&
      __git clone -q "$repo" "$myappdir"
  fi
}
#git_commit "dir"
__git_commit() {
  if [ ! -d "$1" ]; then
    __mkd "$1"
    __git -C "$1" init -q
  fi
  touch "$1/README.md"
  __git -C "${1:-.}" add -A .
  __git -C "${1:-.}" commit -m "${2:-🏠🐜❗ Updated Files 🏠🐜❗}" -q | printf_readline "3"
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
  local githostname="$(__git_hostname $url)"
  if [[ $url =~ $re ]]; then
    protocol=${BASH_REMATCH[1]}
    separator=${BASH_REMATCH[2]}
    hostname=${BASH_REMATCH[3]}
    username=${BASH_REMATCH[4]}
    userrepo=${BASH_REMATCH[5]}
    folder=${githostname}
  else
    return 1
  fi
}
__git_top_dir() { git rev-parse --show-toplevel 2>/dev/null; }
__git_fetch_remote() { git remote -v | grep fetch | head -n 1 | awk '{print $2}' 2>/dev/null; }
__git_porcelain() { [ "$(git status --porcelain | wc -l 2>/dev/null)" -eq "0" ] && return 0 || return 1; }
###################### crontab functions ######################

setupcrontab() {
  local croncmd="logr"
  local additional='bash -c "am_i_online && '$2' &"'
}

addtocrontab() {
  [ "$1" = "--help" ] && printf_help "addtocrontab "0 0 1 * *" "echo hello""
  local frequency="$1"
  local command="am_i_online && && sleep $(expr $RANDOM \% 300) && $2"
  local job="$frequency $command"
  cat <(grep -F -i -v "$command" <(crontab -l)) <(echo "$job") | devnull2 crontab -
}

removecrontab() {
  crontab -l | grep -v -F "$command" | devnull2 crontab -
}

cron_updater() {
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
#backupapp "filename" "directory"
__backupapp() {
  local filename count backupdir rmpre4vbackup
  [ ! -z "$1" ] && local myappdir="$1" || local myappdir="$APPDIR"
  [ ! -z "$2" ] && local myappname="$2" || local myappname="$APPNAME"
  local logdir="$HOME/.local/log/backupapp"
  local curdate="$(date +%Y-%m-%d-%H-%M-%S)"
  local filename="$myappname-$curdate.tar.gz"
  local backupdir="${MY_BACKUP_DIR:-$HOME/.local/backups}/${PREFIX:-apps}/"
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
    rm -Rf "$myappdir"
  fi
  if [ "$count" -gt "3" ]; then rm_rf $rmpre4vbackup; fi
}
###################### menu functions ######################
#attemp_install_menus "programname"
__attemp_install_menus() {
  local prog="$1"
  if (dialog --timeout 10 --trim --cr-wrap --colors --title "install $1" --yesno "$prog in not installed! \nshould I try to install it?" 15 40); then
    sleep 2
    clear
    printf_custom "191" "\n\n\n\n\t\tattempting install of $prog\n\t\tThis could take a bit...\n\n\n"
    __devnull pkmgr silent "$1"
    [ "$?" -ne 0 ] && dialog --timeout 10 --trim --cr-wrap --colors --title "failed" --msgbox "$1 failed to install" 10 41
    clear
  fi
}

__custom_menus() {
  printf_custom_question "6" "Enter your custom program : "
  read custom
  printf_custom_question "6" "Enter any additional options [type file to choose] : "
  read opts
  if [ "$opts" = "file" ]; then opts="$(open_file_menus $custom)"; fi
  $custom "$opts" >/dev/null 2>&1 || clear
  printf_red "$custom is an invalid program"
}

#run_prog_menus
__run_prog_menus() {
  local prog="$1"
  shift 1
  local args="$*"
  if __cmd_exists $prog; then
    __devnull2 "$prog $*" || clear printf_red "An error has occured"
  else
    attemp_install_menus "$prog" &&
      __devnull2 "$prog" "$args" || return 1
  fi
}
#open_file_menus
__open_file_menus() {
  local prog="$1"
  shift 1
  local args="$*"
  if __cmd_exists "$prog"; then
    local file=$(dialog --title "Play a file" --stdout --title "Please choose a file or url to play" --fselect "$HOME/" 14 48)
    [ -z "$file" ] && __devnull2 "$prog" "$file" || clear
    printf_red "No file selected"
  else
    attemp_install_menus "$prog" &&
      __devnull2 "$prog" "$args" || return 1
  fi
}

##################### sudo functions ####################
sudoif() { (sudo -vn && sudo -ln) 2>&1 | grep -v 'may not' >/dev/null && return 0 || return 1; }

sudorun() { if sudoif; then sudo "$@"; else "$@"; fi; }

sudorerun() {
  local ARGS="$ARGS"
  if [[ $UID != 0 ]]; then if sudoif; then sudo "$APPNAME" "$ARGS" && exit $?; else sudoreq; fi; fi
}

sudoreq() { if [[ $UID != 0 ]]; then
  echo "" && printf_error "Please run this script with sudo"
  __returnexitcode
  exit 1
fi; }

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
    __sudoask && __sudoexit && sudo "$@" 2>/dev/null
  else
    printf_red "You dont have access to sudo\n\t\tPlease contact the syadmin for access"
    return 1
  fi
}

###################### spinner and execute funtion ######################
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
show_spinner() {
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
  local EXITSTATUS="$EXIT"
  if [ "$EXITSTATUS" -eq 0 ]; then
    BG_EXIT="${BG_GREEN}"
    return 0
  else
    BG_EXIT="${BG_RED}"
    return 1
  fi
  unset local EXIT
}
#returnexitcode $?
__returnexitcode() {
  local EXIT=$?
  [ -z "$1" ] || EXIT=$1
  if [ "$EXIT" -eq 0 ]; then
    BG_EXIT="${BG_GREEN}"
    PS_SYMBOL=" 😺 "
    return 0
  else
    BG_EXIT="${BG_RED}"
    PS_SYMBOL=" 😟 "
    return "$EXIT"
  fi
  unset local EXIT
}
#getexitcode "OK Message" "Error Message"
__getexitcode() {
  local EXIT="$?"
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
  if [ "$EXIT" -eq 0 ]; then
    printf_cyan "$PSUCCES"
  else
    printf_red "$PERROR"
  fi
  __returnexitcode $EXIT
}
###################### OS Functions ######################
#alternative names
mlocate() { cmd_exists locate || cmd_exists mlocate || return 1; }
xfce4() { cmd_exists xfce4-about || return 1; }
imagemagick() { cmd_exists convert || return 1; }
fdfind() { cmd_exists fdind || cmd_exists fd || return 1; }
speedtest() { cmd_exists speedtest-cli || cmd_exists speedtest || return 1; }
neovim() { cmd_exists nvim || cmd_exists neovim || return 1; }
chromium() { cmd_exists chromium || cmd_exists chromium-browser || return 1; }
firefox() { cmd_exists firefox-esr || cmd_exists firefox || return 1; }
gtk-2.0() { find /lib* /usr* -iname "*libgtk*2*.so*" -type f | grep -q . || return 0; }
gtk-3.0() { find /lib* /usr* -iname "*libgtk*3*.so*" -type f | grep -q . || return 0; }
httpd() { cmd_exists httpd || cmd_exists apache2 || return 1; }

#export -f mlocate xfce4 imagemagick fdfind speedtest neovim chromium firefox gtk-2.0 gtk-3.0 httpd

#notifications "title" "message"
notifications() {
  local title="$1"
  shift 1
  local msg="$*"
  shift
  cmd_exists notify-send && notify-send -u normal -i "notification-message-IM" "$title" "$msg" || return 0
}
#connection test
__am_i_online() {
  return_code() {
    if [ "$1" = 0 ]; then
      return 0
    else
      return 1
    fi
  }
  __test_ping() {
    timeout 0.3 ping -c1 8.8.8.8 >/dev/null 2>&1
    local pingExit=$?
    return_code $pingExit
  }
  __test_http() {
    curl -LSIs --max-time 1 http://1.1.1.1" | grep -e "HTTP/[0123456789]" | grep "200 -n1 >/dev/null 2>&1
    local httpExit=$?
    return_code $httpExit
  }
  __test_ping || __test_http
}
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
  if cmd_exists route || cmd_exists ip; then
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
    distroname="MacOS"
    distroversion="$(sw_vers -productVersion)"
  else
    return 1
  fi
  for id_like in "$@"; do
    if [[ "$(echo $1 | tr '[:upper:]' '[:lower:]')" =~ $id_like ]]; then
      case "$1" in
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
          return 0
        else
          return 1
        fi
        ;;
      darwin | mac | macos)
        if [[ "$distroname" =~ ^mac ]] || [[ "$distroname" =~ ^darwin ]]; then
          distro_id="Mac"
          distro_version="$distroversion"
          return 0
        else
          return 1
        fi
        ;;
      *)
        return
        ;;
      esac
    else
      return 1
    fi
  done
  [ -z $distro_id ] || distro_id="Unknown"
  [ -z $distro_version ] || distro_version="Unknown"
  #echo $id_like $distroname $distroversion
}

##
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
    __mkd "$SYSUPDATEDIR"
    __mkd "$SHARE/applications"
    __mkd "$SHARE/CasjaysDev/functions"
    __mkd "$SHARE/wallpapers/system"
  fi
  return 0
}

###################### setup folders ######################
user_installdirs() {
  APPNAME="${APPNAME:-installer}"
  if [[ $(id -u) -eq 0 ]] || [[ $EUID -eq 0 ]] || [[ "$WHOAMI" = "root" ]]; then
    BIN="$HOME/.local/bin"
    CONF="$HOME/.config"
    SHARE="$HOME/.local/share"
    LOGDIR="$HOME/.local/log"
    STARTUP="$HOME/.config/autostart"
    SYSBIN="/usr/local/bin"
    SYSCONF="/usr/local/etc"
    SYSSHARE="/usr/local/share"
    SYSLOGDIR="/usr/local/log"
    BACKUPDIR="$HOME/.local/backups/dotfiles"
    COMPDIR="$HOME/.local/share/bash-completion/completions"
    THEMEDIR="$SHARE/themes"
    ICONDIR="$SHARE/icons"
    FONTDIR="$SHARE/fonts"
    FONTCONF="$SYSCONF/fontconfig/conf.d"
    CASJAYSDEVSHARE="$SHARE/CasjaysDev"
    CASJAYSDEVSAPPDIR="$CASJAYSDEVSHARE/apps"
    WALLPAPERS="${WALLPAPERS:-$SYSSHARE/wallpapers}"
    #USRUPDATEDIR="$SHARE/CasjaysDev/apps/dotfiles"
    #SYSUPDATEDIR="$SYSSHARE/CasjaysDev/apps/dotfiles"
  else
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
    BACKUPDIR="$HOME/.local/backups/dotfiles"
    COMPDIR="$HOME/.local/share/bash-completion/completions"
    THEMEDIR="$SHARE/themes"
    ICONDIR="$SHARE/icons"
    FONTDIR="$SHARE/fonts"
    FONTCONF="$SYSCONF/fontconfig/conf.d"
    CASJAYSDEVSHARE="$SHARE/CasjaysDev"
    CASJAYSDEVSAPPDIR="$CASJAYSDEVSHARE/apps"
    WALLPAPERS="$HOME/.local/share/wallpapers"
    #USRUPDATEDIR="$SHARE/CasjaysDev/apps/dotfiles"
    #SYSUPDATEDIR="$SYSSHARE/CasjaysDev/apps/dotfiles"
  fi
}

system_installdirs() {
  APPNAME="${APPNAME:-installer}"
  if [[ $(id -u) -eq 0 ]] || [[ $EUID -eq 0 ]] || [[ "$WHOAMI" = "root" ]]; then
    BACKUPDIR="$HOME/.local/backups/dotfiles"
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
    #USRUPDATEDIR="/usr/local/share/CasjaysDev/apps"
    #SYSUPDATEDIR="/usr/local/share/CasjaysDev/apps"
  else
    INSTALL_TYPE=system
    HOME="${HOME:-/home/$WHOAMI}"
    BACKUPDIR="${BACKUPS:-$HOME/.local/backups/dotfiles}"
    BIN="$HOME/.local/bin"
    CONF="$HOME/.config"
    SHARE="$HOME/.local/share"
    LOGDIR="$HOME/.local/log"
    STARTUP="$HOME/.config/autostart"
    SYSBIN="$HOME/.local/bin"
    SYSCONF="$HOME/.local/etc"
    SYSSHARE="$HOME/.local/share"
    SYSLOGDIR="$HOME/.local/log"
    COMPDIR="$HOME/.local/share/bash-completion/completions"
    THEMEDIR="$HOME/.local/share/themes"
    ICONDIR="$HOME/.local/share/icons"
    FONTDIR="$HOME/.local/share/fonts"
    FONTCONF="$HOME/.local/share/fontconfig/conf.d"
    CASJAYSDEVSHARE="$HOME/.local/share/CasjaysDev"
    CASJAYSDEVSAPPDIR="$HOME/.local/share/CasjaysDev/apps"
    WALLPAPERS="$HOME/.local/share/wallpapers"
    #USRUPDATEDIR="$HOME/.local/share/CasjaysDev/apps"
    #SYSUPDATEDIR="/usr/local/share/CasjaysDev/apps"
  fi
}

###################### dfmgr settings ######################

dfmgr_install() {
  user_installdirs
  PREFIX="dfmgr"
  REPO="${DFMGRREPO}"
  REPORAW="$REPO/$APPNAME/raw"
  HOMEDIR="$CONF"
  APPDIR="${APPDIR:-$HOMEDIR/$APPNAME}"
  USRUPDATEDIR="$SHARE/CasjaysDev/apps/$PREFIX"
  SYSUPDATEDIR="$SYSSHARE/CasjaysDev/apps/$PREFIX"
  ARRAY="$(cat /usr/local/share/CasjaysDev/scripts/helpers/$PREFIX/array)"
  LIST="$(cat /usr/local/share/CasjaysDev/scripts/helpers/$PREFIX/list)"
  if [ -f "$CASJAYSDEVSAPPDIR/dotfiles/$PREFIX-$APPNAME" ]; then
    APPVERSION="$(cat $CASJAYSDEVSAPPDIR/dotfiles/$PREFIX-$APPNAME)"
  else
    APPVERSION="N/A"
  fi
  __mkd "$USRUPDATEDIR" "$SYSUPDATEDIR"
}

###################### dockermgr settings ######################

dockermgr_install() {
  user_installdirs
  PREFIX="dockermgr"
  REPO="${DOCKERMGRREPO}"
  REPORAW="$REPO/$APPNAME/raw"
  HOMEDIR="$SHARE/CasjaysDev/$PREFIX"
  APPDIR="${APPDIR:-$HOMEDIR/$APPNAME}"
  USRUPDATEDIR="$SHARE/CasjaysDev/apps/$PREFIX"
  SYSUPDATEDIR="$SYSSHARE/CasjaysDev/apps/$PREFIX"
  ARRAY="$(cat /usr/local/share/CasjaysDev/scripts/helpers/$PREFIX/array)"
  LIST="$(cat /usr/local/share/CasjaysDev/scripts/helpers/$PREFIX/list)"
  if [ -f "$CASJAYSDEVSAPPDIR/dotfiles/$PREFIX-$APPNAME" ]; then
    APPVERSION="$(cat $CASJAYSDEVSAPPDIR/dotfiles/$PREFIX-$APPNAME)"
  else
    APPVERSION="N/A"
  fi
  __mkd "$USRUPDATEDIR" "$SYSUPDATEDIR"
}

###################### fontmgr settings ######################

fontmgr_install() {
  system_installdirs
  PREFIX="fontmgr"
  REPO="${FONTMGRREPO}"
  REPORAW="$REPO/$APPNAME/raw"
  HOMEDIR="$SHARE/CasjaysDev/$PREFIX"
  APPDIR="${APPDIR:-$HOMEDIR/$APPNAME}"
  USRUPDATEDIR="$SHARE/CasjaysDev/apps/$PREFIX"
  SYSUPDATEDIR="$SYSSHARE/CasjaysDev/apps/$PREFIX"
  FONTDIR="${FONTDIR:-$SHARE/fonts}"
  ARRAY="$(cat /usr/local/share/CasjaysDev/scripts/helpers/$PREFIX/array)"
  LIST="$(cat /usr/local/share/CasjaysDev/scripts/helpers/$PREFIX/list)"
  if [ -f "$CASJAYSDEVSAPPDIR/dotfiles/$PREFIX-$APPNAME" ]; then
    APPVERSION="$(cat $CASJAYSDEVSAPPDIR/dotfiles/$PREFIX-$APPNAME)"
  else
    APPVERSION="N/A"
  fi
  __mkd "$USRUPDATEDIR" "$SYSUPDATEDIR" "$FONTDIR" "$HOMEDIR"
}

###################### iconmgr settings ######################

iconmgr_install() {
  system_installdirs
  PREFIX="iconmgr"
  REPO="${ICONMGRREPO}"
  REPORAW="$REPO/$APPNAME/raw"
  HOMEDIR="$SYSSHARE/CasjaysDev/$PREFIX"
  APPDIR="${APPDIR:-$HOMEDIR/$APPNAME}"
  USRUPDATEDIR="$SHARE/CasjaysDev/apps/$PREFIX"
  SYSUPDATEDIR="$SYSSHARE/CasjaysDev/apps/$PREFIX"
  ICONDIR="${ICONDIR:-$SHARE/icons}"
  ARRAY="$(cat /usr/local/share/CasjaysDev/scripts/helpers/$PREFIX/array)"
  LIST="$(cat /usr/local/share/CasjaysDev/scripts/helpers/$PREFIX/list)"
  if [ -f "$CASJAYSDEVSAPPDIR/dotfiles/$PREFIX-$APPNAME" ]; then
    APPVERSION="$(cat $CASJAYSDEVSAPPDIR/dotfiles/$PREFIX-$APPNAME)"
  else
    APPVERSION="N/A"
  fi
  __mkd "$USRUPDATEDIR" "$SYSUPDATEDIR" "$ICONDIR" "$HOMEDIR"
}

###################### pkmgr settings ######################

pkmgr_install() {
  PREFIX="pkmgr"
  REPO="${PKMGRREPO}"
  REPORAW="$REPO/$APPNAME/raw"
  HOMEDIR="$SYSSHARE/CasjaysDev/$PREFIX"
  APPDIR="${APPDIR:-$HOMEDIR/$APPNAME}"
  USRUPDATEDIR="$SHARE/CasjaysDev/apps/$PREFIX"
  SYSUPDATEDIR="$SYSSHARE/CasjaysDev/apps/$PREFIX"
  REPODF="https://raw.githubusercontent.com/pkmgr/dotfiles/master"
  ARRAY="$(cat /usr/local/share/CasjaysDev/scripts/helpers/$PREFIX/array)"
  LIST="$(cat /usr/local/share/CasjaysDev/scripts/helpers/$PREFIX/list)"
  if [ -f "$CASJAYSDEVSAPPDIR/dotfiles/$PREFIX-$APPNAME" ]; then
    APPVERSION="$(cat $CASJAYSDEVSAPPDIR/dotfiles/$PREFIX-$APPNAME)"
  else
    APPVERSION="N/A"
  fi
  __mkd "$USRUPDATEDIR" "$SYSUPDATEDIR"
}

###################### systemmgr settings ######################

systemmgr_install() {
  system_installdirs
  PREFIX="systemmgr"
  REPO="${SYSTEMMGRREPO}"
  REPORAW="$REPO/$APPNAME/raw"
  CONF="/usr/local/etc"
  SHARE="/usr/local/share"
  HOMEDIR="/usr/local/etc"
  APPDIR="${APPDIR:-$HOMEDIR/$APPNAME}"
  USRUPDATEDIR="/usr/local/share/CasjaysDev/apps/$PREFIX"
  SYSUPDATEDIR="/usr/local/share/CasjaysDev/apps/$PREFIX"
  ARRAY="$(cat /usr/local/share/CasjaysDev/scripts/helpers/$PREFIX/array)"
  LIST="$(cat /usr/local/share/CasjaysDev/scripts/helpers/$PREFIX/list)"
  if [ -f "$CASJAYSDEVSAPPDIR/dotfiles/$PREFIX-$APPNAME" ]; then
    APPVERSION="$(cat $CASJAYSDEVSAPPDIR/dotfiles/$PREFIX-$APPNAME)"
  else
    APPVERSION="N/A"
  fi
  __mkd "$USRUPDATEDIR" "$SYSUPDATEDIR"
}

###################### thememgr settings ######################

thememgr_install() {
  system_installdirs
  PREFIX="thememgr"
  REPO="${THEMEMGRREPO}"
  REPORAW="$REPO/$APPNAME/raw"
  HOMEDIR="$SYSSHARE/CasjaysDev/$PREFIX"
  APPDIR="${APPDIR:-$HOMEDIR/$APPNAME}"
  USRUPDATEDIR="$SHARE/CasjaysDev/apps/$PREFIX"
  SYSUPDATEDIR="$SYSSHARE/CasjaysDev/apps/$PREFIX"
  THEMEDIR="${THEMEDIR:-$SHARE/themes}"
  ARRAY="$(cat /usr/local/share/CasjaysDev/scripts/helpers/$PREFIX/array)"
  LIST="$(cat /usr/local/share/CasjaysDev/scripts/helpers/$PREFIX/list)"
  if [ -f "$CASJAYSDEVSAPPDIR/dotfiles/$PREFIX-$APPNAME" ]; then
    APPVERSION="$(cat $CASJAYSDEVSAPPDIR/dotfiles/$PREFIX-$APPNAME)"
  else
    APPVERSION="N/A"
  fi
  __mkd "$USRUPDATEDIR" "$SYSUPDATEDIR"
}

###################### wallpapermgr settings ######################

wallpapermgr_install() {
  system_installdirs
  PREFIX="wallpapermgr"
  REPO="${WALLPAPERMGRREPO}"
  REPORAW="$REPO/$APPNAME/raw"
  HOMEDIR="$SYSSHARE/CasjaysDev/wallpapers"
  APPDIR="${APPDIR:-$HOMEDIR/$APPNAME}"
  USRUPDATEDIR="$SHARE/CasjaysDev/apps/wallpapers"
  SYSUPDATEDIR="$SYSSHARE/CasjaysDev/apps/wallpapers"
  WALLPAPERS="${WALLPAPERS:-$SHARE/wallpapers}"
  ARRAY="$(cat /usr/local/share/CasjaysDev/scripts/helpers/$PREFIX/array)"
  LIST="$(cat /usr/local/share/CasjaysDev/scripts/helpers/$PREFIX/list)"
  if [ -f "$CASJAYSDEVSAPPDIR/dotfiles/$PREFIX-$APPNAME" ]; then
    APPVERSION="$(cat $CASJAYSDEVSAPPDIR/dotfiles/$PREFIX-$APPNAME)"
  else
    APPVERSION="N/A"
  fi
  __mkd "$USRUPDATEDIR" "$SYSUPDATEDIR" "$WALLPAPERS"
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
  printf "\n"
  if [ -f "$SCRIPTSFUNCTDIR/helpers/man/$APPNAME" ] && [ -s "$SCRIPTSFUNCTDIR/helpers/man/$APPNAME" ]; then
    source "$SCRIPTSFUNCTDIR/helpers/man/$APPNAME"
  else
    printf_help "1" "There is no man page for this app in: "
    printf_help "1" "$SCRIPTSFUNCTDIR/helpers/man/$APPNAME"
  fi
  printf "\n"
  exit 0
}

[ "$1" = "--help" ] && __help
[ "$1" = "--version" ] && get_app_info "$APPNAME"

###################### export and call functions ######################
export -f __cd_into
__getpythonver

###################### debugging tool ######################
__load_debug() {
  systemmgr_install
  user_installdirs
  if [ -f ./applications.debug ]; then . ./applications.debug; fi
  DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
  printf_info "$(dirname $0)/$APPNAME"
  printf_custom "4" "ARGS: $DEBUGARGS"
  printf_custom "4" "FUNCTIONSDir: $DIR"
  for path in USER:$USER HOME:$HOME PREFIX:$PREFIX CONF:$CONF SHARE:$SHARE \
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
if [ "$1" = "--vdebug" ]; then
  shift 1
  __load_debug
fi
###################### unload variables ######################
unload_var_path() {
  unset APPDIR APPVERSION ARRAY BACKUPDIR BIN CASJAYSDEVSAPPDIR CASJAYSDEVSHARE COMPDIR CONF DEVENVMGR
  unset DFMGRREPO DOCKERMGRREPO FONTCONF FONTDIR FONTMGRREPO HOMEDIR ICONDIR ICONMGRREPO INSTALL_TYPE
  unset LIST PKMGRREPO PREFIX REPO REPODF REPORAW SHARE STARTUP SYSBIN SYSCONF SYSLOGDIR SYSSHARE SYSTEMMGRREPO
  unset SYSSHARE SYSTEMMGRREPO SYSUPDATEDIR THEMEDIR THEMEMGRREPO USRUPDATEDIR WALLPAPERMGRREPO WALLPAPERS
}

###################### end application functions ######################
