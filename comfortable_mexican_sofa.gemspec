# encoding: utf-8

$:.unshift File.expand_path('../lib', __FILE__)
require 'comfortable_mexican_sofa/version'

Gem::Specification.new do |s|
  s.name          = "comfortable_mexican_sofa"
  s.version       = ComfortableMexicanSofa::VERSION
  s.authors       = ["Oleg Khabarov", "The Working Group Inc"]
  s.email         = ["oleg@khabarov.ca"]
  s.homepage      = "http://github.com/comfy/comfortable-mexican-sofa"
  s.summary       = "CMS Engine for Rails 4 apps"
  s.description   = "ComfortableMexicanSofa is a powerful CMS Engine for Ruby on Rails applications"
  s.license       = 'MIT'
  
  s.files         = `git ls-files`.split("\n")
  s.platform      = Gem::Platform::RUBY
  s.require_paths = ['lib']
  
  s.add_dependency 'rails',             '~> 4.0'
  s.add_dependency 'formatted_form',    '>= 2.1.0'
  s.add_dependency 'active_link_to',    '>= 1.0.0'
  s.add_dependency 'paperclip',         '>= 3.4.0'
  s.add_dependency 'kramdown',          '>= 1.0.0'
  s.add_dependency 'jquery-rails',      '>= 3.0.0'
  s.add_dependency 'jquery-ui-rails',   '>= 4.0.0'
  s.add_dependency 'haml-rails',        '>= 0.3.0'
  s.add_dependency 'sass-rails',        '>= 3.1.0'
  s.add_dependency 'coffee-rails',      '>= 3.1.0'
  s.add_dependency 'codemirror-rails',  '>= 3.0.0'
  s.add_dependency 'kaminari',          '>= 0.14.0'
end
