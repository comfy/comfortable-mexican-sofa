source 'http://rubygems.org'

gemspec

# gem 'rails', github: "rails/rails"
# gem "rails", github: "GBH/rails", branch: "active-storage-routes-prepend"
gem "rails", path: "~/Code/rails"

# apps can also use will_paginate so there's no dependency in gemspec
gem 'kaminari'

gem 'arel', github: 'rails/arel'

group :development do
  gem "listen"
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
