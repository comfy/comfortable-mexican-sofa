# frozen_string_literal: true

module ComfortableMexicanSofa::RenderMethods

  def self.included(base)
    # If application controller doesn't have template associated with it
    # CMS will attempt to find one. This is so you don't have to explicitly
    # call render cms_page: '/something'
    base.rescue_from "ActionView::MissingTemplate" do |e|
      begin
        render cms_page: request.path
      rescue ComfortableMexicanSofa::MissingPage, ComfortableMexicanSofa::MissingSite
        raise e
      end
    end
  end

  # Now you can render cms_page simply by calling:
  #   render cms_page: '/path/to/page'
  # This way application controllers can use CMS content while populating
  # instance variables that can be used in partials (that are included by
  # by the cms page and/or layout)
  #
  # Or how about not worrying about setting up CMS pages and rendering
  # application view using a CMS layout?
  #   render cms_layout: 'layout_slug', cms_fragments: {
  #     fragment_identifier_a: 'content text',
  #     fragment_identifier_b: {template: 'path/to/template' },
  #     fragment_identifier_c: {partial:  'path/to/partial' }
  #   }
  #
  # This way you are populating page block content and rendering
  # an instantialized CMS page.
  #
  # Site is loaded automatically based on the request. However you can force
  # it by passing :cms_site parameter with site's slug. For example:
  #   render cms_page: '/path/to/page', cms_site: 'default'
  #
  def render(options = {}, locals = {}, &block)
    return super unless options.is_a?(Hash)

    if (site_identifier = options.delete(:cms_site))
      unless (@cms_site = Comfy::Cms::Site.find_by_identifier(site_identifier))
        raise ComfortableMexicanSofa::MissingSite, site_identifier
      end
    end

    if (page_path = options.delete(:cms_page)) || (layout_identifier = options.delete(:cms_layout))
      unless @cms_site ||= Comfy::Cms::Site.find_site(request.host_with_port.downcase, request.fullpath)
        raise ComfortableMexicanSofa::MissingSite, "#{request.host.downcase}/#{request.fullpath}"
      end
    end

    if page_path
      render_cms_page(page_path, options, locals, &block)
    elsif layout_identifier
      render_cms_layout(layout_identifier, options, locals, &block)
    else
      super
    end
  end

  def render_cms_page(path, options = {}, locals = {}, &block)
    path.gsub!(%r{^/#{@cms_site.path}}, "") if @cms_site.path.present?

    unless (@cms_page = @cms_site.pages.find_by_full_path(path))
      raise ComfortableMexicanSofa::MissingPage, path
    end

    @cms_page.translate!

    @cms_layout = @cms_page.layout
    if (cms_fragments = options.delete(:cms_fragments)).present?
      cms_fragments.each do |identifier, value|
        content = value.is_a?(Hash) ? render_to_string(value.merge(layout: false)) : value.to_s
        page_fragment = @cms_page.fragments.detect { |f| f.identifier == identifier.to_s } ||
                        @cms_page.fragments.build(identifier: identifier.to_s)
        page_fragment.content = content
      end
    end
    cms_app_layout = @cms_layout.app_layout
    options[:layout] ||= cms_app_layout.blank? ? nil : cms_app_layout
    options[:inline] = @cms_page.render

    render(options, locals, &block)
  end

  def render_cms_layout(identifier, options = {}, locals = {}, &block)
    unless (@cms_layout = @cms_site.layouts.find_by_identifier(identifier))
      raise ComfortableMexicanSofa::MissingLayout, identifier
    end

    cms_app_layout = @cms_layout.app_layout
    cms_page = @cms_site.pages.build(layout: @cms_layout)
    cms_fragments =
      options.delete(:cms_fragments) || { content: render_to_string({ layout: false }.merge(options)) }

    cms_fragments.each do |frag_identifier, value|
      content = value.is_a?(Hash) ? render_to_string(value.merge(layout: false)) : value.to_s
      cms_page.fragments.build(identifier: frag_identifier.to_s, content: content)
    end
    options[:layout] ||= cms_app_layout.blank? ? nil : cms_app_layout
    options[:inline] = cms_page.render

    render(options, locals, &block)
  end

end

ActiveSupport.on_load :action_controller_base do
  include ComfortableMexicanSofa::RenderMethods
end
