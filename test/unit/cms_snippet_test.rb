require File.expand_path('../test_helper', File.dirname(__FILE__))

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
    assert_has_errors_on snippet, [:label, :slug]
  end
  
  def test_method_content
    assert_equal cms_snippets(:default).content, CmsSnippet.content_for('default')
    assert_equal '', CmsSnippet.content_for('nonexistent_snippet')
  end
  
  def test_load_from_file
    assert !CmsSnippet.load_from_file(cms_sites(:default), 'default')
    
    ComfortableMexicanSofa.configuration.seed_data_path = File.expand_path('../cms_seeds', File.dirname(__FILE__))
    
    assert !CmsSnippet.load_from_file(cms_sites(:default), 'bogus')
    
    assert snippet = CmsSnippet.load_from_file(cms_sites(:default), 'default')
    assert_equal 'Default Snippet', snippet.label
    assert_equal 'Content for Default Snippet', snippet.content
  end
  
end
