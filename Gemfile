# frozen_string_literal: true

source "http://rubygems.org"

gemspec

gem "ruby-vips", "~> 2.2"

group :development, :test do
  gem "rspec-rails",         "~> 8.0.4"
  gem "rspec-html-matchers", "~> 0.10"
  gem "capybara"

  gem "autoprefixer-rails"#, "~> 8.1.0"
  gem "byebug"#,             "~> 10.0.0", platforms: %i[mri mingw x64_mingw]
  #,           "~> 2.17.0"
  gem "kaminari"#,           "~> 1.1.1"
  gem "puma"#,               "~> 3.12.2"
  gem "rubocop"#,            "~> 0.55.0", require: false
  gem "selenium-webdriver"#, "~> 3.9.0"
  gem "sqlite3"#,            "~> 1.4.2"
end

group :development do
  gem "bootsnap", require: false

  gem "listen"#,       "~> 3.1.5"
  gem "web-console"#,  "~> 3.5.1"
end

group :test do




  gem "diffy"#,                    "~> 3.2.0"
  gem "equivalent-xml"#,           "~> 0.6.0"
  gem "mocha"#,                    "~> 1.3.0", require: false
  gem "rails-controller-testing"#, "~> 1.0.2"
end
