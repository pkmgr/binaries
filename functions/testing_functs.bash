#!/usr/bin/env bash

export PATH="$(echo $PATH | tr ':' '\n' | awk '!seen[$0]++' | tr '\n' ':' | sed 's#::#:.#g')"

export systemdate="$(date +%Y-%m-%d)-$(date +%H-%m)"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# @Author      : Jason
# @Contact     : casjaysdev@casjay.net
# @File        : install
# @Created     : Wed, Aug 05, 2020, 02:00 EST
# @License     : WTFPL
# @Copyright   : Copyright (c) CasjaysDev
# @Description : Application Functions
#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# fail if git is not installed

if ! command -v "git" >/dev/null 2>&1; then
  echo -e "\t\t\033[0;31mGit is not installed\033[0m"
  exit 1
fi

##################################################################################################

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

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

printf_color() { printf "%b" "$(tput setaf "$2" 2>/dev/null)" "$1" "$(tput sgr0 2>/dev/null)"; }
printf_normal() { printf_color "\t\t$1\n" "$2"; }
printf_green() { printf_color "\t\t$1\n" 2; }
printf_red() { printf_color "\t\t$1\n" 1; }
printf_purple() { printf_color "\t\t$1\n" 5; }
printf_yellow() { printf_color "\t\t$1\n" 3; }
printf_blue() { printf_color "\t\t$1\n" 4; }
printf_cyan() { printf_color "\t\t$1\n" 6; }
printf_info() { printf_color "\t\t[ ℹ️ ] $1\n" 3; }
printf_exit() {
  printf_color "\t\t$1\n" 1
  exit 1
}
printf_help() { printf_color "\t\t$1\n" 1; }
printf_read() { printf_color "\t\t$1" 5; }
printf_success() { printf_color "\t\t[ ✔ ] $1\n" 2; }
printf_error() { printf_color "\t\t[ ✖ ] $1 $2\n" 1; }
printf_warning() { printf_color "\t\t[ ❗ ] $1\n" 3; }
printf_question() { printf_color "\t\t[ ❓ ] $1 - [y/N] [❓] " 6; }
printf_error_stream() { while read -r line; do printf_error "↳ ERROR: $line"; done; }
printf_execute_success() { printf_color "\t\t[ ✔ ] $1 [ ✔ ] \n" 2; }
printf_execute_error() { printf_color "\t\t[ ✖ ] $1 $2 [ ✖ ] \n" 1; }
printf_execute_result() {
  if [ "$1" -eq 0 ]; then printf_execute_success "$2"; else printf_execute_error "$2"; fi
  return "$1"
}
printf_execute_error_stream() { while read -r line; do printf_execute_error "↳ ERROR: $line"; done; }

##################################################################################################

printf_result() {
  [ ! -z "$1" ] && EXIT="$1" || EXIT="$?"
  [ ! -z "$2" ] && local OK="$2" || local OK="Command executed successfully"
  [ ! -z "$2" ] && local FAIL="$2" || local FAIL="Command has failed"
  if [ "$EXIT" -eq 0 ]; then
    printf_success "$OK"
    exit 0
  else
    printf_error "$FAIL"
    exit 1
  fi
}

##################################################################################################

devnull() { "$@" >/dev/null 2>&1; }
killpid() { devnull kill -9 $(pidof "$1"); }
hostname2ip() { getent hosts "$1" | cut -d' ' -f1 | head -n1; }
cmd_exists() {
  local pkg LISTARRAY
  declare -a LISTARRAY="$*"
  for cmd in $LISTARRAY; do
    type -P "$1" | grep -q "/" 2>/dev/null
  done
}
set_trap() { trap -p "$1" | grep "$2" &>/dev/null || trap '$2' "$1"; }
getuser() { [ -z "$1" ] && cut -d: -f1 /etc/passwd | grep "$USER" || cut -d: -f1 /etc/passwd | grep "$1"; }

##################################################################################################

xfce4() { cmd_exists xfce4-about; }
imagemagick() { cmd_exists convert; }
emacs() { cmd_exists emacs26 || cmd_exists emacs; }
firefox() { cmd_exists firefox-esr || cmd_exists firefox; }
chromium() { cmd_exists chromium || cmd_exists chromium-browser; }
speedtest() { cmd_exists speedtest-cli || cmd_exists speedtest; }
gtk-2.0() { devnull find /lib* /usr* -iname "*libgtk*2*.so*" -type f | grep -q . && return 0 || return 1; }
gtk-3.0() { devnull find /lib* /usr* -iname "*libgtk*3*.so*" -type f | grep -q . && return 0 || return 1; }

##################################################################################################

backupfile() {
  local myappname="${APPNAME:-$USER}"
  local date="$systemdate"
  local backupdir="${BACKUPS:-$HOME/.local/backups/dotfiles}"
  local filename="$myappname-$date.tar.gz"
  declare -a args="$@"
  for f in $args; do
    [ ! -f "$backupdir/$filename" ] && tar cfzv "$backupdir/$filename" "$f" >>"$backupdir/$myappname.log"
    if [ -L "$f" ]; then
      [ ! -L "$(ls -ltra $f | grep '\->' | awk '{print $11}')" ] &&
        [ -e "$(ls -ltra $f | grep '\->' | awk '{print $11}')" ] &&
        tar ufzv "$backupdir/$filename" "$f" >>"$backupdir/$myappname.log" >>"$backupdir/$myappname.log" &&
        tar ufzv "$backupdir/$filename" "$(ls -ltra $f | grep '\->' | sed "s#.*-.##g" | sed "s# ##g")" >>"$backupdir/$myappname.log"
    else
      tar ufzv "$backupdir/$filename" "$f" >>"$backupdir/$myappname.log"
    fi
  done
  return 0
}

##################################################################################################

backupapp() {
  local myappdir="$APPDIR"
  local myappname="${APPNAME:-$USER}"
  local date="$systemdate"
  local backupdir="${BACKUPS:-$HOME/.local/backups/dotfiles}"
  local count="$(cat $backupdir/$myappname.txt 2>/dev/null | wc -l)"
  local filename="$myappname-$date.tar.gz"
  local prev3backup="$(ls -tr1dQ $backupdir/$myappname*.tar.gz 2>/dev/null | head -n 3)"
  local rmpre4vbackup"$(ls -t1dQ $backupdir/$myappname*.tar.gz 2>/dev/null | head -n 1)"
  touch "$backupdir/$myappname.txt"
  if [ -e "$myappdir" ] && [ ! -d $myappdir/.git ]; then
    echo "#################################" >>"$backupdir/$myappname.log"
    echo "# $(date +'%A, %B %d, %Y')" >>"$backupdir/$myappname.log"
    echo "# $backupdir/$filename $myappdir" >>"$backupdir/$myappname.log"
    echo "#################################" >>"$backupdir/$myappname.log"
    tar cfzv "$backupdir/$filename" "$myappdir" >>"$backupdir/$myappname.log"
    echo "$prev3backup" >"$backupdir/$myappname.txt"
  fi
  [ "$count" -gt "3" ] && rm_rf $rmpre4vbackup
  rm_rf "$myappdir"
  return 0
}

##################################################################################################

runapp() {
  local logdir="${LOGDIR:-$HOME/.local/logs}"
  mkdir -p "$logdir"
  if [ "$1" = "--bg" ]; then
    local logname="$2"
    shift 2
    echo "#################################" >>"$logdir/$logname.log"
    echo "$(date +'%A, %B %d, %Y')" >>"$logdir/$logname.log"
    echo "#################################" >>"$logdir/$logname.err"
    "$@" >>"$logdir/$logname.log" 2>>"$logdir/$logname.err" &
  elif [ "$1" = "--log" ]; then
    local logname="$2"
    shift 2
    echo "#################################" >>"$logdir/$logname.log"
    echo "$(date +'%A, %B %d, %Y')" >>"$logdir/$logname.log"
    echo "#################################" >>"$logdir/$logname.err"
    "$@" >>"$logdir/$logname.log" 2>>"$logdir/$logname.err"
  else
    echo "#################################" >>"$logdir/${APPNAME:-$1}.log"
    echo "$(date +'%A, %B %d, %Y')" >>"$logdir/${APPNAME:-$1}.log"
    echo "#################################" >>"$logdir/${APPNAME:-$1}.err"
    "$@" >>"$logdir/${APPNAME:-$1}.log" 2>>"$logdir/${APPNAME:-$1}.err"
  fi
}

##################################################################################################

cmdif() {
  local package=$1
  devnull unalias "$package"
  if devnull command -v "$package"; then return 0; else return 1; fi
}
perlif() {
  local package=$1
  if devnull perl -M$package -le 'print $INC{"$package/Version.pm"}'; then return 0; else return 1; fi
}
pythonif() {
  local package=$1
  if devnull $PYTHONVER -c "import $package"; then return 0; else return 1; fi
}

##################################################################################################

cmd_missing() { cmdif "$1" || MISSING+="$1 "; }
perl_missing() { perlif $1 || MISSING+="perl-$1 "; }
python_missing() { pythonif "$1" || MISSING+="$PYTHONVER-$1 "; }

##################################################################################################

ln_rm() { devnull find "$1" -xtype l -delete; }
rm_rf() { if [ -e "$1" ]; then backupfile "$@" && devnull rm -Rf "$@"; fi; }
cp_rf() { if [ -e "$1" ]; then backupfile "$2" && devnull cp -Rfa "$@"; fi; }
ln_sf() {
  backupfile "$@"
  [ -L "$2" ] && rm_rf "$2"
  devnull ln -sf "$@"
}
mv_f() { if [ -e "$1" ]; then
  backupfile "$2"
  devnull mv -f "$@"
fi; }
mkd() { devnull mkdir -p "$@"; }
replace() { find "$1" -not -path "$1/.git/*" -type f -exec sed -i "s#$2#$3#g" {} \; >/dev/null 2>&1; }
rmcomments() { sed 's/[[:space:]]*#.*//;/^[[:space:]]*$/d'; }
countwd() { cat $@ | wc-l | rmcomments; }
urlcheck() { devnull curl --output /dev/null --silent --head --fail "$1"; }
urlinvalid() { if [ -z "$1" ]; then printf_red "Invalid URL\n"; else
  printf_red "Can't find $1\n"
  exit 1
fi; }
urlverify() { urlcheck $1 || urlinvalid $1; }
symlink() { ln_sf "$1" "$2"; }

##################################################################################################

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
  if [ "$(cmdif yay)" ] || [ "$(cmdif pacman)" ]; then PYTHONVER="python" && PIP="pip3"; fi
}
__getpythonver

##################################################################################################

setexitstatus() {
  [ ! -z "$EXIT" ] && local EXIT="$?"
  export EXITSTATUS+="$EXIT"
  if [ -z "$EXITSTATUS" ] || [ "$EXITSTATUS" -ne 0 ]; then
    BG_EXIT="${BG_RED}"
    return 1
  else
    BG_EXIT="${BG_GREEN}"
    return 0
  fi
}

##################################################################################################

returnexitcode() {
  if [ "$EXIT" -eq 0 ]; then
    BG_EXIT="${BG_GREEN}"
    return 0
  else
    BG_EXIT="${BG_RED}"
    return 1
  fi
}

##################################################################################################

getexitcode() {
  EXIT="$?"
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
    local PERROR="Command failed"
  fi
  if [ "$EXIT" -eq 0 ]; then
    printf_cyan "$PSUCCES"
  else
    printf_red "$PERROR"
  fi
  unset ERROR SUCCES
  returnexitcode
}

##################################################################################################

getlipaddr() {
  NETDEV="$(ip route | grep default | sed -e "s/^.*dev.//" -e "s/.proto.*//")"
  CURRIP4="$(/sbin/ifconfig $NETDEV | grep -E "venet|inet" | grep -v "127.0.0." | grep 'inet' | grep -v inet6 | awk '{print $2}' | sed s#addr:##g | head -n1)"
}

##################################################################################################

check_app() {
  local MISSING=""
  for cmd in "$@"; do cmdif $cmd || MISSING+="$cmd "; done
  if [ ! -z "$MISSING" ]; then
    printf_question "$cmd is not installed Would you like install it" [y/N]
    read -n 1 -s choice
    if [[ $choice == "y" || $choice == "Y" ]]; then
      for miss in $MISSING; do
        execute "pkmgr install $miss" "Installing $miss"
      done
    fi
  else
    return 1
  fi
}

##################################################################################################

check_pip() {
  local MISSING=""
  for cmd in "$@"; do cmdif $cmd || MISSING+="$cmd "; done
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

##################################################################################################

check_cpan() {
  local MISSING=""
  for cmd in "$@"; do cmdif $cmd || MISSING+="$cmd "; done
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

##################################################################################################

can_i_sudo() {
  (
    ISINDSUDO=$(sudo grep -Re "$MYUSER" /etc/sudoers* | grep "ALL" >/dev/null)
    sudo -vn && sudo -ln
  ) 2>&1 | grep -v 'may not' >/dev/null
}

##################################################################################################

sudoask() {
  if [ ! -f "$HOME/.sudo" ]; then
    sudo true &>/dev/null
    while true; do
      echo "$$" >"$HOME/.sudo"
      sudo -n true
      sleep 10
      rm -Rf "$HOME/.sudo"
      kill -0 "$$" || return
    done &>/dev/null &
  fi
}

##################################################################################################

git_clone() {
  local repo="$1"
  rm_rf "$2"
  devnull git clone -q --recursive "$@"
  setexitstatus
}

##################################################################################################

git_update() {
  local repo="$(git remote -v | grep fetch | head -n 1 | awk '{print $2}')"
  devnull git reset --hard &&
    devnull git pull --recurse-submodules -fq &&
    devnull git submodule update --init --recursive -q &&
    devnull git reset --hard -q
  if [ "$?" -ne "0" ]; then
    cd "$HOME"
    devnull git_clone "$repo" "$PROJECT_DIR/$USERNAME/$i"
  fi
  setexitstatus
}

##################################################################################################

sudoexit() {
  if [ $? -eq 0 ]; then
    sudoask || printf_green "Getting privileges successfull continuing"
  else
    printf_red "Failed to get privileges\n"
  fi
}

##################################################################################################

requiresudo() {
  if [ -f "$(command -v sudo 2>/dev/null)" ]; then
    if (sudo -vn && sudo -ln) 2>&1 | grep -v 'may not' >/dev/null; then
      sudoask
      sudoexit
      sudo "$@" 2>/dev/null
    fi
  else
    printf_red "You dont have access to sudo\n\t\tPlease contact the syadmin for access"
  fi
}

##################################################################################################

kill_all_subprocesses() {
  local i=""
  for i in $(jobs -p); do
    kill "$i"
    wait "$i" &>/dev/null
  done
}

##################################################################################################

execute() {
  local -r CMDS="$1"
  local -r MSG="${2:-$1}"
  local -r TMP_FILE="$(mktemp /tmp/XXXXX)"
  local exitCode=0
  local cmdsPID=""
  set_trap "EXIT" "kill_all_subprocesses"
  eval "$CMDS" &>/dev/null 2>"$TMP_FILE" &
  cmdsPID=$!
  show_spinner "$cmdsPID" "$CMDS" "$MSG"
  wait "$cmdsPID" &>/dev/null
  exitCode=$?
  printf_execute_result $exitCode "$MSG"
  if [ $exitCode -ne 0 ]; then
    printf_execute_error_stream <"$TMP_FILE"
  fi
  rm -rf "$TMP_FILE"
  return $exitCode
}
##################################################################################################
show_spinner() {
  local -r FRAMES='/-\|'
  local -r NUMBER_OR_FRAMES=${#FRAMES}
  local -r CMDS="$2"
  local -r MSG="$3"
  local -r PID="$1"
  local i=0
  local frameText=""
  if [ "$TRAVIS" != "true" ]; then
    printf "\n\n\n"
    tput cuu 3
    tput sc
  fi
  while kill -0 "$PID" &>/dev/null; do
    frameText="                [ ${FRAMES:i++%NUMBER_OR_FRAMES:1} ] $MSG"
    if [ "$TRAVIS" != "true" ]; then
      printf "%s\n" "$frameText"
    else
      printf "%s" "$frameText"
    fi
    sleep 0.2
    if [ "$TRAVIS" != "true" ]; then
      tput rc
    else
      printf "\r"
    fi
  done
}

##################################################################################################

# end
# vi: set expandtab ts=4 fileencoding=utf-8 filetype=sh noai
