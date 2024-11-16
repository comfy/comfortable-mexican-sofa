# frozen_string_literal: true

require 'rails/generators/generated_attribute'
require 'rails/generators/active_record'

module Comfy
  module Generators
    class ScaffoldGenerator < Rails::Generators::NamedBase
      include Rails::Generators::Migration

      no_tasks do
        attr_accessor :model_attrs
      end

      source_root File.expand_path(File.join(File.dirname(__FILE__), 'templates'))

      argument :model_args, type: :array, default: [], banner: 'attribute:type'

      def initialize(*args, &)
        super
        @model_attrs = []
        model_args.each do |arg|
          next unless arg.include?(':')

          @model_attrs << Rails::Generators::GeneratedAttribute.new(*arg.split(':'))
        end
      end

      def self.next_migration_number(dirname)
        ActiveRecord::Generators::Base.next_migration_number(dirname)
      end

      def generate_model
        migration_template 'migration.rb', "db/migrate/create_#{file_name.pluralize}.rb"
        template 'model.rb', "app/models/#{file_name}.rb"
        template 'tests/model.rb', "test/models/#{file_name}_test.rb"
        template 'tests/fixture.yml', "test/fixtures/#{file_name.pluralize}.yml"
      end

      def generate_controller
        template 'controller.rb', "app/controllers/admin/#{file_name.pluralize}_controller.rb"
        template 'tests/controller.rb', "test/controllers/admin/#{file_name.pluralize}_controller_test.rb"
      end

      def generate_views
        template 'views/index.haml', "app/views/admin/#{file_name.pluralize}/index.html.haml"
        template 'views/show.haml', "app/views/admin/#{file_name.pluralize}/show.html.haml"
        template 'views/new.haml', "app/views/admin/#{file_name.pluralize}/new.html.haml"
        template 'views/edit.haml', "app/views/admin/#{file_name.pluralize}/edit.html.haml"
        template 'views/_form.haml', "app/views/admin/#{file_name.pluralize}/_form.html.haml"
      end

      def generate_route
        route_string = <<~TEXT
          namespace :admin do
            resources :#{file_name.pluralize}
          end

        TEXT
        route route_string
      end

      def generate_navigation_link
        partial_path = 'app/views/comfy/admin/cms/partials/_navigation_inner.html.haml'

        unless File.exist?(File.join(destination_root, partial_path))
          create_file partial_path
        end

        append_file partial_path do
          <<~HAML
            %li.nav-item
              = active_link_to '#{class_name.pluralize}', admin_#{file_name.pluralize}_path, class: 'nav-link'
          HAML
        end
      end
    end
  end
end
