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

    base = ComfortableMexicanSofa.config.public_cms_path || ''
    unless base.ends_with?("/") # => true
      base = base + "/"
    end

    case type
    when 'css'
      out = "#{base}cms-css/#{blockable.site.id}/#{identifier}/#{layout.cache_buster}.css"
      out = "<link href='#{out}' media='screen' rel='stylesheet' type='text/css' />" if format == 'html_tag'
      out
    when 'js'
      out = "#{base}cms-js/#{blockable.site.id}/#{identifier}/#{layout.cache_buster}.js"
      out = "<script src='#{out}' type='text/javascript'></script>" if format == 'html_tag'
      out
    end
  end
end
