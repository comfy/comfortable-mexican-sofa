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

namespace :test do
  Rake::TestTask.new(:lib) do |t|
    t.libs << 'test'
    t.pattern = 'test/lib/**/*_test.rb'
    t.verbose = true
  end

  Rake::TestTask.new(:generators) do |t|
    t.libs << 'test'
    t.pattern = 'test/generators/**/*_test.rb'
    t.verbose = true
  end
end

Rake::Task[:test].enhance do
  Rake::Task['test:lib'].invoke
  Rake::Task['test:generators'].invoke
end