class ActionDispatch::Routing::Mapper

  def comfy_route_cms_admin(options = {})
    options[:path] ||= 'admin'

    scope :module => :comfy, :as => :comfy do
      scope :module => :admin do
        namespace :cms, :as => :admin_cms, :path => options[:path], :except => :show do
          concern :revisionable do
            resources :revisions, :only => [:index, :show, :revert] do
              patch :revert, :on => :member
            end
          end

          concern :orderable do
            put :reorder, :on => :collection
          end

          get '/', :to => 'base#jump'

          resources :sites do
            resources :pages, :concerns => [:revisionable, :orderable] do
              get :form_blocks, :on => :member
              get :toggle_branch, :on => :member
              resources :translations, :concerns => :revisionable, :except => :index
            end
            resources :files, :concerns => :orderable
            resources :layouts, :concerns => [:revisionable, :orderable]
            resources :snippets, :concerns => [:revisionable, :orderable]
            resources :categories
          end
        end
      end
    end
  end
end
