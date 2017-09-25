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
    @template = ComfortableMexicanSofa::Content::Template.new(comfy_cms_pages(:default))

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
      "fragment"    => ComfortableMexicanSofa::Content::Tag::Fragment,
      "test"        => ContentTemplateTest::TestTag,
      "test_nested" => ContentTemplateTest::TestNestedTag,
      "test_block"  => ContentTemplateTest::TestBlockTag
    }), ComfortableMexicanSofa::Content::Template.tags
  end

  def test_register_tags
    ComfortableMexicanSofa::Content::Template.register_tag(:other, TestTag)
    assert_equal ({
      "fragment"    => ComfortableMexicanSofa::Content::Tag::Fragment,
      "test"        => ContentTemplateTest::TestTag,
      "test_nested" => ContentTemplateTest::TestNestedTag,
      "test_block"  => ContentTemplateTest::TestBlockTag,
      "other"       => ContentTemplateTest::TestTag
    }), ComfortableMexicanSofa::Content::Template.tags
  ensure
    ComfortableMexicanSofa::Content::Template.tags.delete("other")
  end

  def test_tokenize
    assert_equal ["test text"], @template.tokenize("test text")
  end

  def test_tokenize_with_tag
    assert_equal ["test ", {tag_class: "tag", tag_params: ""}, " text"],
      @template.tokenize("test {{cms:tag}} text")
  end

  def test_tokenize_with_tag_and_params
    assert_equal ["test ", {tag_class: "tag", tag_params: "name, key:val"}, " text"],
      @template.tokenize("test {{cms:tag name, key:val}} text")
  end

  def test_tokenize_with_invalid_tag
    assert_equal ["test {{abc:tag}} text"],
      @template.tokenize("test {{abc:tag}} text")
  end

  def test_nodes
    tokens = @template.tokenize("test")
    nodes = @template.nodes(tokens)
    assert_equal ["test"], nodes
  end

  def test_nodes_with_tags
    tokens = @template.tokenize("test {{cms:test}} content {{cms:test}}")
    nodes = @template.nodes(tokens)
    assert_equal 4, nodes.count
    assert_equal "test ", nodes[0]
    assert nodes[1].is_a?(ContentTemplateTest::TestTag)
    assert_equal " content ", nodes[2]
    assert nodes[3].is_a?(ContentTemplateTest::TestTag)
  end

  def test_nodes_with_block_tag
    string = "a {{cms:test_block}} b {{cms:end}} c"
    tokens = @template.tokenize(string)
    nodes = @template.nodes(tokens)
    assert_equal 3, nodes.count

    assert_equal "a ", nodes[0]
    assert_equal " c", nodes[2]

    block = nodes[1]
    assert block.is_a?(ContentTemplateTest::TestBlockTag)
    assert_equal [" b "], block.nodes
  end

  def test_nodes_with_block_tag_and_tag
    string = "a {{cms:test_block}} b {{cms:test}} c {{cms:end}} d"
    tokens = @template.tokenize(string)
    nodes = @template.nodes(tokens)
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
    tokens = @template.tokenize(string)
    nodes = @template.nodes(tokens)
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
    tokens = @template.tokenize(string)
    assert_exception_raised ComfortableMexicanSofa::Content::Template::SyntaxError, "unclosed block detected" do
      @template.nodes(tokens)
    end
  end

  def test_nodes_with_closed_tag
    string = "a {{cms:end}} b"
    tokens = @template.tokenize(string)
    assert_exception_raised ComfortableMexicanSofa::Content::Template::SyntaxError, "closing unopened block" do
      @template.nodes(tokens)
    end
  end

  def test_render
    out = @template.render("test")
    assert_equal "test", out
  end

  def test_render_with_tag
    comfy_cms_blocks(:default_page_text).update_column(:content, "fragment content")
    out = @template.render("a {{cms:fragment default_page_text}} z")
    assert_equal "a fragment content z", out
  end
end
