# frozen_string_literal: true

# A mixin for tags that returns the file as their content.
module ComfortableMexicanSofa::Content::Tag::FileContentMixin

  # When resizing let's not allow gigantic dimensions
  MAX_VARIANT_DIMENSION = 2500.freeze

  attr_reader :as, :label, :html_class, :filename

  def initialize(context:, params: [], source: nil)
    super

    @as         = options["as"] || "url"
    @label      = options["label"]
    @html_class = options["class"]
    @filename   = options["filename"]

    @variant_options = options.slice(
      "resize_to_limit",
      "resize_to_fit",
      "resize_to_fill",
      "resize_and_pad"
    )
  end

  def content
    return "" if fragment_attachments.blank?

    url_helpers = Rails.application.routes.url_helpers
    helpers     = ActionController::Base.helpers

    variant_options_cached = variant_options
    join_string = ""

    fragment_attachments.collect do |attachment|
      file =
        if variant_options.present? && attachment.image?
          attachment.variant(variant_options_cached)
        else
          attachment
        end

      file_label = label || file&.filename
      file_url   = url_helpers.rails_blob_path(file, only_path: true)

      case as
      when "link"
        helpers.link_to(file_label, file_url, class: html_class, target: "_blank")
      when "image"
        helpers.image_tag(file_url, class: html_class, alt: file_label)
      else
        join_string = ", "
        file_url
      end
    end.join(join_string)
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

  def fragment_attachments
    return [] if fragment.nil?

    if filename.present?
      Array.wrap(fragment.attachments.detect { |a| a.filename.to_s == filename })
    else
      fragment.attachments
    end
  end
end
