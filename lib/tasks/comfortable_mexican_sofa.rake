# Small hack to auto-run migrations during testing
namespace :db do
  task :abort_if_pending_migrations => [:migrate]
end

namespace :comfortable_mexican_sofa do
  namespace :fixtures do
    
    desc 'Import Fixture data into database (options: FROM=example.local TO=example.com)'
    task :import => :environment do |task, args|
      to    = args[:to] || args[:from]
      from  = args[:from]
      
      abort "Site with hostname [#{to}] not found. Aborting." if !Cms::Site.find_by_hostname(to)
      puts "Importing from Folder [#{from}] to Site [#{to}] ..."
      ComfortableMexicanSofa::Fixtures.import_all(to, from)
      puts 'Done!'
    end
    
    desc 'Export database data into Fixtures (options: FROM=example.com TO=example.local)'
    task :export => :environment do |task, args|
      to    = args[:to] || args[:from]
      from  = args[:from]
      
      abort "Site with hostname [#{from}] not found. Aborting." if !Cms::Site.find_by_hostname(from)
      puts "Exporting from Site [#{from}] to Folder [#{to}] ..."
      ComfortableMexicanSofa::Fixtures.export_all(from, to)
      puts 'Done!'
    end
  end
end