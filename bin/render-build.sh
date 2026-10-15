#!/usr/bin/env sh
set -eu

bundle install
bundle exec rails assets:precompile
