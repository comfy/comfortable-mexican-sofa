# frozen_string_literal: true

require_relative "../../../../test_helper"

class Comfy::Admin::Cms::FilesControllerTest < ActionDispatch::IntegrationTest

  def setup
    @site = comfy_cms_sites(:default)
    @file = comfy_cms_files(:default)
  end

  def test_get_index
    @site.files.create!(
      label: "other",
      file: fixture_file_upload("files/image.jpg", "image/jpeg")
    )

    r :get, comfy_admin_cms_site_files_path(site_id: @site)
    assert_response :success
    assert assigns(:files)
    assert_template :index
  end

  def test_get_index_with_category
    category = comfy_cms_categories(:default)
    r :get, comfy_admin_cms_site_files_path(site_id: @site), params: {
      categories: category.label
    }
    assert_response :success
    assert assigns(:files)
    assert_equal 1, assigns(:files).count
    assert assigns(:files).first.categories.member? category
  end

  def test_get_index_with_category_invalid
    r :get, comfy_admin_cms_site_files_path(site_id: @site), params: {
      categories: "invalid"
    }
    assert_response :success
    assert assigns(:files)
    assert_equal 0, assigns(:files).count
  end

  def test_get_index_with_redactor_images
    r :get, comfy_admin_cms_site_files_path(site_id: @site), params: {
      source: "redactor", type: "image"
    }
    assert_response :success

    assert_equal [{
      "thumb" => url_for(@file.attachment.variant(combine_options: Comfy::Cms::File::VARIANT_SIZE[:redactor])),
      "image" => url_for(@file.attachment),
      "title" => @file.label
    }], JSON.parse(response.body)
  end

  def test_get_index_with_redactor_files
    r :get, comfy_admin_cms_site_files_path(site_id: @site), params: {
      source: "redactor", type: "file"
    }
    assert_response :success

    assert_equal [{
      "title" => @file.label,
      "name"  => @file.attachment.filename.to_s,
      "link"  => url_for(@file.attachment),
      "size"  => "12.1 KB"
    }], JSON.parse(response.body)
  end

  def test_get_index_with_svg_file
    @site.files.create(
      file: fixture_file_upload("files/image.svg", "image/svg+xml")
    )

    r :get, comfy_admin_cms_site_files_path(site_id: @site)
    assert_response :success
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
    r :get, edit_comfy_admin_cms_site_file_path(site_id: @site, id: "invalid")
    assert_response :redirect
    assert_redirected_to action: :index
    assert_equal "File not found", flash[:danger]
  end

  def test_create
    file_count            = -> { Comfy::Cms::File.count }
    categorization_count  = -> { Comfy::Cms::Categorization.count }
    attachment_count      = -> { ActiveStorage::Attachment.count }

    assert_difference [file_count, categorization_count, attachment_count] do
      r :post, comfy_admin_cms_site_files_path(site_id: @site), params: { file: {
        label:        "Test File",
        description:  "Test Description",
        file:         fixture_file_upload("files/image.jpg", "image/jpeg"),
        category_ids: [comfy_cms_categories(:default).id]
      } }
      assert_response :redirect
      file = Comfy::Cms::File.last
      assert_equal comfy_cms_sites(:default), file.site
      assert_equal "Test File", file.label
      assert_equal "Test Description", file.description
      assert_redirected_to action: :edit, id: file
      assert_equal "Files uploaded", flash[:success]
    end
  end

  def test_create_failure
    assert_no_difference -> { Comfy::Cms::File.count } do
      r :post, comfy_admin_cms_site_files_path(site_id: @site), params: { file: {} }
      assert_response :success
      assert_template :new
      assert_equal "Failed to upload files", flash[:danger]
    end
  end

  def test_create_as_plupload
    file_count        = -> { Comfy::Cms::File.count }
    attachment_count  = -> { ActiveStorage::Attachment.count }

    assert_difference [file_count, attachment_count] do
      r :post, comfy_admin_cms_site_files_path(site_id: @site), params: {
        source: "plupload",
        file: {
          file: fixture_file_upload("files/image.jpg", "image/jpeg")
        }
      }
      assert_response :success
      assert_no_select "body"
      assert_select "li[data-id='#{Comfy::Cms::File.last.id}']"
    end
  end

  def test_create_as_plupload_failure
    assert_no_difference -> { Comfy::Cms::File.count } do
      r :post, comfy_admin_cms_site_files_path(site_id: @site), params: {
        source: "plupload",
        file:   {}
      }
      assert_response :unprocessable_entity
    end
  end

  def test_create_as_redactor
    file_count            = -> { Comfy::Cms::File.count }
    categorization_count  = -> { Comfy::Cms::Categorization.count }
    attachment_count      = -> { ActiveStorage::Attachment.count }

    assert_difference [file_count, categorization_count, attachment_count] do
      r :post, comfy_admin_cms_site_files_path(site_id: @site), params: {
        source: "redactor",
        file:   fixture_file_upload("files/image.jpg", "image/jpeg")
      }
      assert_response :success

      file = Comfy::Cms::File.last
      assert_equal ({
        "filelink" => url_for(file.attachment),
        "filename" => file.attachment.filename
      }), JSON.parse(response.body)

      category = Comfy::Cms::Category.last
      assert_equal "wysiwyg", category.label
      assert_equal [category], file.categories
    end
  end

  def test_create_as_redactor_failure
    assert_no_difference -> { Comfy::Cms::File.count } do
      r :post, comfy_admin_cms_site_files_path(site_id: @site), params: {
        source: "redactor",
        file:   {}
      }
      assert_response :unprocessable_entity
    end
  end

  def test_create_as_plupload_with_selected_category
    category = comfy_cms_categories(:default)

    file_count        = -> { Comfy::Cms::File.count }
    attachment_count  = -> { ActiveStorage::Attachment.count }

    assert_difference [file_count, attachment_count] do
      r :post, comfy_admin_cms_site_files_path(site_id: @site), params: {
        categories: [category.label],
        source:     "plupload",
        file: {
          file: fixture_file_upload("files/image.jpg", "image/jpeg")
        }
      }
      assert_response :success

      file = Comfy::Cms::File.last
      assert_equal [category], file.categories
    end
  end

  def test_update
    r :put, comfy_admin_cms_site_file_path(site_id: @site, id: @file), params: { file: {
      label:       "Updated File",
      description: "Updated Description",
      file:        fixture_file_upload("files/image.jpg", "image/jpeg")
    } }
    assert_response :redirect
    assert_redirected_to action: :edit, site_id: @site, id: @file
    assert_equal "File updated", flash[:success]
    @file.reload
    assert_equal "Updated File", @file.label
    assert_equal "Updated Description", @file.description
    assert_equal "image.jpg", @file.attachment.filename.to_s
  end

  def test_destroy
    file_count        = -> { Comfy::Cms::File.count }
    attachment_count  = -> { ActiveStorage::Attachment.count }

    assert_difference([file_count, attachment_count], -1) do
      r :delete, comfy_admin_cms_site_file_path(site_id: @site, id: @file)
      assert_response :redirect
      assert_redirected_to action: :index
      assert_equal "File deleted", flash[:success]
    end
  end

  def test_destroy_as_xhr
    assert_difference(-> { Comfy::Cms::File.count }, -1) do
      r :delete, comfy_admin_cms_site_file_path(site_id: @site, id: @file), xhr: true
      assert_response :success
    end
  end

  def test_reorder
    file_one = @file
    file_two = @site.files.create(
      file: fixture_file_upload("files/image.jpg", "image/jpeg")
    )
    assert_equal 0, file_one.position
    assert_equal 1, file_two.position

    r :put, reorder_comfy_admin_cms_site_files_path(site_id: @site), params: {
      order: [file_two.id, file_one.id]
    }
    assert_response :success
    file_one.reload
    file_two.reload

    assert_equal 1, file_one.position
    assert_equal 0, file_two.position
  end

end
