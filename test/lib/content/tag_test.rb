require_relative "../../test_helper"

class ContentTagTest < ActiveSupport::TestCase

  class TestTag < ComfortableMexicanSofa::Content::Tag
    def content
      "test tag content"
    end
  end

  class TestNestedTag < ComfortableMexicanSofa::Content::Tag
    def content
      "test {{cms:test}} content"
    end
  end

  setup do
    ComfortableMexicanSofa::Content::Renderer.register_tag(:test, TestTag)
    ComfortableMexicanSofa::Content::Renderer.register_tag(:test_nested, TestNestedTag)
  end

  teardown do
    ComfortableMexicanSofa::Content::Renderer.tags.delete("test")
    ComfortableMexicanSofa::Content::Renderer.tags.delete("test_nested")
  end

  # -- Tests -------------------------------------------------------------------

  def test_init_with_params
    tag = TestTag.new(nil, "param_a, key: value")
    assert_equal ["param_a", {"key"=>"value"}], tag.params
  end

  def test_nodes
    tag = TestTag.new(nil, "")
    assert_equal ["test tag content"], tag.nodes
  end

  def test_tag_nodes_with_nested_tag
    tag = TestNestedTag.new(nil, "")
    nodes = tag.nodes
    assert_equal 3, nodes.count
    assert_equal "test ", nodes[0]
    assert nodes[1].is_a?(ContentTagTest::TestTag)
    assert_equal " content", nodes[2]
  end
end
