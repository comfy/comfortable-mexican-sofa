# frozen_string_literal: true

# Tag for text content that is going to be rendered using text input with datetime widget
#   {{ cms:datetime identifier, strftime: "at %I:%M%p" }}
#
# `strftime` - Format datetime string during rendering
#
class ComfortableMexicanSofa::Content::Tag::Datetime < ComfortableMexicanSofa::Content::Tag::Fragment

  attr_reader :strftime

  def initialize(context:, params: [], source: nil)
    super
    @strftime = options["strftime"]
  end

  def content
    fragment.datetime
  end

  def render
    return "" unless renderable

    if strftime.present?
      content.strftime(strftime)
    else
      content.to_s
    end
  end

  def form_field(object_name, view, index)
    name    = "#{object_name}[fragments_attributes][#{index}][datetime]"
    options = { id: form_field_id, class: "form-control", data: { "cms-datetime" => true } }
    value   = content.present? ? content.to_s(:db) : ""
    input   = view.send(:text_field_tag, name, value, options)

    yield input
  end

end

ComfortableMexicanSofa::Content::Renderer.register_tag(
  :datetime, ComfortableMexicanSofa::Content::Tag::Datetime
)
