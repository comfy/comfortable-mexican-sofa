require_relative '../test_helper'

class ViewMethodsTest < ActionView::TestCase

  include Comfy::CmsHelper

  module TestViewHelpers
    def hello
      'hello'
    end
  end
  ActionView::Base.send :include, TestViewHelpers

  setup do
    # we're simulating instance variables that are present on the view/controller
    @cms_site = comfy_cms_sites(:default)
    @cms_page = comfy_cms_pages(:default)
  end

  def test_cms_fragment_content
    assert_equal "content", cms_fragment_content(:content)
    assert_equal "content", cms_fragment_content(:content, @cms_page)
    assert_equal "", cms_fragment_content(:invalid)
  end

  def test_cms_fragment_with_files
    flunk "todo"
  end

  def test_cms_fragment_render
    assert_equal "content", cms_fragment_render(:content)
    assert_equal "", cms_fragment_render(:invalid)
  end

  def test_cms_fragment_render_with_tags
    comfy_cms_fragments(:default).update_column(:content, "a {{cms:helper hello }} b")
    assert_equal "a hello b", cms_fragment_render(:content)
  end

  def test_cms_fragment_render_with_erb
    comfy_cms_fragments(:default).update_column(:content, "<%= 1 + 1 %>")
    assert_equal "&lt;%= 1 + 1 %&gt;", cms_fragment_render(:content)
  end

  def test_cms_fragment_render_with_files
    flunk "todo"
  end

  def test_cms_snippet_content
    assert_equal "snippet content", cms_snippet_content(:default)
    assert_equal "snippet content", cms_snippet_content(:default, @cms_site)
    assert_equal "", cms_snippet_content(:invalid)
  end

  def test_cms_snippet_content_with_site_loading
    @cms_site = nil
    assert_equal "snippet content", cms_snippet_content(:default)
  end

  def test_cms_snippet_render
    assert_equal "snippet content", cms_snippet_render(:default)
  end

  def test_cms_snippet_with_erb
    comfy_cms_snippets(:default).update_column(:content, "<%= 1 + 1 %>")
    assert_equal "&lt;%= 1 + 1 %&gt;", cms_snippet_render(:default)
  end

  def test_cms_snippet_render_with_tags
    comfy_cms_snippets(:default).update_column(:content, "a {{cms:helper hello}} b")
    assert_equal "a hello b", cms_snippet_render(:default)
  end
end
