require_relative '../test_helper'

class RescueNotFoundTest < ActionDispatch::IntegrationTest

  def setup
    ComfortableMexicanSofa.configure { |config| config.rescue_from_404 = false }
    load File.expand_path("../../../app/controllers/comfy/cms/content_controller.rb", __FILE__)
  end

  def teardown
    reset_config
    load File.expand_path("../../../app/controllers/comfy/cms/content_controller.rb", __FILE__)
  end

  def test_do_not_rescue_from_404
    assert_exception_raised ActiveRecord::RecordNotFound do
      get '/doesnotexist'
    end
  end
end
