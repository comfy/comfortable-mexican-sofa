Rails.application.routes.draw do
  
  namespace :cms_admin, :path => ComfortableMexicanSofa.config.admin_route_prefix, :except => :show do
    get '/' => redirect("/#{ComfortableMexicanSofa.config.admin_route_prefix}/pages")
    resources :pages do
      member do 
        match :form_blocks
      end
    end
    resources :sites
    resources :layouts
    resources :snippets
    resources :uploads
  end
  
  scope :controller => :cms_content do
    get '/cms-css/:id'  => :render_css,   :as => 'cms_css',   :format => 'css'
    get '/cms-js/:id'   => :render_js,    :as => 'cms_js',    :format => 'js'
    get '/'             => :render_html,  :as => 'cms_html',  :path => '(*cms_path)'
  end
  
end
