#! /usr/bin/env bash

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

: "${TARGETS?No targets to check. Nothing to do.}"
: "${GITHUB_WORKSPACE?GITHUB_WORKSPACE has to be set. Did you use the actions/checkout action?}"
pushd "${GITHUB_WORKSPACE}" || exit 1

args=("$@")

[[ -n "${OVERRIDE}" ]] && pip install "${OVERRIDE}" && pip check
>&2 echo -E "Completed installing override dependencies"
>&2 echo -E "Running ansible-lint --nocolor -p ${args[*]} ${TARGETS}"

# Enable recursive glob patterns, such as '**/*.yml'.
shopt -s globstar

# shellcheck disable=SC2086
ansible-lint --nocolor -p "${args[@]}" ${TARGETS} | reviewdog -f=ansible-lint -name="ansible-lint" -reporter="${INPUT_REPORTER}" -level="${INPUT_LEVEL}" -fail-on-error="${INPUT_FAIL_ON_ERROR}" -filter-mode="${INPUT_FILTER_MODE}"
ansible_lint_return="${PIPESTATUS[0]}" reviewdog_return="${PIPESTATUS[1]}" exit_code=$?

shopt -u globstar

echo ::set-output name=ansible-lint-return-code::"${ansible_lint_return}"
echo ::set-output name=reviewdog-return-code::"${reviewdog_return}"

exit $exit_code