module ComfortableMexicanSofa::Content::ParamsParser

  class Error < StandardError; end

  SINGLE_STRING_LITERAL = %r{'[^']*'}
  DOUBLE_STRING_LITERAL = %r{"[^"]*"}
  IDENTIFIER            = %r{[a-z0-9][\w\-/.]*}i
  COLUMN                = %r{:}
  COMMA                 = %r{,}

  def self.parse(text)
    parameterize(slice(tokenize(text.to_s)))
  end

  def self.parameterize(token_groups)
    params = [ ]
    token_groups.each do |tokens|
      if tokens.count == 1
        collect_param_for_string!(params, tokens[0])
      elsif tokens.count == 3
        collect_param_for_hash!(params, tokens)
      else
        raise Error, "Unexpected tokens found: #{tokens}"
      end
    end
    params
  end

  def self.collect_param_for_string!(params, token)
    type, value = token
    raise Error, "Unexpected token: #{token}" unless type == :string
    params << value
  end

  def self.collect_param_for_hash!(params, tokens)
    key, col, val = tokens
    key_type, key_value = key
    col_type,           = col
    val_type, val_value = val

    unless key_type == :string && col_type == :column && val_type == :string
      raise Error, "Unexpected tokens: #{tokens}"
    end

    hash = params.last.is_a?(Hash) ? params.pop : {}
    hash[key_value] = val_value
    params << hash
  end

  # grouping tokens based on the comma and also removing comma tokens
  def self.slice(tokens)
    slices = tokens.slice_after do |token|
      token[0] == :comma
    end
    slices.map do |expression|
      expression.reject{|t| t[0] == :comma}
    end
  end

  # tokenizing input string into a list of touples
  def self.tokenize(args_string)
    tokens = []
    ss = StringScanner.new(args_string)
    until ss.eos?
      ss.skip(%r{\s*})
      break if ss.eos?
      token =
        if    (t = ss.scan(SINGLE_STRING_LITERAL)) then [:string, t[1...t.size - 1]]
        elsif (t = ss.scan(DOUBLE_STRING_LITERAL)) then [:string, t[1...t.size - 1]]
        elsif (t = ss.scan(IDENTIFIER))            then [:string, t]
        elsif (t = ss.scan(COLUMN))                then [:column, t]
        elsif (t = ss.scan(COMMA))                 then [:comma, t]
        else
          raise Error, "Unexpected char: #{ss.getch}"
        end
      tokens << token
    end
    tokens
  end
end
