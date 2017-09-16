require_relative '../test_helper'

class TagTest < ActiveSupport::TestCase

  # def test_something
  #   params = 'fragment_name, type: something'
  #   tag = FragmentTag.send(:new, 'cms_fragment', params, Liquid::ParseContext.new)
  #   assert_equal ["fragment_name", {"type"=>"something"}], tag.params
  # end


  def test_parsing
    t = Liquid::Template.parse("text {% cms_fragment frag_name %} text", context: Comfy::Cms::Page.first)
    raise t.render
  end

end