require_relative '../../test_helper'

class PageFileTagTest < ActiveSupport::TestCase
  
  def test_initialize_tag
    assert tag = ComfortableMexicanSofa::Tag::PageFile.initialize_tag(
      cms_pages(:default), '{{ cms:page_file:label }}'
    )
    assert_equal 'label', tag.identifier
    assert_nil tag.namespace
    assert 'url', tag.type
    assert_equal nil, tag.dimensions
    
    assert tag = ComfortableMexicanSofa::Tag::PageFile.initialize_tag(
      cms_pages(:default), '{{ cms:page_file:label:partial }}'
    )
    assert_equal 'partial', tag.type
    
    assert tag = ComfortableMexicanSofa::Tag::PageFile.initialize_tag(
      cms_pages(:default), '{{ cms:page_file:namespace.label:partial }}'
    )
    assert_equal 'namespace.label', tag.identifier
    assert_equal 'namespace', tag.namespace
  end
  
  def test_initialize_tag_with_dimentions
    assert tag = ComfortableMexicanSofa::Tag::PageFile.initialize_tag(
      cms_pages(:default), '{{ cms:page_file:label:image[100x100#] }}'
    )
    assert_equal 'image', tag.type
    assert_equal '100x100#', tag.dimensions
  end
  
  def test_initialize_tag_failure
    [
      '{{cms:page_file}}',
      '{{cms:not_page_file:label}}',
      '{not_a_tag}'
    ].each do |tag_signature|
      assert_nil ComfortableMexicanSofa::Tag::PageFile.initialize_tag(
        cms_pages(:default), tag_signature
      )
    end
  end
  
  def test_content_and_render
    page = cms_pages(:default)
    
    assert tag = ComfortableMexicanSofa::Tag::PageFile.initialize_tag(page, '{{ cms:page_file:file:partial }}')
    assert_equal "<%= render :partial => 'partials/page_file', :locals => {:identifier => nil} %>", tag.render
    
    assert tag = ComfortableMexicanSofa::Tag::PageFile.initialize_tag(page, '{{ cms:page_file:file }}')
    assert_equal nil, tag.content
    assert_equal '', tag.render
    
    page.update_attributes!(
      :blocks_attributes => [
        { :identifier => 'file',
          :content    => fixture_file_upload('files/image.jpg', "image/jpeg") }
      ]
    )
    file = tag.block.files.first
    file_url = file.file.url
    
    assert_equal file, tag.content
    assert_match file_url, tag.render
    
    assert tag = ComfortableMexicanSofa::Tag::PageFile.initialize_tag(page, '{{ cms:page_file:file:link }}')
    assert_equal "<a href='#{file_url}' target='_blank'>file</a>", 
      tag.render
      
    assert tag = ComfortableMexicanSofa::Tag::PageFile.initialize_tag(page, '{{ cms:page_file:file:link:link label }}')
    assert_equal "<a href='#{file_url}' target='_blank'>link label</a>", 
      tag.render
      
    assert tag = ComfortableMexicanSofa::Tag::PageFile.initialize_tag(page, '{{ cms:page_file:file:image }}')
    assert_equal "<img src='#{file_url}' alt='file' />", 
      tag.render
      
    assert tag = ComfortableMexicanSofa::Tag::PageFile.initialize_tag(page, '{{ cms:page_file:file:image:image alt }}')
    assert_equal "<img src='#{file_url}' alt='image alt' />", 
      tag.render
      
    assert tag = ComfortableMexicanSofa::Tag::PageFile.initialize_tag(page, '{{ cms:page_file:file:partial }}')
    assert_equal "<%= render :partial => 'partials/page_file', :locals => {:identifier => #{file.id}} %>", 
      tag.render
      
    assert tag = ComfortableMexicanSofa::Tag::PageFile.initialize_tag(page, '{{ cms:page_file:file:partial:path/to/partial }}')
    assert_equal "<%= render :partial => 'path/to/partial', :locals => {:identifier => #{file.id}} %>", 
      tag.render
      
    assert tag = ComfortableMexicanSofa::Tag::PageFile.initialize_tag(page, '{{ cms:page_file:file:partial:path/to/partial:a:b }}')
    assert_equal "<%= render :partial => 'path/to/partial', :locals => {:identifier => #{file.id}, :param_1 => 'a', :param_2 => 'b'} %>", 
      tag.render
      
    assert tag = ComfortableMexicanSofa::Tag::PageFile.initialize_tag(page, '{{ cms:page_file:file:field }}')
    assert_equal '', tag.render
  end
  
  def test_content_and_render_with_dimentions
    layout = cms_layouts(:default)
    layout.update_attributes(:content => '{{ cms:page_file:file:image[10x10#] }}')
    page = cms_pages(:default)
    upload = fixture_file_upload('files/image.jpg', 'image/jpeg')
    
    assert_difference 'Cms::File.count' do
      page.update_attributes!(
        :blocks_attributes => [
          { :identifier => 'file',
            :content    => upload }
        ]
      )
      file = Cms::File.last
      assert_equal 'image.jpg', file.file_file_name
      # assert file.file_file_size < upload.size
    end
  end
  
end