#!/usr/bin/env bash

APPNAME="$(basename $0)"
USER="${SUDO_USER:-${USER}}"
HOME="${USER_HOME:-${HOME}}"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
##@Version       : REPLACE_VERSION
# @Author        : REPLACE_AUTHOR
# @Contact       : REPLACE_EMAIL
# @License       : REPLACE_LICENSE
# @Copyright     : Copyright (c) REPLACE_YEAR, REPLACE_AUTHOR
# @Created       : REPLACE_DATE
# @File          : REPLACE_FILENAME
# @Description   :
# @TODO          :
# @Other         :
# @Resource      :
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# check for needed applications
cmd_exists || exit 1

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Set variables

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Set functions
printf_color() { printf "%b" "$(tput setaf "$1" 2>/dev/null)" "\t\t$2\n" "$(tput sgr0 2>/dev/null)"; }

__help() {
  printf_color "4" "usage: $APPNAME"

  exit
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Main application

case "$1" in
--help)
  shift 1
  __help

  ;;
esac

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
exit $?
# end
