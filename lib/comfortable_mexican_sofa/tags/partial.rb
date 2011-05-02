class ComfortableMexicanSofa::Tag::Partial
  include ComfortableMexicanSofa::Tag
  
  def self.regex_tag_signature(label = nil)
    label ||= /[\w\/\-]+/
    /\{\{\s*cms:partial:(#{label}):?(.*?)\s*\}\}/
  end
  
  def content
    ps = params.split(':').collect_with_index{|p, i| ":param_#{i+1} => '#{p}'"}.join(', ')
    "<%= render :partial => '#{label}'#{ps.blank?? nil : ", :locals => {#{ps}}"} %>"
  end
  
end