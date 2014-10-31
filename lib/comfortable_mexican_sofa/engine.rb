require 'rubygems'
require 'comfortable_mexican_sofa'
require 'rails'
require 'rails-i18n'
require 'bootstrap_form'
require 'active_link_to'
require 'paperclip'
require 'kramdown'
require 'jquery-rails'
require 'jquery-ui-rails'
require 'haml-rails'
require 'sass-rails'
require 'coffee-rails'
require 'codemirror-rails'
require 'kaminari'
require 'tinymce-rails'
require 'plupload-rails'

module ComfortableMexicanSofa
  class Engine < ::Rails::Engine
    # Configure asset lookup
    initializer 'comfortable-mexican-sofa.assets' do |app|
      # Add bootstrap-sass asset paths
      app.root.join('vendor/assets/bower_components/bootstrap-sass/assets').tap do |path|
        app.config.sass.load_paths << path.join('stylesheets')
        app.config.assets.paths += %w(javascripts fonts images).map(&path.method(:join))
      end
      # Minimum precision required by bootstrap-sass
      ::Sass::Script::Number.precision = [10, ::Sass::Script::Number.precision].max
    end
  end
end
