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
    walk_tree = lambda do |items, depth = 0|
      items.flat_map do |item|
        [
          ["#{"\u00A0\u00B7\u00A0" * depth} #{item[:label]}", item[:id]],
          *walk_tree.call(item[:children], depth + 1)
        ]
      end
    end

    walk_tree.call(@page.class.tree(records: @page.site.pages))
  end
end
