require_relative '../../../test_helper'

class Admin::Cms::UsersControllerTest < ActionController::TestCase

  def test_destroy
    assert_difference 'Cms::User.count', -1 do
      delete :destroy, id: cms_users(:normal_user)
      assert_response :redirect
      assert_redirected_to action: :index
      assert_equal I18n.t('cms.users.deleted'), flash[:success]
    end
  end

end
