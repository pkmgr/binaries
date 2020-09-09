#!/usr/bin/env bash

APPNAME="${APPNAME:-app-installer}"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# @Author      : Jason
# @Contact     : casjaysdev@casjay.net
# @File        : app-installer.bash
# @Created     : Wed, Aug 05, 2020, 02:00 EST
# @License     : WTFPL
# @Copyright   : Copyright (c) CasjaysDev
# @Description : installer functions for apps
#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

set -o pipefail
trap '' ERR EXIT

export PATH="$(echo $PATH:/usr/local/bin:/usr/bin:/user/games | tr ':' '\n' | awk '!seen[$0]++' | tr '\n' ':' | sed 's#::#:.#g')"
export SUDO_PROMPT="$(printf "\t\t\033[1;31m")[sudo]$(printf "\033[1;36m") password for $(printf "\033[1;32m")%p: $(printf "\033[0m")"
export TMP="${TMP:-/tmp}"
export TEMP="${TEMP:-/tmp}"

export WHOAMI="${SUDO_USER:-$USER}"
export HOME="${USER_HOME:-$HOME}"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

cmd_exists() {
  local pkg LISTARRAY
  declare -a LISTARRAY="$*"
  for cmd in $LISTARRAY; do
    type -P "$1" | grep -q "/" 2>/dev/null
  done
}

devnull() { "$@" >/dev/null 2>&1; }
#devnull() { mkdir -p "$HOME/.local/log/dfmgr"; touch "$HOME/.local/log/dfmgr/$APPNAME.log" "$HOME/.local/log/dfmgr/$APPNAME.err"; chmod -Rf 755 "$HOME/.local/log/dfmgr"; "$@" >>"$HOME/.local/log/dfmgr/$APPNAME.log" 2>>"$HOME/.local/log/dfmgr/$APPNAME.err"; }

devnull2() { "$@" 2>/dev/null; }

# fail if git is not installed

if ! command -v "git" >/dev/null 2>&1; then
  echo -e "\t\t\033[0;31mAttempting to install git\033[0m"
  if cmd_exists apt; then
    apt install -yy -q git >/dev/null 2>&1
  elif cmd_exists pacman; then
    pacman -S --noconfirm git >/dev/null 2>&1
  elif cmd_exists yum; then
    yum install -yy -q git >/dev/null 2>&1
  elif cmd_exists brew; then
    brew install -f git >/dev/null 2>&1
  elif cmd_exists choco; then
    choco install git -y >/dev/null 2>&1
    if ! command -v git >/dev/null 2>&1; then
      echo -e "\t\t\033[0;31mGit was not installed\033[0m"
      exit 1
    fi
  else
    echo -e "\t\t\033[0;31mGit is not installed\033[0m"
    exit 1
  fi
fi

##################################################################################################

# Set Main Repo for dotfiles
export DOTFILESREPO="${DOTFILESREPO:-https://github.com/dfmgr}"

# Set other Repos
export DFMGRREPO="${DFMGRREPO:-https://github.com/dfmgr}"
export PKMGRREPO="${PKMGRREPO:-https://github.com/pkmgr}"
export DEVENVMGRREPO="${DEVENVMGR:-https://github.com/devenvmgr}"
export ICONMGRREPO="${ICONMGRREPO:-https://github.com/iconmgr}"
export FONTMGRREPO="${FONTMGRREPO:-https://github.com/fontmgr}"
export THEMEMGRREPO="${THEMEMGRREPO:-https://github.com/thememgr}"
export SYSTEMMGRREPO="${SYSTEMMGRREPO:-https://github.com/systemmgr}"
export WALLPAPERMGRREPO="${WALLPAPERMGRREPO:-https://github.com/wallpapermgr}"

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

##################################################################################################

printf_color() { printf "%b" "$(tput setaf "$2" 2>/dev/null)" "$1" "$(tput sgr0 2>/dev/null)"; }
printf_normal() { printf_color "\t\t$1\n" "$2"; }
printf_green() { printf_color "$1" 2; }
printf_red() { printf_color "$1" 1; }
printf_purple() { printf_color "$1" 5; }
printf_yellow() { printf_color "$1" 3; }
printf_blue() { printf_color "$1" 4; }
printf_cyan() { printf_color "$1" 6; }
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
printf_question() { printf_color "\t\t[ ❓ ] $1 [❓] " 6; }
printf_error_stream() { while read -r line; do printf_error "↳ ERROR: $line"; done; }
printf_execute_success() { printf_color "\t\t[ ✔ ] $1 \n" 2; }
printf_execute_error() { printf_color "\t\t[ ✖ ] $1 $2 \n" 1; }
printf_execute_result() {
  if [ "$1" -eq 0 ]; then
    printf_execute_success "$2"
  else
    printf_execute_error "$2"
  fi
  return "$1"
}
printf_execute_error_stream() { while read -r line; do printf_execute_error "↳ ERROR: $line"; done; }

##################################################################################################

printf_readline() {
  $(set -o pipefail)
  [[ $1 == ?(-)+([0-9]) ]] && local color="$1" && shift 1 || local color="3"
  while read line; do
    printf_custom "$color" "$line"
  done
  $(set +o pipefail)
}

##################################################################################################

printf_custom() {
  [[ $1 == ?(-)+([0-9]) ]] && local color="$1" && shift 1 || local color="1"
  local msg="$*"
  shift
  printf_color "\t\t$msg" "$color"
  echo ""
}

##################################################################################################

printf_custom_input() {
  local color="1"
  local msg="$1"
  shift
  read -e -p
}

##################################################################################################

printf_custom_question() {
  local custom_question
  [[ $1 == ?(-)+([0-9]) ]] && local color="$1" && shift 1 || local color="1"
  local msg="$*"
  shift
  printf_color "\t\t$msg " "$color"
}

##################################################################################################

printf_question_timeout() {
  local custom_question
  [[ $1 == ?(-)+([0-9]) ]] && local color="$1" && shift 1 || local color="1"
  local msg="$*"
  shift
  printf_color "\t\t$msg " "$color"
  read -t 10 -n 1 answer && echo ""
  #if [[ $answer == "y" || $answer == "Y" ]]; then
  #fi
}

##################################################################################################

printf_head() {
  [[ $1 == ?(-)+([0-9]) ]] && local color="$1" && shift 1 || local color="6"
  local msg="$*"
  shift
  printf_color "
\t\t##################################################
\t\t$msg
\t\t##################################################\n\n" "$color"
}

##################################################################################################

printf_result() {
  [ ! -z "$1" ] && EXIT="$1" || EXIT="$?"
  [ ! -z "$2" ] && local OK="$2" || local OK="Command executed successfully"
  [ ! -z "$2" ] && local FAIL="$2" || local FAIL="Last command failed"
  if [ "$EXIT" -eq 0 ]; then
    printf_success "$OK"
    exit 0
  else
    printf_error "$FAIL"
    exit 1
  fi
}

##################################################################################################

notifications() {
  local title="$1"
  shift 1
  local msg="$*"
  shift
  cmd_exists notify-send && notify-send -u normal -i "notification-message-IM" "$title" "$msg" || return 0
}

##################################################################################################

die() { echo -e "$1" exit ${2:9999}; }
killpid() { devnull kill -9 "$(pidof "$1")"; }
hostname2ip() { getent hosts "$1" | cut -d' ' -f1 | head -n1; }
set_trap() { trap -p "$1" | grep "$2" &>/dev/null || trap '$2' "$1"; }
getuser() { [ -z "$1" ] && cut -d: -f1 /etc/passwd | grep "$USER" || cut -d: -f1 /etc/passwd | grep "$1"; }

system_service_exists() {
  if sudo systemctl list-units --full -all | grep -Fq "$1"; then return 0; else return 1; fi
  setexitstatus
  set --
}

system_service_enable() {
  if system_service_exists; then execute "sudo systemctl enable -f $1" "Enabling service: $1"; fi
  setexitstatus
  set --
}

system_service_disable() {
  if system_service_exists; then execute "sudo systemctl disable --now $1" "Disabling service: $1"; fi
  setexitstatus
  set --
}

run_post() {
  local e="$1"
  local m="${e//devnull//}"
  #local m="$(echo $1 | sed 's#devnull ##g')"
  execute "$e" "executing: $m"
  setexitstatus
  set --
}

##################################################################################################

#transmission-remote-cli() { cmd_exists transmission-remote-cli || cmd_exists transmission-remote ;}
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

export -f mlocate xfce4 imagemagick fdfind speedtest neovim chromium firefox gtk-2.0 gtk-3.0

##################################################################################################

backupapp() {
  local filename count backupdir rmpre4vbackup
  [ ! -z "$1" ] && local myappdir="$1" || local myappdir="$APPDIR"
  [ ! -z "$2" ] && local myappname="$2" || local myappname="$APPNAME"
  local logdir="$HOME/.local/log/backupapp"
  local curdate="$(date +%Y-%m-%d-%H-%M-%S)"
  local filename="$myappname-$curdate.tar.gz"
  local backupdir="${MY_BACKUP_DIR:-$HOME/.local/backups/dotfiles}"
  local count="$(ls $backupdir/$myappname*.tar.gz 2>/dev/null | wc -l 2>/dev/null)"
  local rmpre4vbackup="$(ls $backupdir/$myappname*.tar.gz 2>/dev/null | head -n 1)"
  mkdir -p "$backupdir" "$logdir"
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

##################################################################################################

rm_rf() { if [ -e "$1" ]; then devnull rm -Rf "$@"; else return 0; fi; }
cp_rf() { if [ -e "$1" ]; then devnull cp -Rfa "$@"; else return 0; fi; }
ln_rm() { devnull find "$1" -xtype l -delete || return 0; }
ln_sf() {
  [ -L "$2" ] && rm_rf "$2"
  devnull ln -sf "$@" || return 0
}
mv_f() { if [ -e "$1" ]; then devnull mv -f "$@"; else return 0; fi; }
mkd() { if [ ! -e "$1" ]; then devnull mkdir -p "$@"; else return 0; fi; }
replace() { find "$1" -not -path "$1/.git/*" -type f -exec sed -i "s#$2#$3#g" {} \; >/dev/null 2>&1; }
rmcomments() { sed 's/[[:space:]]*#.*//;/^[[:space:]]*$/d'; }
countwd() { cat "$@" | wc-l | rmcomments; }
urlcheck() { devnull curl --config /dev/null --connect-timeout 3 --retry 3 --retry-delay 1 --output /dev/null --silent --head --fail "$1"; }
urlinvalid() { if [ -z "$1" ]; then
  printf_red "\t\tInvalid URL\n"
  failexitcode
else
  printf_red "\t\tCan't find $1\n"
  failexitcode
fi; }
urlverify() { urlcheck "$1" || urlinvalid "$1"; }
symlink() { ln_sf "$1" "$2"; }

##################################################################################################

cmdif() {
  local package="$1"
  unalias "$package" >/dev/null 2>&1
  if command -v "$package" >/dev/null 2>&1; then return 0; else return 1; fi
}

gemif() {
  local package="$1"
  if devnull gem query -i -n "$package"; then return 0; else return 1; fi
}

perlif() {
  local package="$1"
  if devnull perl -M$package -le 'print $INC{"$package/Version.pm"}' || devnull perl -M$package -le 'print $INC{"$package.pm"}' || devnull perl -M$package -le 'print $INC{"$package"}'; then
    return 0
  else
    return 1
  fi
}

pythonif() {
  local package="$1"
  if devnull $PYTHONVER -c "import $package"; then return 0; else return 1; fi
}

##################################################################################################

retry_cmd() {
  retries="${1:-}"
  shift
  count=0
  until "$@"; do
    exit=$?
    wait=$((2 ** count))
    count=$((count + 1))
    if [ "$count" -lt "$retries" ]; then
      echo "Retry $count/$retries exited $exit, retrying in $wait seconds ..."
      sleep $wait
    else
      echo "Retry $count/$retries exited $exit, no more retries left."
      exit $exit
    fi
  done
}

##################################################################################################

returnexitcode() {
  local RETVAL="$?"
  EXIT="$RETVAL"
  if [ "$RETVAL" -ne 0 ]; then
    return "$EXIT"
  fi
}

##################################################################################################

getexitcode() {
  local RETVAL="$?"
  local ERROR="Setup failed"
  local SUCCES="$1"
  EXIT="$RETVAL"
  if [ "$RETVAL" -eq 0 ]; then
    printf_success "$SUCCES"
  else
    printf_error "$ERROR"
    exit "$EXIT"
  fi
}

##################################################################################################

failexitcode() {
  local RETVAL="$?"
  [ ! -z "$1" ] && local fail="$1" || local fail="Command has failed"
  [ ! -z "$2" ] && local success="$2" || local success=""
  if [ "$RETVAL" -ne 0 ]; then
    set -eE
    printf_error "$fail"
    exit 1
  else
    set +eE
    [ -z "$success" ] || printf_custom "42" "$success"
  fi
}

##################################################################################################

setexitstatus() {
  [ -z "$EXIT" ] && local EXIT="$?" || local EXIT="$EXIT"
  local EXITSTATUS+="$EXIT"
  if [ -z "$EXITSTATUS" ] || [ "$EXITSTATUS" -ne 0 ]; then
    BG_EXIT="${BG_RED}"
    return 1
  else
    BG_EXIT="${BG_GREEN}"
    return 0
  fi
}

##################################################################################################

get_answer() { printf "%s" "$REPLY"; }
ask() {
  printf_question "$1"
  read -r
}
answer_is_yes() { [[ "$REPLY" =~ ^[Yy]$ ]] && return 0 || return 1; }
ask_for_confirmation() {
  printf_question "$1 (y/n) "
  read -r -n 1
  printf "\n"
}

##################################################################################################

__getip() {
  NETDEV="$(ip route | grep default | sed -e "s/^.*dev.//" -e "s/.proto.*//")"
  CURRIP4="$(/sbin/ifconfig $NETDEV | grep -E "venet|inet" | grep -v "127.0.0." | grep 'inet' | grep -v inet6 | awk '{print $2}' | sed s/addr://g | head -n1)"
}
__getip

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

sudoif() { (sudo -vn && sudo -ln) 2>&1 | grep -v 'may not' >/dev/null; }
sudorun() { if sudoif; then sudo -HE "$@"; else "$@"; fi; }
sudorerun() {
  local ARGS="$ARGS"
  if [[ $UID != 0 ]]; then if sudoif; then sudo -HE "$APPNAME" "$ARGS" && exit $?; else sudoreq; fi; fi
}
sudoreq() { if [[ $UID != 0 ]]; then
  echo "" && printf_error "Please run this script with sudo"
  returnexitcode
  exit 1
fi; }

######################

can_i_sudo() {
  (
    ISINDSUDO=$(sudo grep -Re "$MYUSER" /etc/sudoers* | grep "ALL" >/dev/null)
    sudo -vn && sudo -ln
  ) 2>&1 | grep -v 'may not' >/dev/null
}

######################

sudoask() {
  if [ ! -f "$HOME/.sudo" ]; then
    sudo true &>/dev/null
    while true; do
      echo -e "$!" >"$HOME/.sudo"
      sudo -n true && echo -e "$$" >>"$HOME/.sudo"
      sleep 10
      rm -Rf "$HOME/.sudo"
      kill -0 "$$" || return
    done &>/dev/null &
  fi
}

######################

sudoexit() {
  if [ $? -eq 0 ]; then
    sudoask || printf_green "\t\tGetting privileges successfull continuing\n" &&
      sudo -n true
  else
    printf_red "\t\tFailed to get privileges\n"
  fi
}

######################

requiresudo() {
  if [ -f "$(command -v sudo 2>/dev/null)" ]; then
    if (sudo -vn && sudo -ln) 2>&1 | grep -v 'may not' >/dev/null; then
      sudoask
      sudoexit && sudo "$@"
    fi
  else
    printf_red "\t\tYou dont have access to sudo\n\t\tPlease contact the syadmin for access\n"
  fi
}

##################################################################################################

crontab_add() {
  shift
  case "$1" in
  remove)
    if [[ $EUID -ne 0 ]]; then
      printf_green "\t\tRemoving $APPNAME from $WHOAMI crontab\n"
      crontab -l | grep -v -F "$APPNAME" | crontab -

    else
      printf_green "\t\tRemoving $APPNAME from root crontab\n"
      sudo crontab -l | grep -v -F "$APPNAME" | sudo crontab -
    fi
    ;;
  *)
    local sleepcmd="$(expr $RANDOM \% 300)"
    local cronjob="0 4 * * * sleep ${sleepcmd} ;"
    if [[ $EUID -ne 0 ]]; then
      local croncmd="devnull bash -c $APPDIR/install.sh &\n"
      printf_green "\t\tAdding $APPNAME to $WHOAMI crontab"
      crontab -l | grep -qv -F "$croncmd"
      echo "$cronjob $croncmd" | tee | devnull crontab -
    else
      local croncmd="devnull sudo bash -c $APPDIR/install.sh &"
      printf_green "\t\tAdding $APPNAME to root crontab\n"
      sudo crontab -l | grep -qv -F "$croncmd"
      echo "$cronjob $croncmd" | tee | devnull sudo crontab -
    fi
    ;;
  esac
}

##################################################################################################

versioncheck() {
  if [ -f $APPDIR/version.txt ]; then
    printf_green "\t\tChecking for updates\n"
    local NEWVERSION="$(echo $APPVERSION | grep -v "#" | tail -n 1)"
    local OLDVERSION="$(cat $APPDIR/version.txt | grep -v "#" | tail -n 1)"
    if [ "$NEWVERSION" == "$OLDVERSION" ]; then
      printf_green "\t\tNo updates available current\n\t\tversion is $OLDVERSION\n"
    else
      printf_blue "\t\tThere is an update available\n"
      printf_blue "\t\tNew version is $NEWVERSION and current\n\t\tversion is $OLDVERSION\n"
      printf_question "Would you like to update" [y/N]
      read -n 1 -s choice
      echo ""
      if [[ $choice == "y" || $choice == "Y" ]]; then
        [ -f "$APPDIR/install.sh" ] && bash -c "$APPDIR/install.sh" && echo ||
          cd $APPDIR && git pull -q &&
          printf_green "\t\tUpdated to $NEWVERSION\n" ||
          printf_red "\t\tFailed to update\n"
      else
        printf_cyan "\t\tYou decided not to update\n"
      fi
    fi
  fi
  exit $?
}

##################################################################################################

scripts_check() {
  if ! cmd_exists "pkmgr" && [ ! -f ~/.noscripts ]; then
    printf_red "\t\tPlease install my scripts repo - requires root/sudo\n"
    printf_question "Would you like to do that now" [y/N]
    read -n 1 -s choice && echo ""
    if [[ $choice == "y" || $choice == "Y" ]]; then
      urlverify $REPO/scripts/raw/master/install.sh &&
        sudo bash -c "$(curl -LSs $REPO/installer/raw/master/install.sh)" && echo
    else
      touch ~/.noscripts
      exit 1
    fi
  fi
}

##################################################################################################

#is_url() { echo "$1" | grep -q http; }
#strip_url() { echo "$1" | sed 's#git+##g' | awk -F//*/ '{print $2}' | sed 's#.*./##g' | sed 's#python-##g'; }

cmd_missing() { cmdif "$1" && return 0 || MISSING+="$1 " && return 1; }
cpan_missing() { perlif "$1" && return 0 || MISSING+="$1" && return 1; }
gem_missing() { gemif "$1" && return 0 || MISSING+="$1 " && return 1; }
perl_missing() { perlif "$1" && return 0 || MISSING+="$(echo perl-$1 | sed 's#::#-#g') " && return 1; }
pip_missing() { pythonif "$1" && return 0 || MISSING+="$1 " && return 1; }

if cmd_exists pacman; then
  python_missing() { pythonif "$1" && return 0 || MISSING+="python-$1 " && return 1; }
else
  python_missing() { pythonif "$1" && return 0 || MISSING+="$PYTHONVER-$1 " && return 1; }
fi

##################################################################################################

git_clone() {
  local repo="$1"
  [ ! -z "$2" ] && local myappdir="$2" || local myappdir="$APPDIR"
  [ ! -d "$myappdir" ] || rm_rf "$myappdir"
  devnull git clone --depth=1 -q --recursive "$@"
}

##################################################################################################

git_update() {
  cd "$APPDIR" || exit 1
  local repo="$(git remote -v | grep fetch | head -n 1 | awk '{print $2}')"
  devnull git reset --hard &&
    devnull git pull --recurse-submodules -fq &&
    devnull git submodule update --init --recursive -q &&
    devnull git reset --hard -q
  if [ "$?" -ne "0" ]; then
    cd "$HOME" || exit 1
    backupapp "$APPDIR" "$APPNAME" &&
      devnull rm_rf "$APPDIR" &&
      git_clone "$repo" "$APPDIR"
  fi
}

##################################################################################################

dotfilesreqcmd() {
  local gitrepo="$REPO"
  urlverify "$gitrepo/$conf/raw/master/install.sh" &&
    bash -c "$(curl -LSs $gitrepo/$conf/raw/master/install.sh)" ||
    return 1
}

dotfilesreq() {
  local confdir="$USRUPDATEDIR"
  declare -a LISTARRAY="$@"
  for conf in ${LISTARRAY[*]}; do
    if [ ! -f "$confdir/$conf" ] && [ ! -f "$TEMP/$conf.inst.tmp" ]; then
      execute \
        "dotfilesreqcmd" \
        "Installing required dotfile $conf"
    fi
  done
  rm_rf $TEMP/*.inst.tmp
}

##################################################################################################
dotfilesreqadmincmd() {
  local gitrepo="$REPO"
  urlverify "$gitrepo/$conf/raw/master/install.sh" &&
    sudo bash -c "$(curl -LSs $gitrepo/$conf/raw/master/install.sh)" ||
    return 1
}

dotfilesreqadmin() {
  local confdir="$SYSUPDATEDIR"
  declare -a LISTARRAY="$@"
  for conf in ${LISTARRAY[*]}; do
    if [ ! -f "$confdir/$conf" ] && [ ! -f "$TEMP/$conf.inst.tmp" ]; then
      execute \
        "dotfilesreqadmincmd" \
        "Installing required dotfile $conf"
    fi
  done
  rm_rf $TEMP/*.inst.tmp
}

##################################################################################################

install_packages() {
  local MISSING=""
  for cmd in "$@"; do cmdif $cmd || MISSING+="$cmd "; done
  if [ ! -z "$MISSING" ]; then
    if cmd_exists "pkmgr"; then
      printf_warning "Attempting to install missing packages"
      printf_warning "$MISSING"
      for miss in $MISSING; do
        if cmd_exists yay; then
          execute "pkmgr --enable-aur silent $miss" "Installing $miss"
        else
          execute "pkmgr silent $miss" "Installing $miss"
        fi
      done
    fi
  fi
  unset MISSING
}

##################################################################################################

install_required() {
  local MISSING=""
  for cmd in "$@"; do cmdif $cmd || MISSING+="$cmd "; done
  if [ ! -z "$MISSING" ]; then
    if cmd_exists "pkmgr"; then
      printf_warning "Installing from package list"
      printf_warning "Still missing: $MISSING"
      if cmd_exists yay; then
        pkmgr --enable-aur dotfiles "$APPNAME"
      else
        pkmgr dotfiles "$APPNAME"
      fi
    fi
  fi
  unset MISSING
}

##################################################################################################

install_python() {
  local MISSING=""
  for cmd in "$@"; do python_missing "$cmd"; done
  if [ ! -z "$MISSING" ]; then
    if cmd_exists "pkmgr"; then
      printf_warning "Attempting to install missing python packages"
      printf_warning "$MISSING"
      for miss in $MISSING; do
        if cmd_exists yay; then
          execute "pkmgr --enable-aur silent $miss" "Installing $miss"
        else
          execute "pkmgr silent $miss" "Installing $miss"
        fi
      done
    fi
  fi
  unset MISSING
}

##################################################################################################

install_perl() {
  local MISSING=""
  for cmd in "$@"; do perl_missing "$cmd"; done
  if [ ! -z "$MISSING" ]; then
    if cmd_exists "pkmgr"; then
      printf_warning "Attempting to install missing perl packages"
      printf_warning "$MISSING"
      for miss in $MISSING; do
        if cmd_exists yay; then
          execute "pkmgr --enable-aur silent $miss" "Installing $miss"
        else
          execute "pkmgr silent $miss" "Installing $miss"
        fi
      done
    fi
  fi
  unset MISSING
}

##################################################################################################

install_pip() {
  local MISSING=""
  for cmd in "$@"; do cmdif $cmd || pip_missing "$cmd"; done
  if [ ! -z "$MISSING" ]; then
    if cmd_exists "pkmgr"; then
      printf_warning "Attempting to install missing pip packages"
      printf_warning "$MISSING"
      for miss in $MISSING; do
        execute "pkmgr pip $miss" "Installing $miss"
      done
    fi
  fi
  unset MISSING
}

##################################################################################################

install_cpan() {
  local MISSING=""
  for cmd in "$@"; do cmdif $cmd || cpan_missing "$cmd"; done
  if [ ! -z "$MISSING" ]; then
    if cmd_exists "pkmgr"; then
      printf_warning "Attempting to install missing cpan packages"
      printf_warning "$MISSING"
      for miss in $MISSING; do
        execute "pkmgr cpan $miss" "Installing $miss"
      done
    fi
  fi
  unset MISSING
}

##################################################################################################

install_gem() {
  local MISSING=""
  for cmd in "$@"; do cmdif $cmd || gem_missing $cmd; done
  if [ ! -z "$MISSING" ]; then
    if cmd_exists "pkmgr"; then
      printf_warning "Attempting to install missing gem packages"
      printf_warning "$MISSING"
      for miss in $MISSING; do
        execute "pkmgr gem $miss" "Installing $miss"
      done
    fi
  fi
  unset MISSING
}

##################################################################################################

trim() {
  local IFS=' '
  local trimmed="${*//[[:space:]]/}"
  echo "$trimmed"
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

git_repo_urls() {
  REPO="${REPO:-https://github.com/dfmgr}"
  REPORAW="${REPORAW:-$REPO/$APPNAME/raw}"
}

##################################################################################################

os_support() {
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

unsupported_oses() {
  for OSes in "$@"; do
    if [[ "$(echo $1 | tr '[:upper:]' '[:lower:]')" =~ "$(os_support)" ]]; then
      printf_red "\t\t$(os_support $OSes) is not supported\n"
      exit
    fi
  done
}

##################################################################################################

user_installdirs() {
  touch "$TEMP/$APPNAME.inst.tmp"
  APPNAME="${APPNAME:-installer}"

  if [[ $(id -u) -eq 0 ]] || [[ $EUID -eq 0 ]] || [[ "$WHOAMI" = "root" ]]; then
    export INSTALL_TYPE=user
    export HOME="/root"
    export BIN="$HOME/.local/bin"
    export CONF="$HOME/.config"
    export SHARE="$HOME/.local/share"
    export LOGDIR="$HOME/.local/log"
    export STARTUP="$HOME/.config/autostart"
    export SYSBIN="/usr/local/bin"
    export SYSCONF="/usr/local/etc"
    export SYSSHARE="/usr/local/share"
    export SYSLOGDIR="/usr/local/log"
    export BACKUPDIR="$HOME/.local/backups/dotfiles"
    export COMPDIR="$HOME/.local/share/bash-completion/completions"
    export THEMEDIR="$SHARE/themes"
    export ICONDIR="$SHARE/icons"
    export FONTDIR="$SHARE/fonts"
    export FONTCONF="$SYSCONF/fontconfig/conf.d"
    export CASJAYSDEVSHARE="$SHARE/CasjaysDev"
    export CASJAYSDEVSAPPDIR="$CASJAYSDEVSHARE/apps"
    export WALLPAPERS="${WALLPAPERS:-$SYSSHARE/wallpapers}"
    #    USRUPDATEDIR="$SHARE/CasjaysDev/apps/dotfiles"
    #    SYSUPDATEDIR="$SYSSHARE/CasjaysDev/apps/dotfiles"
  else
    export INSTALL_TYPE=user
    export HOME="${HOME}"
    export BIN="$HOME/.local/bin"
    export CONF="$HOME/.config"
    export SHARE="$HOME/.local/share"
    export LOGDIR="$HOME/.local/log"
    export STARTUP="$HOME/.config/autostart"
    export SYSBIN="$HOME/.local/bin"
    export SYSCONF="$HOME/.config"
    export SYSSHARE="$HOME/.local/share"
    export SYSLOGDIR="$HOME/.local/log"
    export BACKUPDIR="$HOME/.local/backups/dotfiles"
    export COMPDIR="$HOME/.local/share/bash-completion/completions"
    export THEMEDIR="$SHARE/themes"
    export ICONDIR="$SHARE/icons"
    export FONTDIR="$SHARE/fonts"
    export FONTCONF="$SYSCONF/fontconfig/conf.d"
    export CASJAYSDEVSHARE="$SHARE/CasjaysDev"
    export CASJAYSDEVSAPPDIR="$CASJAYSDEVSHARE/apps"
    export WALLPAPERS="$HOME/.local/share/wallpapers"
    #    USRUPDATEDIR="$SHARE/CasjaysDev/apps/dotfiles"
    #    SYSUPDATEDIR="$SYSSHARE/CasjaysDev/apps/dotfiles"
  fi
  git_repo_urls
}

##################################################################################################

system_installdirs() {
  touch "$TEMP/$APPNAME.inst.tmp"
  APPNAME="${APPNAME:-installer}"

  if [[ $(id -u) -eq 0 ]] || [[ $EUID -eq 0 ]] || [[ "$WHOAMI" = "root" ]]; then
    #printf_info "Install Type: system - ${WHOAMI}"
    #printf_red "\t\tInstalling as root ❓\n"
    export INSTALL_TYPE=system
    export BACKUPDIR="$HOME/.local/backups/dotfiles"
    export HOME="/root"
    export BIN="/usr/local/bin"
    export CONF="/usr/local/etc"
    export SHARE="/usr/local/share"
    export LOGDIR="/usr/local/log"
    export STARTUP="/dev/null"
    export SYSBIN="/usr/local/bin"
    export SYSCONF="/usr/local/etc"
    export SYSSHARE="/usr/local/share"
    export SYSLOGDIR="/usr/local/log"
    export COMPDIR="/etc/bash_completion.d"
    export THEMEDIR="/usr/local/share/themes"
    export ICONDIR="/usr/local/share/icons"
    export FONTDIR="/usr/local/share/fonts"
    export FONTCONF="/usr/local/share/fontconfig/conf.d"
    export CASJAYSDEVSHARE="/usr/local/share/CasjaysDev"
    export CASJAYSDEVSAPPDIR="/usr/local/share/CasjaysDev/apps"
    export WALLPAPERS="/usr/local/share/wallpapers"
    #    USRUPDATEDIR="/usr/local/share/CasjaysDev/apps"
    #    SYSUPDATEDIR="/usr/local/share/CasjaysDev/apps"
  else
    export INSTALL_TYPE=system
    export BACKUPDIR="${BACKUPS:-$HOME/.local/backups/dotfiles}"
    export HOME="${HOME:-/home/$WHOAMI}"
    export BIN="$HOME/.local/bin"
    export CONF="$HOME/.config"
    export SHARE="$HOME/.local/share"
    export LOGDIR="$HOME/.local/log"
    export STARTUP="$HOME/.config/autostart"
    export SYSBIN="$HOME/.local/bin"
    export SYSCONF="$HOME/.local/etc"
    export SYSSHARE="$HOME/.local/share"
    export SYSLOGDIR="$HOME/.local/log"
    export COMPDIR="$HOME/.local/share/bash-completion/completions"
    export THEMEDIR="$HOME/.local/share/themes"
    export ICONDIR="$HOME/.local/share/icons"
    export FONTDIR="$HOME/.local/share/fonts"
    export FONTCONF="$HOME/.local/share/fontconfig/conf.d"
    export CASJAYSDEVSHARE="$HOME/.local/share/CasjaysDev"
    export CASJAYSDEVSAPPDIR="$HOME/.local/share/CasjaysDev/apps"
    export WALLPAPERS="$HOME/.local/share/wallpapers"
    #    USRUPDATEDIR="$HOME/.local/share/CasjaysDev/apps"
    #    SYSUPDATEDIR="/usr/local/share/CasjaysDev/apps"
  fi
  git_repo_urls
}

##################################################################################################

ensure_dirs() {
  if [[ $EUID -ne 0 ]] || [[ "$WHOAMI" != "root" ]]; then
    mkd "$BIN"
    mkd "$SHARE"
    mkd "$LOGDIR"
    mkd "$LOGDIR/dfmgr"
    mkd "$LOGDIR/fontmg"
    mkd "$LOGDIR/iconmgr"
    mkd "$LOGDIR/systemmgr"
    mkd "$LOGDIR/thememgr"
    mkd "$LOGDIR/wallpapermgr"
    mkd "$COMPDIR"
    mkd "$STARTUP"
    mkd "$BACKUPDIR"
    mkd "$FONTDIR"
    mkd "$ICONDIR"
    mkd "$THEMEDIR"
    mkd "$FONTCONF"
    mkd "$CASJAYSDEVSHARE"
    mkd "$CASJAYSDEVSAPPDIR"
    mkd "$USRUPDATEDIR"
    mkd "$SYSUPDATEDIR"
    mkd "$SHARE/applications"
    mkd "$SHARE/CasjaysDev/functions"
    mkd "$SHARE/wallpapers/system"
  fi
  return 0
}

##################################################################################################

ensure_perms() {
  # chown -Rf "$WHOAMI":"$WHOAMI" "$LOGDIR"
  # chown -Rf "$WHOAMI":"$WHOAMI" "$BACKUPDIR"
  # chown -Rf "$WHOAMI":"$WHOAMI" "$CASJAYSDEVSHARE"
  # chown -Rf "$WHOAMI":"$WHOAMI" "$HOME/.local/backups"
  # chown -Rf "$WHOAMI":"$WHOAMI" "$HOME/.local/log"
  # chown -Rf "$WHOAMI":"$WHOAMI" "$HOME/.local/share/CasjaysDev"
  # chmod -Rf 755 "$SHARE"
  # chmod -Rf 755 "$LOGDIR"
  # chmod -Rf 755 "$BACKUPDIR"
  # chmod -Rf 755 "$CASJAYSDEVSHARE"
  # chmod -Rf 755 "$HOME/.local/backups"
  # chmod -Rf 755 "$HOME/.local/log"
  # chmod -Rf 755 "$HOME/.local/share/CasjaysDev"
  return 0
}

##################################################################################################

get_app_version() {
  if [ -f "$APPDIR/version.txt" ]; then
    local version="$(cat "$APPDIR/version.txt" | grep -v "#" | tail -n 1)"
  else
    local version="0000000"
  fi
  local APPVERSION="${APPVERSION:-$REPORAW/master/version.txt}"
  [ -n "$WHOAMI" ] && printf_info "WhoamI:                    $WHOAMI"
  [ -n "$INSTALL_TYPE" ] && printf_info "Install Type:              $INSTALL_TYPE"
  [ -n "$APPNAME" ] && printf_info "APP name:                  $APPNAME"
  [ -n "$APPDIR" ] && printf_info "APP dir:                   $APPDIR"
  [ -n "$REPO/$APPNAME" ] && printf_info "APP repo:                  $REPO/$APPNAME"
  [ -n "$PLUGNAMES" ] && printf_info "Plugins:                   $PLUGNAMES"
  [ -n "$PLUGDIR" ] && printf_info "PluginsDir:                $PLUGDIR"
  [ -n "$version" ] && printf_info "APP Version:               $version"
  [ -n "$APPVERSION" ] && printf_info "Git Version:               $APPVERSION"
  if [ "$version" = "$APPVERSION" ]; then
    printf_info "Update Available:          No"
  else
    printf_info "Update Available:          True"
  fi
}

##################################################################################################

show_optvars() {
  if [ "$1" = "--update" ]; then
    versioncheck
    exit "$?"
  fi

  if [ "$1" = "--cron" ]; then
    crontab_add "$@"
    exit "$?"
  fi

  if [ "$1" = "--stow" ]; then
    config add "$@"
    exit "$?"
  fi

  if [ "$1" = "--help" ]; then
    #    if cmd_exists xdg-open; then
    #      xdg-open "$REPO/$APPNAME"
    #    elif cmd_exists open; then
    #      open "$REPO/$APPNAME"
    #    else
    printf_cyan "\t\tGo to $REPO/$APPNAME for help"
    #    fi
    exit
  fi

  if [ "$1" = "--version" ]; then
    get_app_version
    exit $?
  fi

  if [ "$1" = "--location" ]; then
    printf_info "AppName:                   $APPNAME"
    printf_info "Installed to:              $APPDIR"
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
    printf_info "CompletionsDir:            $COMPDIR"
    printf_info "CasjaysDevDir:             $CASJAYSDEVSHARE"
    exit $?
  fi

  if [ "$1" = "--full" ]; then
    get_app_version
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
    printf_info "ThemeDir                   $THEMEDIR"
    printf_info "FontDir:                   $SHARE/fonts"
    printf_info "FontConfDir:               $FONTCONF"
    printf_info "CompletionsDir:            $COMPDIR"
    printf_info "CasjaysDevDir:             $CASJAYSDEVSHARE"
    printf_info "DevEnv Repo:               $DEVENVMGRREPO"
    printf_info "Package Manager Repo:      $PKMGRREPO"
    printf_info "Icon Manager Repo:         $ICONMGRREPO"
    printf_info "Font Manager Repo:         $FONTMGRREPO"
    printf_info "Theme Manager Repo         $THEMEMGRREPO"
    printf_info "System Manager Repo:       $SYSTEMMGRREPO"
    printf_info "Wallpaper Manager Repo:    $WALLPAPERMGRREPO"
    printf_info "REPORAW:                   $REPO/$APPNAME/raw"
    exit $?
  fi

  if [ "$1" = "--debug" ]; then
    get_app_version
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
    printf_info "REPORAW:                   $REPO/$APPNAME/raw"
    exit $?
  fi

  if [ "$1" = "--installed" ]; then
    printf_green "\t\tUser                               Group                              AppName"
    ls -l $CASJAYSDEVSAPPDIR/dotfiles | tr -s ' ' | cut -d' ' -f3,4,9 | sed 's# #                               #g' | grep -v "total." | printf_readline "5"
    exit $?
  fi

}

##################################################################################################

installer_noupdate() {
  if [ -f "$SYSSHARE/CasjaysDev/apps/systemmgr/$APPNAME" ] || [ -d $APPDIR ]; then
    ln_sf "$APPDIR/install.sh" "$SYSUPDATEDIR/$APPNAME"
    printf_warning "Updating of $APPNAME has been disabled"
    exit 0
  fi
}

##################################################################################################

install_version() {
  mkdir -p "$CASJAYSDEVSAPPDIR/dotfiles" "$CASJAYSDEVSAPPDIR/dotfiles"
  if [ -f "$APPDIR/install.sh" ] && [ -f "$APPDIR/version.txt" ]; then
    ln_sf "$APPDIR/install.sh" "$CASJAYSDEVSAPPDIR/dotfiles/$PREFIX-$APPNAME"
  fi
}

##################################################################################################

dfmgr_install() {
  user_installdirs
  PREFIX="dfmgr"
  REPO="${DFMGRREPO}"
  REPORAW="$REPO/$APPNAME/raw"
  HOMEDIR="$CONF"
  APPDIR="${APPDIR:-$HOMEDIR/$APPNAME}"
  USRUPDATEDIR="$SHARE/CasjaysDev/apps/dfmgr"
  SYSUPDATEDIR="$SYSSHARE/CasjaysDev/apps/dfmgr"
  APPVERSION="$(curl -LSs ${REPO:-https://github.com/$PREFIX}/$APPNAME/raw/master/version.txt)"
}

dfmgr_run_post() {
  dfmgr_install
  run_postinst_global
  replace "$APPDIR" "/home/jason" "$HOME"
}

dfmgr_install_version() {
  dfmgr_install
  install_version
  mkdir -p "$CASJAYSDEVSAPPDIR/dfmgr" "$CASJAYSDEVSAPPDIR/dfmgr"
  if [ -f "$APPDIR/install.sh" ] && [ -f "$APPDIR/version.txt" ]; then
    ln_sf "$APPDIR/install.sh" "$CASJAYSDEVSAPPDIR/dfmgr/$APPNAME"
  fi
}

##################################################################################################

fontmgr_install() {
  system_installdirs
  PREFIX="fontmgr"
  REPO="${FONTMGRREPO}"
  REPORAW="$REPO/$APPNAME/raw"
  HOMEDIR="$SHARE/CasjaysDev/fontmgr"
  APPDIR="${APPDIR:-$HOMEDIR/$APPNAME}"
  USRUPDATEDIR="$SHARE/CasjaysDev/apps/fontmgr"
  SYSUPDATEDIR="$SYSSHARE/CasjaysDev/apps/fontmgr"
  FONTDIR="${FONTDIR:-$SHARE/fonts}"
  APPVERSION="$(curl -LSs ${REPO:-https://github.com/$PREFIX}/$APPNAME/raw/master/version.txt)"
}

fontmgr_run_post() {
  fontmgr_install
  run_postinst_global
  if [ -d "$HOME/Library/Fonts" ] && [ -d "$APPDIR/fonts" ]; then
    ln_sf "$APPDIR/fonts" "$HOME/Library/Fonts"
  fi
  fc-cache -f "$ICONDIR"
}

fontmgr_install_version() {
  fontmgr_install
  install_version
  mkdir -p "$CASJAYSDEVSAPPDIR/fontmgr" "$CASJAYSDEVSAPPDIR/fontmgr"
  if [ -f "$APPDIR/install.sh" ] && [ -f "$APPDIR/version.txt" ]; then
    ln_sf "$APPDIR/install.sh" "$CASJAYSDEVSAPPDIR/fontmgr/$APPNAME"
  fi
}

##################################################################################################

iconmgr_install() {
  system_installdirs
  PREFIX="iconmgr"
  REPO="${ICONMGRREPO}"
  REPORAW="$REPO/$APPNAME/raw"
  HOMEDIR="$SYSSHARE/CasjaysDev/iconmgr"
  APPDIR="${APPDIR:-$HOMEDIR/$APPNAME}"
  USRUPDATEDIR="$SHARE/CasjaysDev/apps/iconmgr"
  SYSUPDATEDIR="$SYSSHARE/CasjaysDev/apps/iconmgr"
  ICONDIR="${ICONDIR:-$SHARE/icons}"
  APPVERSION="$(curl -LSs ${REPO:-https://github.com/$PREFIX}/$APPNAME/raw/master/version.txt)"
}

iconmgr_run_post() {
  iconmgr_install
  run_postinst_global
  [ -d "$ICONDIR/$APPNAME" ] || ln_sf "$APPDIR" "$ICONDIR/$APPNAME"
  devnull sudo find "$ICONDIR/$APPNAME" -type d -exec chmod 755 {} \;
  devnull sudo find "$ICONDIR/$APPNAME" -type f -exec chmod 644 {} \;
  devnull sudo gtk-update-icon-cache -q -t -f "$ICONDIR/$APPNAME"
}

iconmgr_install_version() {
  iconmgr_install
  install_version
  mkdir -p "$CASJAYSDEVSAPPDIR/iconmgr" "$CASJAYSDEVSAPPDIR/apps/iconmgr"
  if [ -f "$APPDIR/install.sh" ] && [ -f "$APPDIR/version.txt" ]; then
    ln_sf "$APPDIR/install.sh" "$CASJAYSDEVSAPPDIR/iconmgr/$APPNAME"
  fi
}

generate_icon_index() {
  iconmgr_install
  ICONDIR="${ICONDIR:-$SHARE/icons}"
  fc-cache -f "$ICONDIR"
}

##################################################################################################

pkmgr_install() {
  system_installdirs
  PREFIX="pkmgr"
  REPO="${PKMGRREPO}"
  REPORAW="$REPO/$APPNAME/raw"
  HOMEDIR="$SYSSHARE/CasjaysDev/pkmgr"
  APPDIR="${APPDIR:-$HOMEDIR/$APPNAME}"
  USRUPDATEDIR="$SHARE/CasjaysDev/apps/pkmgr"
  SYSUPDATEDIR="$SYSSHARE/CasjaysDev/apps/pkmgr"
  REPODF="https://raw.githubusercontent.com/pkmgr/dotfiles/master"
  APPVERSION="$(curl -LSs ${REPO:-https://github.com/$PREFIX}/$APPNAME/raw/master/version.txt)"
}

pkmgr_run_postinst() {
  pkmgr_install
  run_postinst_global
}

pkmgr_install_version() {
  pkmgr_install
  install_version
  mkdir -p "$CASJAYSDEVSAPPDIR/pkmgr" "$CASJAYSDEVSAPPDIR/pkmgr"
  if [ -f "$APPDIR/install.sh" ] && [ -f "$APPDIR/version.txt" ]; then
    ln_sf "$APPDIR/install.sh" "$CASJAYSDEVSAPPDIR/pkmgr/$APPNAME"
  fi
}

##################################################################################################

systemmgr_install() {
  requiresudo "true"
  system_installdirs
  PREFIX="systemmgr"
  REPO="${SYSTEMMGRREPO}"
  REPORAW="$REPO/$APPNAME/raw"
  CONF="/usr/local/etc"
  SHARE="/usr/local/share"
  HOMEDIR="/usr/local/etc"
  APPDIR="${APPDIR:-$HOMEDIR/$APPNAME}"
  USRUPDATEDIR="/usr/local/share/CasjaysDev/apps/systemmgr"
  SYSUPDATEDIR="/usr/local/share/CasjaysDev/apps/systemmgr"
  APPVERSION="$(curl -LSs ${REPO:-https://github.com/$PREFIX}/$APPNAME/raw/master/version.txt)"
}

systemmgr_run_postinst() {
  systemmgr_install
  run_postinst_global
}

systemmgr_install_version() {
  systemmgr_install
  install_version
  mkdir -p "$SYSUPDATEDIR"
  if [ -f "$APPDIR/install.sh" ] && [ -f "$APPDIR/version.txt" ]; then
    ln_sf "$APPDIR/install.sh" "$CASJAYSDEVSAPPDIR/systemmgr/$APPNAME"
  fi
}

##################################################################################################

thememgr_install() {
  system_installdirs
  PREFIX="thememgr"
  REPO="${THEMEMGRREPO}"
  REPORAW="$REPO/$APPNAME/raw"
  HOMEDIR="$SYSSHARE/CasjaysDev/thememgr"
  APPDIR="${APPDIR:-$HOMEDIR/$APPNAME}"
  USRUPDATEDIR="$SHARE/CasjaysDev/apps/thememgr"
  SYSUPDATEDIR="$SYSSHARE/CasjaysDev/apps/thememgr"
  THEMEDIR="${THEMEDIR:-$SHARE/themes}"
  APPVERSION="$(curl -LSs ${REPO:-https://github.com/$PREFIX}/$APPNAME/raw/master/version.txt)"
}

generate_theme_index() {
  thememgr_install
  THEMEDIR="${THEMEDIR:-$SHARE/themes}"
  sudo find "$THEMEDIR" -mindepth 1 -maxdepth 2 -type d -not -path "*/.git/*" | while read -r THEME; do
    if [ -f "$THEME/index.theme" ]; then
      cmd_exists gtk-update-icon-cache && gtk-update-icon-cache -f -q "$THEME"
    fi
  done
}

thememgr_run_post() {
  thememgr_install
  run_postinst_global
  [ -d "$THEMEDIR/$APPNAME" ] || ln_sf "$APPDIR" "$THEMEDIR/$APPNAME"
  generate_theme_index
}

thememgr_install_version() {
  thememgr_install
  install_version
  mkdir -p "$CASJAYSDEVSAPPDIR/thememgr" "$CASJAYSDEVSAPPDIR/thememgr"
  if [ -f "$APPDIR/install.sh" ] && [ -f "$APPDIR/version.txt" ]; then
    ln_sf "$APPDIR/install.sh" "$CASJAYSDEVSAPPDIR/thememgr/$APPNAME"
  fi
}

##################################################################################################

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
  APPVERSION="$(curl -LSs ${REPO:-https://github.com/$PREFIX}/$APPNAME/raw/master/version.txt)"
}

wallpapermgr_run_postinst() {
  wallpapermgr_install
  run_postinst_global
}

wallpaper_install_version() {
  wallpapermgr_install
  mkdir -p "$CASJAYSDEVSAPPDIR/wallpapermgr" "$CASJAYSDEVSAPPDIR/wallpapermgr"
  if [ -f "$APPDIR/install.sh" ] && [ -f "$APPDIR/version.txt" ]; then
    ln_sf "$APPDIR/install.sh" "$CASJAYSDEVSAPPDIR/wallpapermgr/$APPNAME"
  fi
}

##################################################################################################

run_postinst_global() {
  #  OIFS="$IFS"
  #  IFS=$'\n'
  if [[ "$APPNAME" = "scripts" ]] || [[ "$APPNAME" = "installer" ]]; then
    # Only run on the scripts install
    ln_rm "$SYSBIN/"
    ln_rm "$COMPDIR/"

    dfunFiles="$(ls $APPDIR/completions)"
    for dfun in $dfunFiles; do
      rm_rf "$COMPDIR/$dfun"
    done

    myfunctFiles="$(ls $APPDIR/functions)"
    for myfunct in $myfunctFiles; do
      ln_sf "$APPDIR/functions/$myfunct" "$HOME/.local/share/CasjaysDev/functions/$myfunct"
    done

    compFiles="$(ls $APPDIR/completions)"
    for comp in $compFiles; do
      cp_rf "$APPDIR/completions/$comp" "$COMPDIR/$comp"
    done

    appFiles="$(ls $APPDIR/bin)"
    for app in $appFiles; do
      chmod -Rf 755 "$APPDIR/bin/$app"
      ln_sf "$APPDIR/bin/$app" "$SYSBIN/$app"
    done
    cmd_exists updatedb && updatedb

  else
    # Run on everything else
    if [ -d "$APPDIR/wallpapers" ]; then
      mkdir -p $WALLPAPERS/$APPNAME
      local wallpapers="$(ls $APPDIR/backgrounds/ 2>/dev/null | wc -l)"
      if [ "$wallpapers" != "0" ]; then
        wallpaperFiles="$(ls $APPDIR/backgrounds)"
        for wallpaper in $wallpaperFiles; do
          ln_sf "$APPDIR/backgrounds/$wallpaper" "$WALLPAPERS/$APPNAME/$wallpaper"
        done
      fi
      ln_rm "$WALLPAPERS/$APPNAME/"
    fi

    if [ -d "$APPDIR/startup" ]; then
      local autostart="$(ls $APPDIR/startup/ 2>/dev/null | wc -l)"
      if [ "$autostart" != "0" ]; then
        startFiles="$(ls $APPDIR/startup)"
        for start in $startFiles; do
          ln_sf "$APPDIR/startup/$start" "$STARTUP/$start"
        done
      fi
      ln_rm "$STARTUP/"
    fi

    if [ -d "$APPDIR/bin" ]; then
      local bin="$(ls $APPDIR/bin/ 2>/dev/null | wc -l)"
      if [ "$bin" != "0" ]; then
        bFiles="$(ls $APPDIR/bin)"
        for b in $bFiles; do
          chmod -Rf 755 "$APPDIR/bin/$app"
          ln_sf "$APPDIR/bin/$b" "$BIN/$b"
        done
      fi
      ln_rm "$BIN/"
    fi

    if [ -d "$APPDIR/completions" ]; then
      local comps="$(ls $APPDIR/completions/ 2>/dev/null | wc -l)"
      if [ "$comps" != "0" ]; then
        compFiles="$(ls $APPDIR/completions)"
        for comp in $compFiles; do
          cp_rf "$APPDIR/completions/$comp" "$COMPDIR/$comp"
        done
      fi
      ln_rm "$COMPDIR/"
    fi

    if [ -d "$APPDIR/applications" ]; then
      local apps="$(ls $APPDIR/applications/ 2>/dev/null | wc -l)"
      if [ "$apps" != "0" ]; then
        aFiles="$(ls $APPDIR/applications)"
        for a in $aFiles; do
          ln_sf "$APPDIR/applications/$a" "$SHARE/applications/$a"
        done
      fi
      ln_rm "$SHARE/applications/"
    fi

    if [ -d "$APPDIR/fontconfig" ]; then
      local fontconf="$(ls $APPDIR/fontconfig 2>/dev/null | wc -l)"
      if [ "$fontconf" != "0" ]; then
        fcFiles="$(ls $APPDIR/fontconfig)"
        for fc in $fcFiles; do
          ln_sf "$APPDIR/fontconfig/$fc" "$FONTCONF/$fc"
        done
      fi
      ln_rm "$FONTCONF/"
      cmd_exists fc-cache && fc-cache -f "$FONTCONF"
      return 0
    fi

    if [ -d "$APPDIR/fonts" ]; then
      local font="$(ls "$APPDIR/fonts" 2>/dev/null | wc -l)"
      if [ "$font" != "0" ]; then
        fFiles="$(ls $APPDIR/fonts --ignore='.conf' --ignore='.uuid')"
        for f in $fFiles; do
          ln_sf "$APPDIR/fonts/$f" "$FONTDIR/$f"
        done
      fi
      ln_rm "$FONTDIR/"
      cmd_exists fc-cache && fc-cache -f "$FONTDIR"
      return 0
    fi
  fi

  # Permission fix
  ensure_perms

  #  IFS="$OIFS"
}

##################################################################################################

run_exit() {
  if [ -f "$TEMP/$APPNAME.inst.tmp" ]; then rm_rf "$TEMP/$APPNAME.inst.tmp"; fi
  if [ -f "/tmp/$SCRIPTSFUNCTFILE" ]; then rm_rf "/tmp/$SCRIPTSFUNCTFILE"; fi
  if [ -n "$EXIT" ]; then exit "$EXIT"; fi
}

##################################################################################################

#set_trap "EXIT" "install_packages"
#set_trap "EXIT" "install_required"
#set_trap "EXIT" "install_python"
#set_trap "EXIT" "install_perl"
#set_trap "EXIT" "install_pip"
#set_trap "EXIT" "install_cpan"
#set_trap "EXIT" "install_gem"

# end
