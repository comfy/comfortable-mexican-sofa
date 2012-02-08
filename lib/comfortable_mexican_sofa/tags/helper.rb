class ComfortableMexicanSofa::Tag::Helper
  include ComfortableMexicanSofa::Tag
  
  PROTECTED_METHODS = %w(eval class_eval instance_eval)
  
  def self.regex_tag_signature(identifier = nil)
    identifier ||= /[\w\-]+/
    /\{\{\s*cms:helper:(#{identifier}):?(.*?)\s*\}\}/
  end
  
  def content
    "<%= #{identifier}(#{params.collect{|p| "'#{p}'"}.join(', ')}) %>"
  end
  
  def render
    content if !PROTECTED_METHODS.member?(identifier) || ComfortableMexicanSofa.config.allow_irb
  end
  
end