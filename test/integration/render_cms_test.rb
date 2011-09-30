require File.expand_path('../test_helper', File.dirname(__FILE__))

class RenderCmsTest < ActionDispatch::IntegrationTest
  
  def setup
    Rails.application.routes.draw do
      get '/render-implicit'  => 'render_test#implicit'
      get '/render-explicit'  => 'render_test#explicit'
      get '/render-text'      => 'render_test#render_text'
      get '/render-update'    => 'render_test#render_update'
      get '/render-layout'    => 'render_test#render_layout'
    end
    super
  end
  
  def teardown
    load(File.expand_path('config/routes.rb', Rails.root))
  end
  
  class ::RenderTestController < ApplicationController
    append_view_path(File.expand_path('../fixtures/views', File.dirname(__FILE__)))
    
    def implicit
      render
    end
    def explicit
      render :cms_page => '/render-explicit-page'
    end
    def render_text
      render :text => 'rendered text'
    end
    def render_update
      render :update do |page|
        page.alert('rendered text')
      end
    end
    def render_layout
      render :cms_layout => 'default', :default_page_text => 'default'
    end
  end
  
  def test_get_with_no_template
    assert_exception_raised ActionView::MissingTemplate do
      get '/render-implicit'
    end
  end
  
  def test_get_with_implicit_cms_template
    page = cms_pages(:child)
    page.slug = 'render-implicit'
    page.save!
    get '/render-implicit'
    assert_response :success
    assert assigns(:cms_site)
    assert assigns(:cms_layout)
    assert assigns(:cms_page)
  end
  
  def test_get_with_explicit_cms_template
    page = cms_pages(:child)
    page.slug = 'render-explicit-page'
    page.save!
    get '/render-explicit'
    assert_response :success
    assert assigns(:cms_site)
    assert assigns(:cms_layout)
    assert assigns(:cms_page)
  end
  
  def test_get_with_explicit_cms_template_failure
    page = cms_pages(:child)
    page.slug = 'render-explicit-404'
    page.save!
    assert_exception_raised ComfortableMexicanSofa::MissingPage do
      get '/render-explicit'
    end
  end
  
  def test_get_render_text
    get '/render-text'
    assert_response :success
  end
  
  def test_get_render_update
    return 'Not supported >= 3.1' if Rails::VERSION::MAJOR == 3 && Rails::VERSION::MINOR >= 1
    get '/render-update'
    assert_response :success
  end
  
  def test_get_render_with_cms_layout
    get '/render-layout'
    assert_response :success
    assert_equal "\nlayout_content_a\nDefault Template\nlayout_content_b\ndefault_snippet_content\nlayout_content_c", response.body
  end
  
end