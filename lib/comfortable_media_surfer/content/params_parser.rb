# frozen_string_literal: true

require 'strscan'

class ComfortableMediaSurfer::Content::ParamsParser
  class Error < StandardError; end

  STRING_LITERAL  = %r{'[^']*'|"[^"]*"}
  IDENTIFIER      = %r{[a-z0-9][\w\-/.]*}i
  HASH_KEY        = %r{#{IDENTIFIER}:}
  COMMA           = %r{,}
  HASH_OPEN       = %r{\{}
  HASH_CLOSE      = %r{\}}
  ARRAY_OPEN      = %r{\[}
  ARRAY_CLOSE     = %r{\]}
  INTEGER         = %r{\b[0-9]+\b}i

  # @param <String> string
  def initialize(string = '')
    @string = string
  end

  # Takes CMS content tag parameters and converts them into array of strings,
  # hashes and arrays.
  #
  # @return [Array<String, {String => String}>]
  # @raise [Error] if the given `text` is malformed.
  #
  # @example
  #   new("a, b, c").parse
  #   #=> ["a", "b", "c"]
  #
  #   new("a, b: c, d: e").parse
  #   #=> ["a", {"b" => "c", "d" => "e"}]
  #
  #   new("a, b: {c: [d, e]}").parse
  #   #=> ["a", {"b" => {"c" => ["d", "e"]}}]
  #
  def params
    @tokens = tokenize(@string)
    parse_params
  end

private

  # Contructs root-level list of arguments sent via content tag
  def parse_params
    params = []
    while (token = @tokens.shift)
      params << parse_value(token)
    end
    params
  end

  # Gets token value. Will trigger parsing of hash and array structures
  def parse_value(token)
    case token&.first
    when :string
      token[1]
    when :hash_key
      @tokens.unshift(token)
      parse_hash
    when :hash_open
      parse_hash
    when :array_open
      parse_array
    else
      raise Error, "Invalid params: #{@string}"
    end
  end

  # Hash constructor method. Will handle nested hashes as well
  def parse_hash
    opens = 1
    hash = {}

    while (token = @tokens.shift)
      case token&.first
      when :hash_key
        hash[token[1]] = parse_value(@tokens.shift)
      when :hash_close
        opens -= 1
      when :hash_open
        opens += 1
      else
        raise Error, "Invalid params: #{@string}"
      end

      return hash if opens.zero?
    end

    # We're can't really detect unclosed hashes as we can construct them without
    # opening brakets. For example, `a: b, c: d` is same as `{a: b, c: d}` and
    # `{a: b, c: d` is also ends up to be a valid hash. It will error out if
    # unclosed hash is followed by some other unexpected token. Like: `{a: b, c`
    hash
  end

  # Array construction method. Will handle nested arrays
  def parse_array
    opens = 1
    array = []
    while (token = @tokens.shift)
      case token&.first
      when :array_close
        opens -= 1
      else
        array << parse_value(token)
      end

      return array if opens.zero?
    end

    raise Error, "Unclosed array param: #{@string}"
  end

  # Tokenizing input string into a list of touples
  # Also args_string is stripped of "smart" quotes coming from wysiwyg
  #
  # @param [String] args_string
  # @return [Array<String>] tokens
  def tokenize(args_string)
    args_string = args_string.tr('“”‘’', %q(""''))
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
        elsif (t = ss.scan(INTEGER))        then [:string, t.to_i]
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
