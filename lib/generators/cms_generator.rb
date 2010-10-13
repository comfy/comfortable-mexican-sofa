class CmsGenerator < Rails::Generators::Base
  
  include Rails::Generators::Migration
  include Thor::Actions
  
  source_root File.expand_path('../../..', __FILE__)
  
  def generate_migration
    migration_template 'db/migrate/01_create_cms.rb', 'db/migrate/create_cms.rb'
  end
  
  def generate_public_assets
    directory 'public/stylesheets/comfortable_mexican_sofa', 'public/stylesheets/comfortable_mexican_sofa'
    directory 'public/javascripts/comfortable_mexican_sofa', 'public/javascripts/comfortable_mexican_sofa'
    directory 'public/images/comfortable_mexican_sofa', 'public/images/comfortable_mexican_sofa'
  end
  
  def show_readme
    readme 'lib/generators/README'
  end
  
  def self.next_migration_number(dirname)
    orm = Rails.configuration.generators.options[:rails][:orm]
    require "rails/generators/#{orm}"
    "#{orm.to_s.camelize}::Generators::Base".constantize.next_migration_number(dirname)
  end
  
end