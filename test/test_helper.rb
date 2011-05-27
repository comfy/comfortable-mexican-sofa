ENV['RAILS_ENV'] = 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  
  fixtures :all
  include ActionDispatch::TestProcess
  
  def setup
    reset_config
  end
  
  # resetting default configuration
  def reset_config
    ComfortableMexicanSofa.configure do |config|
      config.cms_title              = 'ComfortableMexicanSofa MicroCMS'
      config.authentication         = 'ComfortableMexicanSofa::HttpAuth'
      config.admin_route_prefix     = 'cms-admin'
      config.content_route_prefix   = ''
      config.admin_route_redirect   = 'pages'
      config.enable_multiple_sites  = false
      config.enable_mirror_sites    = false
      config.allow_irb              = false
      config.enable_caching         = true
      config.enable_fixtures        = false
      config.fixtures_path          = File.expand_path('db/cms_fixtures', Rails.root)
      config.revisions_limit        = 25
    end
    ComfortableMexicanSofa::HttpAuth.username = 'username'
    ComfortableMexicanSofa::HttpAuth.password = 'password'
  end
  
  # Example usage:
  #   assert_has_errors_on( @record, [:field_1, :field_2] )
  #   assert_has_errors_on( @record, {:field_1 => 'Message1', :field_2 => 'Message 2'} )
  def assert_has_errors_on(record, fields)
    fields = [fields].flatten unless fields.is_a?(Hash)
    fields.each do |field, message|
      assert record.errors.to_hash.has_key?(field.to_sym), "#{record.class.name} should error on invalid #{field}"
      if message && record.errors[field].is_a?(Array) && !message.is_a?(Array)
        assert_not_nil record.errors[field].index(message)
      elsif message
        assert_equal message, record.errors[field]
      end
    end
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
  
  # Small method that allows for better formatting in tests
  def rendered_content_formatter(string)
    string.gsub(/^[ ]+/, '')
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
  end
  
  # Attaching http_auth stuff with request. Example use:
  #   http_auth :get, '/cms-admin/pages'
  def http_auth(method, path, options = {}, username = 'username', password = 'password')
    send(method, path, options, {'HTTP_AUTHORIZATION' => "Basic #{Base64.encode64(username + ':' + password)}"})
  end
end
