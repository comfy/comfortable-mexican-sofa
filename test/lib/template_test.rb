require_relative '../test_helper'

class TemplateTest < ActiveSupport::TestCase

  class TestTag < NewTag
    def content
      "test tag content"
    end
  end
  ComfortableMexicanSofa::Template.register_tag(:test, TestTag)

  class TestNestedTag < NewTag
    def content
      "test {{cms:test}} content"
    end
  end
  ComfortableMexicanSofa::Template.register_tag(:test_nested, TestNestedTag)

  # -- Tests -------------------------------------------------------------------
  def test_tags
    assert_equal ({
      "test"        => TemplateTest::TestTag,
      "test_nested" => TemplateTest::TestNestedTag
    }), ComfortableMexicanSofa::Template.tags
  end

  def test_register_tags
    ComfortableMexicanSofa::Template.register_tag(:other, TestTag)
    assert_equal ({
      "test"        => TemplateTest::TestTag,
      "test_nested" => TemplateTest::TestNestedTag,
      "other"       => TemplateTest::TestTag
    }), ComfortableMexicanSofa::Template.tags
  ensure
    ComfortableMexicanSofa::Template.tags.delete("other")
  end

  def test_tokenize
    assert_equal ["test text"], ComfortableMexicanSofa::Template.tokenize("test text")
  end

  def test_tokenize_with_tag
    assert_equal ["test ", {tag_class: "tag", tag_params: ""}, " text"],
      ComfortableMexicanSofa::Template.tokenize("test {{cms:tag}} text")
  end

  def test_tokenize_with_tag_and_params
    assert_equal ["test ", {tag_class: "tag", tag_params: "name, key:val"}, " text"],
      ComfortableMexicanSofa::Template.tokenize("test {{cms:tag name, key:val}} text")
  end

  def test_tokenize_with_invalid_tag
    assert_equal ["test {{abc:tag}} text"],
      ComfortableMexicanSofa::Template.tokenize("test {{abc:tag}} text")
  end

  def test_nodes
    tokens = ComfortableMexicanSofa::Template.tokenize("test")
    nodes = ComfortableMexicanSofa::Template.nodes(nil, tokens)
    assert_equal ["test"], nodes
  end

  def test_nodes_with_tags
    tokens = ComfortableMexicanSofa::Template.tokenize("test {{cms:test}} content {{cms:test}}")
    nodes = ComfortableMexicanSofa::Template.nodes(nil, tokens)
    assert_equal 4, nodes.count
    assert_equal "test ", nodes[0]
    assert nodes[1].is_a?(TemplateTest::TestTag)
    assert_equal " content ", nodes[2]
    assert nodes[3].is_a?(TemplateTest::TestTag)
  end

  # TODO: move this
  def test_tag_nodes
    tag = TestTag.new(nil)
    assert_equal ["test tag content"], tag.nodes
  end

  def test_tag_nodes_with_nested_tag
    tag = TestNestedTag.new(nil)
    nodes = tag.nodes
    assert_equal 3, nodes.count
    assert_equal "test ", nodes[0]
    assert nodes[1].is_a?(TemplateTest::TestTag)
    assert_equal " content", nodes[2]
  end

end