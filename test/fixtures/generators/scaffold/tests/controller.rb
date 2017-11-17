require_relative '../../test_helper'

class Admin::FoosControllerTest < ActionDispatch::IntegrationTest

  setup do
    @foo = foos(:default)
  end

  # Vanilla CMS has BasicAuth, so we need to send that with each request.
  # Change this to fit your app's authentication strategy.
  # Move this to test_helper.rb
  def r(verb, path, options = {})
    headers = options[:headers] || {}
    headers['HTTP_AUTHORIZATION'] =
      ActionController::HttpAuthentication::Basic.encode_credentials(
        ComfortableMexicanSofa::AccessControl::AdminAuthentication.username,
        ComfortableMexicanSofa::AccessControl::AdminAuthentication.password
      )
    options.merge!(headers: headers)
    send(verb, path, options)
  end

  def test_get_index
    r :get, admin_foos_path
    assert_response :success
    assert assigns(:foos)
    assert_template :index
  end

  def test_get_show
    r :get, admin_foo_path(@foo)
    assert_response :success
    assert assigns(:foo)
    assert_template :show
  end

  def test_get_show_failure
    r :get, admin_foo_path('invalid')
    assert_response :redirect
    assert_redirected_to action: :index
    assert_equal 'Foo not found', flash[:danger]
  end

  def test_get_new
    r :get, new_admin_foo_path
    assert_response :success
    assert assigns(:foo)
    assert_template :new
    assert_select "form[action='/admin/foos']"
  end

  def test_get_edit
    r :get, edit_admin_foo_path(@foo)
    assert_response :success
    assert assigns(:foo)
    assert_template :edit
    assert_select "form[action='/admin/foos/#{@foo.id}']"
  end

  def test_creation
    assert_difference 'Foo.count' do
      r :post, admin_foos_path, params: {foo: {
        bar: 'test bar',
      }}
      foo = Foo.last
      assert_response :redirect
      assert_redirected_to action: :show, id: foo
      assert_equal 'Foo created', flash[:success]
    end
  end

  def test_creation_failure
    assert_no_difference 'Foo.count' do
      r :post, admin_foos_path, params: {foo: { }}
      assert_response :success
      assert_template :new
      assert_equal 'Failed to create Foo', flash[:danger]
    end
  end

  def test_update
    r :put, admin_foo_path(@foo), params: {foo: {
      bar: 'Updated'
    }}
    assert_response :redirect
    assert_redirected_to action: :show, id: @foo
    assert_equal 'Foo updated', flash[:success]
    @foo.reload
    assert_equal 'Updated', @foo.bar
  end

  def test_update_failure
    r :put, admin_foo_path(@foo), params: {foo: {
      bar: ''
    }}
    assert_response :success
    assert_template :edit
    assert_equal 'Failed to update Foo', flash[:danger]
    @foo.reload
    refute_equal '', @foo.bar
  end

  def test_destroy
    assert_difference 'Foo.count', -1 do
      r :delete, admin_foo_path(@foo)
      assert_response :redirect
      assert_redirected_to action: :index
      assert_equal 'Foo deleted', flash[:success]
    end
  end
end
