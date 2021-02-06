#!/usr/bin/env bash

APPNAME="$(basename $0)"
USER="${SUDO_USER:-${USER}}"
HOME="${USER_HOME:-${HOME}}"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# @Author          : Jason
# @Contact         : casjaysdev@casjay.net
# @File            : install.sh
# @Created         : Wed, Aug 09, 2020, 02:00 EST
# @License         : WTFPL
# @Copyright       : Copyright (c) CasjaysDev
# @Description     : My custom scripts
#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Set functions

SCRIPTSFUNCTURL="${SCRIPTSAPPFUNCTURL:-https://github.com/dfmgr/installer/raw/master/functions}"
SCRIPTSFUNCTDIR="${SCRIPTSAPPFUNCTDIR:-/usr/local/share/CasjaysDev/scripts}"
SCRIPTSFUNCTFILE="${SCRIPTSAPPFUNCTFILE:-app-installer.bash}"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if [ -f "$PWD/functions/$SCRIPTSFUNCTFILE" ]; then
  . "$PWD/functions/$SCRIPTSFUNCTFILE"
elif [ -f "$SCRIPTSFUNCTDIR/functions/$SCRIPTSFUNCTFILE" ]; then
  . "$SCRIPTSFUNCTDIR/functions/$SCRIPTSFUNCTFILE"
else
  mkdir -p "/tmp/CasjaysDev/functions"
  curl -LSs "$SCRIPTSFUNCTURL/$SCRIPTSFUNCTFILE" -o "/tmp/CasjaysDev/functions/$SCRIPTSFUNCTFILE" || exit 1
  . "/tmp/CasjaysDev/functions/$SCRIPTSFUNCTFILE"
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Make sure the scripts repo is installed

#scripts_check

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Defaults

APPNAME="scripts"
PLUGNAME=""

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# git repos

PLUGINREPO=""

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# if installing system wide - change to system_installdirs

systemmgr_install

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Version

APPVERSION="$(__appversion ${DOTFILESREPO:-https://github.com/dfmgr}/$APPNAME/raw/master/version.txt)"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Set options

APPDIR="/usr/local/share/CasjaysDev/$APPNAME"
PLUGDIR="/usr/local/share/CasjaysDev/addons/${PLUGNAME}"
INSTDIR="$APPDIR"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Script options IE: --help

show_optvars "$@"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Requires root - no point in continuing

sudoreq # sudo required
#sudorun  # sudo optional

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if_os mac && APP="jq sudo curl wget "
if_os linux && APP="ruby expect byobu killall setcap nethogs iftop iotop iperf rsync mlocate pass python " &&
  APP+="bash ifconfig fc-cache jq tf sudo xclip curl wget dialog qalc links html2text dict speedtest-cli "
PERL="CPAN "
PYTH="pip "
PIPS=""
CPAN=""
GEMS="mdless "

# install packages - useful for package that have the same name on all oses
install_packages $APP

# install required packages using file
install_required $APP

# check for perl modules and install using system package manager
install_perl $PERL

# check for python modules and install using system package manager
install_python $PYTH

# check for pip binaries and install using python package manager
install_pip $PIPS

# check for cpan binaries and install using perl package manager
install_cpan $CPAN

# check for ruby binaries and install using ruby package manager
install_gem $GEMS

# Other dependencies
dotfilesreq
dotfilesreqadmin

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Ensure directories exist

ensure_dirs
ensure_perms

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Main progam

if [ -d "$APPDIR/.git" ]; then
  execute \
    "git_update $APPDIR" \
    "Updating $APPNAME configurations"
else
  execute \
    "git_clone $REPO/$APPNAME $APPDIR" \
    "Installing $APPNAME configurations"
fi

# exit on fail
failexitcode

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Plugins

if __am_i_online; then
  if [ "$PLUGNAME" != "" ]; then
    if [ -d "$PLUGDIR"/.git ]; then
      execute \
        "git_update $PLUGDIR" \
        "Updating $PLUGNAME"
    else
      execute \
        "git_clone $PLUGINREPO $PLUGDIR" \
        "Installing $PLUGNAME"
    fi
  fi

  # exit on fail
  failexitcode
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# run post install scripts

run_postinst() {
  systemmgr_run_postinst
  dotfilesreqadmin cron
  local fontdir="$(devnull2 ls "$CASJAYSDEVSAPPDIR/fontmgr" | wc -l)"
  if [ "$fontdir" = "0" ]; then
    sudo fontmgr install Hack
  fi

  for function in $(ls "$SCRIPTSFUNCTDIR/functions"); do
    ln_sf "$SCRIPTSFUNCTDIR/functions/$function" "$CASJAYSDEVSHARE/functions/$function"
  done

  for app in $(ls "$SCRIPTSFUNCTDIR/applications"); do
    ln_sf "$SCRIPTSFUNCTDIR/applications/$app" "$SYSSHARE/applications/$app"
  done

  ln_rm "$SHARE/applications/"
  ln_sf "$APPDIR" "$SYSSHARE/CasjaysDev/installer"
  mkd /etc/casjaysdev/messages/motd
  mkd /etc/casjaysdev/messages/issue
  if [ -f "$APPDIR/templates/casjaysdev-legal.txt" ] && [ ! -f /etc/casjaysdev/messages/legal/000.txt ]; then
    cp_rf "$APPDIR/templates/casjaysdev-legal.txt" "/etc/casjaysdev/messages/legal/000.txt"
  fi
  replace /etc/casjaysdev/messages/ MYHOSTIP "$CURRIP4"
  replace /etc/casjaysdev/messages/ MYHOSTNAME "$(hostname -s)"
  replace /etc/casjaysdev/messages/ MYFULLHOSTNAME "$(hostname -f)"
  grep -Riq "git" /etc/casjaysdev/updates/versions/configs.txt && sudo rm -Rfv /etc/casjaysdev/updates/versions/configs.txt
  [ -f /etc/casjaysdev/updates/versions/configs.txt ] || date +"%m%d%Y%H%M-git" | sudo tee /etc/casjaysdev/updates/versions/configs.txt
  [ -f /etc/casjaysdev/updates/versions/date.configs.txt ] || date +"%b %d, %Y at %H:%M" | sudo tee /etc/casjaysdev/updates/versions/date.configs.txt
  cp_rf "$APPDIR/version.txt" /etc/casjaysdev/updates/versions/scripts.txt
  date +"%b %d, %Y at %H:%M" | sudo tee /etc/casjaysdev/updates/versions/date.scripts.txt >/dev/null 2>&1
  cmd_exists update-motd && update-ip && update-motd
  echo 'for f in '$INSTDIR/completions'; do source "$f" >/dev/null 2>&1; done' >"$COMPDIR/_my_scripts_completions"
}

execute \
  "run_postinst" \
  "Running post install scripts"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# create version file

systemmgr_install_version

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# exit
run_exit

# end
