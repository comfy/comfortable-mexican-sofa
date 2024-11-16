# frozen_string_literal: true

module Comfy
  module Generators
    module Cms
      class AssetsGenerator < Rails::Generators::Base
        source_root File.expand_path(File.join(File.dirname(__FILE__), '../../../../app/assets'))

        def generate_assets
          directory 'javascripts/comfy/admin/cms', 'app/assets/javascripts/comfy/admin/cms'
          directory 'stylesheets/comfy/admin/cms', 'app/assets/stylesheets/comfy/admin/cms'
        end
      end
    end
  end
end
