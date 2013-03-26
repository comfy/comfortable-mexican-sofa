# encoding: utf-8

$:.unshift File.expand_path('../lib', __FILE__)
require 'comfortable_mexican_sofa/version'

Gem::Specification.new do |s|
  s.name          = "comfortable_mexican_sofa"
  s.version       = ComfortableMexicanSofa::VERSION
  s.authors       = ["Oleg Khabarov", "The Working Group Inc"]
  s.email         = ["oleg@khabarov.ca"]
  s.homepage      = "http://github.com/comfy/comfortable-mexican-sofa"
  s.summary       = "CMS Engine for Rails 3 apps"
  s.description   = "CMS Engine for Rails 3 apps"
  
  s.files         = `git ls-files`.split("\n")
  s.platform      = Gem::Platform::RUBY
  s.require_paths = ['lib']
  s.rubyforge_project = '[none]'
end