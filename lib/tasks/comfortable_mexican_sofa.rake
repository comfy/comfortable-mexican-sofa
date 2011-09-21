# Small hack to auto-run migrations during testing
namespace :db do
  task :abort_if_pending_migrations => [:migrate]
end

namespace :comfortable_mexican_sofa do
  namespace :fixtures do
    
    desc 'Import Fixture data into database (options: FROM=example.local TO=example.com)'
    task :import => :environment do
      to    = ENV['TO'] || ENV['FROM']
      from  = ENV['FROM']
      
      puts "Importing CMS Fixtures from Folder [#{from}] to Site [#{to}] ..."
      ComfortableMexicanSofa::Fixtures.import_all(to, from)
    end
    
    desc 'Export database data into Fixtures (options: FROM=example.com TO=example.local)'
    task :export => :environment do
      to    = ENV['TO'] || ENV['FROM']
      from  = ENV['FROM']
      
      puts "Exporting CMS data from Site [#{from}] to Folder [#{to}] ..."
      ComfortableMexicanSofa::Fixtures.export_all(from, to)
      puts 'Done!'
    end
  end
end