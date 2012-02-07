class ComfortableMexicanSofa::Tag::Partial
  include ComfortableMexicanSofa::Tag
  
  def self.regex_tag_signature(identifier = nil)
    identifier ||= /[\w\/\-]+/
    /\{\{\s*cms:partial:(#{identifier}):?(.*?)\s*\}\}/
  end
  
  def content
    ps = params.collect_with_index{|p, i| ":param_#{i+1} => '#{self.class.sanitize_parameter(p)}'"}.join(', ')
    "<%= render :partial => '#{identifier}'#{ps.blank?? nil : ", :locals => {#{ps}}"} %>"
  end
  
end