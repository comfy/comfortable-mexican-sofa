require 'test_helper'

class CmsSnippetTest < ActiveSupport::TestCase
  
  # -- Class Methods --------------------------------------------------------
  
  test "get snippet content" do
    assert_equal cms_snippets(:default).content, CmsSnippet.content_for('default_snippet')
    assert_equal '', CmsSnippet.content_for('nonexistent_snippet')
  end
  
end
