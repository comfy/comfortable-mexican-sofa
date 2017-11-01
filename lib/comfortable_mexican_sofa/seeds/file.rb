module ComfortableMexicanSofa::Seeds::File
  class Importer < ComfortableMexicanSofa::Seeds::Importer

    def initialize(from, to = from)
      super
      self.path = ::File.join(ComfortableMexicanSofa.config.seeds_path, from, "files/")
    end

    def import!
      Dir["#{self.path}[^_]*"].each do |file_path|

        filename = ::File.basename(file_path)

        file = self.site.files.with_attached_attachment
          .where("active_storage_blobs.filename" => filename).references(:blob).first ||
          self.site.files.new

        if File.exist?(attrs_path = File.join(self.path, "_#{filename}.yml"))
          if fresh_seed?(file, attrs_path)
            attrs = YAML.load(File.read(attrs_path))
            category_ids = category_names_to_ids(Comfy::Cms::File, attrs.delete("categories"))
            file.attributes = attrs.merge(
              category_ids: category_ids
            )
          end
        end

        if fresh_seed?(file, file_path)
          file_handler = File.open(file_path)
          file.file = {
            io:           file_handler,
            filename:     filename,
            content_type: MimeMagic.by_magic(file_handler)
          }
        end

        if file.save
          message = "[CMS SEEDS] Imported File \t #{file_path}"
          ComfortableMexicanSofa.logger.info(message)
        else
          message = "[CMS SEEDS] Failed to import File \n#{file.errors.inspect}"
          ComfortableMexicanSofa.logger.warn(message)
        end

        self.seed_ids << file.id
      end

      # cleaning up
      self.site.files.where('id NOT IN (?)', seed_ids).destroy_all
    end
  end


  class Exporter < ComfortableMexicanSofa::Seeds::Exporter

    def initialize(from, to = from)
      super
      self.path = ::File.join(ComfortableMexicanSofa.config.seeds_path, to, "files/")
    end

    def export!
      prepare_folder!(self.path)

      self.site.files.each do |file|
        file_path = File.join(self.path, file.attachment.filename.to_s)

        # writing attributes
        open(::File.join(self.path, "_#{file.attachment.filename}.yml"), 'w') do |f|
          f.write({
            "label"       => file.label,
            "description" => file.description,
            "categories"  => file.categories.map{|c| c.label}
          }.to_yaml)
        end

        # writing content
        begin
          open(::File.join(self.path, ::File.basename(file_path)), 'wb') do |f|
            f.write(file.attachment.download)
          end
        rescue Errno::ENOENT, OpenURI::HTTPError
          message = "[CMS SEEDS] No physical File \t #{file.attachment.filename}"
          ComfortableMexicanSofa.logger.warn(message)
          next
        end

        message = "[CMS SEEDS] Exported File \t #{file.attachment.filename}"
        ComfortableMexicanSofa.logger.info(message)
      end
    end
  end
end
