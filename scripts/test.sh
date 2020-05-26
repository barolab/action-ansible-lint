#!/bin/bash

# This script is used mainly as a local test purpose, it is not meant to be used in real use-cases

docker build -t barolab/action-ansible-lint:test .
docker run --rm \
    -e "GITHUB_WORKSPACE=/github" \
    -e "TARGETS=testdata/**/*.yml" \
    -e "INPUT_GITHUB_TOKEN=changeme" \
    -e "INPUT_REPORTER=github-pr-review" \
    -e "INPUT_LEVEL=info" \
    -e "INPUT_FAIL_ON_ERROR=true" \
    -e "INPUT_FILTER_MODE=nofilter" \
    -v "$(pwd):/github" \
    barolab/action-ansible-lint:test \
    '-x 301,305 --exclude testdata/roles/test/**/*.yml'
