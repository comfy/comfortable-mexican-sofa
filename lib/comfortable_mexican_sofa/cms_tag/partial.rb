class CmsTag::Partial
  
  attr_accessor :label
  
  include CmsTag
  
  def self.regex_tag_signature(label = nil)
    label ||= /[\w\/]+/
    /<\s*cms:partial:(#{label})\s*\/?>/
  end
  
  def regex_tag_signature
    self.class.regex_tag_signature(label)
  end
  
  def content
    "<%= render :partial => '#{label}' %>"
  end
  
end