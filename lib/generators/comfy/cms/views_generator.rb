# frozen_string_literal: true

module Comfy
  module Generators
    module Cms
      class ViewsGenerator < Rails::Generators::Base
        source_root File.expand_path(File.join(File.dirname(__FILE__), '../../../../app/views'))

        def generate_views
          directory 'comfy', 'app/views/comfy'
        end
      end
    end
  end
end
