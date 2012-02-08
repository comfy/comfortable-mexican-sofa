require File.expand_path('../../test_helper', File.dirname(__FILE__))

class PageFilesTagTest < ActiveSupport::TestCase
  
  def test_initialize_tag
    assert tag = ComfortableMexicanSofa::Tag::PageFiles.initialize_tag(
      cms_pages(:default), '{{ cms:page_files:label }}'
    )
    assert 'url', tag.type
    assert_equal nil, tag.dimensions
    
    assert tag = ComfortableMexicanSofa::Tag::PageFiles.initialize_tag(
      cms_pages(:default), '{{ cms:page_files:label:partial }}'
    )
    assert 'partial', tag.type
  end
  
  def test_initialize_tag_with_dimentions
    assert tag = ComfortableMexicanSofa::Tag::PageFiles.initialize_tag(
      cms_pages(:default), '{{ cms:page_files:label:image[100x100#] }}'
    )
    assert_equal 'image', tag.type
    assert_equal '100x100#', tag.dimensions
  end
  
  def test_initialize_tag_failure
    [
      '{{cms:page_files}}',
      '{{cms:not_page_files:label}}',
      '{not_a_tag}'
    ].each do |tag_signature|
      assert_nil ComfortableMexicanSofa::Tag::PageFiles.initialize_tag(
        cms_pages(:default), tag_signature
      )
    end
  end
  
  def test_content_and_render
    page = cms_pages(:default)
    
    assert tag = ComfortableMexicanSofa::Tag::PageFiles.initialize_tag(page, '{{ cms:page_files:files:partial }}')
    assert_equal "<%= render :partial => 'partials/page_files', :locals => {:identifier => []} %>", tag.render
    
    assert tag = ComfortableMexicanSofa::Tag::PageFiles.initialize_tag(page, '{{ cms:page_files:files }}')
    assert_equal [], tag.content
    assert_equal '', tag.render
    
    page.update_attributes!(
      :blocks_attributes => [
        { :identifier => 'files',
          :content    => [fixture_file_upload('files/image.jpg'), fixture_file_upload('files/image.gif')] }
      ]
    )
    files = tag.block.files
    file_a, file_b = files
    
    assert_equal files, tag.content
    assert_equal "/system/cms/files/#{file_a.id}/files/original/image.jpg, /system/cms/files/#{file_b.id}/files/original/image.gif", tag.render
    
    assert tag = ComfortableMexicanSofa::Tag::PageFiles.initialize_tag(page, '{{ cms:page_files:files:link }}')
    assert_equal "<a href='/system/cms/files/#{file_a.id}/files/original/image.jpg' target='_blank'>Image</a> <a href='/system/cms/files/#{file_b.id}/files/original/image.gif' target='_blank'>Image</a>", 
      tag.render
      
    assert tag = ComfortableMexicanSofa::Tag::PageFiles.initialize_tag(page, '{{ cms:page_files:files:image }}')
    assert_equal "<img src='/system/cms/files/#{file_a.id}/files/original/image.jpg' alt='Image' /> <img src='/system/cms/files/#{file_b.id}/files/original/image.gif' alt='Image' />", 
      tag.render
    
    assert tag = ComfortableMexicanSofa::Tag::PageFiles.initialize_tag(page, '{{ cms:page_files:files:partial }}')
    assert_equal "<%= render :partial => 'partials/page_files', :locals => {:identifier => [#{files.collect(&:id).join(',')}]} %>", 
      tag.render
      
    assert tag = ComfortableMexicanSofa::Tag::PageFiles.initialize_tag(page, '{{ cms:page_files:files:partial:path/to/partial }}')
    assert_equal "<%= render :partial => 'path/to/partial', :locals => {:identifier => [#{files.collect(&:id).join(',')}]} %>", 
      tag.render
    
    assert tag = ComfortableMexicanSofa::Tag::PageFiles.initialize_tag(page, '{{ cms:page_files:files:partial:path/to/partial:a:b }}')
    assert_equal "<%= render :partial => 'path/to/partial', :locals => {:identifier => [#{files.collect(&:id).join(',')}], :param_1 => 'a', :param_2 => 'b'} %>", 
      tag.render
    
    assert tag = ComfortableMexicanSofa::Tag::PageFiles.initialize_tag(page, '{{ cms:page_files:files:field }}')
    assert_equal '', tag.render
  end
  
  def test_content_and_render_with_dimentions
    layout = cms_layouts(:default)
    layout.update_attribute(:content, '{{ cms:page_files:file:image[10x10#] }}')
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