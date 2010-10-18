class String
  # Converts string to something suitable to be used as an element id
  def idify
    self.strip.gsub(/\W/, '_').gsub(/\s|^_*|_*$/, '').squeeze('_')
  end
  
  # Capitalize all words in the string
  def capitalize_all(delimiter = ' ')
    self.split(delimiter).collect{|w| w.capitalize }.join(' ')
  end
end