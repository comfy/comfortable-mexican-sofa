# frozen_string_literal: true

# This component is responsible for rendering out attached fragment files
# and generates checkboxes that allow file removal on page save
class Comfy::Admin::Cms::FormFragmentFilesComponent < ViewComponent::Base
  haml_template <<~HAML
    - @fragment.attachments.each do |attachment|
      = attachment.inspect
  HAML

  def initialize(object_name:, index:, fragment:)
    @object_name = object_name
    @index       = index
    @fragment    = fragment
  end

  def render?
    @fragment.attachments.present?
  end
end
