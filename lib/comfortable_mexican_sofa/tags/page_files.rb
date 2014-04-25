class ComfortableMexicanSofa::Tag::PageFiles
  include ComfortableMexicanSofa::Tag
  
  def self.regex_tag_signature(identifier = nil)
    identifier ||= IDENTIFIER_REGEX
    /\{\{\s*cms:page_files:(#{identifier}):?(.*?)\s*\}\}/
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
    block.files
  end
  
  def render
    files = block.files
    case self.type
    when 'url'
      return '' if files.blank?
      files.collect do |file|
        file.file.url
      end.join(', ')
    when 'link'
      return '' if files.blank?
      files.collect do |file|
        "<a href='#{file.file.url}' target='_blank'>#{file.label}</a>"
      end.join(' ')
    when 'image'
      return '' if files.blank?
      files.collect do |file|
        "<img src='#{file.file.url}' alt='#{file.label}' />"
      end.join(' ')
    when 'partial'
      path = params[1] || 'partials/page_files'
      ps = (self.params[2..-1] || []).collect_with_index{|p, i| ":param_#{i+1} => '#{p}'"}.join(', ')
      ps = ps.present?? ", #{ps}" : ''
      ids = files.present?? files.collect(&:id).join(',') : ''
      "<%= render :partial => '#{path}', :locals => {:identifier => [#{ids}]#{ps}} %>"
    when 'field'
      ''
    end
  end
  
end