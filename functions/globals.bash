#!/usr/bin/env bash
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
##@Version       : 031120210653-git
# @Author        : Jason Hempstead
# @Contact       : jason@casjaysdev.com
# @License       : WTFPL
# @ReadME        : fuctions.bash
# @Copyright     : Copyright: (c) 2021 Jason Hempstead, CasjaysDev
# @Created       : Thursday, Mar 11, 2021 06:53 EST
# @File          : globals.bash
# @Description   : Basic functions file
# @TODO          :
# @Other         :
# @Resource      :
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
DFMGRREPO="https://github.com/dfmgr"
# dont output
devnull() { "$@" >/dev/null 2>&1; }
devnull2() { "$@" 2>/dev/null; }

# commands
command() { builtin command ${1+"$@"}; }
type() { builtin type ${1+"$@"}; }
mkd() { devnull mkdir -p "$@"; }
rm_rf() { devnull rm -Rf "$@"; }
cp_rf() { if [ -e "$1" ]; then devnull cp -Rfa "$@"; fi; }
mv_f() { if [ -e "$1" ]; then devnull mv -f "$@"; fi; }
ln_rm() { devnull find "${1:-$HOME}" -xtype l -delete; }
ln_sf() {
  devnull ln -sf "$@"
  ln_rm "${1:-$HOME}"
}
cd_into() { pushd "$1" &>/dev/null || printf_return "Failed to cd into $1" 1; }
# colorize
printf_color() { printf "%b" "$(tput setaf "$2" 2>/dev/null)" "$1" "$(tput sgr0 2>/dev/null)"; }
printf_normal() { printf_color "\t\t$1\n" "$2"; }
printf_green() { printf_color "\t\t$1\n" 2; }
printf_red() { printf_color "\t\t$1\n" 1; }
printf_purple() { printf_color "\t\t$1\n" 5; }
printf_yellow() { printf_color "\t\t$1\n" 3; }
printf_blue() { printf_color "\t\t$1\n" 4; }
printf_cyan() { printf_color "\t\t$1\n" 6; }
printf_info() { printf_color "\t\t[ ℹ️  ] $1\n" 3; }
printf_read() { printf_color "\t\t$1" 5; }
printf_success() { printf_color "\t\t[ ✔ ] $1\n" 2; }
printf_error() { printf_color "\t\t[ ✖ ] $1 $2\n" 1; }
printf_warning() { printf_color "\t\t[ ❗ ] $1\n" 3; }
printf_question() { printf_color "\t\t[ ❓ ] $1 " 6; }
printf_error_stream() { while read -r line; do printf_error "↳ ERROR: $line"; done; }
printf_execute_success() { printf_color "\t\t[ ✔ ] $1 [ ✔ ] \n" 2; }
printf_execute_error() { printf_color "\t\t[ ✖ ] $1 $2 [ ✖ ] \n" 1; }
printf_execute_error_stream() { while read -r line; do printf_execute_error "↳ ERROR: $line"; done; }
printf_help() { printf_blue "$*"; }

printf_mkdir() {
  [ -n "$1" ] || return 1
  if ask_confirm "$1 doesn't exist should i create it?" "mkdir -p $1"; then
    true
  else
    printf_red "$1 doesn't seem to be a directory"
    return 1
  fi
}

printf_question_term() {
  printf_question "$* [yN] "
  read -r -n 1 -s REPLY
  printf "\n"
  [[ "$REPLY" == "y" || "$REPLY" == "Y" ]] && return 0 || return 1
}

printf_custom() {
  [[ $1 == ?(-)+([0-9]) ]] && local color="$1" && shift 1 || local color="3"
  local msg="$*"
  shift
  printf_color "\t\t$msg" "$color"
  printf "\n"
}

printf_exit() {
  [[ $1 == ?(-)+([0-9]) ]] && local color="$1" && shift 1 || local color="3"
  [[ $1 == ?(-)+([0-9]) ]] && local exit="$1" && shift 1 || local exit="1"
  printf_color "\t\t$1\n" "$color" && return $exit
}

printf_exit() {
  [[ $1 == ?(-)+([0-9]) ]] && local color="$1" && shift 1 || local color="3"
  [[ $1 == ?(-)+([0-9]) ]] && local exit="$1" && shift 1 || local exit="1"
  printf_color "\t\t$1\n" "$color" && exit $exit
}

printf_custom_question() {
  [[ $1 == ?(-)+([0-9]) ]] && local color="$1" && shift 1 || local color="3"
  local msg="$*"
  shift
  printf_color "\t\t$msg" "$color"
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
    printf_color "\t\t$line" "$color"
    printf "\n"
  done
  set +o pipefail
}

printf_column() {
  set -o pipefail
  test -n "$1" && test -z "${1//[0-9]/}" && local color="$1" && shift 1 || local color="6"
  while read line; do
    printf_color "\t\t$line" "$color"
  done | column
  printf "\n"
  set +o pipefail
}

return_error() {
  printf '%s' "$*"
  printf '\n'
  return 1
}

# get description for help
get_desc() {
  local PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:/usr/sbin"
  local appname="$SRC_DIR/${PROG:-$APPNAME}"
  local desc="$(grep_head "Description" "$appname" | head -n1 | sed 's#..* : ##g')"
  [ -n "$desc" ] && printf '%s' "$desc" || printf '%s' "$appname help"
}
# display help
app_help() {
  printf "\n"
  local set_desc="$(get_desc)"
  test -n "$1" && test -z "${1//[0-9]/}" && local color="$1" && shift 1 || local color="4"
  local msg1="$1" && shift 1
  local msg2="$1" && shift 1 || msg2=
  local msg3="$1" && shift 1 || msg3=
  local msg4="$1" && shift 1 || msg4=
  local msg5="$1" && shift 1 || msg5=
  local msg6="$1" && shift 1 || msg6=
  local msg7="$1" && shift 1 || msg7=
  local msg7="$1" && shift 1 || msg7=
  local msg8="$1" && shift 1 || msg8=
  local msg9="$1" && shift 1 || msg9=
  local msg10="$1" && shift 1 || msg10=
  local msg11="$1" && shift 1 || msg11=
  local msg12="$1" && shift 1 || msg12=
  local msg13="$1" && shift 1 || msg13=
  local msg14="$1" && shift 1 || msg14=
  local msg15="$1" && shift 1 || msg15=
  local msg16="$1" && shift 1 || msg16=
  local msg17="$1" && shift 1 || msg17=
  local msg18="$1" && shift 1 || msg18=
  local msg19="$1" && shift 1 || msg19=
  local msg20="$1" && shift 1 || msg20=
  shift $#
  if [ -n "${PROG:-$APPNAME}" ] && [ -n "$set_desc" ]; then
    printf_purple "$set_desc"
  fi
  [ -z "$msg1" ] || printf_color "\t\t$msg1\n" "$color"
  [ -z "$msg2" ] || printf_color "\t\t$msg2\n" "$color"
  [ -z "$msg3" ] || printf_color "\t\t$msg3\n" "$color"
  [ -z "$msg4" ] || printf_color "\t\t$msg4\n" "$color"
  [ -z "$msg5" ] || printf_color "\t\t$msg5\n" "$color"
  [ -z "$msg6" ] || printf_color "\t\t$msg6\n" "$color"
  [ -z "$msg7" ] || printf_color "\t\t$msg7\n" "$color"
  [ -z "$msg8" ] || printf_color "\t\t$msg8\n" "$color"
  [ -z "$msg9" ] || printf_color "\t\t$msg9\n" "$color"
  [ -z "$msg10" ] || printf_color "\t\t$msg10\n" "$color"
  [ -z "$msg11" ] || printf_color "\t\t$msg11\n" "$color"
  [ -z "$msg12" ] || printf_color "\t\t$msg12\n" "$color"
  [ -z "$msg13" ] || printf_color "\t\t$msg13\n" "$color"
  [ -z "$msg14" ] || printf_color "\t\t$msg14\n" "$color"
  [ -z "$msg15" ] || printf_color "\t\t$msg15\n" "$color"
  [ -z "$msg16" ] || printf_color "\t\t$msg16\n" "$color"
  [ -z "$msg17" ] || printf_color "\t\t$msg17\n" "$color"
  [ -z "$msg18" ] || printf_color "\t\t$msg18\n" "$color"
  [ -z "$msg19" ] || printf_color "\t\t$msg19\n" "$color"
  [ -z "$msg20" ] || printf_color "\t\t$msg20\n" "$color"
  printf "\n"
  exit "${exitCode:-1}"
}
# grep header
sed_remove_empty() { sed '/^\#/d;/^$/d;s#^ ##g'; }
sed_head_remove() { awk -F'  :' '{print $2}'; }
sed_head() { sed -E 's|^.*#||g;s#^ ##g;s|^@||g'; }
grep_head() { grep -sE '[".#]?@[A-Z]' "${2:-$command}" | grep "${1:-}" | head -n 12 | sed_head | sed_remove_empty | grep '^' || return 1; }
grep_head_remove() { grep -sE '[".#]?@[A-Z]' "${2:-$command}" | grep "${1:-}" | grep -Ev 'GEN_SCRIPTS_*|\${|\$\(' | sed_head_remove | sed '/^\#/d;/^$/d;s#^ ##g' | grep '^' || return 1; }
grep_version() { grep_head ''${1:-Version}'' "${2:-$command}" | sed_head | sed_head_remove | sed_remove_empty | head -n1 | grep '^'; }

# display version
app_version() {
  local prog="${PROG:-$APPNAME}"              # get from file
  local name="$(basename "${1:-$prog}")"      # get from os
  local appname="${prog:-$name}"              # figure out wich one
  local filename="$SRC_DIR/${PROG:-$APPNAME}" # get filename
  if [ -f "$filename" ]; then                 # check for file
    printf "\n"
    printf_green "Getting info for $appname"
    grep_head "Version" "$filename" &>/dev/null &&
      grep_head '' "$filename" | printf_readline "3" &&
      printf_green "$(grep_head "Version" "$filename" | head -n1)" ||
      printf_return "${filename:-File} was found, however, No information was provided"
  else
    printf_red "$filename was not found"
    exitCode=1
  fi
  printf "\n"
  exit "${exitCode:-$?}"
}

check_local() {
  local file="${1:-$PWD}"
  if [ -d "$file" ]; then
    type="dir"
    localfile="true"
    return 0
  elif [ -f "$file" ]; then
    type="file"
    localfile="true"
    return 0
  elif [ -L "$file" ]; then
    type="symlink"
    localfile="true"
    return 0
  elif [ -S "$file" ]; then
    type="socket"
    localfile="true"
    return 0
  elif [ -b "$file" ]; then
    type="block"
    localfile="true"
    return 0
  elif [ -p "$file" ]; then
    type="pipe"
    localfile="true"
    return 0
  elif [ -c "$"file"" ]; then
    type=character
    localfile=true
    return 0
  elif [ -e "$file" ]; then
    type="file"
    localfile="true"
    return 0
  else
    type=""
    localfile=""
    return 1
  fi
}
check_uri() {
  local url="$1"
  if echo "$url" | grep -q "http.*://\S\+\.[A-Za-z]\+\S*"; then
    uri="http"
    return 0
  elif echo "$url" | grep -q "ftp.*://\S\+\.[A-Za-z]\+\S*"; then
    uri="ftp"
    return 0
  elif echo "$url" | grep -q "git.*://\S\+\.[A-Za-z]\+\S*"; then
    uri="git"
    return 0
  elif echo "$url" | grep -q "ssh.*://\S\+\.[A-Za-z]\+\S*"; then
    uri="ssh"
    return 0
  else
    uri=""
    return 1
  fi
}
__list_array() {
  local OPTSDIR="${1:-$HOME/.local/share/misc/${PROG:-$APPNAME}/options}"
  mkdir -p "$OPTSDIR"
  echo "${2:-$ARRAY}" >"$OPTSDIR/array" | tr ',' '\n'
  return
}
__list_options() {
  local OPTSDIR="${1:-$HOME/.local/share/misc/${PROG:-$APPNAME}/options}"
  mkdir -p "$OPTSDIR"
  echo -n "-$SHORTOPTS " | sed 's#:##g;s#,# -#g' >"$OPTSDIR/options"
  echo "--$LONGOPTS " | sed 's#:##g;s#,# --#g' >>"$OPTSDIR/options"
  return
}
__dirname() { cd "$1" 2>/dev/null && pwd || return 1; }
__git_porcelain_count() {
  [ -d "$(__git_top_dir "${1:-.}")/.git" ] &&
    [ "$(git -C "${1:-.}" status --porcelain 2>/dev/null | wc -l 2>/dev/null)" -eq "0" ] &&
    return 0 || return 1
}
__git_porcelain() { __git_porcelain_count "${1:-.}" && return 0 || return 1; }
__git_top_dir() { git -C "${1:-.}" rev-parse --show-toplevel 2>/dev/null | grep -v fatal && return 0 || echo "${1:-$PWD}"; }

user_is_root() {
  if [[ $(id -u) -eq 0 ]] || [[ "$EUID" -eq 0 ]] || [[ "$WHOAMI" = "root" ]]; then
    return 0
  else return 1; fi
}


user_install() {
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

