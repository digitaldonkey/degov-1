#!/usr/bin/env bash

set -o nounset
set -o pipefail
set -o errexit

# shellcheck disable=SC2164
__DIR__="$(
  cd "$(dirname "${0}")"
  pwd
)"

# shellcheck source=.
source "$__DIR__/.env"
if [[ -n ${DEBUG:-} ]]; then
  set -o xtrace
fi

_info() {
  local color_info='\x1b[96m'
  local color_reset='\x1b[0m'
  echo -e "$(printf '%s%s%s\n' "$color_info" "$@" "$color_reset")"
}

_composer() {
  export COMPOSER_ALLOW_SUPERUSER
  composer --ansi --profile "$@"
}

main() {
  if [[ -d $PROFILE_DIR ]]; then
    _info "[SKIPPED] ### Install project"
    exit 0
  fi
  cd "$CI_ROOT_DIR/project"
  _info "### Install project"
  _composer install --no-progress --optimize-autoloader
}

main
