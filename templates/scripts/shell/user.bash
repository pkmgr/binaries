#!/usr/bin/env bash
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
APPNAME="REPLACE_FILENAME"
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
# @ReadME        : REPLACE_README
# @Copyright     : REPLACE_COPYRIGHT
# @Created       : REPLACE_DATE
# @File          : REPLACE_FILENAME
# @Description   : REPLACE_DESC
# @TODO          : REPLACE_TODO
# @Other         : REPLACE_OTHER
# @Resource      : REPLACE_RES
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# helper function
__help() {
  printf_help "Usage:  REPLACE_FILENAME |  REPLACE_FILENAME "
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Main function
main() {
  local DIR="${SRC_DIR:-$PWD}"
  if [[ -f "$DIR/functions.bash" ]]; then
    . "$DIR/functions.bash"
  else
    printf "\t\t\\033[0;31m%s \033[0m\n" "Couldn't source the functions file from $DIR"
    return 1
  fi
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  [ "$1" = "--help" ] && __help
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  !
  return "${exitCode:-$?}"
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# execute function
main "$@"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
exit $?
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# end
