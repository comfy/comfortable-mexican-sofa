class ComfortableMexicanSofa::Tag::PageMarkdown
  include ComfortableMexicanSofa::Tag
  
  def self.regex_tag_signature(identifier = nil)
    identifier ||= IDENTIFIER_REGEX
    /\{\{\s*cms:page:(#{identifier}):markdown\s*\}\}/
  end
  
  def content
    block.content
  end
  
  def render
    md = Redcarpet::Markdown.new(Redcarpet::Render::HTML,
      :autolink           => true,
      :no_intra_emphasis  => true,
      :fenced_code_blocks => true,
      :lax_spacing        => true
    )
    md.render(content.to_s)
  end
end