# frozen_string_literal: true

class ActionDispatch::Routing::Mapper

  def comfy_route_cms_admin(path: "admin")
    scope module: :comfy, as: :comfy do
      scope module: :admin do
        namespace :cms, as: :admin_cms, path: path, except: :show do
          get "/", to: "base#jump"

          concern :with_revisions do |options|
            resources :revisions, options.merge(only: %i[index show]) do
              patch :revert, on: :member
            end
          end

          concern :with_reorder do
            put :reorder, on: :collection
          end

          concern :with_form_fragments do
            get :form_fragments, on: :member
          end

          resources :sites do
            resources :pages do
              concerns :with_reorder
              concerns :with_form_fragments
              concerns :with_revisions, controller: "revisions/page"

              get :toggle_branch,  on: :member

              resources :translations, except: [:index] do
                concerns :with_form_fragments
                concerns :with_revisions, controller: "revisions/translation"
              end
            end

            resources :files, concerns: [:with_reorder]

            resources :layouts do
              concerns :with_reorder
              concerns :with_revisions, controller: "revisions/layout"
            end

            resources :snippets do
              concerns :with_reorder
              concerns :with_revisions, controller: "revisions/snippet"
            end

            resources :categories
          end
        end
      end
    end
  end

end
