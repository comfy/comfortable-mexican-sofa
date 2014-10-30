require_relative '../test_helper'
require_relative '../../lib/generators/comfy/cms/cms/cms_views_generator'

class CmsViewsGeneratorTest < Rails::Generators::TestCase
  tests Comfy::Generators::Cms::ViewsGenerator

  def test_generator
    run_generator
    assert_directory 'app/views/comfy'
  end
end