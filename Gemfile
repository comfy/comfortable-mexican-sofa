# frozen_string_literal: true

source "http://rubygems.org"

gemspec

gem "bootsnap", require: false
# gem "propshaft"
gem "puma",        ">= 5.0"
gem "sqlite3",     ">= 2.10.1"
gem "ruby-vips",   "~> 2.2"
gem "rspec-rails", ">= 8.0.4"
gem "capybara",    ">= 3.40.0"
gem "rubocop",     ">= 1.92.1"

group :development do
  gem "web-console"
end








group :development, :test do


  gem "autoprefixer-rails"#, "~> 8.1.0"
  gem "byebug"#,             "~> 10.0.0", platforms: %i[mri mingw x64_mingw]
  #,           "~> 2.17.0"
  gem "kaminari"#,           "~> 1.1.1"


  gem "selenium-webdriver"#, "~> 3.9.0"

end

group :development do


  # gem "listen"#,       "~> 3.1.5"
end

group :test do




  gem "diffy"#,                    "~> 3.2.0"
  gem "equivalent-xml"#,           "~> 0.6.0"
  gem "mocha"#,                    "~> 1.3.0", require: false
  gem "rails-controller-testing"#, "~> 1.0.2"
end
