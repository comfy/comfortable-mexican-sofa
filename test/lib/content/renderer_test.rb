require_relative '../../test_helper'

class ContentRendererTest < ActiveSupport::TestCase

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
    @template = ComfortableMexicanSofa::Content::Renderer.new(comfy_cms_pages(:default))

    ComfortableMexicanSofa::Content::Renderer.register_tag(:test, TestTag)
    ComfortableMexicanSofa::Content::Renderer.register_tag(:test_nested, TestNestedTag)
    ComfortableMexicanSofa::Content::Renderer.register_tag(:test_block, TestBlockTag)
  end

  teardown do
    ComfortableMexicanSofa::Content::Renderer.tags.delete("test")
    ComfortableMexicanSofa::Content::Renderer.tags.delete("test_nested")
    ComfortableMexicanSofa::Content::Renderer.tags.delete("test_block")
  end

  # -- Tests -------------------------------------------------------------------

  def test_tags
    assert_equal ({
      "fragment"    => ComfortableMexicanSofa::Content::Tag::Fragment,
      "partial"     => ComfortableMexicanSofa::Content::Tag::Partial,
      "test"        => ContentRendererTest::TestTag,
      "test_nested" => ContentRendererTest::TestNestedTag,
      "test_block"  => ContentRendererTest::TestBlockTag
    }), ComfortableMexicanSofa::Content::Renderer.tags
  end

  def test_register_tags
    ComfortableMexicanSofa::Content::Renderer.register_tag(:other, TestTag)
    assert_equal ({
      "fragment"    => ComfortableMexicanSofa::Content::Tag::Fragment,
      "partial"     => ComfortableMexicanSofa::Content::Tag::Partial,
      "test"        => ContentRendererTest::TestTag,
      "test_nested" => ContentRendererTest::TestNestedTag,
      "test_block"  => ContentRendererTest::TestBlockTag,
      "other"       => ContentRendererTest::TestTag
    }), ComfortableMexicanSofa::Content::Renderer.tags
  ensure
    ComfortableMexicanSofa::Content::Renderer.tags.delete("other")
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
    assert nodes[1].is_a?(ContentRendererTest::TestTag)
    assert_equal " content ", nodes[2]
    assert nodes[3].is_a?(ContentRendererTest::TestTag)
  end

  def test_nodes_with_block_tag
    string = "a {{cms:test_block}} b {{cms:end}} c"
    tokens = @template.tokenize(string)
    nodes = @template.nodes(tokens)
    assert_equal 3, nodes.count

    assert_equal "a ", nodes[0]
    assert_equal " c", nodes[2]

    block = nodes[1]
    assert block.is_a?(ContentRendererTest::TestBlockTag)
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
    assert block.is_a?(ContentRendererTest::TestBlockTag)
    assert_equal 3, block.nodes.count
    assert_equal " b ", block.nodes[0]
    assert_equal " c ", block.nodes[2]

    tag = block.nodes[1]
    assert tag.is_a?(ContentRendererTest::TestTag)
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
    assert block.is_a?(ContentRendererTest::TestBlockTag)
    assert_equal 3, block.nodes.count
    assert_equal " b ", block.nodes[0]
    assert_equal " d ", block.nodes[2]

    block = block.nodes[1]
    assert_equal [" c "], block.nodes
  end

  def test_nodes_with_unclosed_block_tag
    string = "a {{cms:test_block}} b"
    tokens = @template.tokenize(string)
    assert_exception_raised ComfortableMexicanSofa::Content::Renderer::SyntaxError, "unclosed block detected" do
      @template.nodes(tokens)
    end
  end

  def test_nodes_with_closed_tag
    string = "a {{cms:end}} b"
    tokens = @template.tokenize(string)
    assert_exception_raised ComfortableMexicanSofa::Content::Renderer::SyntaxError, "closing unopened block" do
      @template.nodes(tokens)
    end
  end

  def test_render
    out = @template.render("test")
    assert_equal "test", out
  end

  def test_render_with_tag
    out = @template.render("a {{cms:fragment default}} z")
    assert_equal "a content z", out
  end

  def test_render_with_nested_tag
    flunk "todo"
  end

  def test_render_stack_overflow
    flunk "need to detect deeply nested tags"
  end
end
