require File.dirname(__FILE__) + '/../test_helper'

class CmsSnippetTest < ActiveSupport::TestCase
  
  def test_method_content
    assert_equal cms_snippets(:default).content, CmsSnippet.content_for('default_snippet')
    assert_equal '', CmsSnippet.content_for('nonexistent_snippet')
  end
  
end
