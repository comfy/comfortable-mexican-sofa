ComfortableMexicanSofa.configure do |config|
  # Title of the admin area
  #   config.cms_title = 'ComfortableMexicanSofa MicroCMS'
  
  # Module responsible for authentication. You can replace it with your own.
  # It simply needs to have #authenticate method. See http_auth.rb for reference.
  #   config.authentication = 'ComfortableMexicanSofa::HttpAuth'
  
  # Default url to access admin area is http://yourhost/cms-admin/ 
  # You can change 'cms-admin' to 'admin', for example. To disable admin area
  # entirely set this to '' or nil
  #   config.admin_route_prefix = 'cms-admin'
  
  # By default Cms content is served directly from the root. Change this setting
  # if you wish to restrict all content to a section of your site.
  # To have root page served from http://yourhost/content/ set config below to 'content'
  #   config.content_route_prefix = ''
  
  # Path: /cms-admin redirects to /cms-admin/pages but you can change it
  #   config.admin_route_redirect = 'pages'
  
  # If you enable this setting you'll be able to serve completely different set
  # of sites with their own layouts and pages.
  #   config.enable_multiple_sites = true
  
  # In cases when you need sites with identical page tree structure, like different
  # language versions. This will automatically create/destroy resources across all sites and
  # will keep slugs/paths synced.
  #   config.enable_mirror_sites = true
  
  # By default you cannot have irb code inside your layouts/pages/snippets.
  # Generally this is to prevent putting something like this:
  # <% User.delete_all %> but if you really want to allow it...
  #   config.disable_irb = true
  
  # Asset caching for CSS and JS for admin layout. This setting also controls
  # page caching for CMS Layout CSS and Javascript. Enabled by default. When deploying
  # to an environment with read-only filesystem (like Heroku) turn this setting off.
  #   config.enable_caching = true
  
  # File uploads use Paperclip and can support filesystem or s3 uploads.  Override
  # the upload method and appropriate settings based on Paperclip.  For S3 see:
  # http://rdoc.info/gems/paperclip/2.3.8/Paperclip/Storage/S3, and for 
  # filesystem see: http://rdoc.info/gems/paperclip/2.3.8/Paperclip/Storage/S3
  #   config.upload_file_options = {:storage => :filesystem}
  
  # Sofa allows you to setup entire site from files. Database is updated with each
  # request (if nessesary). Please note that database entries are destroyed if there's
  # no corresponding file. Fixtures are disabled by default.
  #   config.enable_fixtures = false
  
  # Path where fixtures can be located.
  #   config.fixtures_path = File.expand_path('db/cms_fixtures', Rails.root)
  
  # Content for Layouts, Pages and Snippets has a revision history. You can revert
  # a previous version using this system. You can control how many revisions per
  # object you want to keep. Set it to 0 if you wish to turn this feature off.
  #   config.revisions_limit = 25
  
end

# Default credentials for ComfortableMexicanSofa::HttpAuth
# YOU REALLY WANT TO CHANGE THIS BEFORE PUTTING YOUR SITE LIVE
ComfortableMexicanSofa::HttpAuth.username = 'username'
ComfortableMexicanSofa::HttpAuth.password = 'password'

# If you need to inject some html in cms admin views you can define what partial
# should be rendered into the following areas:
#   ComfortableMexicanSofa::ViewHooks.add(:navigation, '/layouts/admin/navigation')
#   ComfortableMexicanSofa::ViewHooks.add(:html_head, '/layouts/admin/html_head')
#   ComfortableMexicanSofa::ViewHooks.add(:page_form, '/layouts/admin/page_form')