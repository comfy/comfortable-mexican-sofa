module ComfortableMexicanSofa::Seeds



  # Writing to the seed file. Takes in file handler and array of hashes with
  # `header` and `content` keys
  def self.write_file_content(path, data)
    open(File.join(path), 'w') do |f|
      data.each do |item|
        f.write("[#{item[:header]}]\n")
        f.write("#{item[:content]}\n")
      end
    end
  end










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
    end

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

    def category_names_to_ids(klass, names)
      [names].flatten.each_with_object({}) do |name, category_ids|
        category = self.site.categories.find_or_create_by(
          label:            name,
          categorized_type: klass.to_s
        )
        category_ids[category.id] = 1
      end
    end










    def get_attributes(file_path)
      YAML.load_file(file_path) || { }
    end

    def save_categorizations!(object, categories)
      object.categorizations.delete_all

      [categories].flatten.compact.each do |label|
        category = self.site.categories.where(
          :label            => label,
          :categorized_type => object.class.to_s
        ).first

        next unless category

        category.categorizations.create!(:categorized => object)
      end
    end

    def import!
      ComfortableMexicanSofa::Seeds::Category::Importer.new(from, to, force_import).import!
      ComfortableMexicanSofa::Seeds::Layout::Importer.new(  from, to, force_import).import!
      ComfortableMexicanSofa::Seeds::Page::Importer.new(    from, to, force_import).import!
      ComfortableMexicanSofa::Seeds::Snippet::Importer.new( from, to, force_import).import!
      ComfortableMexicanSofa::Seeds::File::Importer.new(    from, to, force_import).import!
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
      dir = self.class.name.split('::')[2].downcase.pluralize
      self.path = ::File.join(ComfortableMexicanSofa.config.seeds_path, to, dir)
    end

    def prepare_folder!(path)
      FileUtils.rm_rf(path)
      FileUtils.mkdir_p(path)
    end

    def export!
      ComfortableMexicanSofa::Seeds::File::Exporter.new(    from, to).export!
      ComfortableMexicanSofa::Seeds::Category::Exporter.new(from, to).export!
      ComfortableMexicanSofa::Seeds::Layout::Exporter.new(  from, to).export!
      ComfortableMexicanSofa::Seeds::Page::Exporter.new(    from, to).export!
      ComfortableMexicanSofa::Seeds::Snippet::Exporter.new( from, to).export!
    end
  end

end