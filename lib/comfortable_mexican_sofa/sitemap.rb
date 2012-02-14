class ComfortableMexicanSofa::Sitemap
  
  # we want our callback to include the cms_site and 
  # the view so we have whatever routes are available to us
  # xml is an xml_builder which expects a sitemap url definition, e.g:
  #   xml.url do
  #     xml.loc view.url_for("http://example.org/example")
  #     xml.lastmod 2.days.ago.strftime('%Y-%m-%d')
  #   end
  def self.process(cms_site, view, xml)
    self.sitemap_extensions.each do |extension|
      extension.call(cms_site, view, xml)
    end
  end
  
  def self.register_extension(callback)
    self.sitemap_extensions.push(callback)
  end
  
private
  
  # A list of registered sitemap extension methods
  def self.sitemap_extensions
    @@sitemap_extensions ||= []
  end
  
end
