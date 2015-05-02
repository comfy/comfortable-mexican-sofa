require_relative '../../../../test_helper'

class Comfy::Admin::Cms::TranslationsControllerTest < ActionController::TestCase
  def test_get_new
    page = comfy_cms_pages(:default)
    get :new, :site_id => page.site, :page_id => page
    assert_response :success
    assert assigns(:translateable).is_a?(Comfy::Cms::Page)
    assert assigns(:translation)
    assert_template :new
    assert_select "form[action=/admin/sites/#{page.site.id}/pages/#{page.id}/translations]"
  end

  def test_get_edit
    page = comfy_cms_pages(:default)
    translation = comfy_cms_page_translations(:default)
    get :edit, :site_id => page.site, :page_id => page, :id => translation
    assert_response :success
    assert assigns(:translateable).is_a?(Comfy::Cms::Page)
    assert assigns(:translation)
    assert_template :edit
    assert_select "form[action=/admin/sites/#{page.site.id}/pages/#{page.id}/translations/#{translation.id}]"
  end

  def test_get_edit_failure
    page = comfy_cms_pages(:default)
    get :edit, :site_id => page.site, :page_id => page, :id => 'not_found'
    assert_response :redirect
    assert_redirected_to edit_comfy_admin_cms_site_page_path(page.site, page)
    assert_equal 'Translation not found', flash[:danger]
  end

  def test_creation
    page = comfy_cms_pages(:default)

    assert_difference 'Comfy::Cms::Page::Translation.count' do
      assert_difference 'Comfy::Cms::Block.count', 1 do
        post :create, :site_id => page.site, :page_id => page, :translation => {
          :locale         => :es,
          :label           => 'Test Translation',
          :slug           => 'test-translation',
          :blocks_attributes => [
            { :identifier => 'default_translation_text',
              :content    => 'content content' }
          ]
        }, :commit => 'Create Translation'
        assert_response :redirect
        translation = Comfy::Cms::Page::Translation.last
        assert_equal page, translation.translateable
        assert_redirected_to :action => :edit, :id => translation
        assert_equal 'Translation created', flash[:success]
      end
    end
  end

  def test_creation_failure
    page = comfy_cms_pages(:default)

    assert_no_difference ['Comfy::Cms::Page::Translation.count', 'Comfy::Cms::Block.count'] do
      post :create, :site_id => page.site, :page_id => page, :translation => {
        :label           => 'Test Translation',
        :slug           => 'test-translation',
        :blocks_attributes => [
          { :identifier => 'default_translation_text',
            :content    => 'content content' }
        ]
      }
      assert_response :success
      assert assigns(:translateable).is_a?(Comfy::Cms::Page)
      assert assigns(:translation)
      assert_template :new
      assert_equal 'Failed to create translation', flash[:danger]
    end
  end

  def test_update
    page = comfy_cms_pages(:default)
    translation = comfy_cms_page_translations(:default)
    assert_no_difference 'Comfy::Cms::Block.count' do
      put :update, :site_id => page.site, :page_id => page, :id => translation, :translation => {
        :locale => :es
      }
      translation.reload
      assert_response :redirect
      assert_redirected_to :action => :edit, :id => translation
      assert_equal 'Translation updated', flash[:success]
      assert_equal 'es', translation.locale
    end
  end

  def test_update_failure
    page = comfy_cms_pages(:default)
    translation = comfy_cms_page_translations(:default)
    put :update, :site_id => page.site, :page_id => page, :id => translation, :translation => {
      :locale => ''
    }
    assert_response :success
    assert_template :edit
    assert assigns(:translateable).is_a?(Comfy::Cms::Page)
    assert assigns(:translation)
    assert_equal 'Failed to update translation', flash[:danger]
  end

  def test_destroy
    page = comfy_cms_pages(:default)
    translation = comfy_cms_page_translations(:default)
    assert_difference 'Comfy::Cms::Page::Translation.count', -1 do
      assert_difference 'Comfy::Cms::Block.count', -1 do
        delete :destroy, :site_id => page.site, :page_id => page, :id => translation
        assert_response :redirect
        assert_redirected_to edit_comfy_admin_cms_site_page_path(page.site, page)
        assert_equal 'Translation deleted', flash[:success]
      end
    end
  end

  def test_creation_preview
    page = comfy_cms_pages(:default)

    assert_no_difference 'Comfy::Cms::Page::Translation.count' do
      post :create, :site_id => page.site, :page_id => page, :preview => 'Preview', :translation => {
        :locale         => :es,
        :label           => 'Test Translation',
        :slug           => 'test-translation',
        :blocks_attributes => [
          { :identifier => 'default_page_text',
            :content    => 'preview content' }
        ]
      }
      assert_response :success
      assert_match /preview content/, response.body
      assert_equal 'text/html', response.content_type

      assert_equal page, assigns(:translateable)
      assert assigns(:translation)
      assert assigns(:translation).new_record?
    end
  end

  def test_update_preview
    page = comfy_cms_pages(:default)
    translation = comfy_cms_page_translations(:default)

    assert_no_difference 'Comfy::Cms::Page::Translation.count' do
      put :update, :site_id => page.site, :page_id => page, :id => translation, :preview => 'Preview', :translation => {
        :locale => :es,
        :blocks_attributes => [
          { :identifier => 'default_page_text',
            :content    => 'preview content' }
        ]
      }
      assert_response :success
      assert_match /preview content/, response.body
      translation.reload
      assert_not_equal 'es', translation.locale

      assert_equal page, assigns(:translateable)
      assert assigns(:translation)
    end
  end
end
