class ComfortableMexicanSofa::Content::Tag

  class Error < StandardError; end

  attr_reader :context, :params

  def initialize(context, params_string = "")
    @context  = context
    @params   = parse_params_string(params_string)
  end

  # Normally it's a string. However if tag content has tags, we need to expand
  # them and that produces potentually more stuff
  def nodes
    tokens = ComfortableMexicanSofa::Content::Template.tokenize(content)
    ComfortableMexicanSofa::Content::Template.nodes(@context, tokens)
  end

  def content
    raise Error, "This is a base class. It holds no content"
  end

  def render
    content
  end

  def parse_params_string(string)
    ComfortableMexicanSofa::Content::ParamsParser.parse(string)
  end
end
