require File.dirname(__FILE__) + '/../test_helper'

class RenderCmsSeedTest < ActionDispatch::IntegrationTest
  
  def test_render_with_seed_data_enabled
    get '/child/subchild'
    assert_response 404
    
    ComfortableMexicanSofa.configuration.seed_data_path = File.expand_path('../cms_seeds', File.dirname(__FILE__))
    
    get '/child/subchild'
    assert_response :success
    assert_equal '<html><div>Sub Child Page Content Content for Default Snippet</div></html>', response.body
  end
  
end