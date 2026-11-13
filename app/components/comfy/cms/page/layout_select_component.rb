# frozen_string_literal: true

class Comfy::Cms::Page::LayoutSelectComponent < Comfy::BaseComponent
  haml_template <<~HAML
    = @form.select :layout_id, options
  HAML

  def initialize(form:)
    @form = form
    @page = form.object
  end

  def component_html_options
    {
      data: {
        controller: "components--layout-select"
      }
    }
  end

  def options
    walk_tree = lambda do |items, depth = 0|
      items.flat_map do |item|
        [
          ["#{"\u00A0\u00B7\u00A0" * depth} #{item[:label]}", item[:id]],
          *walk_tree.call(item[:children], depth + 1)
        ]
      end
    end

    walk_tree.call(Comfy::Cms::Layout.tree(records: @page.site.layouts))
  end
end
