source 'http://rubygems.org'

gemspec

gem "bootstrap_form", github: "bootstrap-ruby/rails-bootstrap-forms", branch: "bootstrap-v4"

# apps can also use will_paginate so there's no dependency in gemspec
gem 'kaminari'

group :development do
  gem "listen"
  gem 'awesome_print'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem "rubocop", "~> 0.51.0", require: false
end

group :test do
  gem 'rails-controller-testing'
  gem 'sqlite3'
  gem 'mocha',      require: false
  gem 'coveralls',  require: false
end
