class CmsTag::Partial < CmsTag::Tag
  
  def self.regex
    /\{\{\s*?(cms_partial:.*?)\s*?\}\}/
  end

  def self.render_priority
    3
  end

  def regex
    /\{\{\s*?cms_partial:#{Regexp.escape(label)}\s*?\}\}/
  end
  
  def content
    "<%= render :partial => '#{self.label}' %>"
  end

end
