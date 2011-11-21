class ComfortableMexicanSofa::Tag::PageFile
  include ComfortableMexicanSofa::Tag
  
  # Signature of a tag:
  #   {{ cms:page_file:some_label:type:params }}
  # Simple tag can be:
  #   {{ cms:page_file:some_label }}
  def self.regex_tag_signature(label = nil)
    label ||= /[\w\-]+/
    /\{\{\s*cms:page_file:(#{label}):?(.*?)\s*\}\}/
  end
  
  # Type of the tag controls how file is rendered
  def type
    s = params[0].to_s.gsub(/\[.*?\]/, '')
    %w(partial url image link field).member?(s) ? s : 'url'
  end
  
  def dimensions
    params[0].to_s.match(/\[(.*?)\]/)[1] rescue nil
  end
  
  def content
    block.files.first
  end
  
  def render
    file = block.files.first
    case self.type
    when 'url'
      return '' unless file
      file.file.url
    when 'link'
      return '' unless file
      text = params[1] || label
      "<a href='#{file.file.url}' target='_blank'>#{text}</a>"
    when 'image'
      return '' unless file
      text = params[1] || label
      "<img src='#{file.file.url}' alt='#{text}' />"
    when 'partial'
      path = params[1] || 'partials/page_file'
      ps = (self.params[2..-1] || []).collect_with_index{|p, i| ":param_#{i+1} => '#{p}'"}.join(', ')
      ps = ps.present?? ", #{ps}" : ''
      "<%= render :partial => '#{path}', :locals => {:identifier => #{file.try(:id) || 'nil'}#{ps}} %>"
    when 'field'
      ''
    end
  end
  
end