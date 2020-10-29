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

_unshallow() {
  cd "$CI_ROOT_DIR"

  # shellcheck disable=SC2091
  if $(git rev-parse --is-shallow-repository); then
    git fetch --unshallow
    git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
    git fetch --quiet origin
  fi
}

main() {
  local checksum
  local existing_checksum
  local existing_checksum_filename="$CI_ROOT_DIR/project/checksum_composer.hash"

  _unshallow
  checksum=$(git log -n 1 --pretty=format:%H -- composer.json)

  _info "### Run post install"
  # Was the composer.json changed? Then lets composer download the dependencies.
  if ! git diff --exit-code "origin/$RELEASE_BRANCH" "composer.json" > /dev/null; then
    if [[ -f $existing_checksum_filename ]]; then
      existing_checksum=$("cat $existing_checksum_filename")
      if [[ $checksum == "$existing_checksum" ]]; then
        _info "### [SKIPPED] Apply composer.json changes"
        exit 0
      fi
    fi
    _info "### Apply composer.json changes"
    cd "$CI_ROOT_DIR/project"
    # --no-update change only the composer.json
    _composer require --no-progress "$INSTALL_PROJECT:dev-$BITBUCKET_BRANCH#$BITBUCKET_COMMIT" --no-update
    # Now downloads install profile + list of dependencies.
    _composer update $INSTALL_PROJECT $INSTALL_PROJECT_UPDATE_LIST
    # Re-apply patches in case they was changed.
    _composer install --no-progress --optimize-autoloader
  fi

  cd "$CI_ROOT_DIR/project"
  # Move the lfs_data out of the install profile before we delete it. But lets the pipeline store the data in the project artifact.
  mv -v "$TEST_DIR/lfs_data/$CONTRIBNAME-stable-$DB_DUMP_VERSION.sql.gz" .
  # Do not store data (as artifact in the pipeline) which is in the git repo itself. (this makes artifact smaller)
  # We restore the profile in default_setup_ci.sh.
  rm -rf "$PROFILE_DIR"
  find . -type d -name '.git' -print0 -exec rm -rf {} + > /dev/null
  cd "$CI_ROOT_DIR" \
    && git log -n 1 --pretty=format:%H -- composer.json > "$existing_checksum_filename"
}

main
