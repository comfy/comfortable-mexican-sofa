module ComfortableMexicanSofa::AccessControl
  module PublicAuthentication
    # By defaut all published pages are accessible
    def authenticate
      true
    end
  end
end