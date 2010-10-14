# Comfortable Mexican Sofa initializer. Change defaults to whatever you require

ComfortableMexicanSofa.configure do |config|
  config.cms_title      = 'ComfortableMexicanSofa'
  config.authentication = 'CmsHttpAuthentication'
end

# Credentials for CmsHttpAuthentication
CmsHttpAuthentication.username = 'username'
CmsHttpAuthentication.password = 'password'