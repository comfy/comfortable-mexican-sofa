require File.expand_path('../test_helper', File.dirname(__FILE__))

class ViewMethodsTest < ActiveSupport::TestCase
  
  class HelpersTestController < ActionController::Base
    helper { def hello; 'hello' end }
    def test_cms_snippet_content
      render :inline => '<%= cms_snippet_content(:default) %>'
    end
    def test_cms_page_content
      @cms_page = Cms::Page.root
      render :inline => '<%= cms_page_content(:default_field_text) %>'
    end
  end
  
  # Simulating a call and getting resulting output
  def action_result(action)
    HelpersTestController.action(action).call(ActionController::TestRequest.new.env).last.body
  end
  
  def test_cms_snippet_content
    assert_equal 'default_snippet_content', action_result('test_cms_snippet_content')
  end
  
  def test_cms_snippet_content_with_tags
    cms_snippets(:default).update_attribute(:content, '{{cms:helper:hello}}')
    assert_equal 'hello', action_result('test_cms_snippet_content')
  end
  
  def test_cms_page_content
    assert_equal 'default_field_text_content', action_result('test_cms_page_content')
  end
  
  def test_cms_page_content_with_tags
    cms_blocks(:default_field_text).update_attribute(:content, '{{cms:helper:hello}}')
    assert_equal 'hello', action_result('test_cms_page_content')
  end
  
end