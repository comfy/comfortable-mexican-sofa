require_relative '../test_helper'
require_relative '../../lib/generators/comfy/scaffold/scaffold_generator'

class ScaffoldGeneratorTest < Rails::Generators::TestCase
  tests Comfy::Generators::ScaffoldGenerator
  
  def test_generator
    run_generator %w(Foo bar:string)
    
    assert_migration 'db/migrate/create_foos.rb', read_file('scaffold/migration.rb')
    assert_file 'app/models/foo.rb',              read_file('scaffold/model.rb')
    assert_file 'test/models/foo_test.rb',        read_file('scaffold/tests/model.rb')
    assert_file 'test/fixtures/foos.yml',         read_file('scaffold/tests/fixture')
    
    assert_file 'app/controllers/admin/foos_controller.rb',       read_file('scaffold/controller.rb')
    assert_file 'test/controllers/admin/foos_controller_test.rb', read_file('scaffold/tests/controller.rb')
    
    assert_file 'app/views/admin/foos/index.html.haml', read_file('scaffold/views/index.haml')
    assert_file 'app/views/admin/foos/show.html.haml',  read_file('scaffold/views/show.haml')
    assert_file 'app/views/admin/foos/new.html.haml',   read_file('scaffold/views/new.haml')
    assert_file 'app/views/admin/foos/edit.html.haml',  read_file('scaffold/views/edit.haml')
    assert_file 'app/views/admin/foos/_form.html.haml', read_file('scaffold/views/_form.haml')
    
    assert_file 'config/routes.rb', read_file('scaffold/routes.rb')
    
    assert_file 'app/views/admin/cms/partials/_navigation_inner.html.haml' do |file|
      assert_match "%li= active_link_to 'Foos', admin_foos_path", file
    end
  end
  
end