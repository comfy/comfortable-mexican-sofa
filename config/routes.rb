Rails.application.routes.draw do
  
  namespace :cms_admin, :path => ComfortableMexicanSofa.config.admin_route_prefix, :except => :show do
    get '/' => redirect(ComfortableMexicanSofa.config.admin_route_redirect)
    resources :pages do
      member do 
        match :form_blocks
        match :toggle_branch
      end
      collection do
        match :reorder
      end
    end
    resources :sites
    resources :layouts
    resources :snippets
    resources :uploads, :only => [:create, :destroy]
  end
  
  scope :controller => :cms_content do
    prefix = ComfortableMexicanSofa.config.content_route_prefix
    get "#{prefix}/cms-css/:id"  => :render_css,   :as => 'cms_css'
    get "#{prefix}/cms-js/:id"   => :render_js,    :as => 'cms_js'
    get "#{prefix}/"             => :render_html,  :as => 'cms_html',  :path => "#{prefix}/(*cms_path)"
  end
  
end
