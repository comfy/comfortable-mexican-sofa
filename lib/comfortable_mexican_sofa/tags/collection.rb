class ComfortableMexicanSofa::Tag::Collection
  include ComfortableMexicanSofa::Tag
  
  # Simple example for Albums collection rendered out by albums/show partial
  # making assumtion that we will use `label` and `id` as Album attributes
  #   {{ cms:collection:Album:albums/show }}
  # If Album uses `title` and `slug` tag will look as follows:
  #   {{ cms:collection:Album:albums/show:title:slug }}
  # If you need to send more paramers to the partial just attach them as such:
  #   {{ cms:collection:Album:albums/show:title:slug:param_a:param_b }}
  def self.regex_tag_signature(label = nil)
    label ||= /[\w\/\-]+/
    /\{\{\s*cms:collection:(#{label}):([\w\/\-\:]+)\s*\}\}/
  end
  
  def collection_partial
    self.params.first
  end
  
  def collection_class
    label.classify
  end
  
  def collection_title
    self.params[1] || 'label'
  end
  
  def collection_identifier
    self.params[2] || 'id'
  end
  
  def collection_params
    self.params[3..-1] || []
  end
  
  def content=(value)
    block.content = value
  end
  
  def content
    block.content
  end
  
  def render
    if self.content.present?
      ps = collection_params.collect_with_index{|p, i| ":param_#{i+1} => '#{p}'"}.join(', ')
      ps = ps.present?? ", #{ps}" : ''
      "<%= render :partial => '#{collection_partial}', :locals => {:model => '#{collection_class}', :identifier => '#{content}'#{ps}} %>"
    else
      ''
    end
  end
  
end