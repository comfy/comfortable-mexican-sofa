module Comfy
  module Generators
    module Cms
      class AssetsGenerator < Rails::Generators::Base
        source_root File.expand_path(File.join(File.dirname(__FILE__), '../../../../app/assets'))

        def generate_assets
          directory 'images/comfortable_mexican_sofa',      'app/assets/images/comfortable_mexican_sofa'
          directory 'javascripts/comfortable_mexican_sofa', 'app/assets/javascripts/comfortable_mexican_sofa'
          directory 'stylesheets/comfortable_mexican_sofa', 'app/assets/stylesheets/comfortable_mexican_sofa'
        end
      end
    end
  end
end