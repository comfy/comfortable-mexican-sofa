class ComfortableMexicanSofa::Content::Tag

  class Error < StandardError; end

  attr_reader :context, :params, :source

  def initialize(context: nil, params: [], source: nil)
    @context  = context
    @params   = params
    @source   = source
  end

  # Making sure we don't leak erb from tags by accident.
  # Tag classes can override this, like partials/helpers tags.
  def allow_erb
    false || ComfortableMexicanSofa.config.allow_erb
  end

  # Normally it's a string. However if tag content has tags, we need to expand
  # them and that produces potentually more stuff
  def nodes
    template  = ComfortableMexicanSofa::Content::Renderer.new(@context)
    tokens    = template.tokenize(content)
    template.nodes(tokens)
  end

  def content
    raise Error, "This is a base class. It holds no content"
  end

  def render
    content
  end

end
