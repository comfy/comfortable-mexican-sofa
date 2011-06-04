class ComfortableMexicanSofa::Tag::UploadImage
  include ComfortableMexicanSofa::Tag
  
  def self.regex_tag_signature(label = nil)
    label ||= /[\w\-\.]+/
    /\{\{\s*cms:upload:(#{label}):image:?(.*?)\s*\}\}/
  end
  
  def content
    return nil if upload.nil?
    alt = if params.empty?
      upload.file_file_name
    else
      params
    end
    "<img src='#{upload.file.url}' alt='#{alt}' />"
  end
end