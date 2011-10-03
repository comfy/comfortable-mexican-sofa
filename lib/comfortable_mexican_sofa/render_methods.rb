module ComfortableMexicanSofa::RenderMethods
  
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
    #   render :cms_layout => 'layout_slug', :cms_blocks => {
    #     :block_label_a => 'content text',
    #     :block_label_b => { :template => 'path/to/template' },
    #     :block_label_c => { :partial  => 'path/to/partial' }
    #   }
    # This way you are populating page block content and rendering 
    # an instantialized CMS page.
    def render(options = {}, locals = {}, &block)
      if options.is_a?(Hash) && path = options.delete(:cms_page)
        @cms_site = Cms::Site.find_site(request.host.downcase, request.fullpath)
        if @cms_page = @cms_site && @cms_site.pages.find_by_full_path(path)
          @cms_layout = @cms_page.layout
          cms_app_layout = @cms_layout.try(:app_layout)
          options[:layout] ||= cms_app_layout.blank?? nil : cms_app_layout
          options[:inline] = @cms_page.content
          super(options, locals, &block)
        else
          raise ComfortableMexicanSofa::MissingPage.new(path)
        end
        
      elsif options.is_a?(Hash) && slug = options.delete(:cms_layout)
        @cms_site = Cms::Site.find_site(request.host.downcase, request.fullpath)
        if @cms_layout = @cms_site && @cms_site.layouts.find_by_slug(slug)
          cms_app_layout = @cms_layout.try(:app_layout)
          cms_page = @cms_site.pages.build(:layout => @cms_layout)
          cms_blocks = options.delete(:cms_blocks) || { :content => render_to_string }
          cms_blocks.each do |block_label, value|
            content = if value.is_a?(Hash)
              render_to_string(value.keys.first.to_sym => value[value.keys.first])
            else
              value.to_s
            end
            cms_page.blocks.build(:label => block_label.to_s, :content => content)
          end
          options[:layout] ||= cms_app_layout.blank?? nil : cms_app_layout
          options[:inline] = cms_page.content(true)
          super(options, locals, &block)
        else
          raise ComfortableMexicanSofa::MissingLayout.new(slug)
        end
        
      else
        super(options, locals, &block)
      end
    end
  end
end

ActionController::Base.send :include, ComfortableMexicanSofa::RenderMethods