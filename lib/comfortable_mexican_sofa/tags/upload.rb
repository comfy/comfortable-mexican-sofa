class ComfortableMexicanSofa::Tag::Upload
  include ComfortableMexicanSofa::Tag
  
  def self.regex_tag_signature(label = nil)
    label ||= /[\w\-\.]+/
    /\{\{\s*cms:upload:(#{label}):?(.*?)\s*\}\}/
  end
  
  def content
    return unless upload
    
    format  = params[0]
    text    = params[1] || label
    
    case format
    when 'link'
      "<a href='#{upload.file.url}' target='_blank'>#{text}</a>"
    when 'image'
      "<img src='#{upload.file.url}' alt='#{text}' />"
    else
      upload.file.url
    end
  end
end