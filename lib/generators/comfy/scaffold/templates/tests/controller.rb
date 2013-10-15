require_relative '../../test_helper'

class Admin::<%= class_name.pluralize %>ControllerTest < ActionController::TestCase

  def setup
    # TODO: login as admin user
    @<%= file_name %> = <%= file_name.pluralize %>(:default)
  end

  def test_get_index
    get :index
    assert_response :success
    assert assigns(:<%= file_name.pluralize %>)
    assert_template :index
  end

  def test_get_show
    get :show, :id => @<%= file_name %>
    assert_response :success
    assert assigns(:<%= file_name %>)
    assert_template :show
  end

  def test_get_show_failure
    get :show, :id => 'invalid'
    assert_response :redirect
    assert_redirected_to :action => :index
    assert_equal '<%= class_name.titleize %> not found', flash[:error]
  end

  def test_get_new
    get :new
    assert_response :success
    assert assigns(:<%= file_name %>)
    assert_template :new
    assert_select 'form[action=/admin/<%= file_name.pluralize %>]'
  end

  def test_get_edit
    get :edit, :id => @<%= file_name %>
    assert_response :success
    assert assigns(:<%= file_name %>)
    assert_template :edit
    assert_select "form[action=/admin/<%= file_name.pluralize %>/#{@<%= file_name %>.id}]"
  end

  def test_creation
    assert_difference '<%= class_name %>.count' do
      post :create, :<%= file_name %> => {
      <%- model_attrs.each do |attr| -%>
        :<%= attr.name %> => 'test <%= attr.name %>',
      <%- end -%>
      }
      <%= file_name %> = <%= class_name %>.last
      assert_response :redirect
      assert_redirected_to :action => :show, :id => <%= file_name %>
      assert_equal '<%= class_name.titleize %> created', flash[:success]
    end
  end

  def test_creation_failure
    assert_no_difference '<%= class_name %>.count' do
      post :create, :<%= file_name %> => { }
      assert_response :success
      assert_template :new
      assert_equal 'Failed to create <%= class_name.titleize %>', flash[:error]
    end
  end

  def test_update
    put :update, :id => @<%= file_name %>, :<%= file_name %> => {
    <%- if attr = model_attrs.first -%>
      :<%= attr.name %> => 'Updated'
    <%- end -%>
    }
    assert_response :redirect
    assert_redirected_to :action => :show, :id => @<%= file_name %>
    assert_equal '<%= class_name.titleize %> updated', flash[:success]
    @<%= file_name %>.reload
    assert_equal 'Updated', @<%= file_name %>.<%= attr.try(:name) || 'attribute' %>
  end

  def test_update_failure
    put :update, :id => @<%= file_name %>, :<%= file_name %> => {
      :<%= attr.try(:name) || 'attribute' %> => ''
    }
    assert_response :success
    assert_template :edit
    assert_equal 'Failed to update <%= class_name.titleize %>', flash[:error]
    @<%= file_name %>.reload
    refute_equal '', @<%= file_name %>.<%= attr.try(:name) || 'attribute' %>
  end

  def test_destroy
    assert_difference '<%= class_name %>.count', -1 do
      delete :destroy, :id => @<%= file_name %>
      assert_response :redirect
      assert_redirected_to :action => :index
      assert_equal '<%= class_name.titleize %> deleted', flash[:success]
    end
  end
end