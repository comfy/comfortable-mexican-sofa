class ComfortableMexicanSofa::Tag::Collection
  include ComfortableMexicanSofa::Tag
  
  # Here's a full tag signature:
  #   {{ cms:collection:label:collection_class:collection_partial:collection_title:collection_identifier:collection_params }}
  # Most minimal tag can look like this:
  #   {{ cms:collection:album:foo/my_album }}
  # A more complete example of the above:
  #   {{ cms:collection:album:foo/my_album:albums/show:title:slug:param_a:param_b }}
  def self.regex_tag_signature(identifier = nil)
    identifier ||= IDENTIFIER_REGEX
    /\{\{\s*cms:collection:(#{identifier}):(.*?)\s*\}\}/
  end
  
  # Class definitition. It's basically `Herp::DerpityDerp.undescore` so an example
  # of valid definition is: `herp/derpity_derp`
  def collection_class
    self.params[0].classify
  end
  
  # Path to the partial. Example: `path/to/partial`
  def collection_partial
    self.params[1] || "partials/#{self.collection_class.underscore.pluralize}"
  end
  
  # Title method for the Collection objects. Default is `label`
  def collection_title
    self.params[2] || 'label'
  end
  
  # Identifier that will be used to find selected collection object. Defaults to `id`
  def collection_identifier
    self.params[3] || 'id'
  end
  
  # Extra params that will be passed to the partial AND ALSO will be passed as parameters
  # for the `cms_collection` scope you can define for your Collection object
  def collection_params
    self.params[4..-1] || []
  end
  
  # Array of objects used in the collection
  # You may set up a scope on the model `scope :cms_collection, lambda|*args| do ... end `
  # `args` will be the set of `collection_params`
  def collection_objects
    klass = self.collection_class.constantize
    klass.respond_to?(:cms_collection) ? klass.cms_collection(*collection_params) : klass.all
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