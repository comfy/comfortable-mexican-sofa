source 'http://rubygems.org'

gemspec

# apps can also use will_paginate so there's no dependency in gemspec
gem 'kaminari'

gem 'rails', '~> 5.0.0'

group :development do
  gem 'awesome_print'
  gem 'better_errors'
  gem 'binding_of_caller'
end

group :test do
  gem 'rails-controller-testing'
  
  gem 'sqlite3',                          :platform => [:ruby, :mswin, :mingw]
  gem 'jdbc-sqlite3',                     :platform => :jruby
  gem 'activerecord-jdbcsqlite3-adapter', :platform => :jruby

  gem 'mocha',      :require => false
  gem 'coveralls',  :require => false
end
