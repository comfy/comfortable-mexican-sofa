class CmsTag::Helper
  
  attr_accessor :label
  
  include CmsTag
  
  def self.regex_tag_signature(label = nil)
    label ||= /\w+/
    /\{\s*cms:helper:(#{label}):?(.*?)\s*\}/
  end
  
  def regex_tag_signature
    self.class.regex_tag_signature(label)
  end
  
  def content
    "<%= #{label}(#{params.split(':').collect{|p| "'#{p}'"}.join(', ')}) %>"
  end
  
end