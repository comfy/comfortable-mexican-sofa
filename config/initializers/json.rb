# frozen_string_literal: true

module JSON
module_function

  def parse(source, opts = {})
    Parser.new(source, **opts).parse
  end
end
