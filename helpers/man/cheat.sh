#!/usr/bin/env bash
source ./.functions
printf_help "4" "Usage:"
printf_help "4" "QUERY                               process QUERY and exit"
printf_help "4" "--help                              show this help"
printf_help "4" "--shell [LANG]                      shell mode (open LANG if specified)"
printf_help "4" "--standalone-install [DIR|help]     install cheat.sh in the standalone mode (by default, into ~/.config/cheat.sh)"
printf_help "4" "--mode [auto|lite]                  set (or display) mode of operation"
printf_help "4" "                                    * auto - prefer the local installation"
printf_help "4" "                                    * lite - use the cheat sheet server"
