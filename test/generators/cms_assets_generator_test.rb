# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../../lib/generators/comfy/cms/assets_generator"

class CmsAssetsGeneratorTest < Rails::Generators::TestCase

  tests Comfy::Generators::Cms::AssetsGenerator

  def test_generator
    run_generator
    assert_directory "app/assets/javascripts/comfy/admin/cms"
    assert_directory "app/assets/stylesheets/comfy/admin/cms"
  end

end
