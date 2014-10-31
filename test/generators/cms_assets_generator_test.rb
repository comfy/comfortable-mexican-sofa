require_relative '../test_helper'
require_relative '../../lib/generators/comfy/cms/assets_generator'

class CmsAssetsGeneratorTest < Rails::Generators::TestCase
  tests Comfy::Generators::Cms::AssetsGenerator

  def test_generator
    run_generator
    assert_directory 'app/assets/images/comfortable_mexican_sofa'
    assert_directory 'app/assets/javascripts/comfortable_mexican_sofa'
    assert_directory 'app/assets/stylesheets/comfortable_mexican_sofa'
  end
end