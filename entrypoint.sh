#! /usr/bin/env bash

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

ansible_lint_return=0
reviewdog_return=0

# Filter out arguments that are not available to this action
# args:
#   $@: Arguments to be filtered
parse_args() {
  local opts=""
  while (( "$#" )); do
    case "$1" in
      -c)
        opts="$opts -c $2"
        shift 2
        ;;
      -r)
        opts="$opts -r $2"
        shift 2
        ;;
      -R)
        opts="$opts -R"
        shift
        ;;
      -t)
        opts="$opts -t $2"
        shift 2
        ;;
      -x)
        opts="$opts -x $2"
        shift 2
        ;;
      --exclude)
        opts="$opts --exclude=$2"
        shift 2
        ;;
      --) # end argument parsing
        shift
        break
        ;;
      -*) # unsupported flags
        >&2 echo "ERROR: Unsupported flag: '$1'"
        exit 1
        ;;
      *) # positional arguments
        shift  # ignore
        ;;
    esac
  done

  # set remaining positional arguments (if any) in their proper place
  eval set -- "$opts"

  echo "${opts/ /}"
  return 0
}

override_python_packages() {
  [[ -n "${OVERRIDE}" ]] && pip install "${OVERRIDE}" && pip check
  >&2 echo "Completed installing override dependencies..."
}

: "${TARGETS?No targets to check. Nothing to do.}"
: "${GITHUB_WORKSPACE?GITHUB_WORKSPACE has to be set. Did you use the actions/checkout action?}"
pushd "${GITHUB_WORKSPACE}"

args=("$@")
override_python_packages
opts=$(parse_args "${args[@]}" || exit 1)

>&2 echo -E ""
>&2 echo -E "Running Ansible Lint..."
>&2 echo -E ""

# Enable recursive glob patterns, such as '**/*.yml'.
shopt -s globstar

# shellcheck disable=SC2086
ansible-lint --nocolor -p $opts ${TARGETS} | reviewdog -f=ansible-lint -name="ansible-lint" -reporter="${INPUT_REPORTER}" -level="${INPUT_LEVEL}" -fail-on-error="${INPUT_FAIL_ON_ERROR}" -filter-mode="${INPUT_FILTER_MODE}"
ansible_lint_return="${PIPESTATUS[0]}" reviewdog_return="${PIPESTATUS[1]}" exit_code=$?

shopt -u globstar

echo ::set-output name=ansible-lint-return-code::"${ansible_lint_return}"
echo ::set-output name=reviewdog-return-code::"${reviewdog_return}"

exit $exit_code