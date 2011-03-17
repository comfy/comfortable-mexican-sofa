ComfortableMexicanSofa.configure do |config|
  # Title of the admin area
  config.cms_title      = 'ComfortableMexicanSofa MicroCMS'
  
  # Module responsible for authentication. You can replace it with your own.
  # It simply needs to have #authenticate method. See http_auth.rb for reference.
  config.authentication = 'ComfortableMexicanSofa::HttpAuth'
  
  # Default url to access admin area is http://yourhost/cms-admin/ 
  # You can change 'cms-admin' to 'admin', for example.
  #   config.admin_route_prefix = 'cms-admin'
  
  # Path: /cms-admin redirects to /cms-admin/pages but you can change it
  # You don't need to change it when changing admin_route_prefix
  #   config.admin_route_redirect = '/cms-admin/pages'
  
  # Location of YAML files that can be used to render pages instead of pulling
  # data from the database. Not active if not specified. Containing folder name
  # should be the hostname of the site. Example: my-app.local
  #   config.seed_data_path = File.expand_path('db/cms_seeds', Rails.root)
  
  # Let CMS handle site creation and management. Enabled by default.
  #   config.auto_manage_sites = true
  
  # By default you cannot have irb code inside your layouts/pages/snippets.
  # Generally this is to prevent putting something like this:
  # <% User.delete_all %> but if you really want to allow it...
  #   config.disable_irb = true
  
  # Asset caching for CSS and JS for admin layout. This setting also controls
  # page caching for CMS Layout CSS and Javascript. Enabled by default. When deploying
  # to an environment with read-only filesystem (like Heroku) turn this setting off.
  #   config.enable_caching = true

  # Override the host used to look up the active CmsSite.  If you are not
  # planning on using the site features, I recommend you set this override to
  # limit unexpected "Site not found" errors when you try to hit app01.example.com
  # instead of www.example.com.
  #   config.override_host = "www.exmample.com"
end

# Default credentials for ComfortableMexicanSofa::HttpAuth
ComfortableMexicanSofa::HttpAuth.username = 'username'
ComfortableMexicanSofa::HttpAuth.password = 'password'

# If you need to inject some html in cms admin views you can define what partial
# should be rendered into the following areas:
#   ComfortableMexicanSofa::ViewHooks.add(:navigation, '/layouts/admin/navigation')
#   ComfortableMexicanSofa::ViewHooks.add(:html_head, '/layouts/admin/html_head')
#   ComfortableMexicanSofa::ViewHooks.add(:page_form, '/layouts/admin/page_form')