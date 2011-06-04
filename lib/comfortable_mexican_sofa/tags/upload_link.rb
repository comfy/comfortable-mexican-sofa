class ComfortableMexicanSofa::Tag::UploadLink
  include ComfortableMexicanSofa::Tag
  
  def self.regex_tag_signature(label = nil)
    label ||= /[\w\-\.]+/
    /\{\{\s*cms:upload:(#{label}):link:?(.*?)\s*\}\}/
  end
  
  def content
    return nil if upload.nil?
    text = if params.empty?
      upload.file_file_name
    else
      params
    end
    "<a href='#{upload.file.url}'>#{text}</a>"
  end
  
end