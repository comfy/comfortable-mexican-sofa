# frozen_string_literal: true

require_relative "../test_helper"

class FormBuilderTest < ActionView::TestCase

  setup do
    @page = Comfy::Cms::Page.new
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

end
