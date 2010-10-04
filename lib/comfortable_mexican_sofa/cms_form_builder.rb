class CmsFormBuilder < ActionView::Helpers::FormBuilder
  
  helpers = field_helpers -
    %w(hidden_field fields_for) +
    %w(select)
    
  helpers.each do |name|
    class_eval %Q^
      def #{name}(field, *args)
        options = args.extract_options!
        args << options
        return super if options.delete(:disable_builder)
        default_field('#{name}', field, options){ super }
      end
    ^
  end
  
  def default_field(type, field, options = {}, &block)
    %(
      <div class='form_element #{type}_element'>
        <div class='label'>#{label_for(field, options)}</div>
        <div class='value'>#{yield}</div>
      </div>
    ).html_safe
  end
  
  def label_for(field, options)
    label = options.delete(:label) || field.to_s.titleize.capitalize
    "<label for=\"#{object_name}_#{field}\">#{label}</label>".html_safe
  end
  
  def page_text(tag)
    raise 'yey'
  end
  
  def page_string(tag)
    raise 'yey'
  end
  
  # Capturing all calls of cms_tag_* type. For those we'll try to render
  # a form element. Everything else can trigger MethodNotFound error.
  def method_missing(method_name, *args)
    if m = method_name.to_s.match(/^cms_tag_(\w+)$/)
      send(m[1], args) if respond_to?(m[1])
    else
      super
    end
  end
  
  def tag_field(tag)
    %(
      <div class='form_element #{tag_method}_element'>
        <div class='label'>#{tag.label.to_s.titleize}</div>
        <div class='value'>
          #{send(form_method, 'cms_page[cms_blocks_attributes][][content]', tag.content)}
          #{hidden_field_tag('cms_page[cms_blocks_attributes][][label]', tag.label)}
          #{hidden_field_tag('cms_page[cms_blocks_attributes][][type]', tag.type)}
          #{hidden_field_tag('cms_page[cms_blocks_attributes][][id]', tag.id) unless tag.new_record?}
        </div>
      </div>
    )
  end
  
end