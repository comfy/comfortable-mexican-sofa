source 'http://rubygems.org'

gem 'rails',          '3.1.0'
gem 'active_link_to', '>=1.0.0'
gem 'paperclip',      '>=2.3.14'

group :development do
  # gem 'sqlite3'
end

group :test do
  gem 'sqlite3'
  gem 'jeweler', '>=1.4.0'
end
