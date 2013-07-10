module ComfortableMexicanSofa::Fixture::Category
  class Importer < ComfortableMexicanSofa::Fixture::Importer
    def import!
      {
        'files'     => 'Cms::File',
        'pages'     => 'Cms::Page',
        'snippets'  => 'Cms::Snippet'
      }.each do |file, type|
        if File.exists?(attrs_path = File.join(path, "#{file}.yml"))
          categories = get_attributes(attrs_path)
          [categories].flatten.each do |label|
            self.site.categories.find_or_create_by(:label => label, :categorized_type => type)
          end
        end
      end
    end
  end
  
  class Exporter < ComfortableMexicanSofa::Fixture::Exporter
    def export!
      prepare_folder!(self.path)
      {
        'files'     => 'Cms::File',
        'pages'     => 'Cms::Page',
        'snippets'  => 'Cms::Snippet'
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