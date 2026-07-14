#!/usr/bin/env bash

set -Eeuxo pipefail

file_env() {
  local var="$1"
  local fileVar="${var}_FILE"
  local def="${2:-}"
  if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
    printf >&2 'error: both %s and %s are set (but are exclusive)\n' "$var" "$fileVar"
    exit 1
  fi
  local val="$def"
  if [ "${!var:-}" ]; then
    val="${!var}"
  elif [ "${!fileVar:-}" ]; then
    val="$(< "${!fileVar}")"
  fi
  export "$var"="$val"
  unset "$fileVar"
}

_is_sourced() {
  [ "${#FUNCNAME[@]}" -ge 2 ] \
    && [ "${FUNCNAME[0]}" = '_is_sourced' ] \
    && [ "${FUNCNAME[1]}" = 'source' ]
}

_want_help() {
  local arg
  for arg; do
    case "$arg" in
      -h|--help-env|--help-xoptions|--help-all)
        return 0
        ;;
    esac
  done
  return 1
}

pre_setup() {
  uv run alembic upgrade head
}

_main() {
  if [ "${1:0:1}" = '-' ]; then
    set -- python "$@"
  fi

  if [ "$1" = 'python' ] && ! _want_help "$@"; then
    # pre_setup
    exec uv run "$@" -m main
  fi

  exec "$@"
}

if ! _is_sourced; then
  _main "$@"
fi
