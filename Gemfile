source 'http://rubygems.org'

gemspec

gem "transitions", :require => ["transitions", "active_model/transitions"]

group :development do
  gem 'awesome_print'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'quiet_assets'
end

group :test do
  gem 'sqlite3',                          :platform => [:ruby, :mswin, :mingw]
  gem 'jdbc-sqlite3',                     :platform => :jruby
  gem 'activerecord-jdbcsqlite3-adapter', :platform => :jruby
  gem 'mocha',      :require => false
  gem 'coveralls',  :require => false
  gem 'timecop'
end

gem 'mas-build', :git => 'git@github.com:moneyadviceservice/mas-build' if ENV['MAS_BUILD']

