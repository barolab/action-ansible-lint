FROM python:3.8-slim

ENV REVIEWDOG_VERSION=v0.10.0

LABEL "com.github.actions.name"="Run ansible-lint with reviewdog"
LABEL "com.github.actions.description"=" 🐶 Run ansible-lint with reviewdog on pull requests to improve code review experience."
LABEL "com.github.actions.icon"="edit"
LABEL "com.github.actions.color"="gray-dark"

# Install git (required by ansible-lint)
RUN set -ex && apt-get update && apt-get -q install -y -V git wget && rm -rf /var/lib/apt/lists/*
RUN pip install ansible-lint

# Install reviewdog
RUN wget -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh | sh -s -- -b /usr/local/bin/ ${REVIEWDOG_VERSION}

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
