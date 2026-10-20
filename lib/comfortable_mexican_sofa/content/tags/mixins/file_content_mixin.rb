# frozen_string_literal: true

# A mixin for tags that returns the file as their content.
module ComfortableMexicanSofa::Content::FileContentMixin

  # When resizing let's not allow gigantic dimensions
  MAX_VARIANT_DIMENSION = 2500.freeze

  def content
    return "" unless file

    url_helpers = Rails.application.routes.url_helpers
    helpers     = ActionController::Base.helpers

    attachment =
      if variant_options.present? && file.image?
        file.variant(variant_options)
      else
        file
      end

    attachment_url = url_helpers.rails_blob_path(attachment, only_path: true)

    case as
    when "link"
      helpers.link_to(label, attachment_url, class: @html_class, target: "_blank")
    when "image"
      helpers.image_tag(attachment_url, class: @html_class, alt: label)
    else
      attachment_url
    end
  end

  # For simplicity sake, we only allow resizing and will convert variant options
  # into something that image_processing accepts by default
  def variant_options
    key, value = @variant_options&.first
    return {} unless key && value

    x, y = value.split("x").map(&:to_i).map{ [_1, MAX_VARIANT_DIMENSION].min }
    return {} unless x.positive? && y.positive?

    { key.to_sym => [x, y] }
  end
end
