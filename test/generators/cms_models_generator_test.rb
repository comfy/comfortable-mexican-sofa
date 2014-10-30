require_relative '../test_helper'
require_relative '../../lib/generators/comfy/cms/cms/cms_models_generator'

class CmsModelsGeneratorTest < Rails::Generators::TestCase
  tests Comfy::Generators::Cms::ModelsGenerator

  def test_generator
    run_generator
    assert_directory 'app/models/comfy'
  end
end