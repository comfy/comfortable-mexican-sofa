# encoding: utf-8

class ComfortableMexicanSofa::Configuration
  
  # Don't like Comfortable Mexican Sofa? Set it to whatever you like. :(
  attr_accessor :cms_title
  
  # Module that will handle authentication to access cms-admin area
  attr_accessor :admin_auth
  
  # Module that will handle authentication for public pages
  attr_accessor :public_auth
  
  # Default url to access admin area is http://yourhost/cms-admin/ 
  # You can change 'cms-admin' to 'admin', for example.
  attr_accessor :admin_route_prefix
  
  # When arriving at /cms-admin you may chose to redirect to arbirtary path,
  # for example '/cms-admin/users'
  attr_accessor :admin_route_redirect
  
  # Not allowing irb code to be run inside page content. False by default.
  attr_accessor :allow_irb
  
  # Upload settings
  attr_accessor :upload_file_options
  
  # With each page load, files will be synched with the database. Database entries are
  # destroyed if there's no corresponding file. Fixtures are disabled by default.
  attr_accessor :enable_fixtures
  
  # Path where fixtures can be located.
  attr_accessor :fixtures_path
  
  # Number of revisions kept. Default is 25. If you wish to disable: set this to 0.
  attr_accessor :revisions_limit
  
  # Locale definitions. If you want to define your own locale merge
  # {:locale => 'Locale Title'} with this.
  attr_accessor :locales
  
  # Admin interface will respect the locale of the site being managed. However you can
  # force it to English by setting this to `:en`
  attr_accessor :admin_locale
  
  # Database prefix.  If you want to keep your comfortable mexican sofa tables
  # in a location other than the default databases add a database_config.
  # Setting this to `cms` will look for a cms_#{Rails.env} database definition
  # in your database.yml file
  attr_accessor :database_config
  
  # Configuration defaults
  def initialize
    @cms_title            = 'ComfortableMexicanSofa MicroCMS'
    @admin_auth           = 'ComfortableMexicanSofa::HttpAuth'
    @public_auth          = 'ComfortableMexicanSofa::DummyAuth'
    @seed_data_path       = nil
    @admin_route_prefix   = 'cms-admin'
    @admin_route_redirect = ''
    @allow_irb            = false
    @upload_file_options  = {}
    @enable_fixtures      = false
    @fixtures_path        = File.expand_path('db/cms_fixtures', Rails.root)
    @revisions_limit      = 25
    @locales              = { :en => 'English', :es => 'Español', 'pt-BR' => 'Brazilian Portuguese' }
    @admin_locale         = nil
    @database_config      = nil
  end
  
end
