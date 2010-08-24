class CmsTag::PageString
  
  include CmsTag
  
  def self.regex_tag_signature(label = nil)
    label ||= /\w+/
    /<\s*?cms:page:(#{label}):string\s*?\/?>/
  end
  
  def regex_tag_signature
    self.class.regex_tag_signature(label)
  end
  
end