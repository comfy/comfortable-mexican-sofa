namespace :comfortable_mexican_sofa do
  namespace :fixtures do
    
    desc 'Import Fixture data into database (options: FROM=folder_name TO=site_identifier)'
    
    task :import => :environment do
      from  = ENV['FROM']
      to    = ENV['TO'] || ENV['FROM']
      
      puts "Importing CMS Fixtures from Folder [#{from}] to Site [#{to}] ..."
      
      # changing so that logger is going straight to screen
      logger = ComfortableMexicanSofa.logger
      ComfortableMexicanSofa.logger = Logger.new(STDOUT)
      
      ComfortableMexicanSofa::Fixture::Importer.new(from, to, :force).import!
      
      ComfortableMexicanSofa.logger = logger
    end
    
    desc 'Export database data into Fixtures (options: FROM=site_identifier TO=folder_name)'
    task :export => :environment do
      from  = ENV['FROM']
      to    = ENV['TO'] || ENV['FROM']
      
      puts "Exporting CMS data from Site [#{from}] to Folder [#{to}] ..."
      
      # changing so that logger is going straight to screen
      logger = ComfortableMexicanSofa.logger
      ComfortableMexicanSofa.logger = Logger.new(STDOUT)
      
      ComfortableMexicanSofa::Fixture::Exporter.new(from, to).export!
      
      ComfortableMexicanSofa.logger = logger
    end
  end
end