# frozen_string_literal: true

class Comfy::Cms::Page::ParentSelectComponent < Comfy::BaseComponent
  haml_template <<~HAML
    = @form.select :parent_id, options
  HAML

  def initialize(form:)
    @form = form
    @page = form.object
  end

  def render?
    options.present?
  end

  def options
    walk_tree = lambda do |items, depth = 0|
      items.flat_map do |item|
        next [] if item[:id] == @page.id

        spacer = "\u00A0\u00B7\u00A0" * depth
        [["#{spacer} #{item[:label]}", item[:id]], *walk_tree.call(item[:children], depth + 1)]
      end
    end

    walk_tree.call(@page.class.tree(records: @page.site.pages))
  end
end
