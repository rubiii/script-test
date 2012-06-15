#!/usr/bin/env bash
set -e

export LC_ALL="en_GB.UTF-8"
export LANG="en_GB.UTF-8"

setBundlerOpts() {
  BUNDLER_OPTS="--no-color --path ${HOME}/.bundle/cache"
}

ensureJobNameSet() {
  if [ -z "$JOB_NAME" ]; then
    echo 'Expected $JOB_NAME to be set'
    exit 1
  fi
}

checkNeedForXvfb() {
  if [ -z "$UNAME" ]; then
    UNAME="`uname`"
  fi
  if [ "$UNAME" == "Linux" ]; then
    XVFB="xvfb-run -a"
  fi
}

writeDatabaseYml() {
  echo "development: &development
  adapter: mysql2
  encoding: utf8
  host: localhost
  username: root
  password: secret
  reconnect: true
  database: <%= ENV['JOB_NAME'] %>-development
production:
  <<: *development
  database: <%= ENV['JOB_NAME'] %>-production
test:
  <<: *development
  database: <%= ENV['JOB_NAME'] %>-test" > ./config/database.yml
}


#
# RUN!
#

if [ "`whoami`" == "jenkins" ]; then
  setBundlerOpts
  ensureJobNameSet
  checkNeedForXvfb
  writeDatabaseYml
else
  echo "Not running as jenkins user. Skipping server setup!"
fi

bundle install $BUNDLER_OPTS

export CI_REPORTS="fast_test/reports"
$XVFB bundle exec rake --trace db:migrate db:test:load ci:fast_test
