# Small hack to auto-run migrations during testing
namespace :db do
  task :abort_if_pending_migrations => [:migrate]
end

namespace :comfortable_mexican_sofa do
  namespace :fixtures do
    
    desc 'Import Fixture data into database (options: FOLDER=example.local SITE=example.com)'
    task :import => :environment do |task, args|
      hostname = args[:site] || args[:folder]
      site = Cms::Site.find_by_hostname(hostname)
      abort "Site with hostname [#{hostname}] not found. Aborting." if !site
      
      puts "Importing for #{site.hostname}"
      ComfortableMexicanSofa::Fixtures.import_all(site.hostname, (args[:site] || site.hostname))
      puts 'Done!'
    end
    
    desc 'Export database data into Fixtures (options: SITE=example.com FOLDER=example.local)'
    task :export => :environment do |task, args|
      site = Cms::Site.find_by_hostname(args[:folder])
      abort "Site with hostname [#{hostname}] not found. Aborting." if !site
      
      puts "Exporting for #{site.hostname}"
      ComfortableMexicanSofa::Fixtures.export_all((args[:site] || site.hostname), site.hostname)
      puts 'Done!'
    end
  end
end