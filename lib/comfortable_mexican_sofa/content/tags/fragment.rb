# Base Tag class that other fragment tags depend on.
# Tag handles following options:
#   `render`: true (default) | false
#     do we want to render this content on the page, or manually access it via
#     helpers. Good example would be content for meta tags.
#   `namespace`:
#     Just a string that allows grouping of form elements in the admin area
#
class ComfortableMexicanSofa::Content::Tag::Fragment < ComfortableMexicanSofa::Content::Tag

  attr_reader :identifier, :renderable, :namespace, :options

  def initialize(context, params_string)
    super

    @options    = params.extract_options!
    @identifier = params[0]

    unless @identifier.present?
      raise Error, "Missing identifier for fragment tag"
    end

    @namespace  = @options["namespace"] || "default"
    @renderable = @options["render"].to_s.downcase == "false" ? false : true
  end

  # Grabs existing fragment record or spins up a new instance if there's none
  def fragment
    self.context.fragments.detect{|f| f.identifier == self.identifier} ||
    self.context.fragments.build(identifier: self.identifier)
  end

  def content
    fragment.content
  end

  # If `render: false` was passed in we won't render anything. Assuming that
  # that fragment content will be rendered manually
  def render
    self.renderable ? content : ""
  end

  # Tag renders its own form inputs via `form_field(template, index, &block)`
  # For example:
  #   class MyTag < ComfortableMexicanSofa::Content::Tag::Fragment
  #     def form_field(view, index, &block)
  #       # omit yield if you don't want default wrapper
  #       yield view.text_area "input_name", "value"
  #     end
  #   end
  def form_field(view, index, &block)
    raise "Form field rendering not implemented for this Tag"
  end
end
