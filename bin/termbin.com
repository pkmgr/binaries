#!/usr/bin/env bash

APPNAME="$(basename $0)"
USER="${SUDO_USER:-${USER}}"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
##@Version     : 010920210727-git
# @Author      : Jason
# @Contact     : casjaysdev@casjay.net
# @File        : termbin.com
# @Created     : Wed, Aug 05, 2020, 02:00 EST
# @License     : WTFPL
# @Copyright   : Copyright (c) CasjaysDev
# @Description : Post text to termbin.com
#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Set functions

SCRIPTSFUNCTURL="${SCRIPTSAPPFUNCTURL:-https://github.com/dfmgr/installer/raw/master/functions}"
SCRIPTSFUNCTDIR="${SCRIPTSAPPFUNCTDIR:-/usr/local/share/CasjaysDev/scripts}"
SCRIPTSFUNCTFILE="${SCRIPTSAPPFUNCTFILE:-applications.bash}"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if [ -f "$PWD/functions/$SCRIPTSFUNCTFILE" ]; then
  . "$PWD/functions/$SCRIPTSFUNCTFILE"
elif [ -f "$SCRIPTSFUNCTDIR/functions/$SCRIPTSFUNCTFILE" ]; then
  . "$SCRIPTSFUNCTDIR/functions/$SCRIPTSFUNCTFILE"
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
dfmgr_install "$@"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

IFS=''

if ! cmd_exists nc; then
  printf_red "Command nc was not found"
  printf_red "Please install the netcat package"
  exit 1
else

  if [ ! -z "$1" ]; then
    cat "$1" | devnull2 nc termbin.com 9999 >/tmp/termbin
  else
    devnull2 nc termbin.com 9999 >/tmp/termbin
  fi

  if [ -f /tmp/termbin ]; then
    echo "" >>/tmp/termbin
    devnull2 cat /tmp/termbin | printf_readline
    devnull rm -Rf /tmp/termbin
  else
    devnull rm -Rf /tmp/termbin
    printf_red "Something went wrong"
  fi
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# end
