# frozen_string_literal: true

require "comfortable_mexican_sofa"
require "rails"
require "rails-i18n"
require "bootstrap_form"
require "active_link_to"
require "kramdown"
require "jquery-rails"
require "haml-rails"
require "sass-rails"

module ComfortableMexicanSofa
  class Engine < ::Rails::Engine

    config.to_prepare do
      Dir.glob(Rails.root + "app/decorators/comfortable_mexican_sofa/*_decorator*.rb").each do |c|
        require_dependency(c)
      end
    end

  end
end
