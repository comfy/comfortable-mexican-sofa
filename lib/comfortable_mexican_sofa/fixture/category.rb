module ComfortableMexicanSofa::Fixture::Category
  class Importer < ComfortableMexicanSofa::Fixture::Importer
    def import!
      {
        'files'     => 'Comfy::Cms::File',
        'pages'     => 'Comfy::Cms::Page',
        'snippets'  => 'Comfy::Cms::Snippet'
      }.each do |file, type|
        if File.exists?(attrs_path = File.join(path, "#{file}.yml"))
          categories = [get_attributes(attrs_path)].flatten
          existing_categories = self.site.categories.where(:categorized_type => type).map(&:label)
          
          self.site.categories.where(
            :categorized_type => type,
            :label            => existing_categories - categories
          ).destroy_all
          
          (categories - existing_categories).each do |label|
            self.site.categories.create(:label => label, :categorized_type => type)
          end
        end
      end
    end
  end
  
  class Exporter < ComfortableMexicanSofa::Fixture::Exporter
    def export!
      prepare_folder!(self.path)
      {
        'files'     => 'Comfy::Cms::File',
        'pages'     => 'Comfy::Cms::Page',
        'snippets'  => 'Comfy::Cms::Snippet'
      }.each do |file, type|
        if (categories = self.site.categories.of_type(type)).present?
          open(File.join(self.path, "#{file}.yml"), 'w') do |f|
            f.write(categories.map{|c| c.label}.to_yaml)
          end
        end
      end
    end
  end
end