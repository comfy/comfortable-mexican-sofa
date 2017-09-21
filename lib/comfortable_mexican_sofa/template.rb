# This is going to be replacement for Tag class.

# This will take content associated with a page and do a full unroll.

# - load page
# - load page.layout

# - parse layout content
# - if layout has a parent layout we need to merge them on {{ cms:fragment content }}
# - do a scan looking for tags of {{ cms:whatever }} format. This is a tokenization process
# - for tokens that match our tags we will initialize them and get their `content` that might have more tags


# {{ cms:whatever }}          tag   - render
# {{ cms:fragment }}          tag   - expand
# text                        text

# {{ cms:fragment_list items }} tag   - block. process rest seperately?
#   text                      text
#   {{ cms:fragment item }}   tag   - expand
#   text                      text  - text
#   {{ cms:fragment desc }}   tag   - expand
#   {{ cms:helper }}          tag   - render
# {{ cms:end_fragment_list }}   tag   - endblock

# text                        text
# {{ cms:whatever }}          tag   - render

class ComfortableMexicanSofa::Template

  # tags are in this format: {{ cms:tag_class params,  }}
  TAG_REGEX = /\{\{\s*?cms:(?<class>\w+)(?<params>.*?)\}\}/

  class << self
    def tags
      @tags ||= {}
    end

    def register_tag(name, klass)
      tags[name.to_s] = klass
    end
  end

  def initialize(string)
    @string = string
    @tokens = []
  end

  # splitting text with tags into tokens we can process down the line
  def tokenize
    ss = StringScanner.new(@string)
    while string = ss.scan_until(TAG_REGEX)
      text = string.sub(ss[0], '')
      @tokens << text if text.present?
      @tokens << {tag_class: ss[:class], tag_params: ss[:params].strip}
    end
    text = ss.rest
    @tokens << text if text.present?
    @tokens
  end

  # Iterating through tokens and expanding tags.
  # TODO: If tag has more tags inside we
  # we need to expand those too.
  def expand
    @tokens.map do |token|
      case token
      when Hash
        tag_class = self.class.tags[token[:tag_class]]
        tag = tag_class.new(token[:params])
        tag.render
      else
        token
      end
    end
  end

end


