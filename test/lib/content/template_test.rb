require_relative '../../test_helper'

class ContentTemplateTest < ActiveSupport::TestCase

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

  class TestBlockTag < ComfortableMexicanSofa::Content::Block
    # ...
  end

  setup do
    ComfortableMexicanSofa::Content::Template.register_tag(:test, TestTag)
    ComfortableMexicanSofa::Content::Template.register_tag(:test_nested, TestNestedTag)
    ComfortableMexicanSofa::Content::Template.register_tag(:test_block, TestBlockTag)
  end

  teardown do
    ComfortableMexicanSofa::Content::Template.tags.delete("test")
    ComfortableMexicanSofa::Content::Template.tags.delete("test_nested")
    ComfortableMexicanSofa::Content::Template.tags.delete("test_block")
  end

  # -- Tests -------------------------------------------------------------------

  def test_tags
    assert_equal ({
      "test"        => ContentTemplateTest::TestTag,
      "test_nested" => ContentTemplateTest::TestNestedTag,
      "test_block"  => ContentTemplateTest::TestBlockTag
    }), ComfortableMexicanSofa::Content::Template.tags
  end

  def test_register_tags
    ComfortableMexicanSofa::Content::Template.register_tag(:other, TestTag)
    assert_equal ({
      "test"        => ContentTemplateTest::TestTag,
      "test_nested" => ContentTemplateTest::TestNestedTag,
      "test_block"  => ContentTemplateTest::TestBlockTag,
      "other"       => ContentTemplateTest::TestTag
    }), ComfortableMexicanSofa::Content::Template.tags
  ensure
    ComfortableMexicanSofa::Content::Template.tags.delete("other")
  end

  def test_tokenize
    assert_equal ["test text"],
      ComfortableMexicanSofa::Content::Template.tokenize("test text")
  end

  def test_tokenize_with_tag
    assert_equal ["test ", {tag_class: "tag", tag_params: ""}, " text"],
      ComfortableMexicanSofa::Content::Template.tokenize("test {{cms:tag}} text")
  end

  def test_tokenize_with_tag_and_params
    assert_equal ["test ", {tag_class: "tag", tag_params: "name, key:val"}, " text"],
      ComfortableMexicanSofa::Content::Template.tokenize("test {{cms:tag name, key:val}} text")
  end

  def test_tokenize_with_invalid_tag
    assert_equal ["test {{abc:tag}} text"],
      ComfortableMexicanSofa::Content::Template.tokenize("test {{abc:tag}} text")
  end

  def test_nodes
    tokens = ComfortableMexicanSofa::Content::Template.tokenize("test")
    nodes = ComfortableMexicanSofa::Content::Template.nodes(nil, tokens)
    assert_equal ["test"], nodes
  end

  def test_nodes_with_tags
    tokens = ComfortableMexicanSofa::Content::Template.tokenize("test {{cms:test}} content {{cms:test}}")
    nodes = ComfortableMexicanSofa::Content::Template.nodes(nil, tokens)
    assert_equal 4, nodes.count
    assert_equal "test ", nodes[0]
    assert nodes[1].is_a?(ContentTemplateTest::TestTag)
    assert_equal " content ", nodes[2]
    assert nodes[3].is_a?(ContentTemplateTest::TestTag)
  end

  def test_nodes_with_block_tag
    string = "a {{cms:test_block}} b {{cms:end}} c"
    tokens = ComfortableMexicanSofa::Content::Template.tokenize(string)
    nodes = ComfortableMexicanSofa::Content::Template.nodes(nil, tokens)
    assert_equal 3, nodes.count

    assert_equal "a ", nodes[0]
    assert_equal " c", nodes[2]

    block = nodes[1]
    assert block.is_a?(ContentTemplateTest::TestBlockTag)
    assert_equal [" b "], block.nodes
  end

  def test_nodes_with_block_tag_and_tag
    string = "a {{cms:test_block}} b {{cms:test}} c {{cms:end}} d"
    tokens = ComfortableMexicanSofa::Content::Template.tokenize(string)
    nodes = ComfortableMexicanSofa::Content::Template.nodes(nil, tokens)
    assert_equal 3, nodes.count
    assert_equal "a ", nodes[0]
    assert_equal " d", nodes[2]

    block = nodes[1]
    assert block.is_a?(ContentTemplateTest::TestBlockTag)
    assert_equal 3, block.nodes.count
    assert_equal " b ", block.nodes[0]
    assert_equal " c ", block.nodes[2]

    tag = block.nodes[1]
    assert tag.is_a?(ContentTemplateTest::TestTag)
    assert_equal ["test tag content"], tag.nodes
  end

  def test_nodes_with_nested_block_tag
    string = "a {{cms:test_block}} b {{cms:test_block}} c {{cms:end}} d {{cms:end}} e"
    tokens = ComfortableMexicanSofa::Content::Template.tokenize(string)
    nodes = ComfortableMexicanSofa::Content::Template.nodes(nil, tokens)
    assert_equal 3, nodes.count
    assert_equal "a ", nodes[0]
    assert_equal " e", nodes[2]

    block = nodes[1]
    assert block.is_a?(ContentTemplateTest::TestBlockTag)
    assert_equal 3, block.nodes.count
    assert_equal " b ", block.nodes[0]
    assert_equal " d ", block.nodes[2]

    block = block.nodes[1]
    assert_equal [" c "], block.nodes
  end

  def test_nodes_with_unclosed_block_tag
    string = "a {{cms:test_block}} b"
    tokens = ComfortableMexicanSofa::Content::Template.tokenize(string)
    assert_exception_raised ComfortableMexicanSofa::Content::Template::SyntaxError, "unclosed block detected" do
      ComfortableMexicanSofa::Content::Template.nodes(nil, tokens)
    end
  end

  def test_nodes_with_closed_tag
    string = "a {{cms:end}} b"
    tokens = ComfortableMexicanSofa::Content::Template.tokenize(string)
    assert_exception_raised ComfortableMexicanSofa::Content::Template::SyntaxError, "closing unopened block" do
      ComfortableMexicanSofa::Content::Template.nodes(nil, tokens)
    end
  end
end
