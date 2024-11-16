# frozen_string_literal: true

ComfortableMediaSurfer.configure do |config|
  # Title of the admin area
  #   config.cms_title = 'Comfy CMS Engine'

  # Controller that is inherited from CmsAdmin::BaseController
  #   config.admin_base_controller = 'ApplicationController'

  # Controller that Comfy::Cms::BaseController will inherit from
  #   config.public_base_controller = 'ApplicationController'

  # Module responsible for authentication. You can replace it with your own.
  # It simply needs to have #authenticate method. See http_auth.rb for reference.
  #   config.admin_auth = 'ComfyAdminAuthentication'

  # Module responsible for authorization on admin side. It should have #authorize
  # method that returns true or false based on params and loaded instance
  # variables available for a given controller.
  #   config.admin_authorization = 'ComfyAdminAuthorization'

  # Module responsible for public authentication. Similar to the above. You also
  # will have access to @cms_site, @cms_layout, @cms_page so you can use them in
  # your logic. Default module doesn't do anything.
  #   config.public_auth = 'ComfyPublicAuthentication'

  # Module responsible for public authorization. It should have #authorize
  # method that returns true or false based on params and loaded instance
  # variables available for a given controller.
  #   config.public_authorization = 'ComfyPublicAuthorization'

  # When arriving at /cms-admin you may chose to redirect to arbirtary path,
  # for example '/cms-admin/users'
  #   config.admin_route_redirect = ''

  # Sofa allows you to setup entire site from files. Database is updated with each
  # request (if necessary). Please note that database entries are destroyed if there's
  # no corresponding file. Seeds are disabled by default.
  #   config.enable_seeds = false

  # Path where seeds can be located.
  #   config.seeds_path = File.expand_path('db/cms_seeds', Rails.root)

  # Content for Layouts, Pages and Snippets has a revision history. You can revert
  # a previous version using this system. You can control how many revisions per
  # object you want to keep. Set it to 0 if you wish to turn this feature off.
  #   config.revisions_limit = 25

  # Locale definitions. If you want to define your own locale merge
  # {:locale => 'Locale Title'} with this.
  #   config.locales = {:en => 'English', :es => 'Español'}

  # Admin interface will respect the locale of the site being managed. However you can
  # force it to English by setting this to `:en`
  #   config.admin_locale = nil

  # A class that is included as a sweeper to admin base controller if it's set
  #   config.admin_cache_sweeper = nil

  # By default you cannot have irb code inside your layouts/pages/snippets.
  # Generally this is to prevent putting something like this:
  # <% User.delete_all %> but if you really want to allow it...
  #   config.allow_erb = false

  # Whitelist of all helper methods that can be used via {{cms:helper}} tag. By default
  # all helpers are allowed except `eval`, `send`, `call` and few others. Empty array
  # will prevent rendering of all helpers.
  #   config.allowed_helpers = nil

  # Whitelist of partials paths that can be used via {{cms:partial}} tag. All partials
  # are accessible by default. Empty array will prevent rendering of all partials.
  #   config.allowed_partials = nil

  # Site aliases, if you want to have aliases for your site. Good for harmonizing
  # production env with dev/testing envs.
  # e.g. config.hostname_aliases = {'host.com' => 'host.inv', 'host_a.com' => ['host.lvh.me', 'host.dev']}
  # Default is nil (not used)
  #   config.hostname_aliases = nil

  # Reveal partials that can be overwritten in the admin area.
  # Default is false.
  #   config.reveal_cms_partials = false
  #
  # Customize the returned content json data
  # include fragments in content json
  #   config.content_json_options = {
  #     include: [:fragments]
  #   }
end

# Default credentials for ComfortableMediaSurfer::AccessControl::AdminAuthentication
# YOU REALLY WANT TO CHANGE THIS BEFORE PUTTING YOUR SITE LIVE
ComfortableMediaSurfer::AccessControl::AdminAuthentication.username = 'user'
ComfortableMediaSurfer::AccessControl::AdminAuthentication.password = 'pass'

# Uncomment this module and `config.admin_auth` above to use custom admin authentication
# module ComfyAdminAuthentication
#   def authenticate
#     return true
#   end
# end

# Uncomment this module and `config.admin_authorization` above to use custom admin authorization
# module ComfyAdminAuthorization
#   def authorize
#     return true
#   end
# end

# Uncomment this module and `config.public_auth` above to use custom public authentication
# module ComfyPublicAuthentication
#   def authenticate
#     return true
#   end
# end

# Uncomment this module and `config.public_authorization` above to use custom public authorization
# module ComfyPublicAuthorization
#   def authorize
#     return true
#   end
# end
