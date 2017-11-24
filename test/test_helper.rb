# encoding: utf-8
ENV['RAILS_ENV'] = 'test'

require 'simplecov'
require 'coveralls'
SimpleCov.formatter = Coveralls::SimpleCov::Formatter
SimpleCov.start do
  add_filter 'lib/generators'
  add_filter 'lib/comfortable_mexican_sofa/engine.rb '
end
require_relative '../config/environment'

require 'rails/test_help'
require 'rails/generators'
require 'mocha/setup'

Rails.backtrace_cleaner.remove_silencers!


class ActiveSupport::TestCase

  include ActionDispatch::TestProcess

  fixtures :all

  setup :reset_config,
        :reset_locale

  # resetting default configuration
  def reset_config
    ComfortableMexicanSofa.configure do |config|
      config.cms_title            = 'ComfortableMexicanSofa CMS Engine'
      config.admin_auth           = 'ComfortableMexicanSofa::AccessControl::AdminAuthentication'
      config.admin_authorization  = 'ComfortableMexicanSofa::AccessControl::AdminAuthorization'
      config.public_auth          = 'ComfortableMexicanSofa::AccessControl::PublicAuthentication'
      config.public_authorization = 'ComfortableMexicanSofa::AccessControl::PublicAuthorization'
      config.admin_route_redirect = ''
      config.enable_seeds         = false
      config.seeds_path           = File.expand_path('db/cms_seeds', Rails.root)
      config.revisions_limit      = 25
      config.locales              = {
        'en' => 'English',
        'es' => 'Español'
      }
      config.admin_locale         = nil
      config.admin_cache_sweeper  = nil
      config.allow_erb            = false
      config.allowed_helpers      = nil
      config.allowed_partials     = nil
      config.allowed_templates    = nil
      config.hostname_aliases     = nil
      config.public_cms_path      = nil
    end
    ComfortableMexicanSofa::AccessControl::AdminAuthentication.username = 'username'
    ComfortableMexicanSofa::AccessControl::AdminAuthentication.password = 'password'
  end

  def reset_locale
    I18n.default_locale = :en
    I18n.locale         = :en
  end

  # Example usage:
  #   assert_has_errors_on @record, :field_1, :field_2
  def assert_has_errors_on(record, *fields)
    unmatched = record.errors.keys - fields.flatten
    assert unmatched.blank?, "#{record.class} has errors on '#{unmatched.join(', ')}'"
    unmatched = fields.flatten - record.errors.keys
    assert unmatched.blank?, "#{record.class} doesn't have errors on '#{unmatched.join(', ')}'"
  end

  # Example usage:
  #   assert_exception_raised                                 do ... end
  #   assert_exception_raised ActiveRecord::RecordInvalid     do ... end
  #   assert_exception_raised Plugin::Error, 'error_message'  do ... end
  def assert_exception_raised(exception_class = nil, error_message = nil, &block)
    exception_raised = nil
    yield
  rescue => exception_raised
  ensure
    if exception_raised
      if exception_class
        assert_equal exception_class, exception_raised.class, exception_raised.to_s
      else
        assert true
      end
      assert_equal error_message, exception_raised.to_s if error_message
    else
      flunk 'Exception was not raised'
    end
  end

  def assert_no_select(selector, value = nil)
    assert_select(selector, text: value, count: 0)
  end

  def assert_count_difference(models, number = 1, &block)
    counts = [models].flatten.map{|m| "#{m}.count"}
    assert_difference counts, number do
      yield
    end
  end

  def assert_count_no_difference(*models, &block)
    counts = [models].flatten.map{|m| "#{m}.count"}
    assert_no_difference counts do
      yield
    end
  end

  # Capturing STDOUT into a string
  def with_captured_stout
    old = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = old
  end
end


class ActionDispatch::IntegrationTest

  setup :setup_host

  def setup_host
    host! 'test.host'
  end

  # Attaching http_auth stuff with request. Example use:
  #   r :get, '/cms-admin/pages'
  def r(method, path, options = {}, username = 'username', password = 'password')
    headers = options[:headers] || {}
    headers['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(username, password)
    options.merge!(headers: headers)
    send(method, path, options)
  end

  def with_routing(&block)
    yield ComfortableMexicanSofa::Application.routes
  ensure
    ComfortableMexicanSofa::Application.routes_reloader.reload!
  end
end

class Rails::Generators::TestCase

  setup :prepare_destination,
        :prepare_files

  destination File.expand_path('../tmp', File.dirname(__FILE__))

  def prepare_files
    config_path = File.join(self.destination_root, 'config')
    routes_path = File.join(config_path, 'routes.rb')
    app_path    = File.join(config_path, 'application.rb')
    FileUtils.mkdir_p(config_path)
    FileUtils.touch(routes_path)
    File.open(routes_path, 'w') do |f|
      f.write <<-RUBY.strip_heredoc
        Test::Application.routes.draw do
        end
      RUBY
    end
    File.open(app_path, 'w') do |f|
      f.write <<-RUBY.strip_heredoc
        module TestApp
          class Application < Rails::Application
          end
        end
      RUBY
    end
  end

  def read_file(filename)
    File.read(
      File.join(
        File.expand_path('fixtures/generators', File.dirname(__FILE__)),
        filename
      )
    )
  end
end
