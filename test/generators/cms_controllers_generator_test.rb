require_relative '../test_helper'
require_relative '../../lib/generators/comfy/cms/cms/cms_controllers_generator'

class CmsControllersGeneratorTest < Rails::Generators::TestCase
  tests Comfy::Generators::Cms::ControllersGenerator

  def test_generator
    run_generator
    assert_directory 'app/controllers/comfy'
  end
end