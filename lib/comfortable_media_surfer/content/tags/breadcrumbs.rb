# frozen_string_literal: true

# Nav Tag for rendering breadcrumb links to current page
#   {{ cms:breadcrumbs }}
#   {{ cms:breadcrumbs style: "font-weight: bold" }}
# To customize your breadcrumbs style, add a 'breadcrumbs' id to your CSS, e.g
# #breadcrumbs {
#   color: #006633;
#   font-family: Verdana, Arial, Helvetica, sans-serif;
#   font-size: 105%;
#   font-weight: bold;
#   margin-top: 12px;
#   margin-bottom: 4px;
#   font-style: italic;
# }
# and/or pass in style overrides with the 'style' parameter, as above

class ComfortableMediaSurfer::Content::Tags::Breadcrumbs < ComfortableMediaSurfer::Content::Tag
  attr_reader :links, :style, :locals

  def initialize(context:, params: [], source: nil)
    super
    @locals = params.extract_options!
    @style = ''
    @style = "<style>#breadcrumbs {#{@locals['style']}}</style>" if @locals['style']

    @links = '<div id="breadcrumbs">'
    context.ancestors.reverse.each do |a|
      next if Rails.env == 'production' && !a.is_published

      @links += "<a href=#{a.url(relative: true)}>#{a.label}</a> &raquo; "
    end
    @links += "#{context.label}</div>"
  end

  def content
    format("#{@style}#{@links}")
  end
end

ComfortableMediaSurfer::Content::Renderer.register_tag(
  :breadcrumbs, ComfortableMediaSurfer::Content::Tags::Breadcrumbs
)
