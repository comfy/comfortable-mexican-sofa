module ComfortableMexicanSofa::HttpAuth
  # Set username and password in config/initializers/comfortable_mexican_sofa.rb
  # Like this:
  #   ComfortableMexicanSofa::HttpAuth.username = 'myname'
  #   ComfortableMexicanSofa::HttpAuth.password = 'mypassword'
  #
  # You can even use bcrypt (gem 'bcrypt-ruby'):
  #   require 'bcrypt'
  #   ComfortableMexicanSofa::HttpAuth.username = 'myname'
  #   ComfortableMexicanSofa::HttpAuth.password = BCrypt::Password.new '... bcrypt hash ...'
  # Create the bcrypt hash with:
  #   BCrypt::Password.create('password').to_s
  mattr_accessor  :username,
                  :password

  # Simple http_auth. When implementing some other form of authentication
  # this method should return +true+ if everything is great, or redirect user
  # to some other page, thus denying access to cms admin section.
  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      self.username == username && self.password == password
    end
  end

end
