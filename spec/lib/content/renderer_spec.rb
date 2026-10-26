# frozen_string_literal: true

require "rails_helper"

RSpec.describe ComfortableMexicanSofa::Content::Renderer do
  let(:page)     { comfy_cms_pages(:default) }
  let(:renderer) { described_class.new(page) }

  let(:tag_class) do
    klass = Class.new(ComfortableMexicanSofa::Content::Tag) do
      def content = "tag-content"
    end
    stub_const("TestTagClass", klass)
  end

  let(:nesting_tag_class) do
    klass = Class.new(ComfortableMexicanSofa::Content::Tag) do
      def content = "nesting-> {{cms:test}} <-content"
    end
    stub_const("TestNestingTagClass", klass)
  end

  let(:recursive_tag_class) do
    klass = Class.new(ComfortableMexicanSofa::Content::Tag) do
      def content = "infinite expansion: {{cms:test_recursive}}"
    end
    stub_const("TestRecursiveTagClass", klass)
  end

  let(:erb_tag_class) do
    klass = Class.new(ComfortableMexicanSofa::Content::Tag) do
      def content = "<%= 2 + 2 %>"
      def allow_erb? = true
    end
    stub_const("TestErbTagClass", klass)
  end

  before do
    described_class.register_tag(:test, tag_class)
    described_class.register_tag(:test_nested, nesting_tag_class)
    described_class.register_tag(:test_recursive, recursive_tag_class)
    described_class.register_tag(:test_erb, erb_tag_class)
  end

  after do
    described_class.tags.delete("test")
    described_class.tags.delete("test_nesting")
    described_class.tags.delete("test_recursive")
    described_class.tags.delete("test_erb")
  end

  describe ".tags" do
    it "returns has of tag names and tag classes" do
      expect(described_class.tags).to be_a(Hash)
      expect(described_class.tags["text"]).to eq(ComfortableMexicanSofa::Content::Tag::TextTag)
    end
  end

  describe ".register_tag" do
    it "adds entry to the tags list" do
      expect(described_class.tags["foo"]).to be_blank
      described_class.register_tag(:foo, tag_class)
      expect(described_class.tags["foo"]).to be_present
    end
  end

  describe ".new" do
    it "initializes renderer with context" do
      expect(described_class.new(comfy_cms_pages(:default))).to be_an_instance_of(described_class)
    end
  end

  describe "#tokenize" do
    it "tokenizes simple string" do
      expect(renderer.tokenize("foo bar")).to eq(["foo bar"])
    end

    it "tokenizes string with cms tag" do
      input  = "foo {{cms:tag}} bar"
      output = ["foo ", { tag_class: "tag", tag_params: "", source: "{{cms:tag}}" }, " bar"]
      expect(renderer.tokenize(input)).to eq(output)
    end

    it "tokenizes string with complicated tag" do
      input = "foo {{cms:tag abc, def, gh: ij, kl: mn }} bar"
      output = [
        "foo ",
        {
          source:     "{{cms:tag abc, def, gh: ij, kl: mn }}",
          tag_class:  "tag",
          tag_params: "abc, def, gh: ij, kl: mn"
        },
        " bar"
      ]
      expect(renderer.tokenize(input)).to eq(output)
    end

    it "handles newlines" do
      input = "{{cms:test}}\n{{cms:test}}"
      output = [
        { source: "{{cms:test}}", tag_class: "test", tag_params: "" },
        "\n",
        { source: "{{cms:test}}", tag_class: "test", tag_params: "" }
      ]
      expect(renderer.tokenize(input)).to eq(output)
    end

    it "tokenizes string with malformed tag" do
      input  = "foo {{abc:tag}} bar"
      output = ["foo {{abc:tag}} bar"]
      expect(renderer.tokenize(input)).to eq(output)
    end
  end

  describe "#nodes" do
    it "outputs simple string node" do
      tokens = renderer.tokenize("test")
      expect(renderer.nodes(tokens)).to eq(["test"])
    end

    it "outputs nodes with tags" do
      tokens = renderer.tokenize("test {{cms:test}} content {{cms:test}}")
      expect(renderer.nodes(tokens)).to match(
        [
          "test ",
          an_instance_of(TestTagClass),
          " content ",
          an_instance_of(TestTagClass)
        ]
      )
    end

    it "outputs nodes with params" do
      tokens = renderer.tokenize("foo {{cms:test foo, bar, foo: bar}} bar")
      nodes = renderer.nodes(tokens)
      expect(nodes).to match(["foo ", an_instance_of(TestTagClass), " bar"])

      tag = nodes[1]
      expect(tag.context).to eq(page)
      expect(tag.params).to eq(%w[foo bar])
      expect(tag.options).to eq({ "foo" => "bar" })
      expect(tag.source).to eq("{{cms:test foo, bar, foo: bar}}")
    end

    it "errors out on unregistered tag" do
      tokens = renderer.tokenize("foo {{cms:invalid}} bar")
      expect do
        renderer.nodes(tokens)
      end.to raise_error(described_class::SyntaxError, "Unrecognized tag: {{cms:invalid}}")
    end
  end

  describe "#sanitize_erb" do
    it "sanitizes erb" do
      expect(renderer.sanitize_erb("<% test %>", allow_erb: false)).to eq("&lt;% test %&gt;")
    end

    it "leaves erb alone" do
      expect(renderer.sanitize_erb("<% test %>", allow_erb: true)).to eq("<% test %>")
    end
  end

  describe "#render" do
    def render_string(string)
      tokens = renderer.tokenize(string)
      nodes  = renderer.nodes(tokens)
      renderer.render(nodes)
    end

    it "renders simple string" do
      expect(render_string("foo bar")).to eq("foo bar")
    end

    it "renders string with a tag" do
      result = render_string("a {{cms:test}} b {{cms:test}} c")
      expect(result).to eq("a tag-content b tag-content c")
    end

    it "renders with tags that expand content" do
      result = render_string("a {{cms:test_nested}} z")
      expect(result).to eq("a nesting-> tag-content <-content z")
    end

    it "errors out on infinite tag expansion" do
      expect do
        render_string("{{cms:test_recursive}}")
      end.to raise_error(described_class::Error, "Deep tag nesting or recursive nesting detected")
    end

    it "escapes erb" do
      result = render_string("<%= 2 + 2 %>")
      expect(result).to eq("&lt;%= 2 + 2 %&gt;")
    end

    it "allows erb from tags that explicitly allow erb" do
      result = render_string("<%= 'foo' %> {{cms:test_erb}}")
      expect(result).to eq("&lt;%= 'foo' %&gt; <%= 2 + 2 %>")
    end

    it "allows erb if globally enabled" do
      ComfortableMexicanSofa.config.allow_erb = true
      result = render_string("<%= 2 + 2 %>")
      expect(result).to eq("<%= 2 + 2 %>")
    end
  end
end
