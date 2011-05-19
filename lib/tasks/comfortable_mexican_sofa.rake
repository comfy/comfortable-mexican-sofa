# Small hack to auto-run migrations during testing
namespace :db do
  task :abort_if_pending_migrations => [:migrate]
end

namespace :comfortable_mexican_sofa do
  namespace :fixtures do
    
    desc 'Import Fixture data into database (options: FROM=example.local TO=example.com)'
    task :import => :environment do |task, args|
      
      hostname = args[:to] || args[:from]
      site = Cms::Site.find_by_hostname(hostname)
      abort "Site with hostname [#{hostname}] not found. Aborting." if !site
      
      puts "Syncing for #{site.hostname}"
      ComfortableMexicanSofa::Fixtures.import_all(site.hostname, args[:from] || site.hostname)
      puts 'Done!'
    end
  end
end