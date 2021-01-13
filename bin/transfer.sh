#!/usr/bin/env bash

APPNAME="$(basename $0)"
USER="${SUDO_USER:-${USER}}"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
##@Version     : 010920210727-git
# @Author      : Jason
# @Contact     : casjaysdev@casjay.net
# @File        : transfer.sh
# @Created     : Wed, Aug 05, 2020, 02:00 EST
# @License     : WTFPL
# @Copyright   : Copyright (c) CasjaysDev
# @Description : Upload file to https://transfer.sh
#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Set functions

SCRIPTSFUNCTURL="${SCRIPTSAPPFUNCTURL:-https://github.com/dfmgr/installer/raw/master/functions}"
SCRIPTSFUNCTDIR="${SCRIPTSAPPFUNCTDIR:-/usr/local/share/CasjaysDev/scripts}"
SCRIPTSFUNCTFILE="${SCRIPTSAPPFUNCTFILE:-testing.bash}"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if [ -f "$PWD/functions/$SCRIPTSFUNCTFILE" ]; then
  . "$PWD/functions/$SCRIPTSFUNCTFILE"
elif [ -f "$SCRIPTSFUNCTDIR/functions/$SCRIPTSFUNCTFILE" ]; then
  . "$SCRIPTSFUNCTDIR/functions/$SCRIPTSFUNCTFILE"
else
  mkdir -p "/tmp/CasjaysDev/functions"
  __curl "$SCRIPTSFUNCTURL/$SCRIPTSFUNCTFILE" -o "/tmp/CasjaysDev/functions/$SCRIPTSFUNCTFILE" || exit 1
  . "/tmp/CasjaysDev/functions/$SCRIPTSFUNCTFILE"
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
__help() { printf_help "Usage: command | transfer.sh or transfer.sh filename"; }

[ "$1" = "--version" ] && get_app_info "$APPNAME"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

[ "$1" = "--help" ] && __help

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if __api_test; then
  tmpfile=$(mktemp -t transferXXX)
  if tty -s; then
    basefile=$(basename "$1" | sed -e 's/[^a-zA-Z0-9._-]/-/g')
    __curl_upload "$1" "https://transfer.sh/$basefile" >>"$tmpfile"
  else
    __curl_upload "-" "https://transfer.sh/$1" >>"$tmpfile"
  fi
  printf_green "$(cat $tmpfile)\n"
  __rm_rf "$tmpfile"
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# end
