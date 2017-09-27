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

  DEFAULT_REGISTERED_TAGS = {
    "asset"     => ComfortableMexicanSofa::Content::Tag::Asset,
    "fragment"  => ComfortableMexicanSofa::Content::Tag::Fragment,
    "file"      => ComfortableMexicanSofa::Content::Tag::File,
    "snippet"   => ComfortableMexicanSofa::Content::Tag::Snippet,
    "helper"    => ComfortableMexicanSofa::Content::Tag::Helper,
    "partial"   => ComfortableMexicanSofa::Content::Tag::Partial,
    "file_link" => ComfortableMexicanSofa::Content::Tag::FileLink,
    "template"  => ComfortableMexicanSofa::Content::Tag::Template
  }.freeze

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

  # Test helper so we don't have to do this each time
  def render_string(string, template = @template)
    tokens = @template.tokenize(string)
    nodes  = @template.nodes(tokens)
    @template.render(nodes)
  end

  # -- Tests -------------------------------------------------------------------

  def test_tags
    assert_equal (DEFAULT_REGISTERED_TAGS.merge(
      "test"        => ContentRendererTest::TestTag,
      "test_nested" => ContentRendererTest::TestNestedTag,
      "test_block"  => ContentRendererTest::TestBlockTag
    )), ComfortableMexicanSofa::Content::Renderer.tags
  end

  def test_register_tags
    ComfortableMexicanSofa::Content::Renderer.register_tag(:other, TestTag)
    assert_equal (DEFAULT_REGISTERED_TAGS.merge(
      "test"        => ContentRendererTest::TestTag,
      "test_nested" => ContentRendererTest::TestNestedTag,
      "test_block"  => ContentRendererTest::TestBlockTag,
      "other"       => ContentRendererTest::TestTag
    )), ComfortableMexicanSofa::Content::Renderer.tags
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

  def test_sanitize_erb
    out = @template.sanitize_erb("<% test %>", false)
    assert_equal "&lt;% test %&gt;", out

    out = @template.sanitize_erb("<% test %>", true)
    assert_equal "<% test %>", out
  end

  def test_render
    out = render_string("test")
    assert_equal "test", out
  end

  def test_render_with_tag
    out = render_string("a {{cms:fragment content}} z")
    assert_equal "a content z", out
  end

  def test_render_with_erb
    out = render_string("<%= 1 + 1 %>")
    assert_equal "&lt;%= 1 + 1 %&gt;", out
  end

  def test_render_with_erb_allowed
    ComfortableMexicanSofa.config.allow_erb = true
    out = render_string("<%= 1 + 1 %>")
    assert_equal "<%= 1 + 1 %>", out
  end

  def test_render_with_erb_allowed_via_tag
    out = render_string("{{cms:partial path}}")
    assert_equal "<%= render partial: '@path', locals: {} %>", out
  end

  def test_render_with_nested_tag
    string = "a {{cms:fragment content}} b"
    comfy_cms_fragments(:default).update_column(:content, "c {{cms:snippet default}} d")
    comfy_cms_snippets(:default).update_column(:content, "e {{cms:helper test}} f")
    out = render_string(string)
    assert_equal "a c e <%= test() %> f d b", out
  end

  def test_render_stack_overflow
    # making self-referencing content loop here
    comfy_cms_snippets(:default).update_column(:content, "a {{cms:snippet default}} b")
    message = "Deep tag nesting or recursive nesting detected"
    assert_exception_raised ComfortableMexicanSofa::Content::Renderer::Error, message do
      render_string("{{cms:snippet default}}")
    end
  end
end
