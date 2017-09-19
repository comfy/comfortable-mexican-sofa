require_relative '../test_helper'

class TagTest < ActiveSupport::TestCase

  def test_layout_parsing
    page = comfy_cms_pages(:default)
    layout = page.layout
    nested = layout.dup
    nested.content = "NESTED {% cms_fragment content %} CONTENT2"
    nested.identifier = 'nested-test'
    nested.parent = layout
    nested.save!
    page.update_attribute(:layout, nested)
    layout.update_column(:content, "TEST {% cms_fragment content %} CONTENT")
    parser = ComfortableMexicanSofa::Parser.new(page)
    raise parser.parse.inspect
  end

  # def test_something
  #   params = 'fragment_name, type: something'
  #   tag = FragmentTag.send(:new, 'cms_fragment', params, Liquid::ParseContext.new)
  #   assert_equal ["fragment_name", {"type"=>"something"}], tag.params
  # end


  # def test_parsing
  #   t = Liquid::Template.parse("text {% cms_fragment frag_name %} text", context: Comfy::Cms::Page.first)
  #   raise t.render
  # end

  # def test_parsing_and_expanding
  #   page = comfy_cms_pages(:default)
  #   CmsTag.parse(page)
  # end

end