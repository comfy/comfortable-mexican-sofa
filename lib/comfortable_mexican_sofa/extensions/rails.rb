class String
  # Converts string to something suitable to be used as an element id
  def slugify
    self.strip.gsub(/\W|_/, '-').gsub(/\s|^_*|_*$/, '').squeeze('-')
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

ActiveSupportLogger = ActiveSupport::VERSION::MAJOR >= 4 ?
  ActiveSupport::Logger : ActiveSupport::BufferedLogger
class ActiveSupportLogger
  def detailed_error(e)
    error(e.message)
    e.backtrace.each{|line| error line }
  end
end