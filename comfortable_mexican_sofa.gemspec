# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("lib", __dir__)
require "comfortable_mexican_sofa/version"

Gem::Specification.new do |s|
  s.name          = "comfortable_mexican_sofa"
  s.version       = ComfortableMexicanSofa::VERSION
  s.authors       = ["Oleg Khabarov"]
  s.email         = ["oleg@khabarov.ca"]
  s.homepage      = "http://github.com/comfy/comfortable-mexican-sofa"
  s.summary       = "Rails 5.2+ CMS Engine"
  s.description   = "ComfortableMexicanSofa is a powerful Rails 5.2+ CMS Engine"
  s.license       = "MIT"

  s.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|doc)/})
  end

  s.required_ruby_version = ">= 2.7.0"

  s.add_dependency "active_link_to",        "~> 1.0", ">= 1.0.5"
  s.add_dependency "comfy_bootstrap_form",  "~> 4.0", ">= 4.0.0"
  s.add_dependency "haml-rails",            "~> 2.1", ">= 2.1.0"
  s.add_dependency "image_processing",      "~> 1.2", ">= 1.12.2"
  s.add_dependency "jquery-rails",          "~> 4.6", ">= 4.6.0"
  s.add_dependency "kaminari",              "~> 1.2", ">= 1.2.2"
  s.add_dependency "kramdown",              "~> 2.4", ">= 2.4.0"
  s.add_dependency "mimemagic",             "~> 0.4", ">= 0.4.3"
  s.add_dependency "mini_magick",           "~> 4.12", ">= 4.12.0"
  s.add_dependency "rails",                 ">= 6.1.0"
  s.add_dependency "rails-i18n",            ">= 6.0.0"
  s.add_dependency "sassc-rails",           "~> 2.1", ">= 2.1.2"
  s.add_dependency "sprockets-rails",       "~> 3.4", ">= 3.4.2"
end
