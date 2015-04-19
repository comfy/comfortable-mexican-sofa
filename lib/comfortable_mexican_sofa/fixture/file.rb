module ComfortableMexicanSofa::Fixture::File
  class Importer < ComfortableMexicanSofa::Fixture::Importer
    def import!
      Dir["#{self.path}[^_]*"].each do |file_path|
        filename = ::File.basename(file_path)
        file = self.site.files.where(:file_file_name => filename).first || self.site.files.new

        # setting attributes
        categories = []
        if File.exists?(attrs_path = File.join(self.path, "_#{filename}.yml"))
          if fresh_fixture?(file, attrs_path)
            attrs = get_attributes(attrs_path)

            block = if (attrs['page'] && attrs['block']) && (page = self.site.pages.find_by_full_path(attrs['page']))
              page.blocks.find_by_identifier(attrs['block'])
            end

            file.label        = attrs['label']
            file.description  = attrs['description']
            categories        = attrs['categories']
            file.block        = block
          end
        end

        # setting actual file
        if fresh_fixture?(file, file_path)
          file.file = open(file_path)
        end

        if file.changed? || self.force_import
          if file.save
            save_categorizations!(file, categories)
            ComfortableMexicanSofa.logger.info("[FIXTURES] Imported File \t #{file.file_file_name}")
          else
            ComfortableMexicanSofa.logger.warn("[FIXTURES] Failed to import File \n#{file.errors.inspect}")
          end
        end

        self.fixture_ids << file.id
      end

      # cleaning up
      self.site.files.where('id NOT IN (?) AND block_id IS NULL', fixture_ids).each{ |s| s.destroy }
    end
  end

  class Exporter < ComfortableMexicanSofa::Fixture::Exporter
    def export!
      prepare_folder!(self.path)

      self.site.files.each do |file|
        file_path = File.join(self.path, file.file_file_name)
        block = file.block
        page = block.present?? block.blockable : nil

        # writing attributes
        open(::File.join(self.path, "_#{file.file_file_name}.yml"), 'w') do |f|
          f.write({
            'label'       => file.label,
            'description' => file.description,
            'categories'  => file.categories.map{|c| c.label},
            'page'        => page.present?? page.full_path : nil,
            'block'       => block.present?? block.identifier : nil
          }.to_yaml)
        end

        # writing content
        data_path = file.file.options[:storage] == :filesystem ?
          file.file.path :
          file.file.url

        begin
          open(::File.join(self.path, ::File.basename(file_path)), 'wb') do |f|
            open(data_path) { |src| f.write(src.read) }
          end
        rescue Errno::ENOENT, OpenURI::HTTPError
          ComfortableMexicanSofa.logger.warn("[FIXTURES] No physical File \t #{file.file_file_name}")
          next
        end

        ComfortableMexicanSofa.logger.info("[FIXTURES] Exported File \t #{file.file_file_name}")
      end
    end
  end
end
