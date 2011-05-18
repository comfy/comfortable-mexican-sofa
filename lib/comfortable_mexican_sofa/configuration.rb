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
  
  # Number of revisions kept. Default is 25. If you wish to disable: set this to 0.
  attr_accessor :revisions_limit
  
  # Enable multiple languages in a site via route (i.e. http://www.example.com/en, http://www.example.com/fr)
  attr_accessor :enable_multiple_language_routes
  
  # To which locale should non-locale routes be redirected?
  attr_accessor :default_locale
  
  # Configuration defaults
  def initialize
    @cms_title              = 'ComfortableMexicanSofa MicroCMS'
    @authentication         = 'ComfortableMexicanSofa::HttpAuth'
    @seed_data_path         = nil
    @admin_route_prefix     = 'cms-admin'
    @admin_route_redirect   = 'pages'
    @content_route_prefix   = ''
    @enable_multiple_sites  = false
    @allow_irb              = false
    @enable_caching         = true
    @upload_file_options    = {}
    @enable_fixtures        = false
    @fixtures_path          = File.expand_path('db/cms_fixtures', Rails.root)
    @revisions_limit        = 25
    @enable_multiple_language_routes = false
    @default_locale         = "en"
  end
  
end
