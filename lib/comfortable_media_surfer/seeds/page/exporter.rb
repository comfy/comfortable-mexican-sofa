# frozen_string_literal: true

module ComfortableMediaSurfer::Seeds::Page
  class Exporter < ComfortableMediaSurfer::Seeds::Exporter
    def initialize(from, to = from)
      super
      self.path = ::File.join(ComfortableMediaSurfer.config.seeds_path, to, 'pages/')
    end

    def export!
      prepare_folder!(path)

      site.pages.each do |page|
        page.slug = 'index' if page.slug.blank?
        page_path = File.join(path, page.ancestors.reverse.map { |p| p.slug.blank? ? 'index' : p.slug }, page.slug)
        FileUtils.mkdir_p(page_path)

        path = ::File.join(page_path, 'content.html')
        data = []

        attrs = {
          'label' => page.label,
          'layout' => page.layout.try(:identifier),
          'target_page' => page.target_page.try(:full_path),
          'categories' => page.categories.map(&:label),
          'is_published' => page.is_published,
          'position' => page.position
        }.to_yaml

        data << { header: 'attributes', content: attrs }
        data += fragments_data(page, page_path)

        write_file_content(path, data)

        message = "[CMS SEEDS] Exported Page \t #{page.full_path}"
        ComfortableMediaSurfer.logger.info(message)

        export_translations(page, page_path)
      end
    end

  private

    def export_translations(page, page_path)
      page.translations.each do |translation|
        path = ::File.join(page_path, "content.#{translation.locale}.html")
        data = []

        attrs = {
          'label' => translation.label,
          'layout' => translation.layout.try(:identifier),
          'is_published' => page.is_published
        }.to_yaml

        data << { header: 'attributes', content: attrs }
        data += fragments_data(translation, page_path)

        write_file_content(path, data)

        message = "[CMS SEEDS] Exported Translation \t #{translation.locale}"
        ComfortableMediaSurfer.logger.info(message)
      end
    end

    # Collecting fragment data and writing attachment files to disk
    def fragments_data(record, page_path)
      record.fragments.collect do |frag|
        header = "#{frag.tag} #{frag.identifier}"
        content =
          case frag.tag
          when 'datetime', 'date'
            frag.datetime
          when 'checkbox'
            frag.boolean
          when 'file', 'files'
            frag.attachments.map do |attachment|
              ::File.binwrite(::File.join(page_path, attachment.filename.to_s), attachment.download)
              attachment.filename
            end.join("\n")
          else
            frag.content
          end

        { header: header, content: content }
      end
    end
  end
end
