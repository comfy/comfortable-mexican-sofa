# frozen_string_literal: true

class Comfy::Cms::Page::IndexComponent < Comfy::BaseComponent
  haml_template <<~HAML
    = render Comfy::Cms::Page::IndexItemComponent.with_collection(@pages.tree)
  HAML

  def initialize(pages:)
    @pages = pages
  end

  def render_tree(items:)
    items.flat_map do |item|
      if item[:children].present?
        render_tree(items: item[:children])
      end
    end.join
  end
end
