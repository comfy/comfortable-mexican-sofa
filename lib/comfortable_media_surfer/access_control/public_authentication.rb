# frozen_string_literal: true

module ComfortableMediaSurfer::AccessControl
  module PublicAuthentication
    # By defaut all published pages are accessible
    def authenticate
      true
    end
  end
end
