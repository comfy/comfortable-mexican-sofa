class ComfortableMexicanSofa::Tag::PageText
  include ComfortableMexicanSofa::Tag
  
  def self.regex_tag_signature(identifier = nil)
    identifier ||= IDENTIFIER_REGEX
    /\{\{\s*cms:page:(#{identifier}):?(?:text)?\s*\}\}/
  end
  
  def content(include_edit_tags = false)
    include_edit_tags ? ComfortableMexicanSofa::Tag.add_block_edit_tags(block.content, block) : block.content
  end
  
end