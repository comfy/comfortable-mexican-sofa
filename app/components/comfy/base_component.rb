# frozen_string_literal: true

class Comfy::BaseComponent < ViewComponent::Base

  def around_render
    content_tag(self.class.to_s.underscore.dasherize.gsub("/", "--")) do
      yield
    end
  end
end
