# frozen_string_literal: true

require "comfortable_mexican_sofa"
require "rails"
require "rails-i18n"
require "comfy_bootstrap_form"
require "active_link_to"
require "kramdown"
require "jquery-rails"
require "haml-rails"
require "sassc-rails"

module ComfortableMexicanSofa
  class Engine < ::Rails::Engine

    initializer "comfortable_mexican_sofa.setup_assets" do
      ::ComfortableMexicanSofa::Engine.config.assets.precompile += %w[
        comfy/admin/cms/application.js
        comfy/admin/cms/application.css
        comfy/admin/cms/lib/redactor-font.eot
      ]
    end

    config.to_prepare do
      Dir.glob(Rails.root + "app/decorators/comfortable_mexican_sofa/*_decorator*.rb").each do |c|
        require_dependency(c)
      end
    end

  end
end
