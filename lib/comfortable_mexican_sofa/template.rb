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


# wtf does this mean
# it means that all nodes between this must be moved into here
# {{cms:block}} some content {{cms:end_block}}
class BlockTag < NewTag

  attr_accessor :nodes

  def nodes
    @nodes ||= []
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

    # Splitting text with tags into tokens we can process down the line
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

    # Constructing node tree for content. It's a list of strings and tags with
    # their own `nodes` method that has array of strings and tags with their own
    # `nodes` method that... you get the idea.
    def nodes(context, tokens)
      nodes = [[]]
      tokens.each do |token|
        case token

        # tag signature
        when Hash
          case tag_class = token[:tag_class]

          # This handles {{cms:end}} tag. Stopping collecting block nodes.
          when "end"
            nodes.pop
          else
            tag = tags[tag_class].new(context, token[:params])
            nodes.last << tag
            # If it's a block tag we start collecting nodes into it
            nodes << tag.nodes if tag.is_a?(BlockTag)
          end

        # text
        else
          nodes.last << token
        end
      end
      nodes.flatten
    end
  end

end


