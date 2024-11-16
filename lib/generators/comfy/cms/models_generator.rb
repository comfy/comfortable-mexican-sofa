# frozen_string_literal: true

module Comfy
  module Generators
    module Cms
      class ModelsGenerator < Rails::Generators::Base
        source_root File.expand_path(File.join(File.dirname(__FILE__), '../../../../app/models'))

        def generate_models
          directory 'comfy', 'app/models/comfy'
        end
      end
    end
  end
end
