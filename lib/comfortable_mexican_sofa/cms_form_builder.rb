class CmsFormBuilder < ActionView::Helpers::FormBuilder

  %w{ date_select text_field password_field text_area file_field}.each do |selector|
    src = <<-end_src
      def #{selector}(method, options = {})
        options.merge!(:size=> '') if #{%w{text_field password_field}.include?(selector)}
        standard_field('#{selector}', method, options) { super(method, options) }
      end
    end_src
    class_eval src, __FILE__, __LINE__
  end

  def standard_field(type, method, options={}, &block)
    description = options.delete(:desc)
    content = options.delete(:content)
    label = options[:label] || label_for(method, options)
    required = options.delete(:required)

    output = "<div class='form_element #{type}_element'>"
      if type != 'check_box'
        output << "<div class='label'>#{label}"
        output << "#{@template.content_tag(:span, '*', :class => 'required_ind') if required }"
        output << "</div>"
      end
      output << "<div class='value'>"
        output << "#{yield}#{content}"
        output << "#{error_messages_for(method)}"
        output << "#{description(description)}" if type != 'check_box'
      output << "</div>"
    output << "</div>"

    output.html_safe
  end

  def custom_element(label, content, options={})
    css_class = options[:css_class].blank? ? "text_field_element" : options[:css_class]
    errors = if options[:method_name]
      error_for(options.delete(:method_name))
    elsif options[:method_names]
      method_names = options.delete(:method_names)
      method_names.collect{|method_name| error_for(method_name)}.uniq.join(' ')
    end
    %{
      <div class='form_element #{css_class}'>
        <div class='label'>
          #{label}
        </div>
        <div class='value'>
          #{content}
          #{errors}
          #{description(options.delete(:desc))}
        </div>
      </div>
    }.html_safe
  end

  def check_box(method, options = {}, checked_value = "1", unchecked_value = "0")
    options[:content] = label_for(method, options)
    options[:label] = '&nbsp;'
    standard_field('check_box', method, options) { super(method, options, checked_value, unchecked_value) }
  end

  # Example Usage
  #   form.radio_button :field_name, :foo_value
  #   form.radio_button :gender, %w(Male Female)
  #   form.radio_button :gender, [['Male','m'],['Female','f']]
  #   form.radio_button :gender, {'Male' => 'm', 'Female' => 'f'}, :checked => 'f'
  def radio_button(method, tag_value, options = {})
    if tag_value.is_a? Hash
      tag_value_hash = tag_value
      tag_value = []
      tag_value_hash.each_pair do |label, value|
        tag_value << [label,value]
      end
    end

    if tag_value.is_a? Array
      checked_value = options.delete(:checked)
      radios = tag_value.collect do |choice|
        if choice.is_a? Array
          label, value = choice[0], choice[1]
        else
          label = value = choice
        end

        %(
          #{super(method,value,options.merge({:checked => (value == checked_value)}))}
          <label for='#{object_name}_#{method}_#{value.downcase}'>#{label}</label>
        ).html_safe
      end.join

      standard_field('radio_button', method,  {:label => method.to_s.humanize}.merge(options)) { radios }
    else
      standard_field('radio_button', method, options) { super(method, tag_value, options = {}) }
    end
  end

  # Renders a jQuery UI datepicker on a text field
  def datepicker(method, options = {})
    text_field(method, ({'data-datepicker' => true}).merge(options)) 
  end

  def select(method, choices, options = {}, html_options = {})
    standard_field('select', method, options) { super(method, choices, options, html_options) }
  end

  def hidden_field(method, options = {}, html_options = {})
    super(method, options)
  end

  def submit(value, options={}, &block)
    cancel_link = @template.capture(&block) if block_given?
    cancel_link ||= options[:cancel_url] ? ' or ' + options.delete(:cancel_url) : ''
    if options[:show_ajax_loader]
      options[:onclick] = "$(this).parent().next().css('display', 'block');$(this).parent().hide();"
    end
    out = @template.content_tag(:div, super(value, options) + cancel_link, :class => 'form_element submit_element')
    if options[:show_ajax_loader] === true
      options[:show_ajax_loader] = %{
        Sending.. <img src='/images/cms/spinner.gif' />
      }
    end

    if options[:show_ajax_loader]
      out << %{
        <div class="form_element submit_element" style="display:none">
          <div class="submit_ajax_loader">#{options[:show_ajax_loader]}</div>
        </div>
      }.html_safe
    end
    out.html_safe
  end
  

  def label_for(method, options)
    label = options.delete(:label) || method.to_s.titleize.capitalize
    "<label for=\"#{object_name}_#{method}\">#{label}</label>".html_safe
  end

  def description(description)
    "<div class='description'>#{description}</div>".html_safe unless description.nil?
  end

  def error_messages
    if @object && @object.errors.count > 0
      if @object.errors[:base].present?
        message = @object.errors[:base]
      else
        message = %(
          There were some problems submitting this form. <br/>
          Please correct all the highlighted fields and try again.
        ).html_safe
      end
      @template.content_tag(:div, message, :class => 'errorExplanation')
    end
  end

  def error_messages_for(method)
    if (!@object.nil? and @object.respond_to?(:errors) and errors = @object.errors[method] and errors.present?)
      "<div class='errors'>#{method.to_s.humanize} #{errors.is_a?(Array) ? errors.first : errors}</div>".html_safe
    else
      ''
    end
  end
end
