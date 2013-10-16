require_relative '../test_helper'

class TagTest < ActiveSupport::TestCase
  
  def test_tokenizer_regex
    regex = ComfortableMexicanSofa::Tag::TOKENIZER_REGEX
    
    tokens = 'text { text } text'.scan(regex)
    assert_equal nil,                   tokens[0][0]
    assert_equal 'text { text } text',  tokens[0][1]
    
    tokens = 'content<{{cms:some_tag content'.scan(regex)
    assert_equal nil,                     tokens[0][0]
    assert_equal 'content<',              tokens[0][1]
    assert_equal nil,                     tokens[1][0]
    assert_equal '{{',                    tokens[1][1]
    assert_equal nil,                     tokens[2][0]
    assert_equal 'cms:some_tag content',  tokens[2][1]
    
    tokens = 'content<{{cms some_tag}}>content'.scan(regex)
    assert_equal nil,                     tokens[0][0]
    assert_equal 'content<',              tokens[0][1]
    assert_equal nil,                     tokens[1][0]
    assert_equal '{{',                    tokens[1][1]
    assert_equal nil,                     tokens[2][0]
    assert_equal 'cms some_tag}}>content',tokens[2][1]
    
    tokens = 'content<{{cms:some_tag}}>content'.scan(regex)
    assert_equal nil,                     tokens[0][0]
    assert_equal 'content<',              tokens[0][1]
    assert_equal '{{cms:some_tag}}',      tokens[1][0]
    assert_equal nil,                     tokens[1][1]
    assert_equal nil,                     tokens[2][0]
    assert_equal '>content',              tokens[2][1]
    
    tokens = 'content<{{cms:type:label}}>content'.scan(regex)
    assert_equal nil,                     tokens[0][0]
    assert_equal 'content<',              tokens[0][1]
    assert_equal '{{cms:type:label}}',    tokens[1][0]
    assert_equal nil,                     tokens[1][1]
    assert_equal nil,                     tokens[2][0]
    assert_equal '>content',              tokens[2][1]
    
    tokens = 'content<{{cms:type:label }}>content'.scan(regex)
    assert_equal nil,                     tokens[0][0]
    assert_equal 'content<',              tokens[0][1]
    assert_equal '{{cms:type:label }}',   tokens[1][0]
    assert_equal nil,                     tokens[1][1]
    assert_equal nil,                     tokens[2][0]
    assert_equal '>content',              tokens[2][1]
    
    tokens = 'content<{{ cms:type:la/b el }}>content'.scan(regex)
    assert_equal nil,                     tokens[0][0]
    assert_equal 'content<',              tokens[0][1]
    assert_equal '{{ cms:type:la/b el }}',tokens[1][0]
    assert_equal nil,                     tokens[1][1]
    assert_equal nil,                     tokens[2][0]
    assert_equal '>content',              tokens[2][1]
  end
  
  def test_tokenizer_regex_limit
    string = '<p>text</p>' * 400
    tokens = string.scan(ComfortableMexicanSofa::Tag::TOKENIZER_REGEX)
    assert_equal 1, tokens.count
    assert_equal nil, tokens[0][0]
    assert_equal string, tokens[0][1]
  end
  
  def test_content_for_existing_page
    page = cms_pages(:default)
    assert page.tags.blank?
    assert_equal rendered_content_formatter(
      '
      layout_content_a
      default_page_text_content_a
      default_snippet_content
      default_page_text_content_b
      layout_content_b
      default_snippet_content
      layout_content_c'
    ), page.render
    
    assert_equal 4, page.tags.size
    assert_equal 'field_text_default_field_text', page.tags[0].id
    assert_equal 'page_text_default_page_text', page.tags[1].id
    assert_equal 'snippet_default', page.tags[2].id
    assert_equal page.tags[1], page.tags[2].parent
    assert_equal 'snippet_default', page.tags[3].id
  end
  
  def test_content_for_new_page
    page = Cms::Page.new
    assert page.blocks.blank?
    assert page.tags.blank?
    assert_equal '', page.content
    assert page.tags.blank?
  end
  
  def test_content_for_new_page_with_layout
    page = cms_sites(:default).pages.new(:layout => cms_layouts(:default))
    assert page.blocks.blank?
    assert page.tags.blank?
    assert_equal rendered_content_formatter(
      '
      layout_content_a
      
      layout_content_b
      default_snippet_content
      layout_content_c'
    ), page.render
    
    assert_equal 3, page.tags.size
    assert_equal 'field_text_default_field_text', page.tags[0].id
    assert_equal 'page_text_default_page_text', page.tags[1].id
    assert_equal 'snippet_default', page.tags[2].id
  end
  
  def test_content_for_new_page_with_initilized_cms_blocks
    page = cms_sites(:default).pages.new(:layout => cms_layouts(:default))
    assert page.blocks.blank?
    assert page.tags.blank?
    page.blocks_attributes = [
      { :identifier => 'default_field_text',
        :content    => 'new_default_field_content'
      },
      { :identifier => 'default_page_text',
        :content    => "new_default_page_text_content\n{{cms:snippet:default}}"
      },
      { :identifier => 'bogus_field_that_never_will_get_rendered',
        :content    => 'some_content_that_doesnot_matter'
      }
    ]
    assert_equal 3, page.blocks.size
    
    assert_equal rendered_content_formatter(
      '
      layout_content_a
      new_default_page_text_content
      default_snippet_content
      layout_content_b
      default_snippet_content
      layout_content_c'
    ), page.render
    
    assert_equal 4, page.tags.size
    assert_equal 'field_text_default_field_text', page.tags[0].id
    assert_equal 'page_text_default_page_text', page.tags[1].id
    assert_equal 'snippet_default', page.tags[2].id
    assert_equal page.tags[1], page.tags[2].parent
    assert_equal 'snippet_default', page.tags[3].id
  end
  
  def test_content_with_repeated_tags
    page = cms_pages(:default)
    page.layout.content << "\n{{cms:page:default_page_text:text}}"
    page.layout.save!
    
    assert_equal rendered_content_formatter(
      '
      layout_content_a
      default_page_text_content_a
      default_snippet_content
      default_page_text_content_b
      layout_content_b
      default_snippet_content
      layout_content_c
      default_page_text_content_a
      default_snippet_content
      default_page_text_content_b'
    ), page.render
    
    assert_equal 6, page.tags.size
    assert_equal 'field_text_default_field_text', page.tags[0].id
    assert_equal 'page_text_default_page_text', page.tags[1].id
    assert_equal 'snippet_default', page.tags[2].id
    assert_equal page.tags[1], page.tags[2].parent
    assert_equal 'snippet_default', page.tags[3].id
    assert_equal 'page_text_default_page_text', page.tags[4].id
    assert_equal 'snippet_default', page.tags[5].id
    assert_equal page.tags[4], page.tags[5].parent
  end
  
  def test_content_with_cyclical_tags
    page = cms_pages(:default)
    snippet = cms_snippets(:default)
    snippet.update_attributes(:content => "infinite {{cms:page:default}} loop")
    assert_equal rendered_content_formatter(
      '
      layout_content_a
      default_page_text_content_a
      infinite  loop
      default_page_text_content_b
      layout_content_b
      infinite  loop
      layout_content_c'
    ), page.render
    assert_equal 6, page.tags.size
  end
  
  def test_is_cms_block?
    tag = ComfortableMexicanSofa::Tag::PageText.initialize_tag(
      cms_pages(:default), '{{ cms:page:content:text }}'
    )
    assert tag.is_cms_block?
    
    tag = ComfortableMexicanSofa::Tag::FieldText.initialize_tag(
      cms_pages(:default), '{{ cms:field:content:text }}'
    )
    assert tag.is_cms_block?
    
    tag = ComfortableMexicanSofa::Tag::Snippet.initialize_tag(
      cms_pages(:default), '{{ cms:snippet:label }}'
    )
    assert !tag.is_cms_block?

    tag = ComfortableMexicanSofa::Tag::File.initialize_tag(
      cms_pages(:default), '{{ cms:file:sample.jpg }}'
    )
    assert !tag.is_cms_block?
  end
  
  def test_content_with_irb_disabled
    assert_equal false, ComfortableMexicanSofa.config.allow_irb
    
    site = cms_sites(:default)
    layout = site.layouts.create!(
      :identifier => 'no-irb-layout',
      :content    => '<% 1 + 1 %> {{cms:page:content}} {{cms:collection:snippet:cms/snippet}} <%= 1 + 1 %>'
    )
    snippet = site.snippets.create!(
      :identifier => 'no-irb-snippet',
      :content    => '<% 2 + 2 %> snippet <%= 2 + 2 %>'
    )
    page = site.pages.create!(
      :slug       => 'no-irb-page',
      :parent_id  => cms_pages(:default).id,
      :layout_id  => layout.id,
      :blocks_attributes => [
        { :identifier => 'content',
          :content    => 'text {{ cms:snippet:no-irb-snippet }} {{ cms:partial:path/to }} {{ cms:helper:method }} text' },
        { :identifier => 'snippet',
          :content    => snippet.id }
      ]
    )
    assert_equal "&lt;% 1 + 1 %&gt; text &lt;% 2 + 2 %&gt; snippet &lt;%= 2 + 2 %&gt; <%= render :partial => 'path/to' %> <%= method() %> text <%= render :partial => 'partials/cms/snippets', :locals => {:model => 'Cms::Snippet', :identifier => '#{snippet.id}'} %> &lt;%= 1 + 1 %&gt;", page.content
  end
  
  def test_content_with_irb_enabled
    ComfortableMexicanSofa.config.allow_irb = true
    
    site = cms_sites(:default)
    layout = site.layouts.create!(
      :identifier => 'irb-layout',
      :content    => '<% 1 + 1 %> {{cms:page:content}} {{cms:collection:snippet:cms/snippet}} <%= 1 + 1 %>'
    )
    snippet = site.snippets.create!(
      :identifier => 'irb-snippet',
      :content    => '<% 2 + 2 %> snippet <%= 2 + 2 %>'
    )
    page = site.pages.create!(
      :slug       => 'irb-page',
      :parent_id  => cms_pages(:default).id,
      :layout_id  => layout.id,
      :blocks_attributes => [
        { :identifier => 'content',
          :content    => 'text {{ cms:snippet:irb-snippet }} {{ cms:partial:path/to }} {{ cms:helper:method }} text' },
        { :identifier => 'snippet',
          :content    => snippet.id.to_s }
      ]
    )
    
    assert_equal "<% 1 + 1 %> text <% 2 + 2 %> snippet <%= 2 + 2 %> <%= render :partial => 'path/to' %> <%= method() %> text <%= render :partial => 'partials/cms/snippets', :locals => {:model => 'Cms::Snippet', :identifier => '#{snippet.id}'} %> <%= 1 + 1 %>", page.render
  end
  
  def test_escaping_of_parameters
    tag = ComfortableMexicanSofa::Tag::Helper.initialize_tag(
      cms_pages(:default), '{{cms:helper:h:"\'+User.first.inspect+\'"}}'
    )
    assert_equal %{<%= h('\\'+User.first.inspect+\\'') %>}, tag.content
    assert_equal %{<%= h('\\'+User.first.inspect+\\'') %>}, tag.render
  end
  
  def test_tag_initialization_with_namespace
    assert tag = ComfortableMexicanSofa::Tag::PageString.initialize_tag(
      cms_pages(:default), '{{ cms:page:content:string }}'
    )
    assert_equal 'content', tag.identifier
    assert_equal nil, tag.namespace
    
    assert tag = ComfortableMexicanSofa::Tag::PageString.initialize_tag(
      cms_pages(:default), '{{ cms:page:home.content:string }}'
    )
    assert_equal 'home.content', tag.identifier
    assert_equal 'home', tag.namespace
    
    assert tag = ComfortableMexicanSofa::Tag::PageString.initialize_tag(
      cms_pages(:default), '{{ cms:page:home.main.content:string }}'
    )
    assert_equal 'home.main.content', tag.identifier
    assert_equal 'home.main', tag.namespace
    
    assert tag = ComfortableMexicanSofa::Tag::PageString.initialize_tag(
      cms_pages(:default), '{{ cms:page:ho-me.ma-in.con-tent:string }}'
    )
    assert_equal 'ho-me.ma-in.con-tent', tag.identifier
    assert_equal 'ho-me.ma-in', tag.namespace
  end
  
end
