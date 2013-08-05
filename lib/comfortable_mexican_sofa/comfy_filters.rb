module ComfyFilters

  def self.included(base)
    base.class_eval do
      before_filter :load_cms_site,
                    :load_fixtures

      before_filter :load_cms_page,
                    :authenticate,
                    :only => :render_html

      before_filter :load_cms_layout,
                    :only => [
                      :render_css, 
                      :render_js
                    ]
      protected

      def load_fixtures
        return unless ComfortableMexicanSofa.config.enable_fixtures
        ComfortableMexicanSofa::Fixtures.import_all(@cms_site.identifier)
      end
      
      def load_cms_site
        @cms_site ||= if params[:site_id]
          Cms::Site.find_by_id(params[:site_id])
        else
          Cms::Site.find_site(request.host_with_port.downcase, request.fullpath)
        end
        
        if @cms_site
          if params[:cms_path].present?
            params[:cms_path].gsub!(/^#{@cms_site.path}/, '')
            params[:cms_path].to_s.gsub!(/^\//, '')
          end
          I18n.locale = @cms_site.locale
        else
          I18n.locale = I18n.default_locale
          raise ActionController::RoutingError.new('Site Not Found')
        end
      end
      
      def load_cms_page
        @cms_page = @cms_site.pages.published.find_by_full_path!("/#{params[:cms_path]}")
        return redirect_to(@cms_page.target_page.url) if @cms_page.target_page
        
      rescue ActiveRecord::RecordNotFound
        if @cms_page = @cms_site.pages.published.find_by_full_path('/404')
          render_html(404)
        else
          raise ActionController::RoutingError.new('Page Not Found')
        end
      end

      def load_cms_layout
        @cms_layout = @cms_site.layouts.find_by_identifier!(params[:identifier])
      rescue ActiveRecord::RecordNotFound
        render :nothing => true, :status => 404
      end
    end
  end
end

ActionController::Base.send :include, ComfyFilters