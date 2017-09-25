class ComfortableMexicanSofa::Content::Renderer

  class SyntaxError < StandardError; end

  # tags are in this format: {{ cms:tag_class params,  }}
  TAG_REGEX = /\{\{\s*?cms:(?<class>\w+)(?<params>.*?)\}\}/

  class << self

    def tags
      @tags ||= {}
    end

    def register_tag(name, klass)
      tags[name.to_s] = klass
    end
  end

  def initialize(context)
    @context = context
  end

  # This is how we render content out. Takes context (cms page) and starting
  # markup (usually page's layout content)
  def render(string, allow_erb = ComfortableMexicanSofa.config.allow_erb)
    tokens  = tokenize(string)
    nodes   = nodes(tokens)
    nodes.map do |node|
      case node
      when String
        sanitize_erb(node, allow_erb)
      else
        render(node.render, allow_erb || node.allow_erb)
      end
    end.flatten.join
  end

  def sanitize_erb(string, allow_erb)
    if allow_erb
      string.to_s
    else
      string.to_s.gsub('<%', '&lt;%').gsub('%>', '%&gt;')
    end
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
  def nodes(tokens)
    nodes = [[]]
    tokens.each do |token|
      case token

      # tag signature
      when Hash
        case tag_class = token[:tag_class]

        # This handles {{cms:end}} tag. Stopping collecting block nodes.
        when "end"
          if nodes.count == 1
            raise SyntaxError, "closing unopened block"
          end
          nodes.pop

        else
          unless klass = self.class.tags[tag_class]
            raise SyntaxError, "Unrecognized tag #{tag_class}"
          end

          tag = klass.new(@context, token[:tag_params])
          nodes.last << tag

          # If it's a block tag we start collecting nodes into it
          if tag.is_a?(ComfortableMexicanSofa::Content::Block)
            nodes << tag.nodes
          end
        end

      # text
      else
        nodes.last << token
      end
    end

    if nodes.count > 1
      raise SyntaxError, "unclosed block detected"
    end

    nodes.flatten
  end
end
