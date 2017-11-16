module ComfortableMexicanSofa::Seeds::File
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
