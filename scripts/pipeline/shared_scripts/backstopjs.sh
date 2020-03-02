#!/usr/bin/env bash

set -o nounset
set -o pipefail
set -o errexit

if [[ -n "${DEBUG:-}" ]];then
  set -o xtrace
fi

# shellcheck disable=SC2164
__DIR__="$(cd "$(dirname "${0}")"; pwd)"

main() {
  # shellcheck source=.
  source "$__DIR__/../.env"
  bash "$__DIR__/../default_setup_ci.sh"
  # shellcheck source=.
  source "$__DIR__/common_functions.sh"
  _info "### Load Admin cookie for BackstopJS test"
  _robo degov:create-admin-cookie
  _info "### Running BackstopJS test"
  _info "### Set the Development Mode"
  _drush en degov_devel
  _drush config:set degov_devel.settings dev_mode true
  _info "### Clear cache before BackstopJS"
  _drush cr
  _info "### Running BackstopJS test"
  set +o errexit
  _backstopjs test
  EXIT_CODE=$?
  if [[ $EXIT_CODE -gt "0" ]]; then
    _info "### Dumping BackstopJS output"
    (cd $TEST_DIR && tar zhpcf backstopjs.tar.gz backstopjs/ && mv backstopjs.tar.gz $BITBUCKET_CLONE_DIR)
  fi
  # Pipeline needs the exitcode to mark the pipe as failed.
  exit $EXIT_CODE
}

main "$@"