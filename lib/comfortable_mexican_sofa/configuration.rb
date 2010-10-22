class ComfortableMexicanSofa::Configuration
  
  # Don't like Comfortable Mexican Sofa? Set it to whatever you like. :(
  attr_accessor :cms_title
  
  # Module that will handle authentication to access cms-admin area
  attr_accessor :authentication
  
  # Location of YAML files that can be used to render pages instead of pulling
  # data from the database. Not active if not specified.
  attr_accessor :seed_data_path
  
  # Configuration defaults
  def initialize
    @cms_title        = 'ComfortableMexicanSofa'
    @authentication   = 'ComfortableMexicanSofa::HttpAuth'
    @seed_data_path   = nil
  end
  
end