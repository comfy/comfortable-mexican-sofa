%w(
  cms_rails_extensions
  cms_acts_as_tree
  acts_as_categorized
  cms_tag
  cms_tags/block
  cms_tags/page_block
  cms_tags/snippet
  cms_tags/partial
  cms_tags/helper
  cms_form_builder
  engine
).each do |req|
  require File.join(File.dirname(__FILE__), 'comfortable_mexican_sofa', req)
end

ActiveSupport.on_load(:action_controller) do
  ActionController::Base.helper CmsHelper
end

module ComfortableMexicanSofa
  class Config
    def self.cattr_accessor_with_default(name, value = nil)
      cattr_accessor name
      self.send("#{name}=", value) unless value === nil
    end

    cattr_accessor_with_default :http_auth_enabled, true
    cattr_accessor_with_default :http_auth_username, 'username'
    cattr_accessor_with_default :http_auth_password, 'password'
    cattr_accessor_with_default :cms_title
    cattr_accessor_with_default :additional_cms_tabs, { }
    cattr_accessor_with_default :extension_tabs, { }
    cattr_accessor_with_default :logo_path, '/images/cms/default-logo.png'
  end

  def self.config(&block)
    yield ComfortableMexicanSofa::Config
  end
end
