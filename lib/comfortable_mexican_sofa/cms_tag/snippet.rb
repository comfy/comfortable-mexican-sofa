class CmsTag::Snippet < CmsSnippet
  
  include CmsTag
  
  def self.regex_tag_signature(label = nil)
    label ||= /\w+/
    /<\s*?cms:snippet:(#{label})\s*?\/?>/
  end
  
  def regex_tag_signature
    self.class.regex_tag_signature(label)
  end
  
  def content
    self.read_attribute(:content)
  end
  
end