ComfortableMexicanSofa::Application.routes.draw do
  
  # Catch-all route
  match '*path' => 'cms_content#show'
end
