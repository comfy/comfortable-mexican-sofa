module ComfortableMexicanSofa::Seeds::File
  class Importer < ComfortableMexicanSofa::Seeds::Importer

    def import!
      Dir["#{self.path}[^_]*"].each do |file_path|
        filename = ::File.basename(file_path)
        file = self.site.files.with_attached_attachment.where("active_storage_blobs.filename" => filename).references(:blob).first || self.site.files.new

        # setting attributes
        categories = []
        if File.exist?(attrs_path = File.join(self.path, "_#{filename}.yml"))
          if fresh_seed?(file, attrs_path)
            attrs = get_attributes(attrs_path)

            file.label        = attrs['label']
            file.description  = attrs['description']
            categories        = attrs['categories']
            content_type      = attrs["content_type"]
          end
        end

        # setting actual file
        if fresh_seed?(file, file_path)
          file.file = {io: open(file_path), filename: filename, content_type: content_type || "application/octet-stream"}
        end

        if file.changed? || self.force_import
          if file.save!
            save_categorizations!(file, categories)
            ComfortableMexicanSofa.logger.info("[CMS SEEDS] Imported File \t #{file_path}")
          else
            ComfortableMexicanSofa.logger.warn("[CMS SEEDS] Failed to import File \n#{file.errors.inspect}")
          end
        end

        self.seed_ids << file.id
      end

      # cleaning up
      self.site.files.where('id NOT IN (?)', seed_ids).each{ |s| s.destroy }
    end
  end

  class Exporter < ComfortableMexicanSofa::Seeds::Exporter
    def export!
      prepare_folder!(self.path)

      self.site.files.each do |file|
        file_path = File.join(self.path, file.attachment.filename.to_s)

        # writing attributes
        open(::File.join(self.path, "_#{file.attachment.filename}.yml"), 'w') do |f|
          f.write({
            'label'         => file.label,
            'description'   => file.description,
            'categories'    => file.categories.map{|c| c.label},
            "content_type"  => file.attachment.content_type
          }.to_yaml)
        end

        # writing content
        begin
          open(::File.join(self.path, ::File.basename(file_path)), 'wb') do |f|
            f.write(file.attachment.download)
          end
        rescue Errno::ENOENT, OpenURI::HTTPError
          ComfortableMexicanSofa.logger.warn("[CMS SEEDS] No physical File \t #{file.attachment.filename}")
          next
        end

        ComfortableMexicanSofa.logger.info("[CMS SEEDS] Exported File \t #{file.attachment.filename}")
      end
    end
  end
end
