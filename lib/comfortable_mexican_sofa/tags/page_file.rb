class ComfortableMexicanSofa::Tag::PageFile
  include ComfortableMexicanSofa::Tag
  
  # Signature of a tag:
  #   {{ cms:page_file:some_label:type:params }}
  # Simple tag can be:
  #   {{ cms:page_file:some_label }}
  def self.regex_tag_signature(identifier = nil)
    identifier ||= IDENTIFIER_REGEX
    /\{\{\s*cms:page_file:(#{identifier}):?(.*?)\s*\}\}/
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
      when 'url'      then render_url(file)
      when 'link'     then render_link(file)
      when 'image'    then render_image(file)
      when 'partial'  then render_partial(file)
      else ''
    end
  end
  
  def render_url(file)
    return '' unless file
    file.file.url
  end
  
  def render_link(file)
    return '' unless file
    text = params[1] || identifier
    "<a href='#{file.file.url}' target='_blank'>#{text}</a>"
  end
  
  def render_image(file)
    return '' unless file
    text = params[1] || file.label
    "<img src='#{file.file.url}' alt='#{text}' />"
  end
  
  def render_partial(file)
    path = params[1] || 'partials/page_file'
    ps = (self.params[2..-1] || []).collect_with_index{|p, i| ":param_#{i+1} => '#{p}'"}.join(', ')
    ps = ps.present?? ", #{ps}" : ''
    "<%= render :partial => '#{path}', :locals => {:identifier => #{file.try(:id) || 'nil'}#{ps}} %>"
  end
  
end