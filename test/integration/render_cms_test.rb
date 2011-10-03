require File.expand_path('../test_helper', File.dirname(__FILE__))

class RenderCmsTest < ActionDispatch::IntegrationTest
  
  def setup
    Rails.application.routes.draw do
      get '/render-basic'   => 'render_test#render_basic'
      get '/render-page'    => 'render_test#render_page'
      get '/render-layout'  => 'render_test#render_layout'
    end
    cms_layouts(:default).update_attribute(:content, '{{cms:page:content}}')
    cms_pages(:child).update_attribute(:blocks_attributes, [
      { :label => 'content', :content => 'TestBlockContent' }
    ])
    super
  end
  
  def teardown
    load(File.expand_path('config/routes.rb', Rails.root))
  end
  
  class ::RenderTestController < ApplicationController
    append_view_path(File.expand_path('../fixtures/views', File.dirname(__FILE__)))
    
    def render_basic
      case params[:type]
      when 'text'
        render :text => 'TestText'
      when 'update'
        render :update do |page| 
          page.alert('rendered text')
        end
      else
        render
      end
    end
    
    def render_page
      case params[:type]
      when 'page_implicit'
        render
      when 'page_explicit'
        render :cms_page => '/test-page'
      when 'page_explicit_with_status'
        render :cms_page => '/test-page', :status => 404
      else
        raise 'Invalid or no param[:type] provided'
      end
    end
    
    def render_layout
      @test_value = 'TestValue'
      case params[:type]
      when 'layout_defaults'
        render :cms_layout => 'default'
      when 'layout'
        render :cms_layout => 'default', :cms_blocks => {
          :content    => 'TestText',
          :content_b  => { :partial  => 'render_test/test' },
          :content_c  => { :template => 'render_test/render_layout' }
        }
      when 'layout_with_status'
        render :cms_layout => 'default', :status => 404
      when 'layout_invalid'
        render :cms_layout => 'invalid'
      else
        raise 'Invalid or no param[:type] provided'
      end
    end
  end
  
  # -- Basic Render Tests ---------------------------------------------------
  def test_text
    get '/render-basic?type=text'
    assert_response :success
    assert_equal 'TestText', response.body
  end
  
  def test_update
    return 'Not supported in >= 3.1' if Rails::VERSION::MAJOR == 3 && Rails::VERSION::MINOR >= 1
    get '/render-basic?type=update'
    assert_response :success
  end
  
  def test_implicit_cms_page_failure
    assert_exception_raised ActionView::MissingTemplate do
      get '/render-basic'
    end
  end
  
  # -- Page Render Test -----------------------------------------------------
  def test_implicit_cms_page
    page = cms_pages(:child)
    page.update_attribute(:slug, 'render-basic')
    get '/render-basic?type=page_implicit'
    assert_response :success
    assert assigns(:cms_site)
    assert assigns(:cms_layout)
    assert assigns(:cms_page)
    assert_equal page, assigns(:cms_page)
    assert_equal 'TestBlockContent', response.body
  end
  
  def test_explicit_cms_page
    page = cms_pages(:child)
    page.update_attribute(:slug, 'test-page')
    get '/render-page?type=page_explicit'
    assert_response :success
    assert assigns(:cms_site)
    assert assigns(:cms_layout)
    assert assigns(:cms_page)
    assert_equal page, assigns(:cms_page)
    assert_equal 'TestBlockContent', response.body
  end
  
  def test_explicit_cms_page_with_status
    page = cms_pages(:child)
    page.update_attribute(:slug, 'test-page')
    get '/render-page?type=page_explicit_with_status'
    assert_response 404
    assert assigns(:cms_site)
    assert assigns(:cms_layout)
    assert assigns(:cms_page)
    assert_equal page, assigns(:cms_page)
    assert_equal 'TestBlockContent', response.body
  end
  
  def test_explicit_cms_page_failure
    page = cms_pages(:child)
    page.update_attribute(:slug, 'invalid')
    assert_exception_raised ComfortableMexicanSofa::MissingPage do
      get '/render-page?type=page_explicit'
    end
  end
  
  # -- Layout Render Tests --------------------------------------------------
  def test_cms_layout_defaults
    get '/render-layout?type=layout_defaults'
    assert_response :success
    assert_equal 'TestTemplate TestValue', response.body
  end
  
  def test_cms_layout
    cms_layouts(:default).update_attribute(:content, '{{cms:page:content}} {{cms:page:content_b}} {{cms:page:content_c}}')
    get '/render-layout?type=layout'
    assert_response :success
    assert_equal 'TestText TestPartial TestValue TestTemplate TestValue', response.body
  end
  
  def test_cms_layout_with_status
    get '/render-layout?type=layout_with_status'
    assert_response 404
    assert_equal 'TestTemplate TestValue', response.body
  end
  
  def test_cms_layout_failure
    assert_exception_raised ComfortableMexicanSofa::MissingLayout do
      get '/render-layout?type=layout_invalid'
    end
  end
  
end