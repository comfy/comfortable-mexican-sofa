require_relative '../../test_helper'

class Admin::FoosControllerTest < ActionController::TestCase

  def setup
    # TODO: login as admin user
    @foo = foos(:default)
  end

  def test_get_index
    get :index
    assert_response :success
    assert assigns(:foos)
    assert_template :index
  end

  def test_get_show
    get :show, :id => @foo
    assert_response :success
    assert assigns(:foo)
    assert_template :show
  end

  def test_get_show_failure
    get :show, :id => 'invalid'
    assert_response :redirect
    assert_redirected_to :action => :index
    assert_equal 'Foo not found', flash[:error]
  end

  def test_get_new
    get :new
    assert_response :success
    assert assigns(:foo)
    assert_template :new
    assert_select 'form[action=/admin/foos]'
  end

  def test_get_edit
    get :edit, :id => @foo
    assert_response :success
    assert assigns(:foo)
    assert_template :edit
    assert_select "form[action=/admin/foos/#{@foo.id}]"
  end

  def test_creation
    assert_difference 'Foo.count' do
      post :create, :foo => {
        :bar => 'test bar',
      }
      foo = Foo.last
      assert_response :redirect
      assert_redirected_to :action => :show, :id => foo
      assert_equal 'Foo created', flash[:success]
    end
  end

  def test_creation_failure
    assert_no_difference 'Foo.count' do
      post :create, :foo => { }
      assert_response :success
      assert_template :new
      assert_equal 'Failed to create Foo', flash[:error]
    end
  end

  def test_update
    put :update, :id => @foo, :foo => {
      :bar => 'Updated'
    }
    assert_response :redirect
    assert_redirected_to :action => :show, :id => @foo
    assert_equal 'Foo updated', flash[:success]
    @foo.reload
    assert_equal 'Updated', @foo.bar
  end

  def test_update_failure
    put :update, :id => @foo, :foo => {
      :bar => ''
    }
    assert_response :success
    assert_template :edit
    assert_equal 'Failed to update Foo', flash[:error]
    @foo.reload
    refute_equal '', @foo.bar
  end

  def test_destroy
    assert_difference 'Foo.count', -1 do
      delete :destroy, :id => @foo
      assert_response :redirect
      assert_redirected_to :action => :index
      assert_equal 'Foo deleted', flash[:success]
    end
  end
end