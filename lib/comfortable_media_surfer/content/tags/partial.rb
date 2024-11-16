# frozen_string_literal: true

# Tag for injecting partials. Example tag:
#   {{cms:partial path/to/partial, foo: bar, zip: zoop}}
# This expands into a familiar:
#   <%= render partial: "path/to/partial", locals: {foo: bar, zip: zoop} %>
# Whitelist is can be used to control what partials are renderable.
#
class ComfortableMediaSurfer::Content::Tags::Partial < ComfortableMediaSurfer::Content::Tag
  attr_reader :path, :locals

  def initialize(context:, params: [], source: nil)
    super
    @locals = params.extract_options!
    @path   = params[0]

    return if @path.present?

    raise Error, 'Missing path for partial tag'
  end

  # we output erb into rest of the content
  def allow_erb?
    true
  end

  def content
    format(
      '<%%= render partial: %<path>p, locals: %<locals>s %%>',
      path: @path,
      locals: @locals
    )
  end

  def render
    whitelist = ComfortableMediaSurfer.config.allowed_partials
    if whitelist.is_a?(Array)
      whitelist.member?(@path) ? content : ''
    else
      content
    end
  end
end

ComfortableMediaSurfer::Content::Renderer.register_tag(
  :partial, ComfortableMediaSurfer::Content::Tags::Partial
)
