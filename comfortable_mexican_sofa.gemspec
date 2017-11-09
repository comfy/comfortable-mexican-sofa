# encoding: utf-8

$:.unshift File.expand_path('../lib', __FILE__)
require 'comfortable_mexican_sofa/version'

Gem::Specification.new do |s|
  s.name          = "comfortable_mexican_sofa"
  s.version       = ComfortableMexicanSofa::VERSION
  s.authors       = ["Oleg Khabarov"]
  s.email         = ["oleg@khabarov.ca"]
  s.homepage      = "http://github.com/comfy/comfortable-mexican-sofa"
  s.summary       = "Rails 5 CMS Engine"
  s.description   = "ComfortableMexicanSofa is a powerful Rails 5 CMS Engine"
  s.license       = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.platform      = Gem::Platform::RUBY
  s.require_paths = ['lib']

  s.required_ruby_version = ">= 2.2.2"

  # s.add_dependency "rails",             ">= 5.2.0"
  # s.add_dependency "bootstrap_form",    ">= 2.7.0"

  s.add_dependency "bootstrap",           ">= 4.0.0.beta2.1"
  s.add_dependency "mini_magick",         ">= 4.8.0"
  s.add_dependency "mimemagic",           ">= 0.3.2"
  s.add_dependency "jquery-rails",        ">= 4.3.1"
  s.add_dependency "jquery-ui-rails",     ">= 6.0.1"
  s.add_dependency "codemirror-rails",    ">= 5.16.0"
  s.add_dependency "font-awesome-rails",  ">= 4.7.0"

  s.add_dependency 'rails-i18n',        '>= 4.0.0'

  s.add_dependency 'active_link_to',    '>= 1.0.0'
  s.add_dependency 'kramdown',          '>= 1.0.0'


  s.add_dependency 'haml-rails',        '>= 0.3.0'
  s.add_dependency 'sass-rails',        '>= 4.0.3'
  s.add_dependency 'coffee-rails',      '>= 3.1.0'

  s.add_dependency 'plupload-rails',    '>= 1.2.1'

end
