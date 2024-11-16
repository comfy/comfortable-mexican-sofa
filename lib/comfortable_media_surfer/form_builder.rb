# frozen_string_literal: true

class ComfortableMediaSurfer::FormBuilder < ComfyBootstrapForm::FormBuilder
  # Renders form input for a fragment
  #
  # @param [Comfy::Cms::Page] record
  # @param [ComfortableMediaSurfer::Content::Tag] tag
  # @param [Integer] index
  def fragment_field(tag, index)
    tag.form_field(object_name, @template, index) do |tag_input|
      name = "#{object_name}[fragments_attributes][#{index}][identifier]"
      identifer_input = @template.hidden_field_tag(name, tag.identifier, id: nil)

      name  = "#{object_name}[fragments_attributes][#{index}][tag]"
      value = tag.class.to_s.demodulize.underscore
      tag_name_input = @template.hidden_field_tag(name, value, id: nil)

      label = I18n.t("comfy.cms.content.tag.#{tag.identifier}", default: tag.identifier.titleize)
      renderable = tag.respond_to?(:renderable) ? tag.renderable : true

      form_group bootstrap: { label: { text: label, for: tag.form_field_id, class: "renderable-#{renderable}" } } do
        concat identifer_input
        concat tag_name_input
        concat tag_input
      end
    end
  end

  # Wrapper for form action that is sticking to the bottom of the viewport.
  # Example:
  #   = form.form_actions do
  #     = form.submit
  #
  def form_actions(&block)
    content_tag(:div, class: 'form-actions row bg-light') do
      content_tag(:div, class: 'col-lg-8 offset-lg-2') do
        content_tag(:div, class: 'form-group row mb-0') do
          content_tag(:div, class: 'col-sm-10 offset-sm-2', &block)
        end
      end
    end
  end
end
