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
    #
    # This way you are populating page block content and rendering
    # an instantialized CMS page.
    #
    # Site is loaded automatically based on the request. However you can force
    # it by passing :cms_site parameter with site's slug. For example:
    #   render :cms_page => '/path/to/page', :cms_site => 'default'
    # 
    def render(options = {}, locals = {}, &block)
      
      if options.is_a?(Hash) && identifier = options.delete(:cms_site)
        unless @cms_site = Cms::Site.find_by_identifier(identifier)
          raise ComfortableMexicanSofa::MissingSite.new(identifier)
        end
      end
      
      if options.is_a?(Hash) && options[:cms_page]
        render_cms_page(options, locals, &block)
      elsif options.is_a?(Hash) && options[:cms_layout]
        render_cms_layout(options, locals, &block)
      else
        super(options, locals, &block)
      end
    end
    
    def render_cms_page(options = {}, locals = {}, &block)
      path = options.delete(:cms_page)
      
      unless @cms_site ||= Cms::Site.find_site(request.host.downcase, request.fullpath)
        raise ComfortableMexicanSofa::MissingSite.new("#{request.host.downcase}/#{request.fullpath}")
      end
      
      path.gsub!(/^\/#{@cms_site.path}/, '') if @cms_site.path.present?
      
      unless @cms_page = @cms_site.pages.find_by_full_path(path)
        raise ComfortableMexicanSofa::MissingPage.new(path)
      end
      
      @cms_layout = @cms_page.layout
      if (cms_blocks = options.delete(:cms_blocks)).present?
        cms_blocks.each do |identifier, value|
          content = value.is_a?(Hash) ? render_to_string(value.merge(:layout => false)) : value.to_s
          page_block  = @cms_page.blocks.detect{|b| b.identifier == identifier.to_s} ||
                        @cms_page.blocks.build(:identifier => identifier.to_s)
          page_block.content = content
        end
      end
      cms_app_layout = @cms_layout.app_layout
      options[:layout] ||= cms_app_layout.blank?? nil : cms_app_layout
      options[:inline] = @cms_page.render
      
      render(options, locals, &block)
    end
    
    def render_cms_layout(options = {}, locals = {}, &block)
      identifier = options.delete(:cms_layout)
      
      unless @cms_site ||= Cms::Site.find_site(request.host.downcase, request.fullpath)
        raise ComfortableMexicanSofa::MissingSite.new("#{request.host.downcase}/#{request.fullpath}")
      end
      
      unless @cms_layout = @cms_site.layouts.find_by_identifier(identifier)
        raise ComfortableMexicanSofa::MissingLayout.new(identifier)
      end
      
      cms_app_layout = @cms_layout.app_layout
      cms_page = @cms_site.pages.build(:layout => @cms_layout)
      cms_blocks = options.delete(:cms_blocks) || { :content => render_to_string({ :layout => false }.merge(options)) }
      cms_blocks.each do |identifier, value|
        content = value.is_a?(Hash) ? render_to_string(value.merge(:layout => false)) : value.to_s
        cms_page.blocks.build(:identifier => identifier.to_s, :content => content)
      end
      options[:layout] ||= cms_app_layout.blank?? nil : cms_app_layout
      options[:inline] = cms_page.render
      
      render(options, locals, &block)
    end
    
  end
end

ActionController::Base.send :include, ComfortableMexicanSofa::RenderMethods
