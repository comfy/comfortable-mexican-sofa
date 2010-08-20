module CmsHelper
  
  def application_name
    ComfortableMexicanSofa::Config.cms_title || 'CMS'
  end
  
  def tree_state(object)
    name = object.class.name.underscore.to_sym
    if session[name].present?
      session[name].include?(object.id) ? '' : 'closed'
    else
      'closed'
    end
  end
  
  def link_to_toggle(object, children_count)
    link_to_function(children_count, '', :class => ['tree_toggle', tree_state(object)].join(' '), :title => 'Expand/Collapse', :onclick => "object_id = '#{object.id}'")
  end
  
  def cms_form_for(record_or_name_or_array, *args, &proc)
    options = args.extract_options!
    options.merge!(:builder => CmsFormBuilder)    
    (options[:html] ||= {}).merge!(:class => (options[:html][:class].to_s + ' formatted'))
    form_for(record_or_name_or_array, *(args << options), &proc)
  end

end
