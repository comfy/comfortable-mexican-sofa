module ComfortableMexicanSofa::Seeds::Page
  class Importer < ComfortableMexicanSofa::Seeds::Importer

    # tracking target page linking. Since we might be linking to something that
    # doesn't exist yet, we'll defer linking to the end of import
    attr_accessor :target_pages

    def initialize(from, to = from)
      super
      self.path = ::File.join(ComfortableMexicanSofa.config.seeds_path, from, "pages/")
    end


    def import!
      import_page(File.join(self.path, "index/"), nil)

      link_target_pages

      # Remove pages not found in seeds
      self.site.pages.where('id NOT IN (?)', self.seed_ids).each{ |s| s.destroy }
    end

  private

    # Recursive function that will be called for each child page (subfolder)
    def import_page(path, parent)
      slug = path.split("/").last

      # reading file content in, resulting in a hash
      content_path    = File.join(path, "content.html")
      fragments_hash  = parse_file_content(content_path)

      # parsing attributes section
      attributes_yaml = fragments_hash.delete("attributes")
      attrs           = YAML.load(attributes_yaml)

      # setting page record
      page = if parent.present?
        parent.children.find_by(slug: slug) || self.site.pages.new(parent: parent, slug: slug)
      else
        self.site.pages.root ||self. site.pages.new(slug: slug)
      end

      # If file is newer than page record we'll process it
      if fresh_seed?(page, content_path)

        # applying attributes
        layout = self.site.layouts.find_by(identifier: attrs.delete("layout")) || parent.try(:layout)
        category_ids    = category_names_to_ids(Comfy::Cms::Page, attrs.delete("categories"))
        target_page     = attrs.delete("target_page")

        page.attributes = attrs.merge(
          layout: layout,
          category_ids: category_ids
        )

        # applying fragments
        old_fragments         = page.fragments.pluck(:identifier)
        fragments_attributes  = []

        fragments_hash.each do |frag_header, frag_content|
          tag, identifier = frag_header.split
          frag_hash = {
            identifier: identifier,
            tag:        tag
          }

          # tracking fragments that need removing later
          old_fragments -= [identifier]

          # based on tag we need to cram content in proper place and proper format
          case tag
          when "date", "datetime"
            frag_hash[:datetime] = frag_content
          when "checkbox"
            frag_hash[:boolean] = frag_content
          when "file", "files"
            files, file_ids_destroy = files_content(page, identifier, path, frag_content)
            frag_hash[:files]            = files
            frag_hash[:file_ids_destroy] = file_ids_destroy
          else
            frag_hash[:content] = frag_content
          end

          fragments_attributes << frag_hash
        end

        page.fragments_attributes = fragments_attributes

        if page.save
          message = "[CMS SEEDS] Imported Page \t #{page.full_path}"
          ComfortableMexicanSofa.logger.info(message)

          # defering target page linking
          if target_page.present?
            self.target_pages ||= {}
            self.target_pages[page.id] = target_page
          end

          # cleaning up old fragments
          page.fragments.where(identifier: old_fragments).destroy_all

        else
          message = "[CMS SEEDS] Failed to import Page \n#{page.errors.inspect}"
          ComfortableMexicanSofa.logger.warn(message)
        end
      end

      # Tracking what page from seeds we're working with. So we can remove pages
      # that are no longer in seeds
      self.seed_ids << page.id

      # importing child pages (if there are any)
      Dir["#{path}*/"].each do |path|
        import_page(path, page)
      end
    end

    # Preparing fragment attachments. Returns hashes with file data for
    # ActiveStorage and a list of ids of old attachements to destroy
    def files_content(page, identifier, path, frag_content)
      # preparing attachments
      files = frag_content.split.collect do |filename|
        file_handler = File.open(File.join(path, filename))
        {
          io:           file_handler,
          filename:     filename,
          content_type: MimeMagic.by_magic(file_handler)
        }
      end

      # ensuring that old attachments get removed
      ids_destroy = []
      if frag = page.fragments.find_by(identifier: identifier)
        ids_destroy = frag.attachments.pluck(:id)
      end

      [files, ids_destroy]
    end

    def link_target_pages
      return unless self.target_pages.present?

      self.target_pages.each do |page_id, target|
        if target = self.site.pages.find_by(full_path: target)
          @site.pages.find(page_id).update_column(:target_page_id, target.id)
        end
      end
    end
  end


  class Exporter < ComfortableMexicanSofa::Seeds::Exporter

    def initialize(from, to = from)
      super
      self.path = ::File.join(ComfortableMexicanSofa.config.seeds_path, to, "pages/")
    end

    def export!
      prepare_folder!(self.path)

      self.site.pages.each do |page|
        page.slug = 'index' if page.slug.blank?
        page_path = File.join(path, page.ancestors.reverse.map{|p| p.slug.blank?? 'index' : p.slug}, page.slug)
        FileUtils.mkdir_p(page_path)

        path = ::File.join(page_path, "content.html")
        data = []

        attrs = {
          "label"        => page.label,
          "layout"       => page.layout.try(:identifier),
          "parent"       => page.parent && (page.parent.slug.present?? page.parent.slug : 'index'),
          "target_page"  => page.target_page.try(:full_path),
          "categories"   => page.categories.map{|c| c.label},
          "is_published" => page.is_published,
          "position"     => page.position
        }.to_yaml

        data << {header: "attributes", content: attrs}

        page.fragments.each do |frag|

          header = "#{frag.tag} #{frag.identifier}"
          content = case frag.tag
          when "datetime", "date"
            frag.datetime
          when "checkbox"
            frag.boolean
          when "file", "files"
            frag.attachments.map do |attachment|
              ::File.open(::File.join(page_path, attachment.filename.to_s), "w") do |f|
                f.write(attachment.download)
              end
              attachment.filename
            end.join("\n")
          else
            frag.content
          end
          data << {header: header, content: content}
        end

        write_file_content(path, data)

        ComfortableMexicanSofa.logger.info("[CMS SEEDS] Exported Page \t #{page.full_path}")
      end
    end
  end
end
