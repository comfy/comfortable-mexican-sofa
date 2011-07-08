class CmsGenerator < Rails::Generators::Base
  
  require 'rails/generators/active_record'
  include Rails::Generators::Migration
  include Thor::Actions
  
  source_root File.expand_path('../../..', __FILE__)
  
  def generate_migration
    destination   = File.expand_path('db/migrate/01_create_cms.rb', self.destination_root)
    migration_dir = File.dirname(destination)
    destination   = self.class.migration_exists?(migration_dir, 'create_cms')
    
    if destination
      puts "\e[0m\e[31mFound existing cms_create.rb migration. Remove it if you want to regenerate.\e[0m"
    else
      migration_template 'db/migrate/01_create_cms.rb', 'db/migrate/create_cms.rb'
    end
  end
  
  def generate_initialization
    copy_file 'config/initializers/comfortable_mexican_sofa.rb', 'config/initializers/comfortable_mexican_sofa.rb'
  end
  
  def generate_public_assets
    return if ComfortableMexicanSofa.asset_pipeline_enabled?
    directory 'app/assets/stylesheets/comfortable_mexican_sofa',  'public/stylesheets/comfortable_mexican_sofa'
    directory 'app/assets/javascripts/comfortable_mexican_sofa',  'public/javascripts/comfortable_mexican_sofa'
    directory 'app/assets/images/comfortable_mexican_sofa',       'public/images/comfortable_mexican_sofa'
    
    gsub_file 'public/stylesheets/comfortable_mexican_sofa/content.css',
      '/assets/comfortable_mexican_sofa/', '/images/comfortable_mexican_sofa/'
    gsub_file 'public/stylesheets/comfortable_mexican_sofa/widgets.css',
      '/assets/comfortable_mexican_sofa/', '/images/comfortable_mexican_sofa/'
    gsub_file 'public/stylesheets/comfortable_mexican_sofa/jquery_ui.css',
      '/assets/comfortable_mexican_sofa/', '/images/comfortable_mexican_sofa/'
  end
  
  def generate_cms_seeds
    directory 'db/cms_fixtures', 'db/cms_fixtures'
  end
  
  def show_readme
    readme 'lib/generators/README'
  end
  
  def self.next_migration_number(dirname)
    ActiveRecord::Generators::Base.next_migration_number(dirname)
  end
  
end