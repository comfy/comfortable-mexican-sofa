class Fragment < Liquid::Tag

  def initialize(tag_name, arguments, _parse_context)
    super
    @tag = [tag_name, arguments]
  end

  def render(_context)
    "testing #{@tag}"
  end

  def parse_args(arguments)
    name, args = arguments.split(/\s+/, 2)
  end

  def self.tokenize(args_string)
    tokens = []
    ss = StringScanner.new(args_string)
    until ss.eos?
      ss.skip(/\s*/)
      break if ss.eos?
      token = case
        when t = ss.scan(/'[^\']*'/)      then [:string, t]
        when t = ss.scan(/"[^\"]*"/)      then [:string, t]
        when t = ss.scan(/[a-z][\w-]*/i) then [:string, t]
        when t = ss.scan(/\:/)            then [:column, t]
        when t = ss.scan(/\,/)            then [:comma, t]
        else
          raise SyntaxError, "Unexpected char: #{ss.getch}"
      end
      tokens << token
    end
    tokens
  end

  def self.tokens_to_args_hash(tokens)
    hash = { }
    tokens.each_slice(4) do |key, column, value, _comma|
      key_type, key_value   = key
      col_type, _col_value  = column
      val_type, val_value   = value

      unless key_type == :string && col_type == :column && val_type == :string
        raise SyntaxError, "Unexpected args: #{[key, column, value]}"
      end

      hash[key_value] = val_value
    end
    hash
  end
end

Liquid::Template.register_tag('cms_fragment', Fragment)