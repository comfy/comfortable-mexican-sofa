# frozen_string_literal: true

# Tag for reusable snippets within context's site scope. Looks like this:
#   {{cms:snippet identifier}}
# Snippets may have more tags in them like fragments, so they may be expanded too.
#
class ComfortableMexicanSofa::Content::Tag::SnippetTag < ComfortableMexicanSofa::Content::Tag
  attr_reader :identifier

  def initialize(context:, params: [], source: nil)
    super

    @identifier = params[0]

    return if @identifier.present?

    raise Error, "Missing identifier for snippet tag: #{source}"
  end

  def content
    snippet =
      context.site.snippets.detect { |s| s.identifier == identifier } ||
      context.site.snippets.build(identifier: identifier)

    snippet.content.to_s
  end
end

ComfortableMexicanSofa::Content::Renderer.register_tag(
  :snippet, ComfortableMexicanSofa::Content::Tag::SnippetTag
)
