# Loading engine only if this is not a standalone installation
unless defined? ComfortableMexicanSofa::Application
  require_relative 'comfortable_mexican_sofa/engine'
end

require_relative 'comfortable_mexican_sofa/version'
require_relative 'comfortable_mexican_sofa/error'
require_relative 'comfortable_mexican_sofa/configuration'
require_relative 'comfortable_mexican_sofa/routing'
require_relative 'comfortable_mexican_sofa/authentication/http_auth'
require_relative 'comfortable_mexican_sofa/authentication/dummy_auth'
require_relative 'comfortable_mexican_sofa/render_methods'
require_relative 'comfortable_mexican_sofa/view_hooks'
require_relative 'comfortable_mexican_sofa/view_methods'
require_relative 'comfortable_mexican_sofa/form_builder'
require_relative 'comfortable_mexican_sofa/tag'
require_relative 'comfortable_mexican_sofa/fixture'
require_relative 'comfortable_mexican_sofa/fixture/category'
require_relative 'comfortable_mexican_sofa/fixture/layout'
require_relative 'comfortable_mexican_sofa/fixture/page'
require_relative 'comfortable_mexican_sofa/fixture/snippet'
require_relative 'comfortable_mexican_sofa/fixture/file'
require_relative 'comfortable_mexican_sofa/extensions/rails'
require_relative 'comfortable_mexican_sofa/extensions/acts_as_tree'
require_relative 'comfortable_mexican_sofa/extensions/has_revisions'
require_relative 'comfortable_mexican_sofa/extensions/is_mirrored'
require_relative 'comfortable_mexican_sofa/extensions/is_categorized'

Dir.glob(File.expand_path('comfortable_mexican_sofa/tags/*.rb', File.dirname(__FILE__))).each do |path|
  require_relative path
end

module ComfortableMexicanSofa
  class << self
    
    # Modify CMS configuration
    # Example:
    #   ComfortableMexicanSofa.configure do |config|
    #     config.cms_title = 'ComfortableMexicanSofa'
    #   end
    def configure
      yield configuration
    end
    
    # Accessor for ComfortableMexicanSofa::Configuration
    def configuration
      @configuration ||= Configuration.new
    end
    alias :config :configuration

    def logger=(new_logger)
      @logger = new_logger
    end

    def logger
      @logger ||= Rails.logger
    end
    
  end
end
