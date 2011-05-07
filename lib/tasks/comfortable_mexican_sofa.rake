# Small hack to auto-run migrations during testing
namespace :db do
  task :abort_if_pending_migrations => [:migrate]
end

namespace :comfortable_mexican_sofa do
  namespace :fixtures do
    
    desc 'Import Fixture data into database. (options: SITE=example.com)'
    task :import => :environment do |task, args|
      site = if ComfortableMexicanSofa.config.enable_multiple_sites
        Cms::Site.find_by_hostname(args[:site])
      else
        Cms::Site.first
      end
      abort 'SITE is not found. Aborting.' if !site
      
      puts "Syncing for #{site.hostname}"
      ComfortableMexicanSofa::Fixtures.sync(site)
      
      puts 'Done!'
    end
  end
end