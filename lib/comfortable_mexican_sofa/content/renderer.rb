# frozen_string_literal: true

require "strscan"

# Processing content follows these stages:
#
#   string        - Text with tags. like this: "some {{cms:fragment content}} text"
#   tokenization  - Splits string into a list of strings and hashes that define tags
#                   Example: ["some ", {tag_class: "fragment", tag_params: ""}, " text"]
#   nodefying     - Initializes Tag instances from tag hashes and returns list
#                   like this: ["some ", (FragmentTagInstance), " text"]
#   rendering     - Recursively iterates through nodes. Tag instances get their
#                   `render` method called. Result of that is tokenized, nodefied
#                   and rendered once again until there are no tags to expand.
#                   Resulting list is flattened and joined into a final rendered string.
#
class ComfortableMexicanSofa::Content::Renderer

  class SyntaxError < StandardError; end
  class Error < StandardError; end

  MAX_DEPTH = 100

  # tags are in this format: {{ cms:tag_class params }}
  TAG_REGEX = %r{\{\{\s*?cms:(?<class>\w+)(?<params>.*?)\}\}}

  class << self

    # @return [Hash<String, Class<ComfortableMexicanSofa::Content::Tag>>]
    def tags
      @tags ||= {}
    end

    # @param [String] name
    # @param [Class<ComfortableMexicanSofa::Content::Tag>] klass
    def register_tag(name, klass)
      tags[name.to_s] = klass
    end

  end

  # @param [Comfy::Cms::WithFragments, nil] context
  def initialize(context)
    @context = context
    @depth   = 0
  end

  # This is how we render content out. Takes context (cms page) and content
  # nodes
  # @param [Array<String, ComfortableMexicanSofa::Content::Tag>]
  # @param [Boolean] allow_erb
  def render(nodes, allow_erb = ComfortableMexicanSofa.config.allow_erb)
    if (@depth += 1) > MAX_DEPTH
      raise Error, "Deep tag nesting or recursive nesting detected"
    end

    nodes.map do |node|
      case node
      when String
        sanitize_erb(node, allow_erb)
      else
        tokens  = tokenize(node.render)
        nodes   = nodes(tokens)
        render(nodes, allow_erb || node.allow_erb?)
      end
    end.flatten.join
  end

  def sanitize_erb(string, allow_erb)
    if allow_erb
      string.to_s
    else
      string.to_s.gsub("<%", "&lt;%").gsub("%>", "%&gt;")
    end
  end

  # Splitting text with tags into tokens we can process down the line
  # @return [Array<String, {Symbol => String}>]
  def tokenize(string)
    tokens = []
    ss = StringScanner.new(string.to_s)
    while (string = ss.scan_until(TAG_REGEX))
      text = string.sub(ss[0], "")
      tokens << text unless text.empty?
      tokens << {
        tag_class:  ss[:class],
        tag_params: ss[:params].strip,
        source:     ss[0]
      }
    end
    text = ss.rest
    tokens << text if text.present?
    tokens
  end

  # Constructing node tree for content. It's a list of strings and tags with
  # their own `nodes` method that has array of strings and tags with their own
  # `nodes` method that... you get the idea.
  # @param [Array<String, {Symbol => String}>] tokens
  # @return [Array<String, ComfortableMexicanSofa::Content::Tag>]
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
          # @type [Class<ComfortableMexicanSofa::Content::Tag>]
          klass = self.class.tags[tag_class] ||
            raise(SyntaxError, "Unrecognized tag: #{token[:source]}")

          # @type [ComfortableMexicanSofa::Content::Tag]
          tag = klass.new(
            context:  @context,
            params:   ComfortableMexicanSofa::Content::ParamsParser.new(token[:tag_params]).params,
            source:   token[:source]
          )
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
