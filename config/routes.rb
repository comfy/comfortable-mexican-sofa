Rails.application.routes.draw do
  
  namespace :cms_admin, :path => 'cms-admin', :except => :show do
    resources :layouts
    resources :pages do
      member do 
        match :form_blocks
      end
    end
    resources :snippets
    resources :uploads
  end
  
  match '*cms_path', :to => 'cms_content#render_page', :via => :get
  
end
