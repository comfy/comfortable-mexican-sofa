# Comfortable Mexican Sofa initializer. Change defaults to whatever you require

ComfortableMexicanSofa.configure do |config|
  config.cms_title      = 'ComfortableMexicanSofa'
  config.authentication = 'ComfortableMexicanSofa::HttpAuth'
end

# Credentials for CmsHttpAuthentication
ComfortableMexicanSofa::HttpAuth.username = 'username'
ComfortableMexicanSofa::HttpAuth.password = 'password'