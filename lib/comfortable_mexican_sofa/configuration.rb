class ComfortableMexicanSofa::Configuration
  
  # Don't like Comfortable Mexican Sofa? Set it to whatever you like. :(
  attr_accessor :cms_title
  
  # Module that will handle authentication to access cms-admin area
  attr_accessor :authentication
  
  # Location of YAML files that can be used to render pages instead of pulling
  # data from the database. Not active if not specified.
  attr_accessor :seed_data_path
  
  # Default url to access admin area is http://yourhost/cms-admin/ 
  # You can change 'cms-admin' to 'admin', for example.
  attr_accessor :admin_route_prefix
  
  # /cms-admin redirects to /cms-admin/pages but you can change it
  # to something else
  attr_accessor :admin_route_redirect
  
  # Are you running multiple sites from single install? Default assumption is 'No'
  attr_accessor :enable_multiple_sites
  
  # Not allowing irb code to be run inside page content. False by default.
  attr_accessor :allow_irb
  
  # Caching for css/js. For admin layout and ones for cms content. Enabled by default.
  attr_accessor :enable_caching
  
  # Upload settings
  attr_accessor :upload_file_options
  
  # Configuration defaults
  def initialize
    @cms_title              = 'ComfortableMexicanSofa MicroCMS'
    @authentication         = 'ComfortableMexicanSofa::HttpAuth'
    @seed_data_path         = nil
    @admin_route_prefix     = 'cms-admin'
    @admin_route_redirect   = "/#{@admin_route_prefix}/pages"
    @enable_multiple_sites  = false
    @allow_irb              = false
    @enable_caching         = true
    @upload_file_options    = {}
  end
  
end
