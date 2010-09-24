require File.dirname(__FILE__) + '/../test_helper'

class CmsSnippetTest < ActiveSupport::TestCase
  
  def test_fixtures_validity
    CmsSnippet.all.each do |snippet|
      assert snippet.valid?, snippet.errors.full_messages
    end
  end
  
  def test_validations
    snippet = CmsSnippet.new
    snippet.save
    assert snippet.invalid?
    assert_has_errors_on snippet, :label
  end
  
  def test_method_content
    assert_equal cms_snippets(:default).content, CmsSnippet.content_for('default')
    assert_equal '', CmsSnippet.content_for('nonexistent_snippet')
  end
  
end
