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
  
end