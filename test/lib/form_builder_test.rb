# frozen_string_literal: true

require_relative "../test_helper"

class FormBuilderTest < ActionView::TestCase

  setup do
    @page = comfy_cms_pages(:default)
    @builder = ComfortableMexicanSofa::FormBuilder.new(:page, @page, self, bootstrap: { layout: "horizontal" })
  end

  def test_fragment_field_for_text
    tag = ComfortableMexicanSofa::Content::Tag::Text.new(context: @page, params: ["test"])
    actual = @builder.fragment_field(tag, 123)
    expected = <<~HTML
      <div class="form-group row">
        <label class="renderable-true col-form-label col-sm-2 text-sm-right" for="fragment-test">Test</label>
        <div class="col-sm-10">
          <input name="page[fragments_attributes][123][identifier]" type="hidden" value="test"/>
          <input name="page[fragments_attributes][123][tag]" type="hidden" value="text"/>
          <input class="form-control" id="fragment-test" name="page[fragments_attributes][123][content]" type="text"/>
        </div>
      </div>
    HTML
    assert_xml_equal expected, actual
  end

  def test_fragment_field_for_text_non_renderable
    tag = ComfortableMexicanSofa::Content::Tag::Text.new(context: @page, params: ["test", { "render" => "false" }])
    actual = @builder.fragment_field(tag, 123)
    expected = <<~HTML
      <div class="form-group row">
        <label class="renderable-false col-form-label col-sm-2 text-sm-right" for="fragment-test">Test</label>
        <div class="col-sm-10">
          <input name="page[fragments_attributes][123][identifier]" type="hidden" value="test"/>
          <input name="page[fragments_attributes][123][tag]" type="hidden" value="text"/>
          <input class="form-control" id="fragment-test" name="page[fragments_attributes][123][content]" type="text"/>
        </div>
      </div>
    HTML
    assert_xml_equal expected, actual
  end

  def test_fragment_field_for_text_with_content
    tag = ComfortableMexicanSofa::Content::Tag::Text.new(context: @page, params: ["content"])
    actual = @builder.fragment_field(tag, 123)
    expected = <<~HTML
      <div class="form-group row">
        <label class="renderable-true col-form-label col-sm-2 text-sm-right" for="fragment-content">Content</label>
        <div class="col-sm-10">
          <input name="page[fragments_attributes][123][identifier]" type="hidden" value="content"/>
          <input name="page[fragments_attributes][123][tag]" type="hidden" value="text"/>
          <input class="form-control" id="fragment-content" name="page[fragments_attributes][123][content]" type="text" value="content"/>
        </div>
      </div>
    HTML
    assert_xml_equal expected, actual
  end

  def test_fragment_field_for_checkbox
    tag = ComfortableMexicanSofa::Content::Tag::Checkbox.new(context: @page, params: ["test"])
    actual = @builder.fragment_field(tag, 123)
    expected = <<~HTML
      <div class="form-group row">
        <label class="renderable-true col-form-label col-sm-2 text-sm-right" for="fragment-test">Test</label>
        <div class="col-sm-10">
          <input name="page[fragments_attributes][123][identifier]" type="hidden" value="test"/>
          <input name="page[fragments_attributes][123][tag]" type="hidden" value="checkbox"/>
          <div class="form-check mt-2">
            <input name="page[fragments_attributes][123][boolean]" type="hidden" value="0"/>
            <input class="form-check-input position-static" id="fragment-test" name="page[fragments_attributes][123][boolean]" type="checkbox" value="1"/>
          </div>
        </div>
      </div>
    HTML
    assert_xml_equal expected, actual
  end

  def test_fragment_field_for_checkbox_with_value
    tag = ComfortableMexicanSofa::Content::Tag::Checkbox.new(context: @page, params: ["boolean"])
    actual = @builder.fragment_field(tag, 123)
    expected = <<~HTML
      <div class="form-group row">
        <label class="renderable-true col-form-label col-sm-2 text-sm-right" for="fragment-boolean">Boolean</label>
        <div class="col-sm-10">
          <input name="page[fragments_attributes][123][identifier]" type="hidden" value="boolean"/>
          <input name="page[fragments_attributes][123][tag]" type="hidden" value="checkbox"/>
          <div class="form-check mt-2">
            <input name="page[fragments_attributes][123][boolean]" type="hidden" value="0"/>
            <input checked="checked" class="form-check-input position-static" id="fragment-boolean" name="page[fragments_attributes][123][boolean]" type="checkbox" value="1"/>
          </div>
        </div>
      </div>
    HTML
    assert_xml_equal expected, actual
  end

  def test_fragment_field_for_date
    tag = ComfortableMexicanSofa::Content::Tag::Date.new(context: @page, params: ["test"])
    actual = @builder.fragment_field(tag, 123)
    expected = <<~HTML
      <div class="form-group row">
        <label class="renderable-true col-form-label col-sm-2 text-sm-right" for="fragment-test">Test</label>
        <div class="col-sm-10">
          <input name="page[fragments_attributes][123][identifier]" type="hidden" value="test"/>
          <input name="page[fragments_attributes][123][tag]" type="hidden" value="date"/>
          <input class="form-control" data-cms-date="true" id="fragment-test" name="page[fragments_attributes][123][datetime]" type="text" value=""/>
        </div>
      </div>
    HTML
    assert_xml_equal expected, actual
  end

  def test_fragment_field_for_datetime
    tag = ComfortableMexicanSofa::Content::Tag::Datetime.new(context: @page, params: ["test"])
    actual = @builder.fragment_field(tag, 123)
    expected = <<~HTML
      <div class="form-group row">
        <label class="renderable-true col-form-label col-sm-2 text-sm-right" for="fragment-test">Test</label>
        <div class="col-sm-10">
          <input name="page[fragments_attributes][123][identifier]" type="hidden" value="test"/>
          <input name="page[fragments_attributes][123][tag]" type="hidden" value="datetime"/>
          <input class="form-control" data-cms-datetime="true" id="fragment-test" name="page[fragments_attributes][123][datetime]" type="text" value=""/>
        </div>
      </div>
    HTML
    assert_xml_equal expected, actual
  end

  def test_fragment_field_for_file
    tag = ComfortableMexicanSofa::Content::Tag::File.new(context: @page, params: ["test"])
    actual = @builder.fragment_field(tag, 123)
    expected = <<~HTML
      <div class="form-group row">
        <label class="renderable-true col-form-label col-sm-2 text-sm-right" for="fragment-test">Test</label>
        <div class="col-sm-10">
          <input name="page[fragments_attributes][123][identifier]" type="hidden" value="test"/>
          <input name="page[fragments_attributes][123][tag]" type="hidden" value="file"/>
          <input class="form-control" id="fragment-test" name="page[fragments_attributes][123][files]" type="file"/>
          <div class="fragment-attachments"></div>
        </div>
      </div>
    HTML
    assert_xml_equal expected, actual
  end

  def test_fragment_field_for_file_with_content
    tag = ComfortableMexicanSofa::Content::Tag::File.new(context: @page, params: ["file"])
    actual = @builder.fragment_field(tag, 123)

    attachment = active_storage_attachments(:file)
    attachment_url  = view.url_for(attachment)
    thumb_url       = view.url_for(attachment.variant(combine_options: Comfy::Cms::File::VARIANT_SIZE[:thumb]))

    expected = <<~HTML
      <div class="form-group row">
        <label class="renderable-true col-form-label col-sm-2 text-sm-right" for="fragment-file">File</label>
        <div class="col-sm-10">
          <input name="page[fragments_attributes][123][identifier]" type="hidden" value="file"/>
          <input name="page[fragments_attributes][123][tag]" type="hidden" value="file"/>
          <input class="form-control" id="fragment-file" name="page[fragments_attributes][123][files]" type="file"/>
          <div class="fragment-attachments">
            <div class="fragment-attachment btn-group btn-group-sm mb-1">
              <a class="btn btn-light text-truncate" data-cms-file-link-tag="{{ cms:page_file_link file, as: image }}" data-cms-file-thumb-url="#{thumb_url}" href="#{attachment_url}" target="_blank">fragment.jpg</a>
              <input id="attachment_211760658" name="page[fragments_attributes][123][file_ids_destroy][]" type="checkbox" value="211760658"/>
              <label class="btn btn-light" for="attachment_211760658">
                <i class="fas fa-fw fa-times"/>
              </label>
            </div>
          </div>
        </div>
      </div>
    HTML
    assert_xml_equal expected, actual
  end

  def test_fragment_field_for_files
    tag = ComfortableMexicanSofa::Content::Tag::Files.new(context: @page, params: ["test"])
    actual = @builder.fragment_field(tag, 123)
    expected = <<~HTML
      <div class="form-group row">
        <label class="renderable-true col-form-label col-sm-2 text-sm-right" for="fragment-test">Test</label>
        <div class="col-sm-10">
          <input name="page[fragments_attributes][123][identifier]" type="hidden" value="test"/>
          <input name="page[fragments_attributes][123][tag]" type="hidden" value="files"/>
          <input class="form-control" id="fragment-test" multiple="multiple" name="page[fragments_attributes][123][files][]" type="file"/>
          <div class="fragment-attachments"></div>
        </div>
      </div>
    HTML
    assert_xml_equal expected, actual
  end

  def test_fragment_field_for_files_with_content
    tag = ComfortableMexicanSofa::Content::Tag::Files.new(context: @page, params: ["file"])
    actual = @builder.fragment_field(tag, 123)

    attachment = active_storage_attachments(:file)
    attachment_url  = view.url_for(attachment)
    thumb_url       = view.url_for(attachment.variant(combine_options: Comfy::Cms::File::VARIANT_SIZE[:thumb]))

    expected = <<~HTML
      <div class="form-group row">
        <label class="renderable-true col-form-label col-sm-2 text-sm-right" for="fragment-file">File</label>
        <div class="col-sm-10">
          <input name="page[fragments_attributes][123][identifier]" type="hidden" value="file"/>
          <input name="page[fragments_attributes][123][tag]" type="hidden" value="files"/>
          <input class="form-control" id="fragment-file" multiple="multiple" name="page[fragments_attributes][123][files][]" type="file"/>
          <div class="fragment-attachments">
            <div class="fragment-attachment btn-group btn-group-sm mb-1">
              <a class="btn btn-light text-truncate" data-cms-file-link-tag="{{ cms:page_file_link file, filename: &quot;fragment.jpg&quot;, as: image }}" data-cms-file-thumb-url="#{thumb_url}" href="#{attachment_url}" target="_blank">fragment.jpg</a>
              <input id="attachment_211760658" name="page[fragments_attributes][123][file_ids_destroy][]" type="checkbox" value="211760658"/>
              <label class="btn btn-light" for="attachment_211760658">
                <i class="fas fa-fw fa-times"/>
              </label>
            </div>
          </div>
        </div>
      </div>
    HTML
    assert_xml_equal expected, actual
  end

  def test_fragment_field_for_markdown
    tag = ComfortableMexicanSofa::Content::Tag::Markdown.new(context: @page, params: ["test"])
    actual = @builder.fragment_field(tag, 123)
    expected = <<~HTML
      <div class="form-group row">
        <label class="renderable-true col-form-label col-sm-2 text-sm-right" for="fragment-test">Test</label>
        <div class="col-sm-10">
          <input name="page[fragments_attributes][123][identifier]" type="hidden" value="test"/>
          <input name="page[fragments_attributes][123][tag]" type="hidden" value="markdown"/>
          <textarea data-cms-cm-mode="text/x-markdown" id="fragment-test" name="page[fragments_attributes][123][content]"></textarea>
        </div>
      </div>
    HTML
    assert_xml_equal expected, actual
  end

  def test_fragment_field_for_number
    tag = ComfortableMexicanSofa::Content::Tag::Number.new(context: @page, params: ["test"])
    actual = @builder.fragment_field(tag, 123)
    expected = <<~HTML
      <div class="form-group row">
        <label class="renderable-true col-form-label col-sm-2 text-sm-right" for="fragment-test">Test</label>
        <div class="col-sm-10">
          <input name="page[fragments_attributes][123][identifier]" type="hidden" value="test"/>
          <input name="page[fragments_attributes][123][tag]" type="hidden" value="number"/>
          <input class="form-control" id="fragment-test" name="page[fragments_attributes][123][content]" type="number"/>
        </div>
      </div>
    HTML
    assert_xml_equal expected, actual
  end

  def test_fragment_field_for_textarea
    tag = ComfortableMexicanSofa::Content::Tag::File.new(context: @page, params: ["test"])
    actual = @builder.fragment_field(tag, 123)
    expected = <<~HTML
      <div class="form-group row">
        <label class="renderable-true col-form-label col-sm-2 text-sm-right" for="fragment-test">Test</label>
        <div class="col-sm-10">
          <input name="page[fragments_attributes][123][identifier]" type="hidden" value="test"/>
          <input name="page[fragments_attributes][123][tag]" type="hidden" value="file"/>
          <input class="form-control" id="fragment-test" name="page[fragments_attributes][123][files]" type="file"/>
          <div class="fragment-attachments"></div>
        </div>
      </div>
    HTML
    assert_xml_equal expected, actual
  end

  def test_fragment_field_for_wysiwyg
    tag = ComfortableMexicanSofa::Content::Tag::Wysiwyg.new(context: @page, params: ["test"])
    actual = @builder.fragment_field(tag, 123)
    expected = <<~HTML
      <div class="form-group row">
        <label class="renderable-true col-form-label col-sm-2 text-sm-right" for="fragment-test">Test</label>
        <div class="col-sm-10">
          <input name="page[fragments_attributes][123][identifier]" type="hidden" value="test"/>
          <input name="page[fragments_attributes][123][tag]" type="hidden" value="wysiwyg"/>
          <textarea data-cms-rich-text="true" id="fragment-test" name="page[fragments_attributes][123][content]"></textarea>
        </div>
      </div>
    HTML
    assert_xml_equal expected, actual
  end

  def test_form_actions
    actual = @builder.form_actions do
      "test"
    end
    expected = <<~HTML
      <div class="form-actions row bg-light">
        <div class="col-lg-8 offset-lg-2">
          <div class="form-group row mb-0">
            <div class="col-sm-10 offset-sm-2">test</div>
          </div>
        </div>
      </div>
    HTML
    assert_xml_equal expected, actual
  end

end
