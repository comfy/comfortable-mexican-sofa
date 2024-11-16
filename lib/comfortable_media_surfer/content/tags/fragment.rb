# frozen_string_literal: true

# Base Tag class that other fragment tags depend on.
# Tag handles following options:
#   `render`: true (default) | false
#     do we want to render this content on the page, or manually access it via
#     helpers. Good example would be content for meta tags.
#   `namespace`:
#     Just a string that allows grouping of form elements in the admin area
#
class ComfortableMediaSurfer::Content::Tags::Fragment < ComfortableMediaSurfer::Content::Tag
  attr_accessor :renderable
  attr_reader :identifier, :namespace

  # @type [{String => String}]
  attr_reader :options

  def initialize(context:, params: [], source: nil)
    super

    @options    = params.extract_options!
    @identifier = params[0]

    unless @identifier.present?
      raise Error, "Missing identifier for fragment tag: #{source}"
    end

    @namespace  = @options['namespace'] || 'default'
    @renderable = @options['render'].to_s.downcase != 'false'
  end

  # Grabs existing fragment record or spins up a new instance if there's none
  # @return [Comfy::Cms::Fragment]
  def fragment
    context.fragments.detect { |f| f.identifier == identifier } ||
      context.fragments.build(identifier: identifier)
  end

  def content
    fragment.content
  end

  # If `render: false` was passed in we won't render anything. Assuming that
  # that fragment content will be rendered manually
  def render
    renderable ? content : ''
  end

  # Tag renders its own form inputs via `form_field(template, index)`
  # For example:
  #   class MyTag < ComfortableMediaSurfer::Content::Tags::Fragment
  #     def form_field(view, index, &block)
  #       # omit yield if you don't want default wrapper
  #       yield view.text_area "input_name", "value"
  #     end
  #   end
  def form_field
    raise 'Form field rendering not implemented for this Tag'
  end

  def form_field_id
    "fragment-#{@identifier}"
  end
end
