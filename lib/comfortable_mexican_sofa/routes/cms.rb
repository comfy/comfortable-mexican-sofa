class ActionDispatch::Routing::Mapper
  
  def comfy_route_cms(options = {})
    namespace :cms, :path => options[:path] do
      get 'cms-css/:site_id/:identifier' => 'content#render_css', :as => 'render_css'
      get 'cms-js/:site_id/:identifier'  => 'content#render_js',  :as => 'render_js'

      if options[:sitemap]
        get '(:cms_path)/sitemap' => 'content#render_sitemap',
          :as           => 'render_sitemap',
          :constraints  => {:format => /xml/},
          :format       => :xml
      end

      get '/' => 'content#render_html', :as => 'render_html', :path => "(*cms_path)"
    end
  end
end