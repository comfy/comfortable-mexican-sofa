class ComfortableMexicanSofa::Tag::Snippet
  include ComfortableMexicanSofa::Tag
  
  def self.regex_tag_signature(label = nil)
    label ||= /[\w\-]+/
    /\{\{\s*cms:snippet:(#{label})\s*\}\}/
  end
  
  def content
    snippet.content
  end
  
end