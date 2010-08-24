class CmsPageString < CmsBlock
  
  # -- Class Methods --------------------------------------------------------
  # will match tags with this format:
  #   <cms:page:label:string />
  def self.regex_tag_signature(label = nil)
    label ||= /\w+/
    /<\s*?cms:page:(#{label}):?(?:string)\s*?\/?>/
  end
  
  # -- Instance Methods -----------------------------------------------------
  def content
    read_attribute(:content_string)
  end
  
  def render
    content
  end
  
end