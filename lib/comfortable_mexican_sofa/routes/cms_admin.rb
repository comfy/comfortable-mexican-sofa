class ActionDispatch::Routing::Mapper

  def comfy_route_cms_admin(path: "admin")
    scope module: :comfy, as: :comfy do
      scope module: :admin do
        namespace :cms, as: :admin_cms, path: path, except: :show do
          get "/", to: "base#jump"

          concern :with_revisions do
            resources :revisions, only: [:index, :show, :revert] do
              patch :revert, on: :member
            end
          end

          concern :with_reorder do
            put :reorder, on: :collection
          end

          resources :sites do

            resources :pages, concerns: [:with_revisions, :with_reorder] do
              get  :form_fragments, on: :member
              get  :toggle_branch,  on: :member

              resources :translations, except: [:index], concerns: [:with_revisions]
            end

            resources :files, concerns: [:with_reorder]

            resources :layouts, concerns: [:with_revisions, :with_reorder]

            resources :snippets, concerns: [:with_revisions, :with_reorder]

            resources :categories
          end
        end
      end
    end
  end
end
