# encoding: utf-8

ENV['RAILS_ENV'] = 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

# No need to add cache-busters in test environment
Paperclip::Attachment.default_options[:use_timestamp] = false

class ActiveSupport::TestCase
  fixtures :all
  include ActionDispatch::TestProcess
  
  def setup
    reset_config
  end
  
  # resetting default configuration
  def reset_config
    ComfortableMexicanSofa.configure do |config|
      config.cms_title            = 'ComfortableMexicanSofa CMS Engine'
      config.admin_auth           = 'ComfortableMexicanSofa::HttpAuth'
      config.public_auth          = 'ComfortableMexicanSofa::DummyAuth'
      config.admin_route_prefix   = 'cms-admin'
      config.admin_route_redirect = ''
      config.allow_irb            = false
      config.enable_fixtures      = false
      config.fixtures_path        = File.expand_path('db/cms_fixtures', Rails.root)
      config.revisions_limit      = 25
      config.locales              = { 
        'en'    => 'English',
        'es'    => 'Español',
        'pt-BR' => 'Português Brasileiro',
        'zh-CN' => '简体中文' 
      }
      config.admin_locale         = nil
      config.upload_file_options  = { }
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

  def assert_no_select(selector, value = nil)
    assert_select(selector, :text => value, :count => 0)
  end

  # Small method that allows for better formatting in tests
  def rendered_content_formatter(string)
    string.gsub(/^[ ]+/, '')
  end

  # Example usage:
  #   with_translations(:en, :sections => { :products => "Our Products" }) do
  #     assert_equal I18n.translate('products', :scope => 'sections'), "Our Products"
  #     assert_equal I18n.translate('sections'), { :products => "Our Products" }
  #   end
  def with_translations(locale, translations, &block)
    begin
      I18n.backend.store_translations locale, translations
      I18n.locale = locale
      yield
    ensure
      I18n.reload!
    end
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
