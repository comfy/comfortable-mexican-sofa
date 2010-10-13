class CmsGenerator < Rails::Generators::Base
  
  include Rails::Generators::Migration
  include Thor::Actions
  
  source_root File.expand_path('../../..', __FILE__)
  
  def generate_migration
    migration_template 'db/migrate/01_create_cms.rb', 'db/migrate/create_cms.rb'
  end
  
  def self.next_migration_number(dirname)
    orm = Rails.configuration.generators.options[:rails][:orm]
    require "rails/generators/#{orm}"
    "#{orm.to_s.camelize}::Generators::Base".constantize.next_migration_number(dirname)
  end
  
end