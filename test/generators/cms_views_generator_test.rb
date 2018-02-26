# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../../lib/generators/comfy/cms/views_generator"

class CmsViewsGeneratorTest < Rails::Generators::TestCase

  tests Comfy::Generators::Cms::ViewsGenerator

  def test_generator
    run_generator
    assert_directory "app/views/comfy"
    assert_file "app/views/comfy/admin/cms/pages/index.html.haml"
  end

end
