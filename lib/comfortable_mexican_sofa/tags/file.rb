class ComfortableMexicanSofa::Tag::File
  include ComfortableMexicanSofa::Tag
  
  def self.regex_tag_signature(identifier = nil)
    identifier ||= IDENTIFIER_REGEX
    /\{\{\s*cms:file:(#{identifier}):?(.*?)\s*\}\}/
  end
  
  # Initializing Cms::File object
  def file
    page.site.files.detect{|f| f.file_file_name == self.identifier.to_s}
  end
  
  def content
    return unless file
    
    format  = params[0]
    text    = params[1] || identifier
    
    case format
    when 'link'
      "<a href='#{file.file.url}' target='_blank'>#{text}</a>"
    when 'image'
      "<img src='#{file.file.url}' alt='#{text}' />"
    else
      file.file.url
    end
  end
end