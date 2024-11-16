# frozen_string_literal: true

module Comfy
  module Generators
    module Cms
      class ControllersGenerator < Rails::Generators::Base
        source_root File.expand_path(File.join(File.dirname(__FILE__), '../../../../app/controllers'))

        def generate_controllers
          directory 'comfy', 'app/controllers/comfy'
        end
      end
    end
  end
end
