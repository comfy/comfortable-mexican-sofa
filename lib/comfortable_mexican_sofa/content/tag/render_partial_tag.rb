# frozen_string_literal: true

# Tag for injecting partials. Example tag:
#   {{cms:partial path/to/partial, foo: bar, zip: zoop}}
# This expands into a familiar:
#   <%= render partial: "path/to/partial", locals: {foo: bar, zip: zoop} %>
# Whitelist is can be used to control what partials are renderable.
#
class ComfortableMexicanSofa::Content::Tag::RenderPartialTag < ComfortableMexicanSofa::Content::Tag
  attr_reader :path

  def initialize(context:, params: [], source: nil)
    super

    @path = params[0]

    return if @path.present?

    raise Error, "Missing path for render partial tag: #{source}"
  end

  def content
    whitelist = Array.wrap(ComfortableMexicanSofa.config.allowed_partials)
    return "" if whitelist.present? && !whitelist.member?(@path)

    Kernel.format(
      "<%%= render partial: %<path>p, locals: %<locals>s %%>",
      path:   @path,
      locals: @options
    )
  end

  # Ensuring that renderer does not escape erb for this tag
  def allow_erb?
    true
  end
end

ComfortableMexicanSofa::Content::Renderer.register_tag(
  :render_partial, ComfortableMexicanSofa::Content::Tag::RenderPartialTag
)
