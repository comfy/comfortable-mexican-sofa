module ComfortableMexicanSofa::Routing
  
  def self.admin(options = {})
    options[:path] ||= 'cms-admin'
    
    Rails.application.routes.draw do
      namespace :cms_admin, :path => options[:path], :except => :show do
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
      end
    end
  end
  
  def self.content(options = {})
    
    Rails.application.routes.draw do
      namespace :cms_content, :path => options[:path] do
        get 'cms-css/:site_id/:identifier' => :render_css,  :as => 'css'
        get 'cms-js/:site_id/:identifier'  => :render_js,   :as => 'js'
        
        if options[:sitemap]
          get '(:cms_path)/sitemap' => :render_sitemap,
            :as           => 'sitemap',
            :constraints  => {:format => /xml/},
            :format       => :xml
        end
        
        get '/' => :render_html, :as => 'html', :path => "(*cms_path)"
      end
    end
  end
  
end