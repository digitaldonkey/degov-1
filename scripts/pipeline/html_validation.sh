#!/usr/bin/env bash

# Check unset variables
set -o nounset
set -o pipefail

if [[ -n "${DEBUG:-}" ]];then
  set -o xtrace
fi

# shellcheck disable=SC2164
__DIR__="$(cd "$(dirname "${0}")"; pwd)"
__STARTDIR__=${__STARTDIR__:-$__DIR__}
__SHARED_DIR__="$__STARTDIR__/html_validation_shared"
__TMP__="$__STARTDIR__/tmp"

_info() {
  local color_info="\\x1b[32m"
  local color_reset="\\x1b[0m"
  echo -e "$(printf '%s%s%s\n' "$color_info" "$@" "$color_reset")"
}

_err() {
  local color_error="\\x1b[31m"
  local color_reset="\\x1b[0m"
  echo -e "$(printf '%s%s%s\n' "$color_error" "$@" "$color_reset")" 1>&2
}

_fetch_html_content() {
  local URLS=""
  _info "# Fetch HTML"
  URLS=$(jq --raw-output '[ .scenarios[] | select(has("skipValidation") | not) | .url ] | unique[]' ../../testing/backstopjs/backstop.json | tr '\n' ' ')
  # URLS="http://host.docker.internal/degov-demo-content/blog-post "
  rm  -rf "${__TMP__:?}"/* \
  && wget --hsts-file=/tmp/wget-hsts --no-verbose --no-cache --no-cookies --trust-server-names --adjust-extension  --directory-prefix "$__TMP__" $URLS
  local EXITCODE=$?
  if [[ "${EXITCODE:-}" -gt 0 ]] ;then
    _err "Could not fetch the HTML content. Is the host host.docker.internal running?"
    exit $EXITCODE
  fi
  return $EXITCODE;
}

_run_validation() {
  if [[ -n "${CI:-}" ]];then
    _info "# Run validator"
    BUILD_DIR=$BITBUCKET_CLONE_DIR
    docker run \
      -v "$__TMP__":/files \
      -v "$__SHARED_DIR__":/shared \
      --add-host host.docker.internal:$BITBUCKET_DOCKER_HOST_INTERNAL \
      --name="validator" \
      validator/validator:latest /vnu-runtime-image/bin/vnu \
        --filterfile  /shared/message-filters.txt \
        --errors-only \
      /files
  else
    _info "# Run validator locally"
    # BUILD_DIR="/Users/tho/htdocs/GzEvD/degov_nrw-project/docroot"
    docker run \
      -t \
      -v "$__TMP__":/files \
      -v "$__SHARED_DIR__":/shared \
      --cidfile="$__TMP__/.cidfile" \
      validator/validator:latest /vnu-runtime-image/bin/vnu \
        --filterfile  /shared/message-filters.txt \
        --errors-only \
      /files
  fi
  local VALIDATOR_EXITCODE=$?
  if [[ "${VALIDATOR_EXITCODE:-}" = 125 ]] ;then
    _err "Could not validate the HTML content. Docker is not running."
  fi

  # Save assets
  if [[ "${VALIDATOR_EXITCODE:-}" -gt 0 ]] ;then
    _err "Found some validation errors."
    if [ -n "${BUILD_DIR+isset}" ]; then
      _info "# Save HTML validation HTML assets"
      if [[ -d "$BUILD_DIR/html_validation_results" ]] ;then
          rm -rf $BUILD_DIR/html_validation_results/*
      fi
      mkdir -p "$BUILD_DIR/html_validation_results/pages"
      cp $__TMP__/*.html $BUILD_DIR/html_validation_results/pages
      cp -R $__SHARED_DIR__ $BUILD_DIR/html_validation_results
      if [[ -n "${CI:-}" ]];then
          docker logs "validator" >& $BUILD_DIR/html_validation_results/errors.txt
        else
          docker logs "$(cat $__TMP__/.cidfile)" >& $BUILD_DIR/html_validation_results/errors.txt && rm $__TMP__/.cidfile
      fi
      tar -c -p -f html_validation_results.tar.gz -C $BUILD_DIR/html_validation_results/ .
      mv html_validation_results.tar.gz $BUILD_DIR
    fi
  fi
  exit $VALIDATOR_EXITCODE;
}

main() {
  if [[ -n "${CI:-}" ]];then
    echo "$BITBUCKET_DOCKER_HOST_INTERNAL host.docker.internal" >> /etc/hosts
  fi

  cd "$__STARTDIR__" \
  && _info "### Validating HTML5" \
  && _fetch_html_content \
  && _run_validation \
  && _info "No validation errors found"
}

main "$@"
