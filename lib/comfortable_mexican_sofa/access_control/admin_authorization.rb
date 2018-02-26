# frozen_string_literal: true

module ComfortableMexicanSofa::AccessControl
  module AdminAuthorization

    # By default there's no authorization of any kind
    def authorize
      true
    end

  end
end
