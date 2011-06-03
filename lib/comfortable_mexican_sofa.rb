# Loading engine only if this is not a standalone installation
unless defined? ComfortableMexicanSofa::Application
  require File.expand_path('comfortable_mexican_sofa/engine', File.dirname(__FILE__))
end

[ 'comfortable_mexican_sofa/version',
  'comfortable_mexican_sofa/error',
  'comfortable_mexican_sofa/configuration',
  'comfortable_mexican_sofa/http_auth',
  'comfortable_mexican_sofa/rails_extensions',
  'comfortable_mexican_sofa/controller_methods',
  'comfortable_mexican_sofa/view_hooks',
  'comfortable_mexican_sofa/view_methods',
  'comfortable_mexican_sofa/form_builder',
  'comfortable_mexican_sofa/acts_as_tree',
  'comfortable_mexican_sofa/has_revisions',
  'comfortable_mexican_sofa/is_mirrored',
  'comfortable_mexican_sofa/tag',
  'comfortable_mexican_sofa/fixtures'
].each do |path|
  require File.expand_path(path, File.dirname(__FILE__))
end

Dir.glob(File.expand_path('comfortable_mexican_sofa/tags/*.rb', File.dirname(__FILE__))).each do |path|
  require path
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
    
    # Checking if Rails3.1+ asset pipeline is enabled
    def asset_pipeline_enabled?
      Rails::VERSION::MAJOR == 3 && Rails::VERSION::MINOR >= 1 && Rails.configuration.assets.enabled
    end
    
  end
end