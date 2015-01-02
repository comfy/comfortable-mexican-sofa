require_relative '../test_helper'
require_relative '../../lib/generators/comfy/cms/cms_generator'

class CmsGeneratorTest < Rails::Generators::TestCase
  tests Comfy::Generators::CmsGenerator

  def test_generator
    run_generator

    assert_migration 'db/migrate/create_cms.rb'

    assert_file 'config/initializers/comfortable_mexican_sofa.rb'
    assert_file 'config/initializers/mime_types.rb' do |file|
      mime = "Mime::Type.register 'text/plupload', :plupload unless Mime::Type.lookup_by_extension(:plupload)"
      assert_match mime, file
    end

    assert_file 'config/routes.rb', read_file('cms/routes.rb')

    assert_directory 'db/cms_fixtures'

    assert_file 'app/assets/javascripts/comfortable_mexican_sofa/admin/application.js'

    assert_file 'app/assets/stylesheets/comfortable_mexican_sofa/admin/application.css'
  end
end