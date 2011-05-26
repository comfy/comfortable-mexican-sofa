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
    def render(options = {}, locals = {}, &block)
      if options.is_a?(Hash) && path = options.delete(:cms_page)
        site = Cms::Site.find_by_hostname(request.host.downcase)
        page = site && site.pages.find_by_full_path(path)
        if page
          cms_app_layout = page.layout.try(:app_layout)
          options[:layout] ||= cms_app_layout.blank?? nil : cms_app_layout
          options[:inline] = page.content
          @cms_page = page
          super(options, locals, &block)
        else
          raise ComfortableMexicanSofa::MissingPage.new(path)
        end
      else
        super(options, locals, &block)
      end
    end
  end
end

ActionController::Base.send :include, ComfortableMexicanSofa::ControllerMethods