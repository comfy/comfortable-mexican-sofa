Rails.application.routes.draw do

  namespace :cms_admin, :path => ComfortableMexicanSofa.config.admin_route_prefix, :except => :show do
    get '/', :to => 'base#jump'
    resources :sites do
      resources :pages do
        get  :form_blocks,    :on => :member
        get  :toggle_branch,  :on => :member
        put :reorder,         :on => :collection
        resources :revisions, :only => [:index, :show, :revert] do
          put :revert, :on => :member
        end
      end
      resources :files do
        put :reorder, :on => :collection
      end
      resources :layouts do
        put :reorder, :on => :collection
        resources :revisions, :only => [:index, :show, :revert] do
          put :revert, :on => :member
        end
      end
      resources :snippets do
        put :reorder, :on => :collection
        resources :revisions, :only => [:index, :show, :revert] do
          put :revert, :on => :member
        end
      end
      resources :categories
      get 'dialog/:type' => 'dialogs#show', :as => 'dialog'
    end
  end unless ComfortableMexicanSofa.config.admin_route_prefix.blank?
  
  scope :controller => :cms_content do
    get 'cms-css/:site_id/:identifier' => :render_css,  :as => 'cms_css'
    get 'cms-js/:site_id/:identifier'  => :render_js,   :as => 'cms_js'
    
    if ComfortableMexicanSofa.config.enable_sitemap
      get '(:cms_path)/sitemap' => :render_sitemap,
        :as           => 'cms_sitemap',
        :constraints  => {:format => /xml/},
        :format       => :xml
    end
    
    get '/' => :render_html,  :as => 'cms_html',  :path => "(*cms_path)"
  end
  
end if ComfortableMexicanSofa.config.use_default_routes
