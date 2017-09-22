# This is going to be replacement for Tag class.

# This will take content associated with a page and do a full unroll.

# - load page
# - load page.layout

# - parse layout content
# - if layout has a parent layout we need to merge them on {{ cms:fragment content }}
# - do a scan looking for tags of {{ cms:whatever }} format. This is a tokenization process
# - for tokens that match our tags we will initialize them and get their `content` that might have more tags


# {{ cms:whatever }}          tag   - render
# {{ cms:fragment }}          tag   - expand
# text                        text

# {{ cms:fragment_list items }} tag   - block. process rest seperately?
#   text                      text
#   {{ cms:fragment item }}   tag   - expand
#   text                      text  - text
#   {{ cms:fragment desc }}   tag   - expand
#   {{ cms:helper }}          tag   - render
# {{ cms:end_fragment_list }}   tag   - endblock

# text                        text
# {{ cms:whatever }}          tag   - render


# context is our page we're rendering against. might be something else in the future
class NewTag

  attr_reader :context, :params

  def initialize(context, params_string = "")
    @context  = context
    @params   = parse_params_string(params_string)
  end

  # Normally it's a string. However if tag content has tags, we need to expand
  # them and that produces potentually more stuff
  def nodes
    tokens = ComfortableMexicanSofa::Template.tokenize(content)
    ComfortableMexicanSofa::Template.nodes(@context, tokens)
  end

  def content
    "TODO"
  end

  def parse_params_string(string)
    []
  end
end





module ComfortableMexicanSofa::Template

  # tags are in this format: {{ cms:tag_class params,  }}
  TAG_REGEX = /\{\{\s*?cms:(?<class>\w+)(?<params>.*?)\}\}/

  class << self
    def tags
      @tags ||= {}
    end

    def register_tag(name, klass)
      tags[name.to_s] = klass
    end

    # splitting text with tags into tokens we can process down the line
    def tokenize(string)
      tokens = []
      ss = StringScanner.new(string)
      while string = ss.scan_until(TAG_REGEX)
        text = string.sub(ss[0], '')
        tokens << text if text.present?
        tokens << {tag_class: ss[:class], tag_params: ss[:params].strip}
      end
      text = ss.rest
      tokens << text if text.present?
      return tokens
    end

    # TODO: this should be bolted on directly on the context maybe?
    def nodes(context, tokens)
      tokens.map do |token|
        case token
        when Hash
          tag_class = tags[token[:tag_class]] # TODO: will blow up if not registered
          tag_class.new(context, token[:params])
        else
          token
        end
      end
    end
  end

end


