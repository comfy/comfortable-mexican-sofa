class String

  # Converts string to something suitable to be used as an element id
  def idify
    self.strip.gsub(/\W/, '_').gsub(/\s|^_*|_*$/, '').squeeze('_')
  end
  
  # Converts a string to something usable as a url slug
  def slugify
    self.downcase.gsub(/\W|_/, ' ').strip.squeeze(' ').gsub(/\s/, '-')
  end
end