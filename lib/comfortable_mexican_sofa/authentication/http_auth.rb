module ComfortableMexicanSofa::HttpAuth
  # Set username and password in config/initializers/comfortable_mexican_sofa.rb
  # Like this:
  #   ComfortableMexicanSofa::HttpAuth.username = 'myname'
  #   ComfortableMexicanSofa::HttpAuth.password = 'mypassword'
  mattr_accessor  :username,
                  :password
  
  # Simple http_auth. When implementing some other form of authentication
  # this method should return +true+ if everything is great, or redirect user
  # to some other page, thus denying access to cms admin section.
  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == self.username && password == self.password
    end
  end
  
end
