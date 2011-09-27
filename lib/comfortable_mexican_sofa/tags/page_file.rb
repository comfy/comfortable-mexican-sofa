class ComfortableMexicanSofa::Tag::PageFile
  include ComfortableMexicanSofa::Tag
  
  def self.regex_tag_signature(label = nil)
    label ||= /[\w\-]+/
    /\{\{\s*cms:page_file:(#{label}):?(.*?)\s*\}\}/
  end
  
  def content
    # ...
  end
  
end