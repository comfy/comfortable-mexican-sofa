source "http://rubygems.org"

gemspec

# apps can also use will_paginate so there's no dependency in gemspec
gem "kaminari"

group :development do
  gem "awesome_print"
  gem "better_errors"
  gem "binding_of_caller"
  gem "listen"
  gem "rubocop", "~> 0.51.0", require: false
end

group :test do
  gem "coveralls",  require: false
  gem "mocha",      require: false
  gem "rails-controller-testing"
  gem "sqlite3"
end
