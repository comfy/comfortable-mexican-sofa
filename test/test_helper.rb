# encoding: utf-8

require 'coveralls'
Coveralls.wear!('rails')

ENV['RAILS_ENV'] = 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'rails/generators'
require 'mocha/setup'

# No need to add cache-busters in test environment
Paperclip::Attachment.default_options[:use_timestamp] = false

class ActiveSupport::TestCase
  fixtures :all
  include ActionDispatch::TestProcess
  
  def setup
    reset_config
    stub_paperclip
  end
  
  # resetting default configuration
  def reset_config
    ComfortableMexicanSofa.configure do |config|
      config.cms_title            = 'ComfortableMexicanSofa CMS Engine'
      config.admin_auth           = 'ComfortableMexicanSofa::HttpAuth'
      config.public_auth          = 'ComfortableMexicanSofa::DummyAuth'
      config.admin_route_redirect = ''
      config.enable_fixtures      = false
      config.fixtures_path        = File.expand_path('db/cms_fixtures', Rails.root)
      config.revisions_limit      = 25
      config.locales              = { 
        'en'    => 'English',
        'es'    => 'Español',
        'pt-BR' => 'Português Brasileiro',
        'zh-CN' => '简体中文',
        'ja'    => '日本語'
      }
      config.admin_locale         = nil
      config.upload_file_options  = { }
      config.admin_cache_sweeper  = nil
      config.allow_irb            = false
      config.allowed_helpers      = nil
      config.allowed_partials     = nil
      config.hostname_aliases     = nil
    end
    ComfortableMexicanSofa::HttpAuth.username = 'username'
    ComfortableMexicanSofa::HttpAuth.password = 'password'
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
    assert_select(selector, :text => value, :count => 0)
  end

  # Small method that allows for better formatting in tests
  def rendered_content_formatter(string)
    string.gsub(/^[ ]+/, '')
  end
  
  def stub_paperclip
    Cms::Block.any_instance.stubs(:save_attached_files).returns(true)
    Cms::Block.any_instance.stubs(:delete_attached_files).returns(true)
    Paperclip::Attachment.any_instance.stubs(:post_process).returns(true)
  end
  
end

class ActionController::TestCase
  def setup
    @request.env['HTTP_AUTHORIZATION'] = "Basic #{Base64.encode64('username:password')}"
  end
end

class ActionDispatch::IntegrationTest
  
  def setup
    host! 'test.host'
    reset_config
    stub_paperclip
  end
  
  # Attaching http_auth stuff with request. Example use:
  #   http_auth :get, '/cms-admin/pages'
  def http_auth(method, path, options = {}, username = 'username', password = 'password')
    send(method, path, options, {'HTTP_AUTHORIZATION' => "Basic #{Base64.encode64(username + ':' + password)}"})
  end
end

class Rails::Generators::TestCase
  
  destination File.expand_path('../tmp', File.dirname(__FILE__))
  
  setup :prepare_destination,
        :prepare_files
  
  def prepare_files
    config_path = File.join(self.destination_root, 'config')
    routes_path = File.join(config_path, 'routes.rb')
    FileUtils.mkdir_p(config_path)
    FileUtils.touch(routes_path)
    File.open(routes_path, 'w') do |f|
      f.write("Test::Application.routes.draw do\n\nend")
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