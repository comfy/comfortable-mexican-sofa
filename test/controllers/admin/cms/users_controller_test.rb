require_relative '../../../test_helper'

class Admin::Cms::UsersControllerTest < ActionController::TestCase

  def test_destroy
    assert_difference 'Cms::User.count', -1 do
      delete :destroy, user: cms_users(:normal_user)
      assert_response :redirect
      assert_redirected_to action: :index
      assert_equal 'User deleted', flash[:error]
    end
  end

end
