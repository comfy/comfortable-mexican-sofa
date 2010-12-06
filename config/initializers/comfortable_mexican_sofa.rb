ComfortableMexicanSofa.configure do |config|
  # Title of the admin area
  config.cms_title      = 'ComfortableMexicanSofa'
  
  # Module responsible for authentication. You can replace it with your own.
  # It simply needs to have #authenticate method. See http_auth.rb for reference.
  config.authentication = 'ComfortableMexicanSofa::HttpAuth'
  
  # Default url to access admin area is http://yourhost/cms-admin/ 
  # You can change 'cms-admin' to 'admin', for example.
  #   config.admin_route_prefix = 'cms-admin'
  
  # Path: /cms-admin redirects to /cms-admin/pages but you can change it
  # to something else like:
  #   config.admin_route_redirect = '/cms-admin/pages'
  
  # Location of YAML files that can be used to render pages instead of pulling
  # data from the database. Not active if not specified.
  #   config.seed_data_path = File.expand_path('db/cms_seeds', Rails.root)
end

# Default credentials for ComfortableMexicanSofa::HttpAuth
ComfortableMexicanSofa::HttpAuth.username = 'username'
ComfortableMexicanSofa::HttpAuth.password = 'password'

# If you need to inject some html in cms admin views you can define what partial
# should be rendered into the following areas:
#   ComfortableMexicanSofa::ViewHooks.add(:navigation, '/layouts/admin/navigation')
#   ComfortableMexicanSofa::ViewHooks.add(:html_head, '/layouts/admin/html_head')
#   ComfortableMexicanSofa::ViewHooks.add(:page_form, '/layouts/admin/page_form')