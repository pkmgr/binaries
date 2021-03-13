#!/usr/bin/env bash
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
PROG="REPLACE_APPNAME"
USER="${SUDO_USER:-${USER}}"
HOME="${USER_HOME:-${HOME}}"
SRC_DIR="${BASH_SOURCE%/*}"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#set opts

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
##@Version       : REPLACE_VERSION
# @Author        : REPLACE_AUTHOR
# @Contact       : REPLACE_EMAIL
# @License       : REPLACE_LICENSE
# @Copyright     : REPLACE_COPYRIGHT
# @Created       : REPLACE_DATE
# @File          : REPLACE_FILENAME
# @Description   : REPLACE_DESC
# @TODO          : REPLACE_TODO
# @Other         : REPLACE_OTHER
# @Resource      : REPLACE_RES
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Import functions
CASJAYSDEVDIR="${CASJAYSDEVDIR:-/usr/local/share/CasjaysDev/scripts}"
SCRIPTSFUNCTDIR="${CASJAYSDEVDIR:-/usr/local/share/CasjaysDev/scripts}/functions"
SCRIPTSFUNCTFILE="${SCRIPTSAPPFUNCTFILE:-app-installer.bash}"
SCRIPTSFUNCTURL="${SCRIPTSAPPFUNCTURL:-https://github.com/dfmgr/installer/raw/master/functions}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if [ -f "$PWD/$SCRIPTSFUNCTFILE" ]; then
  . "$PWD/$SCRIPTSFUNCTFILE"
elif [ -f "$SCRIPTSFUNCTDIR/$SCRIPTSFUNCTFILE" ]; then
  . "$SCRIPTSFUNCTDIR/$SCRIPTSFUNCTFILE"
else
  echo "Can not load the functions file: $SCRIPTSFUNCTDIR/$SCRIPTSFUNCTFILE" 1>&2
  exit 1
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
run_post() {
  local e="$1"
  local m="$(echo $1 | sed 's#devnull ##g')"
  execute "$e" "executing: $m"
  setexitstatus
  set --
}
system_service_exists() {
  if systemctl list-units --full -all | grep -Fq "$1"; then return 0; else return 1; fi
  setexitstatus
  set --
}
system_service_enable() {
  if system_service_exists "$1"; then execute "systemctl enable --now -f $1" "Enabling service: $1"; fi
  setexitstatus
  set --
}
system_service_disable() {
  if system_service_exists "$1"; then execute "systemctl disable --now $1" "Disabling service: $1"; fi
  setexitstatus
  set --
}

detect_selinux() {
  selinuxenabled
  if [ $? -ne 0 ]; then return 0; else return 1; fi
}
disable_selinux() {
  selinuxenabled
  devnull setenforce 0
}

grab_remote_file() { urlverify "$1" && curl -sSLq "$@" || exit 1; }
run_external() { printf_green "Executing $*" && "$@" >/dev/null 2>&1; }

retrieve_version_file() { grab_remote_file https://github.com/casjay-base/centos/raw/master/version.txt | head -n1 || echo "Unknown version"; }

#### OS Specific
test_pkg() {
  devnull brew list $1 && printf_success "$1 is installed" && return 1 || return 0
  setexitstatus
  set --
}
remove_pkg() {
  if ! test_pkg "$1"; then execute "brew remove -f $1" "Removing: $1"; fi
  setexitstatus
  set --
}
install_pkg() {
  if test_pkg "$1"; then execute "brew install -f $1" "Installing: $1"; fi
  setexitstatus
  set --
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

[ ! -z "$1" ] && printf_exit 'To many options provided'

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

##################################################################################################################
printf_head "Initializing the setup script"
##################################################################################################################

execute "sudo PKMGR"

##################################################################################################################
printf_head "Configuring cores for compiling"
##################################################################################################################

numberofcores=$(grep -c ^processor /proc/cpuinfo)
printf_info "Total cores avaliable: $numberofcores"

if [ -f /etc/makepkg.conf ]; then
  if [ $numberofcores -gt 1 ]; then
    sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j'$(($numberofcores + 1))'"/g' /etc/makepkg.conf
    sed -i 's/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T '"$numberofcores"' -z -)/g' /etc/makepkg.conf
  fi
fi

##################################################################################################################
printf_head "Installing the packages for TEMPLATE"
##################################################################################################################

install_pkg listofpkgs

##################################################################################################################
printf_head "Fixing packages"
##################################################################################################################

##################################################################################################################
printf_head "setting up config files"
##################################################################################################################

run_post "cp -rT /etc/skel $HOME"
run_post "dotfilesreq bash"
run_post "dotfilesreq misc"

run_post dotfilesreqadmin samba

##################################################################################################################
printf_head "Enabling services"
##################################################################################################################

system_service_enable lightdm.service
system_service_enable bluetooth.service
system_service_enable smb.service
system_service_enable nmb.service
system_service_enable avahi-daemon.service
system_service_enable tlp.service
system_service_enable org.cups.cupsd.service
system_service_disable mpd

##################################################################################################################
printf_head "Cleaning up"
##################################################################################################################

remove_pkg xfce4-artwork

##################################################################################################################
printf_head "Finished "
echo""
##################################################################################################################

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
set --

# end
