# Tag that's responsible for rendeting content that comes from the database.
# Tag looks something like this:
#   {{cms:fragment identifier, format: text}}
#
# Tag params are split and first string maps to the `identifier` of the fragment
# Tag handles following options:
#   `format`: wysiwyg (default) | text | textarea | markdown | datetime | date | boolean | number
#     this controls how this gets rendered in admin form
#   `render`: true (default) | false
#     do we want to render this content on the page, or manually access it via
#     helpers. Good example would be content for meta tags.
#   `namespace`:
#     Just a string that allows grouping of form elements in the admin area
#
class ComfortableMexicanSofa::Content::Tag::Fragment < ComfortableMexicanSofa::Content::Tag

  attr_reader :identifier, :format, :renderable, :namespace, :options

  def initialize(context, params_string)
    super

    @options    = params.extract_options!
    @identifier = params[0]

    unless @identifier.present?
      raise Error, "Missing identifier for fragment tag"
    end

    @namespace  = @options["namespace"] || "default"
    @format     = @options["format"] || "wysiwyg"
    @renderable = @options["render"].to_s.downcase == "false" ? false : true
  end

  # Grabs existing fragment or spins up a new instance if there's none
  def fragment
    self.context.fragments.detect{|f| f.identifier == self.identifier} ||
    self.context.fragments.build(identifier: self.identifier)
  end

  def content
    fragment.content
  end

  def render
    self.renderable ? render_with_format(content, @format) : ""
  end

  def render_with_format(content, format)
    case format
    when "markdown"
      Kramdown::Document.new(content.to_s).to_html
    else
      content
    end
  end

end

ComfortableMexicanSofa::Content::Renderer.register_tag(
  :fragment, ComfortableMexicanSofa::Content::Tag::Fragment
)