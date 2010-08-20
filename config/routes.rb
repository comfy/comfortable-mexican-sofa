Rails.application.routes.draw do
  scope '/cms-admin', :module => 'cms_admin', :as => 'cms_admin'  do
    match '/', :to => "base#index"
    resources :layouts do
      collection do
        put :reorder
      end

      member do
        match :toggle
        match :children
      end
    end

    resources :pages do
      collection do
        put :reorder
      end

      member do
        match :toggle
        match :form_blocks
      end
    end

    resources :snippets do
      collection do
        put :reorder
      end
    end

    resources :sites

    resources :categories do
      member do
        match :toggle
        match :children
      end
    end
  end
  
  controller :cms_content do
    match '/sitemap.xml', :to => :sitemap
    match '*path', :to => :show
    root :to => :show
  end
end
