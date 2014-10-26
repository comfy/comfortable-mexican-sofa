require_relative '../../../../test_helper'

class Comfy::Admin::Cms::FilesControllerTest < ActionController::TestCase

  def test_get_index
    get :index, :site_id => comfy_cms_sites(:default)
    assert_response :success
    assert assigns(:files)
    assert_template :index
  end

  def test_get_index_with_category
    get :index, :site_id => comfy_cms_sites(:default), :category => comfy_cms_categories(:default).label
    assert_response :success
    assert assigns(:files)
    assert_equal 1, assigns(:files).count
    assert assigns(:files).first.categories.member? comfy_cms_categories(:default)
  end

  def test_get_index_with_category_invalid
    get :index, :site_id => comfy_cms_sites(:default), :category => 'invalid'
    assert_response :success
    assert assigns(:files)
    assert_equal 0, assigns(:files).count
  end

  def test_get_index_with_page_files
    file = comfy_cms_files(:default)
    file.update_column(:block_id, comfy_cms_blocks(:default_field_text).id)
    get :index, :site_id => comfy_cms_sites(:default)
    assert_response :success
    assert_equal 0, assigns(:files).count
  end

  def test_get_new
    site = comfy_cms_sites(:default)
    get :new, :site_id => site
    assert_response :success
    assert assigns(:file)
    assert_template :new
    assert_select "form[action=/admin/sites/#{site.id}/files][enctype=multipart/form-data]"
  end

  def test_get_edit
    file = comfy_cms_files(:default)
    get :edit, :site_id => file.site, :id => file
    assert_response :success
    assert assigns(:file)
    assert_template :edit
    assert_select "form[action=/admin/sites/#{file.site.id}/files/#{file.id}]"
  end

  def test_get_edit_failure
    get :edit, :site_id => comfy_cms_sites(:default), :id => 'not_found'
    assert_response :redirect
    assert_redirected_to :action => :index
    assert_equal 'File not found', flash[:danger]
  end

  def test_create
    assert_difference ['Comfy::Cms::File.count', 'Comfy::Cms::Categorization.count'] do
      post :create, :site_id => comfy_cms_sites(:default), :file => {
        :label        => 'Test File',
        :description  => 'Test Description',
        :file         => fixture_file_upload('files/image.jpg', 'image/jpeg'),
        :category_ids => {comfy_cms_categories(:default).id => '1'}
      }
      assert_response :redirect
      file = Comfy::Cms::File.last
      assert_equal comfy_cms_sites(:default), file.site
      assert_equal 'Test File', file.label
      assert_equal 'Test Description', file.description
      assert_redirected_to :action => :edit, :id => file
      assert_equal 'Files uploaded', flash[:success]
    end
  end

  def test_create_failure
    assert_no_difference 'Comfy::Cms::File.count' do
      post :create, :site_id => comfy_cms_sites(:default), :file => { }
      assert_response :success
      assert_template :new
      assert_equal 'Failed to upload files', flash[:danger]
    end
  end

  def test_create_as_plupload
    assert_difference 'Comfy::Cms::File.count' do
      post :create,
        :format   => :plupload,
        :site_id  => comfy_cms_sites(:default),
        :file     => {
          :file => fixture_file_upload('files/image.jpg', 'image/jpeg')
        }
      assert_response :success
      assert_no_select "body"
      assert_select "tr[id=comfy_cms_file_#{Comfy::Cms::File.last.id}]"
    end
  end

  def test_create_as_plupload_failure
    assert_no_difference 'Comfy::Cms::File.count' do
      post :create, :format => :plupload, :site_id => comfy_cms_sites(:default), :file => { }
      assert_response :unprocessable_entity
    end
  end

  def test_update
    file = comfy_cms_files(:default)
    put :update, :site_id => file.site, :id => file, :file => {
      :label        => 'New File',
      :description  => 'New Description',
      :file         => fixture_file_upload('files/image.jpg', 'image/jpeg')
    }
    assert_response :redirect
    assert_redirected_to :action => :edit, :site_id => file.site, :id => file
    assert_equal 'File updated', flash[:success]
    file.reload
    assert_equal 'New File', file.label
    assert_equal 'New Description', file.description
  end

  def test_update_failure
    file = comfy_cms_files(:default)
    put :update, :site_id => file.site, :id => file, :file => {
      :file => nil
    }
    assert_response :success
    assert_template :edit
    file.reload
    assert_not_equal nil, file.file
    assert_equal 'Failed to update file', flash[:danger]
  end

  def test_destroy
    assert_difference 'Comfy::Cms::File.count', -1 do
      delete :destroy, :site_id => comfy_cms_sites(:default), :id => comfy_cms_files(:default)
      assert_response :redirect
      assert_redirected_to :action => :index
      assert_equal 'File deleted', flash[:success]
    end
  end

  def test_destroy_as_xhr
    assert_difference 'Comfy::Cms::File.count', -1 do
      xhr :delete, :destroy, :site_id => comfy_cms_sites(:default), :id => comfy_cms_files(:default)
      assert_response :success
    end
  end

  def test_reorder
    file_one = comfy_cms_files(:default)
    file_two = comfy_cms_sites(:default).files.create(
      :file => fixture_file_upload('files/image.jpg', "image/jpeg")
    )
    assert_equal 0, file_one.position
    assert_equal 1, file_two.position

    put :reorder, :site_id => comfy_cms_sites(:default), :comfy_cms_file => [file_two.id, file_one.id]
    assert_response :success
    file_one.reload
    file_two.reload

    assert_equal 1, file_one.position
    assert_equal 0, file_two.position
  end
end
