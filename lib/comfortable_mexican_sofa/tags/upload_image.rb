class ComfortableMexicanSofa::Tag::UploadImage
  include ComfortableMexicanSofa::Tag
  
  def self.regex_tag_signature(label = nil)
    label ||= /[\w\-\.]+/
    /\{\{\s*cms:upload:(#{label}):img\s*\}\}/
  end
  
  def content
    "<img src='#{upload.file.url}'/>"
  end
  
end