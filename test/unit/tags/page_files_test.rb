require File.expand_path('../../test_helper', File.dirname(__FILE__))

class PageFilesTagTest < ActiveSupport::TestCase
  
  def test_initialize_tag
    assert tag = ComfortableMexicanSofa::Tag::PageFiles.initialize_tag(
      cms_pages(:default), '{{ cms:page_files:label }}'
    )
    assert 'url', tag.type
    
    assert tag = ComfortableMexicanSofa::Tag::PageFiles.initialize_tag(
      cms_pages(:default), '{{ cms:page_files:label:partial }}'
    )
    assert 'partial', tag.type
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
        { :label    => 'files',
          :content  => [fixture_file_upload('files/valid_image.jpg'), fixture_file_upload('files/invalid_file.gif')] }
      ]
    )
    files = tag.block.files
    file_a, file_b = files 
    time_a = file_a.updated_at.to_f.to_i
    time_b = file_b.updated_at.to_f.to_i
    
    assert_equal files, tag.content
    assert_equal "/system/files/#{file_a.id}/original/valid_image.jpg?#{time_a}, /system/files/#{file_b.id}/original/invalid_file.gif?#{time_b}", tag.render
    
    assert tag = ComfortableMexicanSofa::Tag::PageFiles.initialize_tag(page, '{{ cms:page_files:files:link }}')
    assert_equal "<a href='/system/files/#{file_a.id}/original/valid_image.jpg?#{time_a}' target='_blank'>Valid Image</a> <a href='/system/files/#{file_b.id}/original/invalid_file.gif?#{time_b}' target='_blank'>Invalid File</a>", 
      tag.render
      
    assert tag = ComfortableMexicanSofa::Tag::PageFiles.initialize_tag(page, '{{ cms:page_files:files:image }}')
    assert_equal "<img src='/system/files/#{file_a.id}/original/valid_image.jpg?#{time_a}' alt='Valid Image' /> <img src='/system/files/#{file_b.id}/original/invalid_file.gif?#{time_b}' alt='Invalid File' />", 
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
  end
  
end