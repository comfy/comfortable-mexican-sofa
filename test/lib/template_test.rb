require_relative '../test_helper'

class TemplateTest < ActiveSupport::TestCase

  class TestTag
    def initialize(params)
      # todo
    end
    def render
      "test tag content"
    end
  end

  ComfortableMexicanSofa::Template.register_tag(:test, TestTag)

  def test_tags
    assert_equal ({"test" => TemplateTest::TestTag}), ComfortableMexicanSofa::Template.tags
  end

  def test_register_tags
    ComfortableMexicanSofa::Template.register_tag(:other, Object)
    assert_equal ({
      "test"  => TemplateTest::TestTag,
      "other" => Object
    }), ComfortableMexicanSofa::Template.tags
  ensure
    ComfortableMexicanSofa::Template.tags.delete("other")
  end

  def test_tokenize
    string = "test text"
    t = ComfortableMexicanSofa::Template.new(string)
    assert_equal ["test text"], t.tokenize
  end

  def test_tokenize_with_tag
    string = "test {{cms:tag}} text"
    t = ComfortableMexicanSofa::Template.new(string)
    assert_equal ["test ", {tag_class: "tag", tag_params: ""}, " text"], t.tokenize
  end

  def test_tokenize_with_tag_and_params
    string = "test {{cms:tag name, key:val}} text"
    t = ComfortableMexicanSofa::Template.new(string)
    assert_equal ["test ", {tag_class: "tag", tag_params: "name, key:val"}, " text"], t.tokenize
  end

  def test_tokenize_with_invalid_tag
    string = "test {{abc:tag}} text"
    t = ComfortableMexicanSofa::Template.new(string)
    assert_equal ["test {{abc:tag}} text"], t.tokenize
  end

  def test_expand
    string = "test {{cms:test}} text"
    t = ComfortableMexicanSofa::Template.new(string)
    t.tokenize
    assert_equal ["test ", "test tag content", " text"], t.expand
  end

end