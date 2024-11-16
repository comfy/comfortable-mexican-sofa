# frozen_string_literal: true

namespace :comfy do
  namespace :cms_seeds do
    desc 'Import CMS Seed data into database (from: folder name, to: site identifier, classes: class name[s])'

    task :import, %i[from to classes] => [:environment] do |_t, args|
      from  = args[:from]
      to    = args[:to] || from
      classes = args[:classes].nil? ? nil : args[:classes].split

      puts "Importing CMS Seed data from Folder [#{from}] to Site [#{to}] ..."

      # changing so that logger is going straight to screen
      logger = ComfortableMediaSurfer.logger
      ComfortableMediaSurfer.logger = Logger.new($stdout)

      ComfortableMediaSurfer::Seeds::Importer.new(from, to).import!(classes)

      ComfortableMediaSurfer.logger = logger
    end

    desc 'Export database data into CMS Seed files (from: site identifier, to: folder name, classes: class name[s])'
    task :export, %i[from to classes] => [:environment] do |_t, args|
      from  = args[:from]
      to    = args[:to] || from
      classes = args[:classes].nil? ? nil : args[:classes].split

      puts "Exporting CMS data from Site [#{from}] to Folder [#{to}] ..."

      # changing so that logger is going straight to screen
      logger = ComfortableMediaSurfer.logger
      ComfortableMediaSurfer.logger = Logger.new($stdout)

      ComfortableMediaSurfer::Seeds::Exporter.new(from, to).export!(classes)

      ComfortableMediaSurfer.logger = logger
    end
  end
end
