class ComfortableMexicanSofa::Tag::PageFiles < ComfortableMexicanSofa::Tag::PageFile
  
  def self.regex_tag_signature(label = nil)
    label ||= /[\w\-]+/
    /\{\{\s*cms:page_files:(#{label}):?(.*?)\s*\}\}/
  end
  
end