# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../../lib/generators/comfy/cms/models_generator"

class CmsModelsGeneratorTest < Rails::Generators::TestCase

  tests Comfy::Generators::Cms::ModelsGenerator

  def test_generator
    run_generator
    assert_directory "app/models/comfy"
    assert_file "app/models/comfy/cms/page.rb"
  end

end
