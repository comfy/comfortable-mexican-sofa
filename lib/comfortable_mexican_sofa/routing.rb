module ComfortableMexicanSofa::Routing
  
  def self.admin(options = {})
    options[:path] ||= 'admin'
    
    Rails.application.routes.draw do
      scope :module => :admin do
        namespace :cms, :as => :admin_cms, :path => options[:path], :except => :show do
          get '/', :to => 'base#jump'
          devise_for :users, class_name: "Cms::User", controllers: {sessions: "admin/cms/sessions"}
          resources :users
          resources :pages do
            get "edit_block/:block_id" => "pages#edit_block", :on => :member
            post :update_block, :on => :member
          end
          resources :sites do
            resources :pages do
              get  :form_blocks,    :on => :member
              get  :toggle_branch,  :on => :member
              put :reorder,         :on => :collection
              post :duplicate,      :on => :member
              resources :revisions, :only => [:index, :show, :revert] do
                patch :revert, :on => :member
              end
            end
            resources :files do
              post :reorder, :on => :collection
            end
            resources :layouts do
              put :reorder, :on => :collection
              resources :revisions, :only => [:index, :show, :revert] do
                patch :revert, :on => :member
              end
            end
            resources :snippets do
              put :reorder, :on => :collection
              resources :revisions, :only => [:index, :show, :revert] do
                patch :revert, :on => :member
              end
            end
            resources :categories
          end
        end
      end
    end
  end
  
  def self.content(options = {})
    
    Rails.application.routes.draw do
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
  
end
