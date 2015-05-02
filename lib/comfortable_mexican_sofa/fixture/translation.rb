module ComfortableMexicanSofa::Fixture::Translation
  class Importer < ComfortableMexicanSofa::Fixture::Importer

    attr_accessor :target_pages

    def import!(path = self.path, translateable_parent = nil, locale = nil, translateable_type = nil)
      paths = translateable_parent ? Dir["#{path}*/"] : Dir["#{path}*/*/*/"]

      paths.each do |path|
        # Get slug, locale and translateable type from subfolders in the current path.
        # A example path could look like this:
        # db/cms_fixtures/example-site/translations/en/pages/my-page
        locale ||= path.split('/')[-3]
        translateable_type ||= path.split('/')[-2]
        slug = path.split('/').last

        if File.exists?(attrs_path = File.join(path, 'attributes.yml'))
          attrs = get_attributes(attrs_path)

          translateable = get_translateable(translateable_type, attrs['translateable'])
          translation = translateable.translations.where(:locale => locale).first || translateable.translations.new(:locale => locale)

          if fresh_fixture?(translation, attrs_path)
            translation.locale       = locale
            translation.slug         = slug
            translation.label        = attrs['label']
            translation.is_published = attrs['is_published'].nil? ? true : attrs['is_published']

            if attrs['target_page']
              self.target_pages ||= {}
              self.target_pages[translation] = attrs['target_page']
            end
          end

          import_blockable translation, path

          # saving
          if translation.changed? || translation.blocks_attributes_changed || self.force_import
            if translation.save
              ComfortableMexicanSofa.logger.info("[FIXTURES] Imported Translation \t #{translation.full_path}")
            else
              ComfortableMexicanSofa.logger.warn("[FIXTURES] Failed to import Translation \n#{translation.errors.inspect}")
            end
          end

          self.fixture_ids << translation.id

          # importing translations for childs of current translateable
          import!(path, translateable, locale, translateable_type)
        end
      end

      # linking up target pages
      if self.target_pages.present?
        self.target_pages.each do |translation, target|
          if target_page = self.site.pages.where(:full_path => target).first
            translation.target_page = target_page
            translation.save
          end
        end
      end

      # cleaning up
      unless translateable_parent
        existing_fixture_ids = self.site.pages.collect{ |page| page.translations.map(&:id) }.flatten
        (existing_fixture_ids - fixture_ids).each{ |id| Comfy::Cms::Translation.find(id).destroy }
      end
    end

    private
      # Returns a translateable by a given identifier.
      # This method must be adjusted for the different translateable types.
      # At the moment only Pages are translateable though.
      def get_translateable(type, identifier)
        case type
        when 'pages'
          self.site.pages.where(:full_path => identifier).first
        else
          raise "Unsupported translateable #{type}!"
        end
      end
  end

  class Exporter < ComfortableMexicanSofa::Fixture::Exporter
    # This method could be adjusted for other translateables for example
    # if they have a identifier instead of a slug.
    def translation_path(translation)
      # Use a translations full path as its export location. Replace the first
      # slash with "index" just like in the Page eyporter where empty slug (aka root page)
      # is replaced by "index".
      File.join(translation.full_path.sub('/', 'index/').split('/'))
    end

    def export!
      prepare_folder!(self.path)

      # Add all translateables here.
      # At the moment only Pages are translateable though.
      {
        'pages' => self.site.pages
      }.each do |translateable_type, translateables|
        translateables.each do |translateable|
          translateable.translations.each do |translation|
            translation.slug = 'index' if translation.slug.blank?
            # We export translations to a subfolder with the translations locale
            # and another with the translateable type. A example path could look like this:
            # db/cms_fixtures/example-site/translations/en/pages/my-page
            translation_path = File.join(path, translation.locale, translateable_type, translation_path(translation))
            FileUtils.mkdir_p(translation_path)

            open(File.join(translation_path, 'attributes.yml'), 'w') do |f|
              f.write({
                'translateable' => translateable.full_path,
                'label'         => translation.label,
                'target_page'   => translation.target_page.try(:full_path),
                'is_published'  => translation.is_published,
              }.to_yaml)
            end
            translation.blocks_attributes.each do |block|
              open(File.join(translation_path, "#{block[:identifier]}.html"), 'w') do |f|
                f.write(block[:content])
              end
            end

            ComfortableMexicanSofa.logger.info("[FIXTURES] Exported Translation \t #{translation.full_path}")
          end
        end
      end
    end
  end
end
