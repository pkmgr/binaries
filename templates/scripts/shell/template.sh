#!/usr/bin/env bash

APPNAME="$(basename $0)"
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
# Set variables

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Set functions
printf_color() { printf "%b" "$(tput setaf "$1" 2>/dev/null)" "\t\t$2\n" "$(tput sgr0 2>/dev/null)"; }

__help() {
  printf_color "4" "usage: $APPNAME"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# check for needed applications
cmd_exists || exit 1

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Main application

case $1 in
--help)
  shift 1
  __help
  exit
  ;;
esac

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
exit $?
# end
