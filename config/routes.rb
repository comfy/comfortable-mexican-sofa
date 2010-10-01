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
  
  scope :controller => :cms_content, :path => '(*cms_path)' do
    get '/styles.css' => :render_css
    get '/jscript.js' => :render_js
    get '/'          => :render_page
  end
  
end
