class ActionDispatch::Routing::Mapper

  def comfy_route_cms(options = {})
    scope :module => :comfy, :as => :comfy do
      namespace :cms, :path => options[:path] do
        Rails.application.config.comfy_cms_path = options[:path]

        get 'cms-css/:site_id/:identifier(/:cache_buster)' => 'assets#render_css', :as => 'render_css'
        get 'cms-js/:site_id/:identifier(/:cache_buster)'  => 'assets#render_js',  :as => 'render_js'

        if options[:sitemap]
          get '(:cms_path)/sitemap' => 'content#render_sitemap',
            :as           => 'render_sitemap',
            :constraints  => {:format => /xml/},
            :format       => :xml
        end

        get '/:format' => 'content#show', :as => 'render_page', :path => "(*cms_path)"
      end
    end
  end
end
