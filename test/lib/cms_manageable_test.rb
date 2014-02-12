require_relative '../test_helper'

class CmsManageableTest < ActiveSupport::TestCase

  include TestHelpers::ActiveRecordMocks

  def test_accepts_blocks_attributes
    mock_active_record_model(:example) do |t|
      t.text :title
      t.text :content
    end
    ExampleMock.class_eval do
      cms_manageable
      def layout
        Cms::Layout.new(:content => '<p>{{cms:page:test}}</p>')
      end
    end
    example = ExampleMock.create(:blocks_attributes => [{:identifier => 'test', :content => 'test'}])
    assert_equal [{:identifier => 'test', :content => 'test'}], example.blocks_attributes
    assert_equal "<p>test</p>", example.content
  end

  def test_skip_cache_option
    mock_active_record_model(:example_skip_cache) do |t|
      t.text :title
      t.text :content
    end
    ExampleSkipCacheMock.class_eval do
      cms_manageable :skip_cache => true
      def layout
        Cms::Layout.new(:content => '{{cms:page:test}}')
      end
    end
    example = ExampleSkipCacheMock.create(:blocks_attributes => [{:identifier => 'test', :content => 'test'}])
    assert example.read_attribute(:content).blank?
    assert_equal 'test', example.content
  end
  
end