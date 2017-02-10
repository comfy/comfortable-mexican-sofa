# encoding: utf-8

$:.unshift File.expand_path('../lib', __FILE__)
require 'comfortable_mexican_sofa/version'

Gem::Specification.new do |s|
  s.name          = "comfortable_mexican_sofa"
  s.version       = ComfortableMexicanSofa::VERSION
  s.authors       = ["Oleg Khabarov"]
  s.email         = ["oleg@khabarov.ca"]
  s.homepage      = "http://github.com/comfy/comfortable-mexican-sofa"
  s.summary       = "Rails 4 CMS Engine"
  s.description   = "ComfortableMexicanSofa is a powerful Rails 4 CMS Engine"
  s.license       = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.platform      = Gem::Platform::RUBY
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 1.9.3'

  s.add_dependency 'rails',             '>= 4.0.0', '<= 4.1.16'
  s.add_dependency 'rails-i18n',        '~> 4.0.0'
  s.add_dependency 'i18n',              '~> 0.7'
  s.add_dependency 'bootstrap_form',    '~> 2.1.1'
  s.add_dependency 'active_link_to',    '>= 1.0.0'
  s.add_dependency 'paperclip',         '>= 4.0.0'
  s.add_dependency 'kramdown',          '>= 1.13'
  s.add_dependency 'jquery-rails',      '>= 3.0.0'
  s.add_dependency 'jquery-ui-rails',   '>= 5.0.0'
  s.add_dependency 'haml-rails',        '>= 0.3.0'
  s.add_dependency 'sass-rails',        '>= 4.0.3'
  s.add_dependency 'coffee-rails',      '>= 3.1.0'
  s.add_dependency 'codemirror-rails',  '>= 3.0.0'
  s.add_dependency 'kaminari',          '>= 0.14.0'
  s.add_dependency 'tinymce-rails',     '>= 4.0.0'
  s.add_dependency 'bootstrap-sass',    '~> 3.1.0'
  s.add_dependency 'transitions',       '>= 0.1.12'

  s.add_development_dependency 'pry-rails'
end
