# frozen_string_literal: true

module ComfortableMediaSurfer::AccessControl
  module AdminAuthorization
    # By default there's no authorization of any kind
    def authorize
      true
    end
  end
end
