class ComfortableMexicanSofa::Tag::Partial
  include ComfortableMexicanSofa::Tag
  
  def self.regex_tag_signature(identifier = nil)
    identifier ||= /[\w\/\-]+/
    /\{\{\s*cms:partial:(#{identifier}):?(.*?)\s*\}\}/
  end
  
  def content
    ps = params.collect_with_index{|p, i| ":param_#{i+1} => '#{p}'"}.join(', ')
    "<%= render :partial => '#{identifier}'#{ps.blank?? nil : ", :locals => {#{ps}}"} %>"
  end
  
  def render
    whitelist = ComfortableMexicanSofa.config.allowed_partials
    if whitelist.is_a?(Array)
      content if whitelist.member?(identifier)
    else
      content
    end
  end
  
end