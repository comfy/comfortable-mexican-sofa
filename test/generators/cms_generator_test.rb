# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../../lib/generators/comfy/cms/cms_generator"

class CmsGeneratorTest < Rails::Generators::TestCase

  tests Comfy::Generators::CmsGenerator

  def test_generator
    run_generator

    assert_migration "db/migrate/create_cms.rb"

    assert_file "config/initializers/comfortable_mexican_sofa.rb"

    assert_file "config/routes.rb", read_file("cms/routes.rb")

    assert_file "config/application.rb", read_file("cms/application.rb")

    assert_directory "db/cms_seeds"

    assert_file "app/assets/javascripts/comfy/admin/cms/custom.js"

    assert_file "app/assets/stylesheets/comfy/admin/cms/custom.sass"
  end

end
