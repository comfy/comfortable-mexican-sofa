class ComfortableMexicanSofa::Tag::Snippet
  include ComfortableMexicanSofa::Tag
  
  def self.regex_tag_signature(label = nil)
    label ||= /[\w\-]+/
    /\{\{\s*cms:snippet:(#{label})\s*\}\}/
  end
  
  # Find or initialize Cms::Snippet object
  def snippet
    page.site.snippets.detect{|s| s.identifier == self.label.to_s} || page.site.snippets.build(:identifier => self.label.to_s)
  end
  
  def content
    snippet.content
  end
  
end