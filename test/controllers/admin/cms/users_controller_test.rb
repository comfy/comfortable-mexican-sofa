require_relative '../../../test_helper'

class Admin::Cms::UsersControllerTest < ActionController::TestCase

  def test_index
    get :index
    assert_response :success
    assert_equal 2, assigns(:users).length
  end

  def test_index_normal_user_can_see_themselves
    sign_in cms_users(:normal)
    get :index
    assert_response :success
    assert_equal 1, assigns(:users).length
  end

  def test_edit
    get :edit, id: cms_users(:normal)
    assert_response :success
    assert assigns(:user)
    assert_template :edit
  end

  def test_edit_unauthorized
    sign_in cms_users(:normal)
    get :edit, id: cms_users(:admin)
    assert_response :redirect
    assert_equal 'You are not authorized to access this page.', flash[:alert]
  end

  def test_new
    get :new
    assert_response :success
    assert assigns(:user)
    assert_template :new
  end

  def test_new_unauthorized
    sign_in cms_users(:normal)
    get :new
    assert_response :redirect
    assert_equal 'You are not authorized to access this page.', flash[:alert]
  end

  def test_create
    assert_difference 'Cms::User.count' do
      post :create, :user => {
        :email => "new-user@example.com",
        :password => "password",
        :site_tokens => cms_sites(:default).id.to_s
      }
      assert_response :redirect
      user = Cms::User.last
      assert_equal "new-user@example.com", user.email
      assert_equal false, user.super_admin?
    end
  end

  def test_create_unauthorized
    sign_in cms_users(:normal)
    post :create, user: {email: "foo"}
    assert_response :redirect
    assert_equal 'You are not authorized to access this page.', flash[:alert]
  end

  def test_update_self
    sign_in cms_users(:normal)
    user = Cms::User.find cms_users(:normal).id
    put :update, id: user.id, user: {
      email: "new-user2@example.com"
    }
    assert Cms::User.find_by(email: "new-user2@example.com")
  end

  def test_cannot_update_unpermitted_fields
    sign_in cms_users(:normal)
    user = Cms::User.find cms_users(:normal).id
    assert_no_difference 'user.reload.sites.count' do
      put :update, id: user.id, user: {
        super_admin: true,
        site_tokens: ""
      }
      refute user.reload.super_admin
    end
  end

  def test_destroy
    assert_difference 'Cms::User.count', -1 do
      delete :destroy, id: cms_users(:normal)
      assert_response :redirect
      assert_redirected_to action: :index
      assert_equal I18n.t('cms.users.deleted'), flash[:success]
    end
  end

end
