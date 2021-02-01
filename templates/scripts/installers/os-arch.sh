#!/usr/bin/env bash

APPNAME="pkmgr-arch"
USER="${SUDO_USER:-${USER}}"
HOME="${USER_HOME:-${HOME}}"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
##@Version       : VERSION
# @Author        : AUTHOR
# @Contact       : EMAIL
# @License       : LICENSE
# @Copyright     : Copyright (c) YEAR, AUTHOR
# @Created       : DATE
# @File          : FILENAME
# @Description   :
# @TODO          :
# @Other         :
# @Resource      :
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Set functions
CASJAYSDEVDIR="${CASJAYSDEVDIR:-/usr/local/share/CasjaysDev}"
SCRIPTSFUNCTURL="${SCRIPTSAPPFUNCTURL:-https://github.com/casjay-dotfiles/scripts/raw/master/functions}"
SCRIPTSFUNCTDIR="${SCRIPTSAPPFUNCTDIR:-$CASJAYSDEVDIR/functions}"
SCRIPTSFUNCTFILE="${SCRIPTSAPPFUNCTFILE:-app-installer.bash}"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if [ -f "$SCRIPTSFUNCTDIR/$SCRIPTSFUNCTFILE" ]; then
  . "$SCRIPTSFUNCTDIR/$SCRIPTSFUNCTFILE"
elif [ -f "$HOME/.local/share/CasjaysDev/functions/$SCRIPTSFUNCTFILE" ]; then
  . "$HOME/.local/share/CasjaysDev/functions/$SCRIPTSFUNCTFILE"
else
  curl -LSs "$SCRIPTSFUNCTURL/$SCRIPTSFUNCTFILE" -o "/tmp/$SCRIPTSFUNCTFILE" || exit 1
  . "/tmp/$SCRIPTSFUNCTFILE"
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
  if systemctl status "$1" >/dev/null 2>&1; then return 0; else return 1; fi
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
run_grub() {
  printf_green "Setting up grub"
  rm -Rf /boot/*rescue*
  devnull grub2-mkconfig -o /boot/grub2/grub.cfg
}

#### OS Specific
test_pkg() {
  devnull sudo pacman -Qi "$1" && printf_success "$1 is installed" && return 1 || return 0
  setexitstatus
  set --
}
remove_pkg() {
  if ! test_pkg "$1"; then execute "sudo pacman -R  --noconfirm $1" "Removing: $1"; fi
  setexitstatus
  set --
}
install_pkg() {
  if test_pkg "$1"; then execute "sudo pacman -S --noconfirm --needed $1" "Installing: $1"; fi
  setexitstatus
  set --
}
install_aur() {
  if test_pkg "$1"; then execute "sudo --user=$(whoami) yay -S --noconfirm $1" "Installing: $1"; fi
  setexitstatus
  set --
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

[ ! -z "$1" ] && printf_exit 'To many options provided'

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

##################################################################################################################
printf_head "Initializing the setup script"
##################################################################################################################

sudoask && sudoexit
execute "sudo PKMGR"

##################################################################################################################
printf_head "Configuring cores for compiling"
##################################################################################################################

numberofcores=$(grep -c ^processor /proc/cpuinfo)
printf_info "Total cores avaliable: $numberofcores"

if [ $numberofcores -gt 1 ]; then
  sudo sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j'$(($numberofcores + 1))'"/g' /etc/makepkg.conf
  sudo sed -i 's/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T '"$numberofcores"' -z -)/g' /etc/makepkg.conf
fi

##################################################################################################################
printf_head "Installing the TEMPLATE packages"
##################################################################################################################

install_pkg qtile

##################################################################################################################
printf_head "Installing the packages fram AUR"
##################################################################################################################

install_aur ttf-font-awesome
install_aur brackets-bin
install_aur cmatrix-git
install_aur font-manager-git
install_aur hardcode-fixer-git
install_aur pamac-aur
install_aur visual-studio-code
install_aur menulibre
install_aur mugshot
install_aur xfce4-panel-profiles

##################################################################################################################
printf_head "Fixing packages"
##################################################################################################################

run_post "sudo sed -i 's/'#AutoEnable=false'/'AutoEnable=true'/g' /etc/bluetooth/main.conf"
run_post "sudo sed -i 's/files mymachines myhostname/files mymachines/g' /etc/nsswitch.conf"
run_post "sudo sed -i 's/\[\!UNAVAIL=return\] dns/\[\!UNAVAIL=return\] mdns dns wins myhostname/g' /etc/nsswitch.conf"
run_post "sudo usermod  -a -G rfkill $USER"

##################################################################################################################
printf_head "setting up config files"
##################################################################################################################

run_post "cp -rT /etc/skel $HOME"
run_post "dotfilesreq APPWM"
run_post "dotfilesreq bash"
run_post "dotfilesreq geany"
run_post "dotfilesreq misc"
run_post "dotfilesreq xfce4"

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

run_post "devnull sudo systemctl set-default graphical.target"

run_post "devnull sudo grub-mkconfig -o /boot/grub/grub.cfg"

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
