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
# @License       : WTFPL
# @ReadME        : REPLACE_FILENAME --help
# @Copyright     : REPLACE_COPYRIGHT
# @Created       : REPLACE_DATE
# @File          : REPLACE_FILENAME
# @Description   : REPLACE_DESC
# @TODO          : REPLACE_TODO
# @Other         : REPLACE_OTHER
# @Resource      : REPLACE_RES
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# helper function
__version() { app_version; }
__help() {
  app_help "Usage: REPLACE_FILENAME  |  REPLACE_FILENAME "
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Main function
main() {
  if [ -f "$SRC_DIR/functions.bash" ]; then
    FUNCTIONS_DIR="$SRC_DIR"
    . "$FUNCTIONS_DIR/functions.bash"
  elif [ -f "$HOME/.local/bin/functions.bash" ]; then
    FUNCTIONS_DIR="$HOME/.local/bin"
    . "$FUNCTIONS_DIR/functions.bash"
  else
    printf "\t\t\033[0;31m%s \033[0m\n" "Couldn't source the functions file from $FUNCTIONS_DIR"
    return 1
  fi
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  [ "$1" = "--version" ] && __version
  [ "$1" = "--help" ] && __help
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Required app check
  cmd_exists --error REPLACE_FILENAME || exit 1
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  #
  return "${exitCode:-0}"
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# execute function
main "$@"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
exit $?
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# end
