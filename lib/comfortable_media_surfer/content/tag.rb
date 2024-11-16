# frozen_string_literal: true

class ComfortableMediaSurfer::Content::Tag
  class Error < StandardError; end

  # @type [Comfy::Cms::WithFragments]
  attr_reader :context

  # @type [Array<String, {String => String}>] params
  attr_reader :params

  # @type [String, nil] source
  attr_reader :source

  # @param [Comfy::Cms::WithFragments] context
  # @param [Array<String, {String => String}>] params
  # @param [String, nil] source
  def initialize(context:, params: [], source: nil)
    @context  = context
    @params   = params
    @source   = source
  end

  # Making sure we don't leak erb from tags by accident.
  # Tag classes can override this, like partials/helpers tags.
  def allow_erb?
    ComfortableMediaSurfer.config.allow_erb
  end

  # Normally it's a {(String)}. However, if tag content has tags,
  # we need to expand them and that produces potentially more stuff.
  # @return [Array<String, ComfortableMediaSurfer::Content::Tag>]
  def nodes
    template  = ComfortableMediaSurfer::Content::Renderer.new(@context)
    tokens    = template.tokenize(content)
    template.nodes(tokens)
  end

  # @return [String]
  def content
    raise Error, 'This is a base class. It holds no content'
  end

  # @return [String]
  def render
    content
  end
end
