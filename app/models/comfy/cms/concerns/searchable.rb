module Comfy::Cms::Concerns::Searchable
  extend ActiveSupport::Concern

  module ClassMethods

    def search(scope, target)
      method(scope).call(target)
    end

  end
end
