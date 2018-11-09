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

  s.required_ruby_version = ">= 2.3.0"

  s.add_dependency "active_link_to",        ">= 1.0.0"
  s.add_dependency "comfy_bootstrap_form",  ">= 4.0.0"
  s.add_dependency "haml-rails",            ">= 1.0.0"
  s.add_dependency "jquery-rails",          ">= 4.3.1"
  s.add_dependency "kramdown",              ">= 1.0.0"
  s.add_dependency "mimemagic",             ">= 0.3.2"
  s.add_dependency "mini_magick",           ">= 4.8.0"
  s.add_dependency "rails",                 ">= 5.2.0"
  s.add_dependency "rails-i18n",            ">= 5.0.0"
  s.add_dependency "sassc-rails",           ">= 2.0.0"
end
