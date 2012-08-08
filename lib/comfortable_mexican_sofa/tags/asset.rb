class ComfortableMexicanSofa::Tag::Asset
  include ComfortableMexicanSofa::Tag

  def self.regex_tag_signature(identifier = nil)
    identifier ||= IDENTIFIER_REGEX
    /\{\{\s*cms:asset:(#{identifier}):?(.*?)\s*\}\}/
  end

  def content
    return unless (layout = Cms::Layout.find_by_identifier(identifier))
    type    = params[0]
    format  = params[1]
    
    case type
    when 'css'
      out = "/cms-css/#{page.site.id}/#{identifier}.css"
      out = "<link href='#{out}' media='screen' rel='stylesheet' type='text/css' />" if format == 'html_tag'
      out
    when 'js'
      out = "/cms-js/#{page.site.id}/#{identifier}.js"
      out = "<script src='#{out}' type='text/javascript'></script>" if format == 'html_tag'
      out
    end
  end
end
