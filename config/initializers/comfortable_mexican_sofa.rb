# encoding: utf-8

ComfortableMexicanSofa.configure do |config|
  # Title of the admin area
  #   config.cms_title = 'ComfortableMexicanSofa MicroCMS'
  
  # Module responsible for authentication. You can replace it with your own.
  # It simply needs to have #authenticate method. See http_auth.rb for reference.
  #   config.admin_auth = 'ComfortableMexicanSofa::HttpAuth'
  
  # Module responsible for public authentication. Similar to the above. You also
  # will have access to @cms_site, @cms_layout, @cms_page so you can use them in
  # your logic. Default module doesn't do anything.
  #   config.public_auth = 'ComfortableMexicanSofa::DummyAuth'
  
  # Default url to access admin area is http://yourhost/cms-admin/ 
  # You can change 'cms-admin' to 'admin', for example. To disable admin area
  # entirely set this to '' or nil
  #   config.admin_route_prefix = 'cms-admin'
  
  # When arriving at /cms-admin you may chose to redirect to arbirtary path,
  # for example '/cms-admin/users'
  #   config.admin_route_redirect = ''
  
  # By default you cannot have irb code inside your layouts/pages/snippets.
  # Generally this is to prevent putting something like this:
  # <% User.delete_all %> but if you really want to allow it...
  #   config.allow_irb = false
  
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
  
  # Locale definitions. If you want to define your own locale merge
  # {:locale => 'Locale Title'} with this.
  #   config.locales = {:en => 'English', :es => 'Español'}
  
  # Admin interface will respect the locale of the site being managed. However you can
  # force it to English by setting this to `:en`
  #   config.admin_locale = nil
  
  # Database prefix.  If you want to keep your comfortable mexican sofa tables
  # in a location other than the default databases add a database_config.
  # Using a prefix of `cms_` will look for a cms_#{Rails.env} definition
  # in your database.yml file
  #   config.database_config = nil
  
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