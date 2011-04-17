[ 'comfortable_mexican_sofa/engine',
  'comfortable_mexican_sofa/configuration',
  'comfortable_mexican_sofa/http_auth',
  'comfortable_mexican_sofa/rails_extensions',
  'comfortable_mexican_sofa/controller_methods',
  'comfortable_mexican_sofa/view_hooks',
  'comfortable_mexican_sofa/view_methods',
  'comfortable_mexican_sofa/form_builder',
  'comfortable_mexican_sofa/acts_as_tree',
  'comfortable_mexican_sofa/cms_tag',
  'comfortable_mexican_sofa/fixtures'
].each do |path|
  require File.expand_path(path, File.dirname(__FILE__))
end

module ComfortableMexicanSofa
  class << self
    
    # Modify CMS configuration
    # Example:
    #   ComfortableMexicanSofa.configure do |config|
    #     config.cms_title = 'Comfortable Mexican Sofa'
    #   end
    def configure
      yield configuration
    end
    
    # Accessor for ComfortableMexicanSofa::Configuration
    def configuration
      @configuration ||= Configuration.new
    end
    alias :config :configuration
    
  end
end