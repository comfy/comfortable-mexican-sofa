Rails.application.routes.draw do
  
  namespace :cms_admin, :except => :show do
    resources :layouts
    resources :pages
    resources :snippets
    resources :assets
  end
  
  match '*cms_path', :to => 'cms_content#render_page', :via => :get
  
end
