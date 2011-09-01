class String
  # Converts string to something suitable to be used as an element id
  def idify
    self.strip.gsub(/\W/, '_').gsub(/\s|^_*|_*$/, '').squeeze('_')
  end
end

module Enumerable
  # Like a normal collect, only with index
  def collect_with_index
    result = []
    self.each_with_index do |elt, idx|
      result << yield(elt, idx)
    end
    result
  end
end