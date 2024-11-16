# frozen_string_literal: true

module ComfortableMediaSurfer::Seeds
  SEED_CLASSES = %w[Layout Page Snippet File].freeze

  class Error < StandardError; end

  require 'mimemagic'

  class Importer
    attr_accessor :site,
                  :path,
                  :from,
                  :to,
                  :seed_ids

    # `from` and `to` indicate site identifier and folder name
    def initialize(from, to = from)
      self.from         = from
      self.to           = to
      self.site         = Comfy::Cms::Site.where(identifier: to).first!
      self.seed_ids     = []

      return if ::File.exist?(path = ::File.join(ComfortableMediaSurfer.config.seeds_path, from))

      raise Error, "Folder for import: '#{path}' is not found"
    end

    # if passed nil will use default seed classes
    def import!(classes = nil)
      classes ||= SEED_CLASSES
      classes.each do |klass|
        klass = "ComfortableMediaSurfer::Seeds::#{klass}::Importer"
        klass.constantize.new(from, to).import!
      end
    end

  private

    # Splitting file content in sections delimited by headers that look like this:
    #   [header]
    #   some content
    #   [header 2]
    #   some more content
    def parse_file_content(file_path)
      text = ::File.read(file_path)
      tokens = text.split(%r{^\[(.*?)\]\r?\n})
      tokens.shift # first item should be blank
      tokens.in_groups_of(2).each_with_object({}) do |pair, h|
        h[pair[0]] = pair[1]
      end
    end

    def fresh_seed?(object, file_path)
      object.new_record? || ::File.mtime(file_path) > object.updated_at
    end

    def category_names_to_ids(record, names)
      [names].flatten.map do |name|
        category = site.categories.find_or_create_by(
          label: name,
          categorized_type: record.class.to_s
        )
        category.id
      end
    end
  end

  class Exporter
    attr_accessor :site,
                  :path,
                  :from,
                  :to

    def initialize(from, to = from)
      self.from = from
      self.to   = to
      self.site = Comfy::Cms::Site.where(identifier: from).first!
    end

    # if passed nil will use default seed classes
    def export!(classes = nil)
      classes ||= SEED_CLASSES
      classes.each do |klass|
        klass = "ComfortableMediaSurfer::Seeds::#{klass}::Exporter"
        klass.constantize.new(from, to).export!
      end
    end

  private

    # Writing to the seed file. Takes in file handler and array of hashes with
    # `header` and `content` keys
    def write_file_content(path, data)
      ::File.open(::File.join(path), 'wb') do |f|
        data.each do |item|
          f.write("[#{item[:header]}]\n#{item[:content]}")
          # adds a newline between items if not already there
          # makes sure last item does not have a newline
          if data.last != item && !item[:content].to_s.end_with?("\n")
            f.write("\n")
          end
        end
      end
    end

    def prepare_folder!(path)
      FileUtils.rm_rf(path)
      FileUtils.mkdir_p(path)
    end
  end
end
