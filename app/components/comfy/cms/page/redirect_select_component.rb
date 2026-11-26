# frozen_string_literal: true

class Comfy::Cms::Page::RedirectSelectComponent < Comfy::BaseComponent
  haml_template <<~HAML
    = @form.select :target_page_id, options, prompt: "\u2015 \#{t(".prompt")} \u2015", disabled: @page.id
  HAML

  def initialize(form:)
    @form = form
    @page = form.object
  end

  def render?
    options.present?
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

    walk_tree.call(@page.site.pages.tree)
  end
end
