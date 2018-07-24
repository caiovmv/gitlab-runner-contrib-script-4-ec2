#!/bin/bash
# By Caio Villela
# Usage ./register-gitlab-runner.sh [gitlab-url] [gitlab-runner-project-registration-token] [gitlab-runner-executor] [gitlab-runner-tags] [server-count]
# Eg. ./setup.sh kaasa dev https://gitlab.com 1212313 shell aws,deploy,us-east-1 01

sudo gitlab-runner register \
  --non-interactive \
  --url "$3" \
  --registration-token "$4" \
  --executor "$5" \
  --tag-list "${6},${2}-${1}${7}" \
  --locked="true"
