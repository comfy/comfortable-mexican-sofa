require "strscan"

module ComfortableMexicanSofa::Content::ParamsParser

  class Error < StandardError; end

  STRING_LITERAL = %r{'[^']*'|"[^"]*"}
  IDENTIFIER     = %r{[a-z0-9][\w\-/.]*}i
  COLON          = %r{:}
  COMMA          = %r{,}

  # @param [String] text
  # @return [Array<String, {String => String}>]
  # @raise [Error] if the given `text` is malformed.
  #
  # @example
  #   parse("happy greeting name:Joe show:true")
  #   #=> ['happy', 'greeting', {'name' => 'Joe', 'show' => 'true'}]
  def self.parse(text)
    parse_token_groups(split_on_commas(tokenize(text.to_s)))
  end

  # @param [Enumerable<Array<(Symbol, String)>>] token_groups
  # @return [Array<String, {String => String}>]
  def self.parse_token_groups(token_groups)
    token_groups.each_with_object([]) do |tokens, params|
      case tokens.count
      when 1
        params << parse_string_param(tokens[0])
      when 3
        param = parse_key_value_param(tokens)
        if params.last.is_a?(Hash)
          params.last.update(param)
        else
          params << param
        end
      else
        raise Error, "Unexpected tokens found: #{tokens}"
      end
    end
  end

  # @param [(:string, String)] token
  # @return [String]
  # @raise [Error] if `token[0] != :string`.
  def self.parse_string_param(token)
    type, value = token
    raise Error, "Unexpected token: #{token}" unless type == :string
    value
  end

  # @param [((:string, String), (:colon, String), (:string, String))] tokens
  # @return [{String => String}]
  # @raise [Error] if `tokens[0][0] != :string`, or `tokens[1][0] != :colon`,
  #   or `tokens[2][0] != :string`.
  def self.parse_key_value_param(tokens)
    (key_type, key_value), (col_type, _col_value), (val_type, val_value) = tokens
    unless key_type == :string && col_type == :colon && val_type == :string
      raise Error, "Unexpected tokens: #{tokens}"
    end
    { key_value => val_value }
  end

  # Splits tokens on commas. The result contains no `:comma` tokens.
  #
  # @param [Enumerable<(Symbol, String)>] tokens
  # @return [Enumerable<Array<(Symbol, String)>>] Token groups.
  def self.split_on_commas(tokens)
    slices = tokens.slice_after do |token|
      token[0] == :comma
    end
    slices.map do |expression|
      expression.reject { |t| t[0] == :comma }
    end
  end

  # Tokenizing input string into a list of touples
  # Also args_string is stripped of "smart" quotes coming from wysiwyg
  #
  # @param [String] args_string
  # @return [Array<String>] tokens
  def self.tokenize(args_string)
    args_string.tr!("“”‘’", %q(""''))
    ss = StringScanner.new(args_string)
    tokens = []
    loop do
      ss.skip(%r{\s*})
      break if ss.eos?
      tokens <<
        if    (t = ss.scan(STRING_LITERAL)) then [:string, t[1...-1]]
        elsif (t = ss.scan(IDENTIFIER))     then [:string, t]
        elsif (t = ss.scan(COLON))          then [:colon, t]
        elsif (t = ss.scan(COMMA))          then [:comma, t]
        else
          raise Error, "Unexpected char: #{ss.getch}"
        end
    end
    tokens
  end

end
