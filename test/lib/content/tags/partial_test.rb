# frozen_string_literal: true

require_relative "../../../test_helper"

class ContentTagsPartialTest < ActiveSupport::TestCase

  def test_init
    tag = ComfortableMexicanSofa::Content::Tag::Partial.new(
      context: @page,
      params: ["path/to/partial"]
    )
    assert_equal "path/to/partial", tag.path
    assert_equal ({}), tag.locals
  end

  def test_init_with_locals
    tag = ComfortableMexicanSofa::Content::Tag::Partial.new(
      context: @page,
      params: ["path/to/partial", { "key" => "val" }]
    )
    assert_equal "path/to/partial", tag.path
    assert_equal ({ "key" => "val" }), tag.locals
  end

  def test_init_without_path
    message = "Missing path for partial tag"
    assert_exception_raised ComfortableMexicanSofa::Content::Tag::Error, message do
      ComfortableMexicanSofa::Content::Tag::Partial.new(
        context: @page,
        params: [{ "key" => "val" }]
      )
    end
  end

  def test_content
    tag = ComfortableMexicanSofa::Content::Tag::Partial.new(
      context: @page,
      params: ["path/to/partial", { "key" => "val" }]
    )
    assert_equal "<%= render partial: \"path/to/partial\", locals: {\"key\"=>\"val\"} %>", tag.content
  end

  def test_render
    tag = ComfortableMexicanSofa::Content::Tag::Partial.new(
      context: @page,
      params: ["path/to/partial", { "key" => "val" }]
    )
    assert_equal "<%= render partial: \"path/to/partial\", locals: {\"key\"=>\"val\"} %>", tag.render
  end

  def test_render_with_whitelist
    ComfortableMexicanSofa.config.allowed_partials = ["safe/path"]

    tag = ComfortableMexicanSofa::Content::Tag::Partial.new(
      context: @page,
      params: ["path/to/partial"]
    )
    assert_equal "", tag.render

    tag = ComfortableMexicanSofa::Content::Tag::Partial.new(
      context: @page,
      params: ["safe/path"]
    )
    assert_equal "<%= render partial: \"safe/path\", locals: {} %>", tag.render
  end

  def test_render_with_erb_injection
    tag = ComfortableMexicanSofa::Content::Tag::Partial.new(
      context: @page,
      params: ["foo\#{:bar}", { "key" => "va\#{:l}ue" }]
    )
    assert_equal "<%= render partial: \"foo\\\#{:bar}\", locals: {\"key\"=>\"va\\\#{:l}ue\"} %>", tag.render
  end

end
