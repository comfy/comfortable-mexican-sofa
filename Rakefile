require 'bundler'
Bundler.setup

require 'rake/testtask'

Rake::TestTask.new(:ci) do |t|
  t.libs << 'test'
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
  t.warning = false
end

require_relative 'config/application'
ComfortableMexicanSofa::Application.load_tasks
