# Tag for injecting partials. Example tag:
#   {{cms:partial path/to/partial, foo: bar, zip: zoop}}
# This expands into a familiar:
#   <%= render partial: "path/to/partial", locals: {foo: bar, zip: zoop} %>
# Whitelist is can be used to control what partials are renderable.
#
class ComfortableMexicanSofa::Content::Tag::Partial < ComfortableMexicanSofa::Content::Tag

  attr_reader :path, :locals

  def initialize(context, params_string)
    super
    @locals = params.extract_options!
    @path   = params[0]

    unless @path.present?
      raise Error, "Missing path for partial tag"
    end
  end

  def content
    "<%= render partial: '@path', locals: #{@locals} %>"
  end

  def render
    whitelist = ComfortableMexicanSofa.config.allowed_partials
    if whitelist.is_a?(Array)
      whitelist.member?(@path) ? content : ""
    else
      content
    end
  end
end

ComfortableMexicanSofa::Content::Renderer.register_tag(
  :partial, ComfortableMexicanSofa::Content::Tag::Partial
)
