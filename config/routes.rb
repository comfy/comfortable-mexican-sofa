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
  
  scope :path => '/layouts/:id', :controller => :cms_content do
    get 'styles.css' => :render_css
    get 'jscript.js' => :render_js
  end
  
  get '*cms_path' => 'cms_content#render_page'

end
