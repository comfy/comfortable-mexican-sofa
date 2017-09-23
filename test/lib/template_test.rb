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

  class TestBlockTag < BlockTag
    # ????
  end
  ComfortableMexicanSofa::Template.register_tag(:test_block, TestBlockTag)

  # -- Tests -------------------------------------------------------------------
  def test_tags
    assert_equal ({
      "test"        => TemplateTest::TestTag,
      "test_nested" => TemplateTest::TestNestedTag,
      "test_block"  => TemplateTest::TestBlockTag
    }), ComfortableMexicanSofa::Template.tags
  end

  def test_register_tags
    ComfortableMexicanSofa::Template.register_tag(:other, TestTag)
    assert_equal ({
      "test"        => TemplateTest::TestTag,
      "test_nested" => TemplateTest::TestNestedTag,
      "test_block"  => TemplateTest::TestBlockTag,
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

  def test_nodes_with_block_tag
    string = "a {{cms:test_block}} b {{cms:end}} c"
    tokens = ComfortableMexicanSofa::Template.tokenize(string)
    nodes = ComfortableMexicanSofa::Template.nodes(nil, tokens)
    assert_equal 3, nodes.count

    assert_equal "a ", nodes[0]
    assert_equal " c", nodes[2]

    block = nodes[1]
    assert block.is_a?(TemplateTest::TestBlockTag)
    assert_equal [" b "], block.nodes
  end

  def test_nodes_with_block_tag_and_tag
    string = "a {{cms:test_block}} b {{cms:test}} c {{cms:end}} d"
    tokens = ComfortableMexicanSofa::Template.tokenize(string)
    nodes = ComfortableMexicanSofa::Template.nodes(nil, tokens)
    assert_equal 3, nodes.count
    assert_equal "a ", nodes[0]
    assert_equal " d", nodes[2]

    block = nodes[1]
    assert block.is_a?(TemplateTest::TestBlockTag)
    assert_equal 3, block.nodes.count
    assert_equal " b ", block.nodes[0]
    assert_equal " c ", block.nodes[2]

    tag = block.nodes[1]
    assert tag.is_a?(TemplateTest::TestTag)
    assert_equal ["test tag content"], tag.nodes
  end

  def test_nodes_with_nested_block_tag
    string = "a {{cms:test_block}} b {{cms:test_block}} c {{cms:end}} d {{cms:end}} e"
    tokens = ComfortableMexicanSofa::Template.tokenize(string)
    nodes = ComfortableMexicanSofa::Template.nodes(nil, tokens)
    assert_equal 3, nodes.count
    assert_equal "a ", nodes[0]
    assert_equal " e", nodes[2]

    block = nodes[1]
    assert block.is_a?(TemplateTest::TestBlockTag)
    assert_equal 3, block.nodes.count
    assert_equal " b ", block.nodes[0]
    assert_equal " d ", block.nodes[2]

    block = block.nodes[1]
    assert_equal [" c "], block.nodes
  end

  def test_nodes_with_unclosed_block_tag
    string = "a {{cms:test_block}} b"
    tokens = ComfortableMexicanSofa::Template.tokenize(string)
    assert_exception_raised ComfortableMexicanSofa::Template::SyntaxError, "unclosed block detected" do
      ComfortableMexicanSofa::Template.nodes(nil, tokens)
    end
  end

  def test_nodes_with_closed_tag
    string = "a {{cms:end}} b"
    tokens = ComfortableMexicanSofa::Template.tokenize(string)
    assert_exception_raised ComfortableMexicanSofa::Template::SyntaxError, "closing unopened block" do
      ComfortableMexicanSofa::Template.nodes(nil, tokens)
    end
  end

  def test_block_tag_nodes
    block = BlockTag.new(nil)
    assert_equal [], block.nodes
    block.nodes << "text"
    assert_equal ["text"], block.nodes
  end

end