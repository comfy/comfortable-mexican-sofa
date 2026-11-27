# frozen_string_literal: true

require "comfortable_mexican_sofa"
require "rails"
require "image_processing"
require "commonmarker"
require "view_component"
require "inline_svg"
require "active_link_to"


require "rails-i18n"
require "comfy_bootstrap_form"
# require "jquery-rails"
require "haml-rails"
# require "sassc-rails"

module ComfortableMexicanSofa
  class Engine < ::Rails::Engine
    initializer "comfy.assets" do |app|
      if app.config.respond_to?(:assets)
        app.config.assets.paths << root.join("app/javascript")
      end
    end

    initializer "comfy.importmap", before: "importmap" do |app|
      if app.config.respond_to?(:importmap)
        app.config.importmap.paths << root.join("config/importmap.rb")
        app.config.importmap.cache_sweepers << root.join("app/javascript")
      end
    end

    config.to_prepare do
      Dir.glob(Rails.root + "app/decorators/comfortable_mexican_sofa/*_decorator*.rb").each do |c|
        require_dependency(c)
      end
    end
  end
end
