require 'test_helper'

class CmsContentControllerTest < ActionController::TestCase

  def test_get_a_page
    assert cms_pages(:complex).published?
    get :show, :path => %w(complex-page)
    assert_response :success
    assert assigns(:cms_page)
  end

  def test_get_a_unpublished_page
    assert !cms_pages(:unpublished).published?
    get :show, :path => %w(unpublished)
    assert_response 404
  end

  def test_get_sitemap
    get :sitemap, :format => 'xml'
    assert_response :success
    assert assigns(:cms_pages)
  end

  def test_default_404_page
    get :show, :path => %w(some non existing page)
    assert_response 404
    assert !assigns(:cms_page)
  end

  def test_custom_404_page
    cms_page = CmsPage.create!(
      :cms_layout => cms_layouts(:default),
      :label      => '404 Page',
      :slug       => '404',
      :published => true
    )
    get :show, :path => %w(some non existing page)
    assert_response 404
    assert assigns(:cms_page)
  end

  def test_get_page_with_extension
    get :show, :path => %w(path to somepage.php?show=1)
    assert_response 404
  end
end
