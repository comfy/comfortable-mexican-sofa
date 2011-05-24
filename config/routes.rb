Rails.application.routes.draw do
  
  namespace :cms_admin, :path => ComfortableMexicanSofa.config.admin_route_prefix, :except => :show do
    get '/' => redirect(
      "/#{ComfortableMexicanSofa.config.admin_route_prefix}/#{ComfortableMexicanSofa.config.admin_route_redirect}"
    )
    resources :pages do
      member do 
        match :form_blocks
        match :toggle_branch
      end
      collection do
        match :reorder
      end
      resources :revisions, :only => [:index, :show, :revert] do
        put :revert, :on => :member
      end
    end
    resources :sites
    resources :uploads, :only => [:create, :destroy]
    resources :layouts do
      resources :revisions, :only => [:index, :show, :revert] do
        put :revert, :on => :member
      end
    end
    resources :snippets do 
      resources :revisions, :only => [:index, :show, :revert] do
        put :revert, :on => :member
      end
    end
  end unless ComfortableMexicanSofa.config.admin_route_prefix.blank?
  
  scope :controller => :cms_content do
    prefix = ComfortableMexicanSofa.config.content_route_prefix
    get "#{prefix}/cms-css/:id"  => :render_css,   :as => 'cms_css'
    get "#{prefix}/cms-js/:id"   => :render_js,    :as => 'cms_js'
    get "#{prefix}/"             => :render_html,  :as => 'cms_html',  :path => "#{prefix}/(*cms_path)"
  end
  
end
