# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rubygems'
require 'rake'

ComfortableMexicanSofa::Application.load_tasks

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name        = 'comfortable_mexican_sofa'
    gem.summary     = 'ComfortableMexicanSofa is a powerful CMS Engine for Ruby on Rails 3 applications'
    gem.description = ''
    gem.email       = 'oleg@theworkinggroup.ca'
    gem.homepage    = 'http://github.com/comfy/comfortable-mexican-sofa'
    gem.authors     = ['Oleg Khabarov', 'The Working Group Inc']
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end