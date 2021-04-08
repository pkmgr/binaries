#!/usr/bin/env bash
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
APPNAME="scripts"
USER="${SUDO_USER:-${USER}}"
HOME="${USER_HOME:-${HOME}}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#set opts

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
##@Version       : 021020210200-git
# @Author        : Jason Hempstead
# @Contact       : jason@casjaysdev.com
# @License       : LICENSE.md
# @ReadME        : README.md
# @Copyright     : Copyright: (c) 2021 Jason Hempstead, CasjaysDev
# @Created       : Wednesday, Feb 10, 2021 02:00 EST
# @File          : install.sh
# @Description   : My custom scripts
# @TODO          : MacOS fixes
# @Other         :
# @Resource      :
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Import functions
CASJAYSDEVDIR="${CASJAYSDEVDIR:-/usr/local/share/CasjaysDev/scripts}"
SCRIPTSFUNCTDIR="${CASJAYSDEVDIR:-/usr/local/share/CasjaysDev/scripts}/functions"
SCRIPTSFUNCTFILE="${SCRIPTSAPPFUNCTFILE:-app-installer.bash}"
SCRIPTSFUNCTURL="${SCRIPTSAPPFUNCTURL:-https://github.com/dfmgr/installer/raw/master/functions}"
connect_test() { ping -c1 1.1.1.1 &>/dev/null || curl --disable -LSs --connect-timeout 3 --retry 0 --max-time 1 1.1.1.1 2>/dev/null | grep -e "HTTP/[0123456789]" | grep -q "200" -n1 &>/dev/null; }
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if [ -f "$PWD/$SCRIPTSFUNCTFILE" ]; then
  . "$PWD/$SCRIPTSFUNCTFILE"
elif [ -f "$SCRIPTSFUNCTDIR/$SCRIPTSFUNCTFILE" ]; then
  . "$SCRIPTSFUNCTDIR/$SCRIPTSFUNCTFILE"
elif connect_test; then
  curl -LSs "$SCRIPTSFUNCTURL/$SCRIPTSFUNCTFILE" -o "/tmp/$SCRIPTSFUNCTFILE" || exit 1
  . "/tmp/$SCRIPTSFUNCTFILE"
else
  echo "Can not load the functions file: $SCRIPTSFUNCTDIR/$SCRIPTSFUNCTFILE" 1>&2
  exit 1
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Call the main function
system_installdirs
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Make sure the scripts repo is installed
#scripts_check
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Defaults
APPNAME="${APPNAME:-scripts}"
APPDIR="/usr/local/share/CasjaysDev/scripts"
INSTDIR="/usr/local/share/CasjaysDev/scripts"
REPO="https://github.com/systemmgr/installer"
REPORAW="$REPO/raw"
APPVERSION="$(__appversion "$REPORAW/master/version.txt")"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Setup plugins
PLUGNAMES=""
PLUGDIR="/usr/local/share/CasjaysDev/apps/$SCRIPTS_PREFIX"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Require a version higher than
systemmgr_req_version "$APPVERSION"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Call the systemmgr function
systemmgr_install
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Script options IE: --help
show_optvars "$@"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Requires root - no point in continuing
sudoreq # sudo required
#sudorun # sudo optional
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Do not update - add --force to overwrite
#installer_noupdate "$@"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# initialize the installer
systemmgr_run_init
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# end with a space
if_os mac && APP="jq sudo curl wget "
if_os linux && APP="ruby expect byobu killall setcap nethogs iftop iotop iperf rsync mlocate pass python " &&
  APP+="bash ifconfig fc-cache jq tf sudo xclip curl wget dialog qalc links html2text dict speedtest-cli mdless"
PERL="CPAN "
PYTH="pip "
PIPS="speedtest-cli "
CPAN=""
GEMS="mdless "

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# install packages - useful for package that have the same name on all oses
install_packages "$APP"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# install required packages using file
install_required "$APP"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# check for perl modules and install using system package manager
install_perl "$PERL"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# check for python modules and install using system package manager
install_python "$PYTH"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# check for pip binaries and install using python package manager
install_pip "$PIPS"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# check for cpan binaries and install using perl package manager
install_cpan "$CPAN"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# check for ruby binaries and install using ruby package manager
install_gem "$GEMS"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Other dependencies
dotfilesreq
dotfilesreqadmin
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Ensure directories exist
ensure_dirs
ensure_perms
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Backup if needed
if [ -d "$APPDIR" ]; then
  execute "backupapp $APPDIR $APPNAME" "Backing up $APPDIR"
fi
# Main progam
if __am_i_online; then
  if [ -d "$INSTDIR/.git" ]; then
    execute "git_update $INSTDIR" "Updating $APPNAME configurations"
  else
    execute "git_clone $REPO/$APPNAME $INSTDIR" "Installing $APPNAME configurations"
  fi
  # exit on fail
  failexitcode $? "Git has failed"
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# run post install scripts
run_postinst() {
  systemmgr_run_post
  dotfilesreqadmin cron
  local fontdir="$(ls "$CASJAYSDEVSAPPDIR/fontmgr" | wc -l)"
  if [ "$fontdir" = "0" ]; then
    sudo fontmgr install Hack
  fi
  # appFiles="$(ls "$INSTDIR/bin")"
  # for bin in $appFiles; do
  #   chmod -Rf 755 "$INSTDIR/bin/$bin"
  #   ln_sf "$INSTDIR/bin/$bin" "$SYSBIN/$bin"
  # done
  for app in $(ls "$CASJAYSDEVDIR/applications"); do
    ln_sf "$CASJAYSDEVDIR/applications/$app" "$SYSSHARE/applications/$app"
  done
  ln_rm "$SHARE/applications/"
  mkd /etc/casjaysdev/messages/motd
  mkd /etc/casjaysdev/messages/issue
  mkd /etc/casjaysdev/messages/legal
  if [ -f "$INSTDIR/templates/casjaysdev-legal.txt" ] && [ ! -f /etc/casjaysdev/messages/legal/000.txt ]; then
    cp_rf "$INSTDIR/templates/casjaysdev-legal.txt" "/etc/casjaysdev/messages/legal/000.txt"
  fi
  replace /etc/casjaysdev/messages/ MYHOSTIP "$CURRIP4"
  replace /etc/casjaysdev/messages/ MYHOSTNAME "$(hostname -s)"
  replace /etc/casjaysdev/messages/ MYFULLHOSTNAME "$(hostname -f)"
  grep -Riq "git" /etc/casjaysdev/updates/versions/configs.txt && sudo rm -Rfv /etc/casjaysdev/updates/versions/configs.txt
  [ -f /etc/casjaysdev/updates/versions/configs.txt ] || date +"%m%d%Y%H%M-git" | sudo tee /etc/casjaysdev/updates/versions/configs.txt
  [ -f /etc/casjaysdev/updates/versions/date.configs.txt ] || date +"%b %d, %Y at %H:%M" | sudo tee /etc/casjaysdev/updates/versions/date.configs.txt
  cp_rf "$INSTDIR/version.txt" /etc/casjaysdev/updates/versions/scripts.txt
  date +"%b %d, %Y at %H:%M" | sudo tee /etc/casjaysdev/updates/versions/date.scripts.txt >/dev/null 2>&1
  cmd_exists update-motd && update-ip && update-motd
  echo 'for f in '$CASJAYSDEVDIR/completions/*'; do source "$f" >/dev/null 2>&1; done' >"$COMPDIR/_my_scripts_completions"
  ln_sf "$APPDIR" "$SYSSHARE/CasjaysDev/$SCRIPTS_PREFIX/$APPNAME"
  ln_sf "$APPDIR" "$SYSSHARE/CasjaysDev/$SCRIPTS_PREFIX/installer"
}
#
execute "run_postinst" "Running post install scripts"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# create version file
systemmgr_install_version
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# exit
run_exit
# end
