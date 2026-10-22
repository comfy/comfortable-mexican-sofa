# frozen_string_literal: true

# This component is responsible for rendering out attached fragment files
# and generates checkboxes that allow file removal on page save
class Comfy::Cms::FormFragmentFilesComponent < Comfy::BaseComponent
  MAX_FILENAME_LENGTH = 40

  haml_template <<~HAML
    - @fragment.attachments.each do |attachment|
      .attachment
        = link_to truncated_filename(attachment: attachment), url_for(attachment), target: "_blank"
        = check_box_tag input_name, attachment.id, false, id: dom_id(attachment)
        %label{ for: dom_id(attachment) }
          = helpers.inline_svg_tag("comfy/x.svg")
  HAML

  def initialize(object_name:, index:, fragment:)
    @object_name = object_name
    @index       = index
    @fragment    = fragment
  end

  def render?
    @fragment.attachments.present?
  end

private

  def truncated_filename(attachment:)
    filename = attachment.filename.to_s
    truncate(filename, length: MAX_FILENAME_LENGTH - 10, omission: "...#{filename.last(10)}")
  end

  def input_name
    "#{@object_name}[fragments_attributes][#{@index}][file_ids_destroy][]"
  end
end
