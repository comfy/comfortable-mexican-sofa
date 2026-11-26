# frozen_string_literal: true

class Comfy::Cms::Page::IndexItemComponent < Comfy::BaseComponent
  with_collection_parameter :item

  haml_template <<~HAML
    %div
      = @item[:label]
      = render Comfy::Cms::Page::IndexItemComponent.with_collection(@item[:children])
  HAML

  def render?
    @item.present?
  end

  def initialize(item:)
    @item = item
  end
end
