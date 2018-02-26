# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../../lib/generators/comfy/cms/controllers_generator"

class CmsControllersGeneratorTest < Rails::Generators::TestCase

  tests Comfy::Generators::Cms::ControllersGenerator

  def test_generator
    run_generator
    assert_directory "app/controllers/comfy"
    assert_file "app/controllers/comfy/admin/cms/base_controller.rb"
  end

end
