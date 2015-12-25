class ComfortableMexicanSofa::Tag::PageHaml
  include ComfortableMexicanSofa::Tag
  
  def self.regex_tag_signature(identifier = nil)
    identifier ||= IDENTIFIER_REGEX
    /\{\{\s*cms:page:(#{identifier}):haml\s*\}\}/
  end
  
  def content
    block.content
  end
  
  def render
    engine = Haml::Engine.new(content.to_s)
    engine.render
  end
end