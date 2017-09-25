class ComfortableMexicanSofa::Content::Tag::Partial < ComfortableMexicanSofa::Content::Tag

  def initialize(context, params_string = "")
    super
    @path   = params[0]
    @locals = params[1] || {}
  end

  def content
    "<%= render partial: '@path', locals: #{@locals} %>"
  end

  def render
    whitelist = ComfortableMexicanSofa.config.allowed_partials
    if whitelist.is_a?(Array)
      content if whitelist.member?(identifier)
    else
      content
    end
  end
end

ComfortableMexicanSofa::Content::Renderer.register_tag(
  :partial, ComfortableMexicanSofa::Content::Tag::Partial
)
