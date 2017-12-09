module ComfortableMexicanSofa::Seeds

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

      unless ::File.exist?(path = ::File.join(ComfortableMexicanSofa.config.seeds_path, from))
        raise Error, "Folder for import: '#{path}' is not found"
      end
    end

    def import!
      %w(Layout Page Snippet File).each do |klass|
        klass = "ComfortableMexicanSofa::Seeds::#{klass}::Importer"
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
      tokens = text.split(/^\[(.*?)\]\n/)
      tokens.shift # first item should be blank
      tokens.in_groups_of(2).each_with_object({}) do |pair, h|
        h[pair[0]] = pair[1]
      end
    end

    def fresh_seed?(object, file_path)
      object.new_record? || ::File.mtime(file_path) > object.updated_at
    end

    def category_names_to_ids(record, names)
      existing_category_ids = record.categories.each_with_object({}) do |id, category_ids|
        category_ids[id] = 0
      end
      [names].flatten.each_with_object(existing_category_ids) do |name, category_ids|
        category = self.site.categories.find_or_create_by(
          label:            name,
          categorized_type: record.class.to_s
        )
        category_ids[category.id] = 1
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

    def export!
      %w(Layout Page Snippet File).each do |klass|
        klass = "ComfortableMexicanSofa::Seeds::#{klass}::Exporter"
        klass.constantize.new(from, to).export!
      end
    end

  private

    # Writing to the seed file. Takes in file handler and array of hashes with
    # `header` and `content` keys
    def write_file_content(path, data)
      open(::File.join(path), "wb") do |f|
        data.each do |item|
          f.write("[#{item[:header]}]\n")
          f.write("#{item[:content]}\n")
        end
      end
    end

    def prepare_folder!(path)
      FileUtils.rm_rf(path)
      FileUtils.mkdir_p(path)
    end
  end
end
