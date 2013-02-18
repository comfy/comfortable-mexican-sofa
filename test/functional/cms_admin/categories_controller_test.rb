require File.expand_path('../../test_helper', File.dirname(__FILE__))

class CmsAdmin::CategoriesControllerTest < ActionController::TestCase

  def test_get_edit
    xhr :get, :edit, :site_id => cms_sites(:default), :id => cms_categories(:default)
    assert_response :success
    assert_template :edit
    assert assigns(:category)
  end

  def test_get_edit_failure
    xhr :get, :edit, :site_id => cms_sites(:default), :id => 'invalid'
    assert_response :success
    assert response.body.blank?
  end

  def test_creation
    assert_difference 'Cms::Category.count' do
      xhr :post, :create, :site_id => cms_sites(:default), :category => {
        :label            => 'Test Label',
        :categorized_type => 'Cms::Snippet'
      }
      assert_response :success
      assert_template :create
      assert assigns(:category)
    end
  end

  def test_creation_failure
    assert_no_difference 'Cms::Category.count' do
      xhr :post, :create, :site_id => cms_sites(:default), :category => { }
      assert_response :success
      assert response.body.blank?
    end
  end

  def test_update
    category = cms_categories(:default)
    xhr :put, :update, :site_id => cms_sites(:default), :id => category, :category => {
      :label => 'Updated Label'
    }
    assert_response :success
    assert_template :update
    assert assigns(:category)
    category.reload
    assert_equal 'Updated Label', category.label
  end

  def test_update_failure
    category = cms_categories(:default)
    xhr :put, :update, :site_id => cms_sites(:default), :id => category, :category => {
      :label => ''
    }
    assert_response :success
    assert response.body.blank?
    category.reload
    assert_not_equal '', category.label
  end

  def test_destroy
    assert_difference 'Cms::Category.count', -1 do
      xhr :delete, :destroy, :site_id => cms_sites(:default), :id => cms_categories(:default)
      assert assigns(:category)
      assert_response :success
      assert_template :destroy
    end
  end

  def test_reorder
    site = cms_sites(:default)
    category_A = site.categories.create(:label => "A", :categorized_type => "Cms::File", :position => 1)
    category_B = site.categories.create(:label => "B", :categorized_type => "Cms::File", :position => 2)

    put :reorder, {:site_id => site, :id => category_B, :position => 1}
    assert_response :success

    # reload categories in order to update the new position
    category_A.reload
    category_B.reload

    assert_equal category_A.position, 2
    assert_equal category_B.position, 1
  end

  def test_reorder_failure
    site = cms_sites(:default)
    category_A = site.categories.create(:label => "A", :categorized_type => "Cms::File", :position => 1)
    category_B = site.categories.create(:label => "B", :categorized_type => "Cms::File", :position => 2)

    put :reorder, {:site_id => site, :id => category_B}
    assert_response :success

    # reload categories in order to update the new position
    category_A.reload
    category_B.reload

    assert_equal category_A.position, 1
    assert_equal category_B.position, 2
  end

end