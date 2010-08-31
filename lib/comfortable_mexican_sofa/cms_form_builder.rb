class CmsFormBuilder < ActionView::Helpers::FormBuilder
  
  helpers = field_helpers -
    %w(hidden_field fields_for)
    
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
  
  # Helper method for all block tags. You can define your own method based
  # on tag type.
  def cms_block_field(block, *args)
    block_method = block.type.split('::').last.underscore.downcase
    return send(block_method, block) if self.respond_to? block_method
    
    form_method = case block
    when CmsTag::PageText
      :text_area_tag
    when CmsTag::PageString
      :text_field_tag
    when CmsTag::PageInteger
      :number_field_tag
    end
    
    %(
      <div class='form_element #{block_method}_element'>
        <div class='label'>#{block.label.to_s.titleize}</div>
        <div class='value'>
          #{@template.send(form_method, 'cms_page[cms_blocks_attributes][][content]', block.content)}
          #{@template.hidden_field_tag('cms_page[cms_blocks_attributes][][label]', block.label)}
          #{@template.hidden_field_tag('cms_page[cms_blocks_attributes][][type]', block.type)}
        </div>
      </div>
    ).html_safe
  end
  
end