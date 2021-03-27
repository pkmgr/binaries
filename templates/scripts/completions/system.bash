#!/usr/bin/env bash
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
##@Version       : GEN_SCRIPTS_REPLACE_VERSION
# @Author        : GEN_SCRIPTS_REPLACE_AUTHOR
# @Contact       : GEN_SCRIPTS_REPLACE_EMAIL
# @License       : GEN_SCRIPTS_REPLACE_LICENSE
# @ReadME        : GEN_SCRIPTS_REPLACE_FILENAME --help
# @Copyright     : GEN_SCRIPTS_REPLACE_COPYRIGHT
# @Created       : GEN_SCRIPTS_REPLACE_DATE
# @File          : GEN_SCRIPTS_REPLACE_FILENAME
# @Description   : GEN_SCRIPTS_REPLACE_FILENAME completion script
# @TODO          : GEN_SCRIPTS_REPLACE_TODO
# @Other         : GEN_SCRIPTS_REPLACE_OTHER
# @Resource      : GEN_SCRIPTS_REPLACE_RES
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
_GEN_SCRIPTS_REPLACE_FILENAME() {
  ___findcmd() { find -L ${1:-$CONFDIR}/ -maxdepth ${3:-3} -type ${2:-f} 2>/dev/null | sed 's|//|/|g;s#'${1:-$CONFDIR}/'##g' | grep '^' || return 1; }
  local cur prev words cword opts
  local cur="${COMP_WORDS[$COMP_CWORD]}"
  local prev="${COMP_WORDS[$COMP_CWORD - 1]}"
  local CONFFILE="settings.conf"
  local CONFDIR="$HOME/.config/myscripts/settings/GEN_SCRIPTS_REPLACE_FILENAME"
  local OPTSDIR="$HOME/.local/share/myscripts/options/GEN_SCRIPTS_REPLACE_FILENAME"
  local SEARCHDIR="${CONFDIR:-$HOME/.config/myscripts/settings/GEN_SCRIPTS_REPLACE_FILENAME}"
  local DEFAULTARRAY="$([ -f "$OPTSDIR/array" ] && grep -sEv '#|^$' "$OPTSDIR/array")"
  local DEFAULTOPTS="$([ -f "$OPTSDIR/options" ] && grep -sEv '#|^$' "$OPTSDIR/options" || echo -v -h)"
  local LONGOPTS="$(grep -sEv '#|^$' "$OPTSDIR/long_opts" || echo "$DEFAULTOPTS" | tr ' ' '\n' | grep '\--')"
  local SHORTOPTS="$(grep -sEv '#|^$' "$OPTSDIR/short_opts" || echo "$DEFAULTOPTS" | tr ' ' '\n' | grep -v '\--')"
  local OPTS="$DEFAULTOPTS"
  local ARRAY="$DEFAULTARRAY"
  local SHOW_COMP_OPTS=""
  local FILEDIR=""

  _init_completion || return
  if [ "$SHOW_COMP_OPTS" != "" ]; then
    local SHOW_COMP_OPTS_SEP="$(echo "$SHOW_COMP_OPTS" | tr ',' ' ')"
    compopt -o $SHOW_COMP_OPTS_SEP
  fi
  if [[ ${cur} == --* ]]; then
    COMPREPLY=($(compgen -W '${LONGOPTS}' -- ${cur}))
  elif [[ ${cur} == -* ]]; then
    COMPREPLY=($(compgen -W '${SHORTOPTS}' -- ${cur}))
  else
    case ${COMP_WORDS[1]:-$prev} in
    --options) prev="--options" && COMPREPLY=($(compgen -W '' -- "${cur}")) ;;
    -c | --config) prev="--config" && COMPREPLY=($(compgen -W '' -- "${cur}")) ;;
    -h | --help) prev="--help" && COMPREPLY=($(compgen -W '' -- "${cur}")) ;;
    -v | --version) prev="--version" && COMPREPLY=($(compgen -W '' -- "${cur}")) ;;
    -l | --list) prev="--list" && COMPREPLY=($(compgen -W '' -- "${cur}")) ;;
    -m | --modify)
      prev="-m"
      compopt -o nospace
      [ $COMP_CWORD -eq 2 ] && COMPREPLY=($(compgen -W '{a..z} {A..Z} {0..9}' -o nospace -- "${cur}"))
      [ $COMP_CWORD -eq 3 ] && COMPREPLY=($(compgen -W '$(_filedir)' -o filenames -o dirnames -- "${cur}"))
      [ $COMP_CWORD -gt 3 ] && COMPREPLY=($(compgen -W '' -- "${cur}"))
      ;;
    -r | --remove)
      prev="-r"
      [ $COMP_CWORD -eq 2 ] && COMPREPLY=($(compgen -W '${ARRAY}' -- "${cur}"))
      [ $COMP_CWORD -gt 3 ] && COMPREPLY=($(compgen -W '' -- "${cur}"))
      ;;
    -)
      prev="-" COMPREPLY=($(compgen -W '${SHORTOPTS} ${LONGOPTS}' -- ${cur}))
      ;;
    *)
      if [ -n "${ARRAY}" ]; then
        COMPREPLY=($(compgen -W '${ARRAY}' -- "${cur}"))
      elif [[ -n "$OPTS" ]]; then
        #[ $COMP_CWORD -gt 3 ] && \
        COMPREPLY=($(compgen -W '${OPTS}' -- "${cur}"))
      elif [[ ${cur} == --* ]]; then
        COMPREPLY=($(compgen -W '${LONGOPTS}' -- ${cur}))
      elif [[ ${cur} == -* ]]; then
        COMPREPLY=($(compgen -W '${SHORTOPTS}' -- ${cur}))
      fi
      return
      ;;
    esac
  fi
} &&
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # enable completions
  complete -F __GEN_SCRIPTS_REPLACE_FILENAME _GEN_SCRIPTS_REPLACE_FILENAME
# vim ft=shell noai
