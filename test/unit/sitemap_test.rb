require File.expand_path('../test_helper', File.dirname(__FILE__))

class SitemapTest < ActiveSupport::TestCase
  class DummySitemapExtension
    @@calls = 0
    def self.calls
      @@calls
    end
    def self.callback(cms_site, view, xml)
      @@calls = @@calls + 1
    end
  end

  def test_should_get_registered_extensions
    ComfortableMexicanSofa::Sitemap.register_extension(DummySitemapExtension.method(:callback))
    ComfortableMexicanSofa::Sitemap.process(cms_sites(:default), nil, "xml")
    assert_equal 1, DummySitemapExtension.calls
  end

end
