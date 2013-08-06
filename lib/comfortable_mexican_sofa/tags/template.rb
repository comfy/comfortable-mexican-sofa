class ComfortableMexicanSofa::Tag::Template
  include ComfortableMexicanSofa::Tag

  def self.regex_tag_signature(identifier = nil)
    identifier ||= /[\w\/\-]+/
    /\{\{\s*cms:template:(#{identifier})\s*\}\}/
  end

  def content
    "<%= render :template => '#{identifier}' %>"
  end

  def render
    whitelist = ComfortableMexicanSofa.config.allowed_templates
    if whitelist.is_a?(Array)
      content if whitelist.member?(identifier)
    else
      content
    end
  end

end