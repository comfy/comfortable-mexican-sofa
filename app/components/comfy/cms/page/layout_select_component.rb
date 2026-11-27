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
    walk_tree = lambda do |tree_nodes, depth = 0|
      tree_nodes.flat_map do |tree_node|
        [
          ["#{"\u00A0\u00B7\u00A0" * depth} #{tree_node.item.label}", tree_node.item.id],
          *walk_tree.call(tree_node.children, depth + 1)
        ]
      end
    end

    walk_tree.call(@page.site.layouts.tree)
  end
end
