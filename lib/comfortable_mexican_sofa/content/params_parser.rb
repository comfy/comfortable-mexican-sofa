# frozen_string_literal: true

require "strscan"

class ComfortableMexicanSofa::Content::ParamsParser

  class Error < StandardError; end

  STRING_LITERAL  = %r{'[^']*'|"[^"]*"}
  IDENTIFIER      = %r{[a-z0-9][\w\-/.]*}i
  HASH_KEY        = %r{#{IDENTIFIER}:}
  COMMA           = %r{,}
  HASH_OPEN       = %r{\{}
  HASH_CLOSE      = %r{\}}
  ARRAY_OPEN      = %r{\[}
  ARRAY_CLOSE     = %r{\]}

  # @param <String> string
  def initialize(string = "")
    @string = string
  end

  # Takes CMS content tag parameters and converts them into array of strings,
  # hashes and arrays.
  #
  # @return [Array<String, {String => String}>]
  # @raise [Error] if the given `text` is malformed.
  #
  # @example
  #   parse("happy, greeting, name: Joe, show: true")
  #   #=> ['happy', 'greeting', {'name' => 'Joe', 'show' => 'true'}]
  #
  def params
    parse(tokenize(@string))
  end

private

  # @param [Enumerable<(Symbol, String)>] tokens
  # @return [Array<String, {String => String}>]
  #
  def parse(tokens, params = [])
    token, *rest = tokens

    return params if token.nil?

    case token[0]
    when :string
      params << token[1]
    when :hash_key
      hash_value, rest = parse_hash_value(rest)
      hash = params.last.is_a?(Hash) ? params.pop : {}
      hash[token[1]] = hash_value
      params << hash
    end

    parse(rest, params)
  end

  def parse_hash_value(tokens)
    token, *rest = tokens
    case token[0]
    when :string
      return [token[1], rest]
    end
  end

  # Tokenizing input string into a list of touples
  # Also args_string is stripped of "smart" quotes coming from wysiwyg
  #
  # @param [String] args_string
  # @return [Array<String>] tokens
  def tokenize(args_string)
    args_string = args_string.tr("“”‘’", %q(""''))
    ss = StringScanner.new(args_string)
    tokens = []
    loop do
      ss.skip(%r{\s*})
      break if ss.eos?

      # commas are just separators like spaces
      next if ss.scan(COMMA)

      tokens <<
        if    (t = ss.scan(STRING_LITERAL)) then [:string, t[1...-1]]
        elsif (t = ss.scan(HASH_KEY))       then [:hash_key, t[0...-1]]
        elsif (t = ss.scan(IDENTIFIER))     then [:string, t]
        elsif (t = ss.scan(HASH_OPEN))      then [:hash_open, t]
        elsif (t = ss.scan(HASH_CLOSE))     then [:hash_close, t]
        elsif (t = ss.scan(ARRAY_OPEN))     then [:array_open, t]
        elsif (t = ss.scan(ARRAY_CLOSE))    then [:array_close, t]
        else
          raise Error, "Unexpected char: #{ss.getch}"
        end
    end

    tokens
  end

end
