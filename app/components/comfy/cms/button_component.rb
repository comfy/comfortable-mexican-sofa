# frozen_string_literal: true

class Comfy::Cms::ButtonComponent < Comfy::BaseComponent
  def initialize(text, url = nil, form: nil, button: false, type: [], icon: nil, **options)
    @text    = text
    @url     = url
    @form    = form
    @button  = button
    @type    = Array.wrap(type).map(&:to_s)
    @icon    = icon
    @options = options
  end

  def call
    if @icon.present?
      @text = helpers.safe_join([helpers.inline_svg_tag("icons/#{@icon}.svg"), @text])
    end

    if @form.present?
      submit_tag @text, **@options
    elsif @button
      button_to @text, @url, **@options
    else
      link_to @text, @url, **@options
    end
  end

  def component_html_options
    { class: @type }
  end
end
