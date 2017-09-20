source 'http://rubygems.org'

gemspec

# apps can also use will_paginate so there's no dependency in gemspec
gem 'kaminari'

gem 'rails', github: 'rails/rails'
gem 'arel', github: 'rails/arel'

group :development do
  gem 'awesome_print'
  gem 'better_errors'
  gem 'binding_of_caller'
end

group :test do
  gem 'rails-controller-testing'

  gem 'sqlite3'

  gem 'mocha',      :require => false
  gem 'coveralls',  :require => false
end
