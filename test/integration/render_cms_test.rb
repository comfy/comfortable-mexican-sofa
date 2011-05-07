require File.expand_path('../test_helper', File.dirname(__FILE__))

class RenderCmsTest < ActionDispatch::IntegrationTest
  
  def setup
    Rails.application.routes.draw do
      get '/render-implicit'  => 'render_test#implicit'
      get '/render-explicit'  => 'render_test#explicit'
      get '/render-text'      => 'render_test#render_text'
      get '/render-update'    => 'render_test#render_update'
    end
    super
  end
  
  def teardown
    load(File.expand_path('config/routes.rb', Rails.root))
  end
  
  class ::RenderTestController < ApplicationController
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
  end
  
  def test_get_with_explicit_cms_template
    page = cms_pages(:child)
    page.slug = 'render-explicit-page'
    page.save!
    get '/render-explicit'
    assert_response :success
  end
  
  def test_get_with_explicit_cms_template_failure
    page = cms_pages(:child)
    page.slug = 'render-explicit-404'
    page.save!
    assert_exception_raised ActionView::MissingTemplate do
      get '/render-explicit'
    end
  end
  
  def test_get_render_text
    get '/render-text'
    assert_response :success
  end
  
  def test_get_render_update
    get '/render-update'
    assert_response :success
  end
  
end