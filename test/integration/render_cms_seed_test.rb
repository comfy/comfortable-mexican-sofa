require File.expand_path('../test_helper', File.dirname(__FILE__))

class RenderCmsSeedTest < ActionDispatch::IntegrationTest
  
  def test_render_with_seed_data_enabled
    get '/child/subchild'
    assert_response 404
    
    ComfortableMexicanSofa.configuration.seed_data_path = File.expand_path('../cms_seeds', File.dirname(__FILE__))
    
    get '/child/subchild'
    assert_response :success
    assert_equal '<html><div>Sub Child Page Content Content for Default Snippet</div></html>', response.body
  end
  
  def test_get_seed_data_page
    ComfortableMexicanSofa.configuration.seed_data_path = File.expand_path('../cms_seeds', File.dirname(__FILE__))
    
    get '/'
    assert_response :success
    assert assigns(:cms_page)
    assert assigns(:cms_page).new_record?
  end
  
  def test_get_seed_data_css
    ComfortableMexicanSofa.configuration.seed_data_path = File.expand_path('../cms_seeds', File.dirname(__FILE__))
    
    get '/cms-css/default'
    assert_response :success
    assert assigns(:cms_layout)
    assert assigns(:cms_layout).new_record?
  end
  
end