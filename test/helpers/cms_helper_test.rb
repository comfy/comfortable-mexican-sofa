# frozen_string_literal: true

require_relative "../test_helper"

class CmsHelperTest < ActionView::TestCase

  include Comfy::CmsHelper

  module TestViewHelpers

    def hello
      "hello"
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

  def test_cms_fragment_content_with_datetime
    frag = comfy_cms_fragments(:datetime)
    assert_equal "datetime", frag.tag
    assert_equal "1981-10-04 12:34:56 UTC", cms_fragment_content(frag.identifier).to_s
  end

  def test_cms_fragment_content_with_date
    frag = comfy_cms_fragments(:datetime)
    frag.update_columns(tag: "date", datetime: "2017-01-01")
    assert_equal "2017-01-01 00:00:00 UTC", cms_fragment_content(frag.identifier).to_s
  end

  def test_cms_fragment_content_with_boolean
    frag = comfy_cms_fragments(:boolean)
    assert_equal true, cms_fragment_content(frag.identifier)
  end

  def test_cms_fragment_content_with_files
    frag = comfy_cms_fragments(:file)
    assert_equal frag.attachments.to_a, cms_fragment_content(frag.identifier).to_a
  end

  def test_cms_fragment_render
    assert_equal "content", cms_fragment_render(:content)
    assert_equal "", cms_fragment_render(:invalid)
  end

  def test_cms_fragment_render_unrenderable
    comfy_cms_layouts(:default).update_column(:content, "{{cms:textarea content, render: false}}")
    assert_equal "content", cms_fragment_render(:content)
  end

  def test_cms_fragment_render_with_tags
    comfy_cms_fragments(:default).update_column(:content, "a {{cms:helper hello }} b")
    assert_equal "a hello b", cms_fragment_render(:content)
  end

  def test_cms_fragment_render_with_erb
    comfy_cms_fragments(:default).update_column(:content, "<%= 1 + 1 %>")
    assert_equal "&lt;%= 1 + 1 %&gt;", cms_fragment_render(:content)
  end

  def test_cms_fragment_render_with_datetime
    comfy_cms_layouts(:default).update_column(:content, "{{cms:datetime datetime}}")
    assert_equal "1981-10-04 12:34:56 UTC", cms_fragment_render(:datetime)
  end

  def test_cms_fragment_render_with_boolean
    comfy_cms_layouts(:default).update_column(:content, "{{cms:checkbox boolean}}")
    assert_equal "true", cms_fragment_render(:boolean)
  end

  def test_cms_fragment_render_with_files
    frag = comfy_cms_fragments(:file)
    comfy_cms_layouts(:default).update_column(:content, "{{cms:file file}}")
    assert_equal url_for(frag.attachments.first), cms_fragment_render(:file)
  end

  def test_cms_snippet_content
    assert_equal "snippet content", cms_snippet_content(:default)
    assert_equal "snippet content", cms_snippet_content(:default, @cms_site)
    assert_equal "", cms_snippet_content(:invalid)
  end

  def test_cms_snippet_content_with_site_detection
    @cms_site = nil
    assert_equal "snippet content", cms_snippet_content(:default)
  end

  def test_cms_snippet_render
    assert_equal "snippet content", cms_snippet_render(:default)
  end

  def test_cms_snippet_render_with_tags_and_context
    file = comfy_cms_files(:default)
    comfy_cms_snippets(:default).update_column(:content, "{{cms:file_link #{file.id}}}")
    assert_equal rails_blob_path(file.attachment, only_path: true), cms_snippet_render(:default)
  end

  def test_cms_snippet_with_erb
    comfy_cms_snippets(:default).update_column(:content, "<%= 1 + 1 %>")
    assert_equal "&lt;%= 1 + 1 %&gt;", cms_snippet_render(:default)
  end

  def test_cms_snippet_render_with_tags
    comfy_cms_snippets(:default).update_column(:content, "a {{cms:helper hello}} b")
    assert_equal "a hello b", cms_snippet_render(:default)
  end

  def test_cms_site_detect
    site = comfy_cms_sites(:default)
    site.update_column(:path, "/en")
    assert_equal site, cms_site_detect

    site_b = Comfy::Cms::Site.create!(
      label:      "with path",
      identifier: "with-path",
      hostname:   site.hostname,
      path:       "fr"
    )
    request.fullpath = "/fr"
    assert_equal site_b, cms_site_detect

    site_b.update_columns(hostname: "site_b.com", path: "en")
    request.host_with_port  = "site_b.com"
    request.fullpath        = "/en"
    assert_equal site_b, cms_site_detect
  end

end
