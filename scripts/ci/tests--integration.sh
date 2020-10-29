#!/usr/bin/env bash

set -o nounset
set -o pipefail
set -o errexit

if [[ -n ${DEBUG:-} ]]; then
  set -o xtrace
fi

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

# shellcheck source=.
source "$__DIR__/common_functions.sh"

main() {
  cd "$CI_ROOT_DIR/project"
  _info "### Importing db dump"
  _drush sql-query --file="$CI_ROOT_DIR/project/$CONTRIBNAME.sql"
  _info "### Running Behat features by tags: $1"
  set +e
  _disable_geocoder_presave 0
  _info "### Start php-server"
  (cd docroot && screen -dmS php-server php -S 0.0.0.0:80 .ht.router.php)
  _behat -c behat.dist.yml --suite=default --tags="$1"
  EXIT_CODE=$?
  _drush_watchdog
  exit $EXIT_CODE
}

main "$@"
