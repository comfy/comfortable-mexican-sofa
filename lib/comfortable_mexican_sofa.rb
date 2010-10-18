# Loading engine only if this is not a standalone installation
unless defined? ComfortableMexicanSofa::Application
  require File.expand_path('comfortable_mexican_sofa/engine', File.dirname(__FILE__))
end

[ 'comfortable_mexican_sofa/configuration',
  'comfortable_mexican_sofa/http_auth',
  'comfortable_mexican_sofa/rails_extensions',
  'comfortable_mexican_sofa/view_methods',
  'comfortable_mexican_sofa/form_builder',
  'comfortable_mexican_sofa/acts_as_tree',
  '../app/models/cms_block',
  '../app/models/cms_snippet',
  'comfortable_mexican_sofa/cms_tag' 
].each do |path|
  require File.expand_path(path, File.dirname(__FILE__))
end

Dir.glob(File.expand_path('comfortable_mexican_sofa/cms_tag/*.rb', File.dirname(__FILE__))).each do |tag_path| 
  require tag_path
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