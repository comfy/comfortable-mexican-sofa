#!/bin/bash -l

set -e

export PATH=./bin:$PATH
export RAILS_ENV=test
export BUNDLE_WITHOUT=development

bundle install

if [ -n "$GO_PIPELINE_NAME" ]; then
  rake db:drop db:create db:migrate
fi

CI_PIPELINE_COUNTER=${GO_PIPELINE_COUNTER-0}
CI_EXECUTOR_NUMBER=${EXECUTOR_NUMBER-0}

rake test
