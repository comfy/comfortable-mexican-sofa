# frozen_string_literal: true

# Nav Tag for unordered list of links to the children of the current page
#   {{ cms:children }}
#   {{ cms:children style: "font-weight: bold", exclude: "404-page, search-page" }}
# To customize your children style, add a 'children' id to your CSS, e.g
# #children {
#   color: #006633;
#   font-size: 90%;
#   margin-bottom: 4px;
#   font-style: italic;
# }
# and/or pass in style overrides with the 'style' parameter, as above
#
# To exclude children, list their slugs with the 'exclude' parameter
# as comma-delimited string, e.g. as above - exclude: "404-page, search-page"

class ComfortableMediaSurfer::Content::Tags::Children < ComfortableMediaSurfer::Content::Tag
  attr_reader :style, :page_children, :locals
  attr_accessor :list

  def initialize(context:, params: [], source: nil)
    super
    @locals = params.extract_options!
    @style  = ''
    @style  = "<style>#children {#{@locals['style']}}</style>\n" if @locals['style']
    @exclude = []
    @exclude = @locals['exclude'].split(',') if @locals['exclude']
    @list = ''
    # ActiveRecord_Associations_CollectionProxy
    @page_children = context.children.order(:position).to_ary
    unless Rails.env == 'development'
      @page_children.delete_if { |child| !child.is_published }
    end
    @page_children.delete_if { |child| @exclude.include? child.slug }
  end

  def content
    if @page_children.any?
      @list = "<ul id=\"children\">\n"
      @page_children.each do |c|
        @list += "  <li><a href=#{c.url(relative: true)}>#{c.label}</a></li>\n"
      end
      @list += '</ul>'
    end
    format("#{@style}#{@list}")
  end
end

ComfortableMediaSurfer::Content::Renderer.register_tag(
  :children, ComfortableMediaSurfer::Content::Tags::Children
)
