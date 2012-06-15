#!/usr/bin/env bash

writeGemfile() {
  echo "source :rubygems
gem 'rake'" > Gemfile
}

writeRakefile() {
  echo "task('db:migrate') { puts 'running task: db:migrate' }"      > Rakefile
  echo "task('db:test:load') { puts 'running task: db:test:load' }" >> Rakefile
  echo "task('ci:fast_test') { puts 'running task: ci:fast_test' }" >> Rakefile
}

assertRunsTask() {
  output=$1
  task=$2

  if [[ "$output" == *"running task: $task"* ]]; then
    assertTrue ${SHUNIT_TRUE}
  else
    fail "Expected the $task task to be invoked"
  fi
}

setUp() {
  writeGemfile
  writeRakefile
}

testRakeTasksAreRun() {
  output="`./script.sh`"

  assertRunsTask "$output" "db:migrate"
  assertRunsTask "$output" "db:test:load"
  assertRunsTask "$output" "ci:fast_test"
}

. ./shunit2-2.1.6/src/shunit2
