# frozen_string_literal: true

class Comfy::BaseComponent < ViewComponent::Base
  def around_render
    tag_name = self.class.to_s.underscore.dasherize.gsub("/", "--")
    content_tag(tag_name, yield)
  end
end
