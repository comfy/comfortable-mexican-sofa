module ComfortableMexicanSofa
  class SearchScore

    LABEL_SCORE    = 100
    META_SCORE     = 35
    HEADING2_SCORE = 30
    HEADING3_SCORE = 20
    WORD_SCORE     = 1

    def initialize(search_term, label, blocks)
      @search_term = search_term
      @label = label
      @blocks = blocks
    end

    def score
      page_label_score + page_content_score
    end

    private

    attr_reader :search_term, :label, :blocks

    def page_label_score
      label.split.count {|w| matches?(w) } * LABEL_SCORE
    end

    def page_content_score
      meta_description_score + lines_score
    end

    def meta_description_score
      block_content_for("meta_description", /\s/).count {|w| matches?(w) } * META_SCORE
    end

    def lines_score
      matching_lines.map {|line| score_for(line) || WORD_SCORE}.flatten.reduce(&:+).to_i
    end

    def matching_lines
      block_content_for("content", /\n/).select {|l| matches?(l) }
    end

    def score_for(line)
      return HEADING3_SCORE if line.match(heading(3))
      return HEADING2_SCORE if line.match(heading(2))
    end

    def heading(num)
      /\A\#{#{num}}/
    end

    def block_content_for(identifier, seperator)
      blocks.select {|block| block[:identifier] == identifier }.flat_map do |block|
        block[:content].split(seperator)
      end
    end

    def matches?(string)
      string.match(Regexp.new(search_term, true))
    end
  end
end
