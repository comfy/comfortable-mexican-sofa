ComfortableMexicanSofa::Application.routes.draw do
  
  namespace :cms_admin, :path => 'cms-admin' do
    resources :layouts, :pages, :snippets, :assets
  end
  
  # Catch-all route
  match '*path' => 'cms_content#show', :via => :get
end
