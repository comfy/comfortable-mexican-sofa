# frozen_string_literal: true

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
      import_page(File.join(path, "index/"), nil)

      link_target_pages

      # Remove pages not found in seeds
      site.pages.where("id NOT IN (?)", seed_ids).destroy_all
    end

  private

    # Recursive function that will be called for each child page (subfolder)
    def import_page(path, parent)
      slug = path.split("/").last

      # setting page record
      page =
        if parent.present?
          child = site.pages.where(slug: slug).first_or_initialize
          child.parent = parent
          child
        else
          site.pages.root || site.pages.new(slug: slug)
        end

      content_path = File.join(path, "content.html")

      # If file is newer than page record we'll process it
      if fresh_seed?(page, content_path)

        # reading file content in, resulting in a hash
        fragments_hash  = parse_file_content(content_path)

        # parsing attributes section
        attributes_yaml = fragments_hash.delete("attributes")
        attrs           = YAML.safe_load(attributes_yaml)

        # applying attributes
        layout = site.layouts.find_by(identifier: attrs.delete("layout")) || parent.try(:layout)
        category_ids    = category_names_to_ids(page, attrs.delete("categories"))
        target_page     = attrs.delete("target_page")

        page.attributes = attrs.merge(
          layout: layout,
          category_ids: category_ids
        )

        # applying fragments
        old_frag_identifiers = page.fragments.pluck(:identifier)

        new_frag_identifiers, fragments_attributes =
          construct_fragments_attributes(fragments_hash, page, path)
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
          page.fragments.where(identifier: old_frag_identifiers - new_frag_identifiers).destroy_all

        else
          message = "[CMS SEEDS] Failed to import Page \n#{page.errors.inspect}"
          ComfortableMexicanSofa.logger.warn(message)
        end
      end

      import_translations(path, page)

      # Tracking what page from seeds we're working with. So we can remove pages
      # that are no longer in seeds
      seed_ids << page.id

      # importing child pages (if there are any)
      Dir["#{path}*/"].each do |page_path|
        import_page(page_path, page)
      end
    end

    # Importing translations for given page. They look like `content.locale.html`
    def import_translations(path, page)
      old_translations = page.translations.pluck(:locale)
      new_translations = []

      Dir["#{path}content.*.html"].each do |file_path|
        locale = File.basename(file_path).match(%r{content\.(\w+)\.html})[1]
        new_translations << locale

        translation = page.translations.where(locale: locale).first_or_initialize

        next unless fresh_seed?(translation, file_path)

        # reading file content in, resulting in a hash
        fragments_hash  = parse_file_content(file_path)

        # parsing attributes section
        attributes_yaml = fragments_hash.delete("attributes")
        attrs           = YAML.safe_load(attributes_yaml)

        # applying attributes
        layout = site.layouts.find_by(identifier: attrs.delete("layout")) || page.try(:layout)
        translation.attributes = attrs.merge(
          layout: layout
        )

        # applying fragments
        old_frag_identifiers = translation.fragments.pluck(:identifier)

        new_frag_identifiers, fragments_attributes =
          construct_fragments_attributes(fragments_hash, translation, path)
        translation.fragments_attributes = fragments_attributes

        if translation.save
          message = "[CMS SEEDS] Imported Translation \t #{locale}"
          ComfortableMexicanSofa.logger.info(message)

          # cleaning up old fragments
          frags_to_remove = old_frag_identifiers - new_frag_identifiers
          translation.fragments.where(identifier: frags_to_remove).destroy_all

        else
          message = "[CMS SEEDS] Failed to import Translation \n#{locale}"
          ComfortableMexicanSofa.logger.warn(message)
        end
      end

      # Cleaning up removed translations
      translations_to_remove = old_translations - new_translations
      page.translations.where(locale: translations_to_remove).destroy_all
    end

    # Constructing frag attributes hash that can be assigned to page or translation
    # also returning list of frag identifiers so we can destroy old ones
    def construct_fragments_attributes(hash, record, path)
      frag_identifiers = []
      frag_attributes = hash.collect do |frag_header, frag_content|
        tag, identifier = frag_header.split
        frag_hash = {
          identifier: identifier,
          tag:        tag
        }

        # tracking fragments that need removing later
        frag_identifiers << identifier

        # based on tag we need to cram content in proper place and proper format
        case tag
        when "date", "datetime"
          frag_hash[:datetime] = frag_content
        when "checkbox"
          frag_hash[:boolean] = frag_content
        when "file", "files"
          files, file_ids_destroy = files_content(record, identifier, path, frag_content)
          frag_hash[:files]            = files
          frag_hash[:file_ids_destroy] = file_ids_destroy
        else
          frag_hash[:content] = frag_content
        end

        frag_hash
      end

      [frag_identifiers, frag_attributes]
    end

    # Preparing fragment attachments. Returns hashes with file data for
    # ActiveStorage and a list of ids of old attachements to destroy
    def files_content(record, identifier, path, frag_content)
      # preparing attachments
      files = frag_content.split("\n").collect do |filename|
        file_handler = File.open(File.join(path, filename))
        {
          io:           file_handler,
          filename:     filename,
          content_type: MimeMagic.by_magic(file_handler)
        }
      end

      # ensuring that old attachments get removed
      ids_destroy = []
      if (frag = record.fragments.find_by(identifier: identifier))
        ids_destroy = frag.attachments.pluck(:id)
      end

      [files, ids_destroy]
    end

    def link_target_pages
      return unless self.target_pages.present?

      self.target_pages.each do |page_id, target|
        if (target = site.pages.find_by(full_path: target))
          @site.pages.find(page_id).update_column(:target_page_id, target.id)
        end
      end
    end

  end
end
