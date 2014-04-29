class ComfortableMexicanSofa::Tag::Asset
  include ComfortableMexicanSofa::Tag

  def self.regex_tag_signature(identifier = nil)
    identifier ||= IDENTIFIER_REGEX
    /\{\{\s*cms:asset:(#{identifier}):?(.*?)\s*\}\}/
  end

  def content
    return unless (layout = Comfy::Cms::Layout.find_by_identifier(identifier))
    type    = params[0]
    format  = params[1]
    
    case type
    when 'css'
      out = "/cms-css/#{blockable.site.id}/#{identifier}.css#{cms_path}"
      out = "<link href='#{out}' media='screen' rel='stylesheet' type='text/css' />" if format == 'html_tag'
      out
    when 'js'
      out = "/cms-js/#{blockable.site.id}/#{identifier}.js#{cms_path}"
      out = "<script src='#{out}' type='text/javascript'></script>" if format == 'html_tag'
      out
    end
  end

private

  def cms_path
    path = blockable.site.path
    if path.present?
      "?cms_path=#{path}"
    else
      ""
    end
  end
end
