# Loading engine only if this is not a standalone installation
unless defined? ComfortableMexicanSofa::Application
  require File.expand_path('comfortable_mexican_sofa/engine', File.dirname(__FILE__))
end

[ 'comfortable_mexican_sofa/version',
  'comfortable_mexican_sofa/error',
  'comfortable_mexican_sofa/configuration',
  'comfortable_mexican_sofa/authentication/http_auth',
  'comfortable_mexican_sofa/authentication/dummy_auth',
  'comfortable_mexican_sofa/render_methods',
  'comfortable_mexican_sofa/view_hooks',
  'comfortable_mexican_sofa/view_methods',
  'comfortable_mexican_sofa/form_builder',
  'comfortable_mexican_sofa/tag',
  'comfortable_mexican_sofa/sitemap',
  'comfortable_mexican_sofa/fixtures',
  'comfortable_mexican_sofa/extensions/rails',
  'comfortable_mexican_sofa/extensions/acts_as_tree',
  'comfortable_mexican_sofa/extensions/has_revisions',
  'comfortable_mexican_sofa/extensions/is_mirrored',
  'comfortable_mexican_sofa/extensions/is_categorized'
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
    
    # Establishing database connection if custom one is defined
    def establish_connection(klass)
      if ComfortableMexicanSofa.config.database_config && !Rails.env.test?
        klass.establish_connection "#{ComfortableMexicanSofa.config.database_config}_#{Rails.env}"
      end
    end

    def logger=(new_logger)
      @logger = new_logger
    end

    def logger
      @logger ||= Rails.logger
    end
    
  end
end
