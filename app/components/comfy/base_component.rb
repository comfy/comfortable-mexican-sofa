# frozen_string_literal: true

class Comfy::BaseComponent < ViewComponent::Base
  def around_render
    content_tag(component_identifier, yield, component_html_options)
  end

  def component_html_options
    {}
  end

  def component_identifier
    self.class.to_s.underscore.dasherize.gsub("/", "--")
  end
end
