require_relative '../../../../test_helper'

class Comfy::Admin::Cms::ControllerAuthenticationTest < ActionController::TestCase

  setup do
    # Configure authentication with a generic filter
    assert_not_nil @controller
    # replace method implementation only for this instance
    @controller.define_singleton_method(:authenticate) do
      render nothing: true, status: :forbidden if current_resource == forbidden_resource
    end
    # By default no resource are forbidden
    @controller.stubs(forbidden_resource: nil)
  end

  private

  def default_site
    comfy_cms_sites(:default)
  end

end

class Comfy::Admin::Cms::LayoutsControllerAuthenticationTest < Comfy::Admin::Cms::ControllerAuthenticationTest

  tests Comfy::Admin::Cms::LayoutsController

  test 'on index current_resource is the class object' do
    @controller.stubs(forbidden_resource: Comfy::Cms::Layout)
    get :index, site_id: default_site
    assert_response :forbidden
  end

  test 'allowed layout does not prevent access' do
    get :edit, site_id: default_site, id: comfy_cms_layouts(:child)
    assert_response :success
  end

  test 'forbidden layout prevents access' do
    @controller.stubs(forbidden_resource: layout)
    get :edit, site_id: default_site, id: layout
    assert_response :forbidden
  end

  private

  def layout
    @layout ||= comfy_cms_layouts(:default)
  end

end


class Comfy::Admin::Cms::PagesControllerAuthenticationTest < Comfy::Admin::Cms::ControllerAuthenticationTest

  tests Comfy::Admin::Cms::PagesController

  test 'on index current_resource is the class object' do
    @controller.stubs(forbidden_resource: Comfy::Cms::Page)
    get :index, site_id: default_site
    assert_response :forbidden
  end

  test 'allowed page does not prevent access' do
    get :edit, site_id: default_site, id: page
    assert_response :success
  end

  test 'forbidden page prevents access' do
    @controller.stubs(forbidden_resource: page)
    get :edit, site_id: default_site, id: page
    assert_response :forbidden
  end

  private

  def page
    @page ||= comfy_cms_pages(:default)
  end

end

class Comfy::Admin::Cms::SitesControllerAuthenticationTest < Comfy::Admin::Cms::ControllerAuthenticationTest

  tests Comfy::Admin::Cms::SitesController

  test 'on index current_resource is the class object' do
    @controller.stubs(forbidden_resource: Comfy::Cms::Site)
    get :index
    assert_response :forbidden
  end

  test 'allowed site does not prevent access' do
    get :edit, id: default_site
    assert_response :success
  end

  test 'forbidden site prevents access' do
    @controller.stubs(forbidden_resource: default_site)
    get :edit, id: default_site
    assert_response :forbidden
  end

end
