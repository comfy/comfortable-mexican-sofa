require_relative './page_file'

class ComfortableMexicanSofa::Tag::PageFiles < ComfortableMexicanSofa::Tag::PageFile
  include ComfortableMexicanSofa::Tag
  
  def self.regex_tag_signature(identifier = nil)
    identifier ||= IDENTIFIER_REGEX
    /\{\{\s*cms:page_files:(#{identifier}):?(.*?)\s*\}\}/
  end
    
  def content
    block.files
  end
  
  def render
    files = block.files
    case self.type
      when 'url'      then render_url(files)
      when 'link'     then render_link(files)
      when 'image'    then render_image(files)
      when 'partial'  then render_partial(files)
      else ''
    end
  end
  
  def render_url(files)
    return '' if files.blank?
    files.collect{|file| super(file)}.join(', ')
  end
  
  def render_link(files)
    return '' if files.blank?
    files.collect do |file|
      "<a href='#{file.file.url}' target='_blank'>#{file.label}</a>"
    end.join(' ')
  end
  
  def render_image(files)
    return '' if files.blank?
    files.collect{|file| super(file)}.join(' ')
  end
  
  def render_partial(files)
    path = params[1] || 'partials/page_files'
    ps = (self.params[2..-1] || []).collect_with_index{|p, i| ":param_#{i+1} => '#{p}'"}.join(', ')
    ps = ps.present?? ", #{ps}" : ''
    ids = files.present?? files.collect(&:id).join(',') : ''
    "<%= render :partial => '#{path}', :locals => {:identifier => [#{ids}]#{ps}} %>"
  end
  
end