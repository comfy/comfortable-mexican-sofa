# frozen_string_literal: true

# Nav Tag for rendering previous and next sibling links relative to current page
#   {{ cms:siblings }}
#   {{ cms:siblings style: "font-style: italic", exclude: "404-page, search-page" }}
# To customize your siblings style, add a 'siblings' id to your CSS, e.g
# #siblings {
#   color: #006633;
#   font-size: 95%;
#   margin-top: 12px;
#   font-style: italic;
# }
# and/or pass in style overrides with the 'style' parameter (see above)
#
# To exclude siblings, list their slugs with the 'exclude' parameter
# as comma-delimited string, e.g. as above - exclude: "404-page, search-page"
#
# style and exclude parameters are optional

class ComfortableMediaSurfer::Content::Tags::Siblings < ComfortableMediaSurfer::Content::Tag
  attr_reader :locals, :style, :sibs
  attr_accessor :links

  def initialize(context:, params: [], source: nil)
    super
    @locals = params.extract_options!
    @style = ''
    @style = "<style>#siblings {#{@locals['style']}}</style>" if @locals['style']
    @exclude = []
    @exclude = @locals['exclude'].split(',') if @locals['exclude']
    @links = ''
    # ActiveRecord_Associations_CollectionProxy
    @sibs = context.self_and_siblings.order(:position).to_ary
    unless Rails.env == 'development'
      @sibs.delete_if { |sib| !sib.is_published }
    end
    @sibs.delete_if { |sib| @exclude.include? sib.slug }
  end

  def content
    if @sibs.count > 1
      @links = '<div id="siblings">'
      prevp = false
      @sibs.each do |sib|
        sib_idx = @sibs.index(sib)
        next if sib.slug == context.slug
        next if Rails.env == 'production' && !sib.is_published
        next unless @sibs.index(context) # current page is excluded

        if sib_idx == @sibs.index(context) - 1
          @links += "<a href=#{sib.url(relative: true)}>#{sib.label}</a> &laquo;&nbsp;<em>Previous</em> &bull; "
          prevp = true
        elsif sib_idx == @sibs.index(context) + 1
          @links += '&bull;' unless prevp
          @links += "<em>Next</em>&nbsp;&raquo; <a href=#{sib.url(relative: true)}>#{sib.label}</a>"
        end
      end
      @links += '</div>'
    end
    format("#{@style}#{@links}")
  end
end

ComfortableMediaSurfer::Content::Renderer.register_tag(
  :siblings, ComfortableMediaSurfer::Content::Tags::Siblings
)
