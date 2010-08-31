require File.join(File.dirname(__FILE__), 'comfortable_mexican_sofa', 'cms_form_builder')

require File.join(File.dirname(__FILE__), '..', 'app', 'models', 'cms_block')
require File.join(File.dirname(__FILE__), 'comfortable_mexican_sofa', 'cms_tag')
Dir.glob(File.join(File.dirname(__FILE__), 'comfortable_mexican_sofa', 'cms_tag', '*.rb')).each do |tag| 
  require tag
end

module ComfortableMexicanSofa
  
  # TODO
  
end
