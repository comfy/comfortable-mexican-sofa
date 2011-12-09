class ComfortableMexicanSofa::Tag::Snippet
  include ComfortableMexicanSofa::Tag
  
  def self.regex_tag_signature(identifier = nil)
    identifier ||= /[\w\-]+/
    /\{\{\s*cms:snippet:(#{identifier})\s*\}\}/
  end
  
  # Find or initialize Cms::Snippet object
  def snippet
    page.site.snippets.detect{|s| s.identifier == self.identifier.to_s} ||
      page.site.snippets.build(:identifier => self.identifier.to_s)
  end
  
  def content
    snippet.content
  end
  
end