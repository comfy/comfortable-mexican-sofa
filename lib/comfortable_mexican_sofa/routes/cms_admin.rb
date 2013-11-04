class ActionDispatch::Routing::Mapper

  def comfy_route_cms_admin(options = {})
    options[:path] ||= 'admin'

    scope :module => :admin do
      namespace :cms, :as => :admin_cms, :path => options[:path], :except => :show do
        get '/', :to => 'base#jump'
        resources :sites do
          resources :pages do
            get  :form_blocks,    :on => :member
            get  :toggle_branch,  :on => :member
            put :reorder,         :on => :collection
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