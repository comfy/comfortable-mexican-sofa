# frozen_string_literal: true

# Tag for injecting template rendering. Example tag:
#   {{ cms:render_template template/path }}
# This expands into something like this:
#   <%= render template: "template/path" %>
#
# ComfortableMexicanSofa.config.allowed_templates can be used to control what templates are available.
#
class ComfortableMexicanSofa::Content::Tag::RenderTemplateTag < ComfortableMexicanSofa::Content::Tag

  attr_reader :path

  def initialize(context:, params: [], source: nil)
    super

    @path = params[0]

    return if @path.present?

    raise Error, "Missing path for render template tag: #{source}"
  end

  def content
    whitelist = Array.wrap(ComfortableMexicanSofa.config.allowed_templates)
    return "" if whitelist.present? && !whitelist.member?(@path)

    Kernel.format("<%%= render template: %<path>p %%>", path: path)
  end

  # Ensuring that renderer does not clobber erb
  def allow_erb?
    true
  end
end

ComfortableMexicanSofa::Content::Renderer.register_tag(
  :render_template, ComfortableMexicanSofa::Content::Tag::RenderTemplateTag
)
