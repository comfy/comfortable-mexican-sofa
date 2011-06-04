class ComfortableMexicanSofa::Tag::UploadText
  include ComfortableMexicanSofa::Tag
  
  def self.regex_tag_signature(label = nil)
    label ||= /[\w\-\.]+/
    /\{\{\s*cms:upload:(#{label}):?(?:text)?\s*\}\}/
  end
  
  def content
    upload.nil? ? nil : upload.file.url
  end
  
end