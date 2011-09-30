module ComfortableMexicanSofa::ControllerMethods
  
  def self.included(base)
    
    # If application controller doesn't have template associated with it
    # CMS will attempt to find one. This is so you don't have to explicitly
    # call render :cms_page => '/something'
    base.rescue_from 'ActionView::MissingTemplate' do |e|
      begin
        render :cms_page => request.path
      rescue ComfortableMexicanSofa::MissingPage
        raise e
      end
    end
    
    # Now you can render cms_page simply by calling:
    #   render :cms_page => '/path/to/page'
    # This way application controllers can use CMS content while populating
    # instance variables that can be used in partials (that are included by
    # by the cms page and/or layout)
    #
    # Or how about not worrying about setting up CMS pages and rendering 
    # application view using a CMS layout?
    #   render :cms_layout => 'layout_slug', :block_label => 'template/view'
    # This way you are populating page block content with `render :template` and
    # rendering an instantialized CMS page.
    def render(options = {}, locals = {}, &block)
      if options.is_a?(Hash) && path = options.delete(:cms_page)
        @cms_site = Cms::Site.find_site(request.host.downcase, request.fullpath)
        if @cms_page = @cms_site && @cms_site.pages.find_by_full_path(path)
          @cms_layout = @cms_page.layout
          cms_app_layout = @cms_layout.try(:app_layout)
          render_options = { }
          render_options[:layout] ||= cms_app_layout.blank?? nil : cms_app_layout
          render_options[:inline] = @cms_page.content
          super(render_options, locals, &block)
        else
          raise ComfortableMexicanSofa::MissingPage.new(path)
        end
        
      elsif options.is_a?(Hash) && slug = options.delete(:cms_layout)
        @cms_site = Cms::Site.find_site(request.host.downcase, request.fullpath)
        if @cms_layout = @cms_site && @cms_site.layouts.find_by_slug(slug)
          cms_app_layout = @cms_layout.try(:app_layout)
          cms_page = @cms_site.pages.build(:layout => @cms_layout)
          options.each do |block_label, template|
            cms_page.blocks.build(
              :label    => block_label.to_s,
              :content  => render_to_string(template)
            )
          end
          render_options = { }
          render_options[:layout] ||= cms_app_layout.blank?? nil : cms_app_layout
          render_options[:inline] = cms_page.content(true)
          super(render_options, locals, &block)
        else
          raise ComfortableMexicanSofa::MissingLayout.new(slug)
        end
        
      else
        super(options, locals, &block)
      end
    end
  end
end

ActionController::Base.send :include, ComfortableMexicanSofa::ControllerMethods