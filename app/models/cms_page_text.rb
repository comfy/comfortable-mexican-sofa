class CmsPageText < CmsBlock
  
  # -- Class Methods --------------------------------------------------------
  # will match tags with this format:
  #   <cms:page:label:text />
  #   <cms:page:label />
  def self.regex_tag_signature(label = nil)
    label ||= /\w+/
    /<\s*?cms:page:(#{label}):?(?:text)?\s*?\/?>/
  end
  
  # -- Instance Methods -----------------------------------------------------
  def regex_tag_signature
    self.class.regex_tag_signature(label)
  end
  
  def content
    read_attribute(:content_text)
  end
  
  def render
    content
  end
  
end