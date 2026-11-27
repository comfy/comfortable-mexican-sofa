# frozen_string_literal: true

class Comfy::Cms::Page::IndexItemComponent < Comfy::BaseComponent
  with_collection_parameter :tree_node

  haml_template <<~HAML
    .page
      .toggle
        = t(".toggle")
        = helpers.inline_svg_tag("comfy/caret.svg")
      .icon
        = helpers.inline_svg_tag("comfy/page.svg")
      .info
        = link_to @page.label, edit_comfy_admin_cms_site_page_path(@site, @page)
        .url
          = link_to @page.url, @page.url, target: "_blank"
      .categories
        - @page.categories.each do |category|
          = category.label
      .links
        - path = new_comfy_admin_cms_site_page_path(@site, parent_id: @page.id)
        = render Comfy::Cms::ButtonComponent.new(t(".add_child_page"), path, type: %i[small secondary])

        - path = edit_comfy_admin_cms_site_page_path(@site, @page)
        = render Comfy::Cms::ButtonComponent.new(t(".edit"), path, type: %i[small secondary])

        -# - path = comfy_admin_cms_site_page_path(@site, @page)
        -# - data = { turbo_method: :delete, turbo_confirm: t(".are_you_sure") }
        -# = render Comfy::Cms::ButtonComponent.new(t(".delete"), path, button: true, data: data, type: %i[small danger])

    - if @tree_node.children.any?
      .page-children
        = render Comfy::Cms::Page::IndexItemComponent.with_collection(@tree_node.children)
  HAML

  def initialize(tree_node:)
    @tree_node = tree_node
    @page      = tree_node.item
    @site      = @page.site
  end
end
