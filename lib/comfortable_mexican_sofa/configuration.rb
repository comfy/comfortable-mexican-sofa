# encoding: utf-8

class ComfortableMexicanSofa::Configuration

  # Don't like ComfortableMexicanSofa? Set it to whatever you like. :(
  attr_accessor :cms_title

  # Controller that is inherited from CmsAdmin::BaseController
  # 'ApplicationController' is the default
  attr_accessor :base_controller

  # Module that will handle authentication to access cms-admin area
  attr_accessor :admin_auth

  # Module that will handle authorization against admin cms resources
  attr_accessor :admin_authorization

  # Module that will handle authentication for public pages
  attr_accessor :public_auth

  # Module that will handle authorization against public resources
  attr_accessor :public_authorization

  # When arriving at /cms-admin you may chose to redirect to arbirtary path,
  # for example '/cms-admin/users'
  attr_accessor :admin_route_redirect

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

  # A class that is included as a sweeper to admin base controller if it's set
  attr_accessor :admin_cache_sweeper

  # Not allowing irb code to be run inside page content. False by default.
  attr_accessor :allow_irb

  # Whitelist of all helper methods that can be used via {{cms:helper}} tag. By default
  # all helpers are allowed except `eval`, `send`, `call` and few others. Empty array
  # will prevent rendering of all helpers.
  attr_accessor :allowed_helpers

  # Whitelist of partials paths that can be used via {{cms:partial}} tag. All partials
  # are accessible by default. Empty array will prevent rendering of all partials.
  attr_accessor :allowed_partials

  # Whitelist of template paths that can be used via {{cms:template}} tag. All templates
  # are accessible by default. Empty array will prevent rendering of all templates.
  attr_accessor :allowed_templates

  # Site aliases, if you want to have aliases for your site. Good for harmonizing
  # production env with dev/testing envs.
  # e.g. config.site_aliases = {'host.com' => 'host.inv', 'host_a.com' => ['host.lvh.me', 'host.dev']}
  # Default is nil (not used)
  attr_accessor :hostname_aliases

  # Reveal partials that can be overwritten in the admin area.
  # Default is false.
  attr_accessor :reveal_cms_partials

  # Auto-setting parameter derived from the routes
  attr_accessor :public_cms_path

  # Configuration defaults
  def initialize
    @cms_title            = 'ComfortableMexicanSofa CMS Engine'
    @base_controller      = 'ApplicationController'
    @admin_auth           = 'ComfortableMexicanSofa::AccessControl::AdminAuthentication'
    @admin_authorization  = 'ComfortableMexicanSofa::AccessControl::AdminAuthorization'
    @public_auth          = 'ComfortableMexicanSofa::AccessControl::PublicAuthentication'
    @public_authorization = 'ComfortableMexicanSofa::AccessControl::PublicAuthorization'
    @seed_data_path       = nil
    @admin_route_redirect = ''
    @enable_sitemap       = true
    @upload_file_options  = { }
    @enable_fixtures      = false
    @fixtures_path        = File.expand_path('db/cms_fixtures', Rails.root)
    @revisions_limit      = 25
    @locales              = {
      'cs'    => 'Česky',
      'da'    => 'Dansk',
      'de'    => 'Deutsch',
      'en'    => 'English',
      'es'    => 'Español',
      'fr'    => 'Français',
      'it'    => 'Italiano',
      'ja'    => '日本語',
      'nb'    => 'Norsk',
      'nl'    => 'Nederlands',
      'pl'    => 'Polski',
      'pt-BR' => 'Português Brasileiro',
      'ru'    => 'Русский',
      'sv'    => 'Svenska',
      'uk'    => 'Українська',
      'zh-CN' => '简体中文',
      'zh-TW' => '正體中文'
    }
    @admin_locale         = nil
    @admin_cache_sweeper  = nil
    @allow_irb            = false
    @allowed_helpers      = nil
    @allowed_partials     = nil
    @hostname_aliases     = nil
    @reveal_cms_partials  = false
    @public_cms_path      = nil
  end

end
