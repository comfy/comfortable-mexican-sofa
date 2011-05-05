class ComfortableMexicanSofa::Configuration
  
  # Don't like Comfortable Mexican Sofa? Set it to whatever you like. :(
  attr_accessor :cms_title
  
  # Module that will handle authentication to access cms-admin area
  attr_accessor :authentication
  
  # Default url to access admin area is http://yourhost/cms-admin/ 
  # You can change 'cms-admin' to 'admin', for example.
  attr_accessor :admin_route_prefix
  
  # Default url to content directly is http://yourhost/
  # You can change '' to 'preview', for example.
  attr_accessor :content_route_prefix
  
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
  
  # With each page load, files will be synched with the database. Database entries are
  # destroyed if there's no corresponding file. Fixtures are disabled by default.
  attr_accessor :enable_fixtures
  
  # Path where fixtures can be located.
  attr_accessor :fixtures_path
  
  # Configuration defaults
  def initialize
    @cms_title              = 'ComfortableMexicanSofa MicroCMS'
    @authentication         = 'ComfortableMexicanSofa::HttpAuth'
    @seed_data_path         = nil
    @admin_route_prefix     = 'cms-admin'
    @content_route_prefix   = ''
    @admin_route_redirect   = "/#{@admin_route_prefix}/pages"
    @enable_multiple_sites  = false
    @allow_irb              = false
    @enable_caching         = true
    @upload_file_options    = {}
    @enable_fixtures        = false
    @fixtures_path          = File.expand_path('db/cms_fixtures', Rails.root)
  end
  
end
