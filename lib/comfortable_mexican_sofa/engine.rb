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
      # Add Bower asset paths
      root.join('vendor', 'assets', 'bower_components').to_s.tap do |bower_path|
        app.config.sass.load_paths << bower_path
        app.config.assets.paths << bower_path
      end
      # Precompile Bootstrap fonts
      app.config.assets.precompile << %r(comfortable_mexican_sofa/bootstrap-sass/assets/fonts/bootstrap/[\w-]+\.(?:eot|svg|ttf|woff)$)
      # Minimum precision required by bootstrap-sass
      ::Sass::Script::Number.precision = [10, ::Sass::Script::Number.precision].max
    end
  end
end
