# frozen_string_literal: true

namespace :comfy do
  namespace :cms_seeds do
    desc "Import CMS Seed data into database (from: folder name, to: site identifier, klasses: class name[s])"

    task :import, %i[from to klasses] => [:environment] do |_t, args|
      from  = args[:from]
      to    = args[:to] || from
      klasses = args[:klasses].nil? ? nil : args[:klasses].split

      puts "Importing CMS Seed data from Folder [#{from}] to Site [#{to}] ..."

      # changing so that logger is going straight to screen
      logger = ComfortableMexicanSofa.logger
      ComfortableMexicanSofa.logger = Logger.new(STDOUT)

      ComfortableMexicanSofa::Seeds::Importer.new(from, to).import!(klasses)

      ComfortableMexicanSofa.logger = logger
    end

    desc "Export database data into CMS Seed files (from: site identifier, to: folder name, klasses: class name[s])"
    task :export, %i[from to klasses] => [:environment] do |_t, args|
      from  = args[:from]
      to    = args[:to] || from
      klasses = args[:klasses]&.split

      puts "Exporting CMS data from Site [#{from}] to Folder [#{to}] ..."

      # changing so that logger is going straight to screen
      logger = ComfortableMexicanSofa.logger
      ComfortableMexicanSofa.logger = Logger.new(STDOUT)

      ComfortableMexicanSofa::Seeds::Exporter.new(from, to).export!(klasses)

      ComfortableMexicanSofa.logger = logger
    end
  end
end
