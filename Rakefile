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