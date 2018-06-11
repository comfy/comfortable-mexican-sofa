# frozen_string_literal: true

require_relative "../test_helper"

class AdminCmsHelpersTest < ActionView::TestCase

  include Comfy::Admin::CmsHelper
  include ComfyBootstrapForm::ViewHelper

  setup do
    @file = comfy_cms_files(:default)
  end

  def test_comfy_form_with
    actual = comfy_form_with(url: "/test") do |form|
      form.text_field :foo
    end
    expected = <<-HTML.gsub(%r{^\s+|\n}, "")
      <form action="/test" accept-charset="UTF-8" method="post">
        <input name="utf8" type="hidden" value="&#x2713;" />
        <div class="form-group row">
          <label class="col-form-label col-sm-2 text-sm-right" for="foo">Foo</label>
          <div class="col-sm-10">
            <input class="form-control" type="text" name="foo" id="foo" />
          </div>
        </div>
      </form>
    HTML
    assert_equal expected, actual
  end

  def test_comfy_admin_partial
    actual = comfy_admin_partial("path/to/partial", foo: "bar")
    assert_nil actual

    ComfortableMexicanSofa.config.reveal_cms_partials = true
    actual = comfy_admin_partial("path/to/partial", foo: "bar")
    expected = '<div class="comfy-admin-partial">path/to/partial</div>'
    assert_equal expected, actual
  end

  def test_cms_page_file_link_tag
    actual = cms_page_file_link_tag(
      fragment_id: "test",
      attachment:   @file.attachment,
      multiple:     false
    )
    assert_equal "{{ cms:page_file_link test, as: image }}", actual
  end

  def test_cms_page_file_link_tag_non_image
    @file.attachment.blob.update_column(:content_type, "application/pdf")
    actual = cms_page_file_link_tag(
      fragment_id: "test",
      attachment:   @file.attachment,
      multiple:     false
    )
    assert_equal "{{ cms:page_file_link test }}", actual
  end

  def test_cms_page_file_link_multiple
    actual = cms_page_file_link_tag(
      fragment_id:  "test",
      attachment:   @file.attachment,
      multiple:     true
    )
    assert_equal '{{ cms:page_file_link test, filename: "default.jpg", as: image }}', actual
  end

  def test_cms_file_link_tag
    actual = cms_file_link_tag(@file)
    assert_equal "{{ cms:file_link 593363170, as: image }}", actual
  end

  def test_cms_file_link_tag_non_image
    @file.attachment.blob.update_column(:content_type, "application/pdf")
    actual = cms_file_link_tag(@file)
    assert_equal "{{ cms:file_link 593363170 }}", actual
  end

end
