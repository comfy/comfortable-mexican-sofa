class ComfortableMexicanSofa::Tag::Asset
  include ComfortableMexicanSofa::Tag

  def self.regex_tag_signature(label = nil)
    label ||= /[\w\-]+/
    /\{\{\s*cms:asset:(#{label}):?(.*?)\s*\}\}/
  end

  def content
    html = ""
    case label
      when 'stylesheet_link_tag'
        params.split(':').each do |slug|
          path = "#{ComfortableMexicanSofa.config.content_route_prefix}/cms-css/#{slug}.css"
          html += "<link href=\"#{path}\" media=\"screen\" rel=\"stylesheet\" type=\"text/css\" />"
        end
      when 'javascript_include_tag'
        params.split(':').each do |slug|
          path = "#{ComfortableMexicanSofa.config.content_route_prefix}/cms-js/#{slug}.js"
          html += "<script src=\"#{path}\" type=\"text/javascript\"></script>"
        end
    end
    html
  end

end
