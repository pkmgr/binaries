#!/usr/bin/env bash
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
APPNAME="REPLACE_APPNAME"
USER="${SUDO_USER:-${USER}}"
HOME="${USER_HOME:-${HOME}}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#set opts

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
##@Version       : REPLACE_VERSION
# @Author        : REPLACE_AUTHOR
# @Contact       : REPLACE_EMAIL
# @License       : REPLACE_LICENSE
# @ReadME        : REPLACE_README
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
scripts_check
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Defaults
APPNAME="${APPNAME:-template}"
APPDIR="${APPDIR:-$SHARE/CasjaysDev/iconmgr/$APPNAME}"
INSTDIR="${APPDIR}"
REPO="${ICONMGRREPO:-https://github.com/iconmgr/$APPNAME}"
REPORAW="${REPORAW:-$REPO/raw}"
APPVERSION="$(__appversion "$REPORAW/master/version.txt")"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Require a version higher than
iconmgr_req_version "$APPVERSION"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Call the iconmgr function
iconmgr_install
iconmgr_run_init
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Script options IE: --help
show_optvars "$@"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Ensure directories exist
ensure_dirs
ensure_perms
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Main progam
if __am_i_online; then
  if [ -d "$INSTDIR/.git" ]; then
    execute "git_update $INSTDIR" "Updating $APPNAME icon pack"
  else
    execute "git_clone $REPO/$APPNAME $INSTDIR" "Installing $APPNAME icon pack"
  fi
  # exit on fail
  failexitcode $? "Git has failed"
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# run post install scripts
run_postinst() {
  iconmgr_run_post
}
#
execute "run_postinst" "Running post install scripts"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# create version file
iconmgr_install_version
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# exit
run_exit
# end
