[ 'comfortable_mexican_sofa/cms_engine',
  'comfortable_mexican_sofa/cms_configuration',
  'comfortable_mexican_sofa/cms_http_authentication',
  'comfortable_mexican_sofa/cms_rails_extensions',
  'comfortable_mexican_sofa/cms_form_builder',
  'comfortable_mexican_sofa/cms_acts_as_tree',
  '../app/models/cms_block',
  '../app/models/cms_snippet',
  'comfortable_mexican_sofa/cms_tag' 
].each do |path|
  require File.expand_path(path, File.dirname(__FILE__))
end

Dir.glob(File.expand_path('comfortable_mexican_sofa/cms_tag/*.rb', File.dirname(__FILE__))).each do |tag_path| 
  require tag_path
end

ActionView::Helpers::AssetTagHelper.register_javascript_expansion :cms => [
  'comfortable_mexican_sofa/jquery',
  'comfortable_mexican_sofa/jquery-ui',
  'comfortable_mexican_sofa/rails',
  'comfortable_mexican_sofa/cms',
  'comfortable_mexican_sofa/plupload/plupload.full.min',
  'comfortable_mexican_sofa/uploader'
]
ActionView::Helpers::AssetTagHelper.register_stylesheet_expansion :cms => [
  'comfortable_mexican_sofa/reset',
  'comfortable_mexican_sofa/structure',
  'comfortable_mexican_sofa/typography'
]

FILE_ICONS = Dir.glob(File.expand_path('public/images/cms/file_icons/*.png', Rails.root)).collect{|f| f.split('/').last.gsub('.png', '')}

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