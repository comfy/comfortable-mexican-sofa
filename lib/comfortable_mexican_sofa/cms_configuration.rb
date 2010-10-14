class ComfortableMexicanSofa::Configuration
  
  # Don't like Comfortable Mexican Sofa? Set it to whatever you like. :(
  attr_accessor :cms_title
  
  # Module that will handle authentication to access cms-admin area
  attr_accessor :authentication
  
  # Enable cms to manage multiple sites
  attr_accessor :multiple_sites
  
  # Configuration defaults
  def initialize
    @cms_title      = 'ComfortableMexicanSofa'
    @authentication = 'CmsAuthentication'
    @multiple_sites = false
  end
  
end