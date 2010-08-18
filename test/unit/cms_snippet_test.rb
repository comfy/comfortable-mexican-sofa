require 'test_helper'

class CmsSnippetTest < ActiveSupport::TestCase
  
  # -- Validations ----------------------------------------------------------
  
  should validate_presence_of(:label)
  should validate_uniqueness_of(:label)
  should_not allow_value("bogus label").for(:label)
  should_not allow_value("bogus^").for(:label)
  should allow_value("snippet-label").for(:label)
  
  # -- Class Methods --------------------------------------------------------
  
  test "get snippet content" do
    assert_equal cms_snippets(:default).content, CmsSnippet.content_for('default_snippet')
    assert_equal '', CmsSnippet.content_for('nonexistent_snippet')
  end
  
end
