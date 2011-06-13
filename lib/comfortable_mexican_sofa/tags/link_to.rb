class ComfortableMexicanSofa::Tag::LinkTo
  include ComfortableMexicanSofa::Tag

  def self.regex_tag_signature(label = nil)
    label ||= /[^:]+/
    /\{\{\s*cms:link_to:(#{label}):?(.*?)\s*\}\}/
  end

  def content
    ps = params.split(':')
    path = ps.first
    unless path =~ /\//
      slug = path
      target_page = page.site.pages.published.find_by_slug(slug)
      return nil unless target_page.present?
      path = ComfortableMexicanSofa.config.content_route_prefix + target_page.full_path
    end
    "<a href=\"#{path}\">#{label}</a>"
  end
end
