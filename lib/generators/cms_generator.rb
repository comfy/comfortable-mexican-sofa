require 'rails/generators'
require 'rails/generators/migration'

class CmsGenerator < Rails::Generators::Base
  include Rails::Generators::Migration
  include Thor::Actions
  source_root File.expand_path('../templates', __FILE__)

  def generate_migration
    empty_directory 'db/migrate'
    @cms_migration_number = 1
    %w(create_cms fix_children_count).each do |fix_migration|
      @cms_migration_number += 1
      begin
        migration_template "migrations/#{fix_migration}.rb", "db/migrate/#{fix_migration}.rb"
      rescue Rails::Generators::Error => e
        say_status :warning, "migration '#{fix_migration}' already exists - skipping", :red
      end
    end
  end

  def generate_stylesheets
    if defined?(Sass)
      sass_dir = Sass::Plugin.options[:template_location].gsub(Rails.root, '') 
      directory "stylesheets", sass_dir.gsub(/^\//,'')
    else
      say_status :warning, "HAML/SASS not installed", :red
    end
  end

  def generate_javascript
    directory 'javascripts', 'public/javascripts/cms'
  end

  def generate_initializers
    directory 'initializers', 'config/initializers'
  end
      
  def generate_images
    directory 'images', 'public/images/cms'
  end

  def show_readme
    readme 'README'
  end

  # Implement the required interface for Rails::Generators::Migration.
  # taken from http://github.com/rails/rails/blob/master/activerecord/lib/generators/active_record.rb
  def self.next_migration_number(dirname)
    ret = nil
    if ActiveRecord::Base.timestamped_migrations
      ret = Time.now.utc.strftime("%Y%m%d%H%M%S")
    else
      ret = "%.3d" % (current_migration_number(dirname) + 1)
    end

    while (Dir.entries(dirname).detect {|f| f.match /^#{ret}_/})
      ret = (ret.to_i + 1).to_s
    end

    return ret
  end

end

