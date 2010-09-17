class CmsTag::Partial
  
  include CmsTag
  
  def self.regex_tag_signature(label = nil)
    label ||= /\w+/
    /<\s*?#{TAG_PREFIX}:partial:(#{label})\s*?\/?>/
  end
  
  def regex_tag_signature
    self.class.regex_tag_signature(label)
  end
  
  def content
    "partial #{label}"
  end
  
end