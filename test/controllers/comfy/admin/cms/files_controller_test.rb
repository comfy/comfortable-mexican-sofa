require_relative '../../../../test_helper'

class Comfy::Admin::Cms::FilesControllerTest < ActionDispatch::IntegrationTest

  def setup
    @site = comfy_cms_sites(:default)
    @file = comfy_cms_files(:default)
  end

  def test_get_index
    r :get, comfy_admin_cms_site_files_path(site_id: @site)
    assert_response :success
    assert assigns(:files)
    assert_template :index
  end

  def test_get_index_with_category
    r :get, comfy_admin_cms_site_files_path(site_id: @site), params: {
      categories: comfy_cms_categories(:default).label
    }
    assert_response :success
    assert assigns(:files)
    assert_equal 1, assigns(:files).count
    assert assigns(:files).first.categories.member? comfy_cms_categories(:default)
  end

  def test_get_index_with_category_invalid
    r :get, comfy_admin_cms_site_files_path(site_id: @site), params: {
      :categories => 'invalid'
    }
    assert_response :success
    assert assigns(:files)
    assert_equal 0, assigns(:files).count
  end

  def test_get_index_with_page_files
    file = comfy_cms_files(:default)
    file.update_column(:block_id, comfy_cms_blocks(:default_field_text).id)
    r :get, comfy_admin_cms_site_files_path(site_id: @site)
    assert_response :success
    assert_equal 0, assigns(:files).count
  end

  def test_get_index_with_redactor_images
    file = comfy_cms_files(:default)

    r :get, comfy_admin_cms_site_files_path(site_id: @site), params: {
      source: 'redactor', type: 'image'
    }
    assert_response :success

    assert_equal [{
      'thumb' => file.file.url(:cms_thumb),
      'image' => file.file.url,
      'title' => file.label
    }], JSON.parse(response.body)
  end

  def test_get_index_with_redactor_files
    file = comfy_cms_files(:default)

    r :get, comfy_admin_cms_site_files_path(site_id: @site), params: {
      source: 'redactor', type: 'file'
    }
    assert_response :success

    assert_equal [{
      'title' => file.label,
      'name'  => file.file_file_name,
      'link'  => file.file.url,
      'size'  => '19.6 KB'
    }], JSON.parse(response.body)
  end

  def test_get_new
    r :get, new_comfy_admin_cms_site_file_path(site_id: @site)
    assert_response :success
    assert assigns(:file)
    assert_template :new
    assert_select "form[action='/admin/sites/#{@site.id}/files'][enctype='multipart/form-data']"
  end

  def test_get_edit
    r :get, edit_comfy_admin_cms_site_file_path(site_id: @site, id: @file)
    assert_response :success
    assert assigns(:file)
    assert_template :edit
    assert_select "form[action='/admin/sites/#{@site.id}/files/#{@file.id}']"
  end

  def test_get_edit_failure
    r :get, edit_comfy_admin_cms_site_file_path(site_id: @site, id: 'invalid')
    assert_response :redirect
    assert_redirected_to action: :index
    assert_equal 'File not found', flash[:danger]
  end

  def test_create
    assert_difference ['Comfy::Cms::File.count', 'Comfy::Cms::Categorization.count'] do
      r :post, comfy_admin_cms_site_files_path(site_id: @site), params:{file: {
        label:        'Test File',
        description:  'Test Description',
        file:         fixture_file_upload('files/image.jpg', 'image/jpeg'),
        category_ids: {comfy_cms_categories(:default).id => '1'}
      }}
      assert_response :redirect
      file = Comfy::Cms::File.last
      assert_equal comfy_cms_sites(:default), file.site
      assert_equal 'Test File', file.label
      assert_equal 'Test Description', file.description
      assert_redirected_to action: :edit, id: file
      assert_equal 'Files uploaded', flash[:success]
    end
  end

  def test_create_failure
    assert_no_difference 'Comfy::Cms::File.count' do
      r :post, comfy_admin_cms_site_files_path(site_id: @site), params: {file: {}}
      assert_response :success
      assert_template :new
      assert_equal 'Failed to upload files', flash[:danger]
    end
  end

  def test_create_as_plupload
    assert_difference 'Comfy::Cms::File.count' do
      r :post, comfy_admin_cms_site_files_path(site_id: @site), params: {
        source: 'plupload',
        file: {
          file: fixture_file_upload('files/image.jpg', 'image/jpeg')
        }
      }
      assert_response :success
      assert_no_select "body"
      assert_select "tr[id=comfy_cms_file_#{Comfy::Cms::File.last.id}]"
    end
  end

  def test_create_as_plupload_failure
    assert_no_difference 'Comfy::Cms::File.count' do
      r :post, comfy_admin_cms_site_files_path(site_id: @site), params: {
        source: 'plupload',
        file:   {}
      }
      assert_response :unprocessable_entity
    end
  end

  def test_create_as_redactor
    assert_difference 'Comfy::Cms::File.count' do
      r :post, comfy_admin_cms_site_files_path(site_id: @site), params: {
        source: 'redactor',
        file:   fixture_file_upload('files/image.jpg', 'image/jpeg')
      }
      assert_response :success

      file = Comfy::Cms::File.last
      assert_equal ({
        'filelink' => file.file.url,
        'filename' => file.label
      }), JSON.parse(response.body)
    end
  end

  def test_create_as_redactor_failure
    assert_no_difference 'Comfy::Cms::File.count' do
      r :post, comfy_admin_cms_site_files_path(site_id: @site), params: {
        source: 'redactor',
        file:   {}
      }
      assert_response :unprocessable_entity
    end
  end

  def test_create_as_plupload_with_selected_category
    category = comfy_cms_categories(:default)

    assert_difference 'Comfy::Cms::File.count' do
      r :post, comfy_admin_cms_site_files_path(site_id: @site), params: {
        category: [category.label],
        source:   'plupload',
        file: {
          file: fixture_file_upload('files/image.jpg', 'image/jpeg')
        },

      }
      assert_response :success

      file = Comfy::Cms::File.last
      assert_equal [category], file.categories
    end
  end

  def test_update
    r :put, comfy_admin_cms_site_file_path(site_id: @site, id: @file), params: { file: {
      label:       'New File',
      description: 'New Description',
      file:        fixture_file_upload('files/image.jpg', 'image/jpeg')
    }}
    assert_response :redirect
    assert_redirected_to action: :edit, site_id: @site, id: @file
    assert_equal 'File updated', flash[:success]
    @file.reload
    assert_equal 'New File', @file.label
    assert_equal 'New Description', @file.description
  end

  def test_update_failure
    r :put, comfy_admin_cms_site_file_path(site_id: @site, id: @file), params: { file: {
      file_file_name: ''
    }}
    assert_response :success
    assert_template :edit
    @file.reload
    assert_not_equal nil, @file.file
    assert_equal 'Failed to update file', flash[:danger]
  end

  def test_destroy
    assert_difference 'Comfy::Cms::File.count', -1 do
      r :delete, comfy_admin_cms_site_file_path(site_id: @site, id: @file)
      assert_response :redirect
      assert_redirected_to action: :index
      assert_equal 'File deleted', flash[:success]
    end
  end

  def test_destroy_as_xhr
    assert_difference 'Comfy::Cms::File.count', -1 do
      r :delete, comfy_admin_cms_site_file_path(site_id: @site, id: @file), xhr: true
      assert_response :success
    end
  end

  def test_reorder
    file_one = @file
    file_two = @site.files.create(
      file: fixture_file_upload('files/image.jpg', 'image/jpeg')
    )
    assert_equal 0, file_one.position
    assert_equal 1, file_two.position

    r :put, reorder_comfy_admin_cms_site_files_path(site_id: @site), params: {
      :comfy_cms_file => [file_two.id, file_one.id]
    }
    assert_response :success
    file_one.reload
    file_two.reload

    assert_equal 1, file_one.position
    assert_equal 0, file_two.position
  end
end
