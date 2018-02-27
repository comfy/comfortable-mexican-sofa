# frozen_string_literal: true

require_relative "../../test_helper"

class ContentParamsParserTest < ActiveSupport::TestCase

  PARSER = ComfortableMexicanSofa::Content::ParamsParser

  def test_tokenizer
    tokens = PARSER.tokenize("param")
    assert_equal [[:string, "param"]], tokens
  end

  def test_tokenizer_with_integer
    tokens = PARSER.tokenize("123")
    assert_equal [[:string, "123"]], tokens
  end

  def test_tokenizer_with_commas
    tokens = PARSER.tokenize("param_a, param_b, param_c")
    assert_equal [
      [:string, "param_a"], [:comma, ","], [:string, "param_b"], [:comma, ","], [:string, "param_c"]
    ], tokens
  end

  def test_tokenizer_with_columns
    tokens = PARSER.tokenize("key: value")
    assert_equal [[:string, "key"], [:colon, ":"], [:string, "value"]], tokens
  end

  def test_tokenizer_with_quoted_value
    tokens = PARSER.tokenize("key: ''")
    assert_equal [[:string, "key"], [:colon, ":"], [:string, ""]], tokens

    tokens = PARSER.tokenize("key: 'test'")
    assert_equal [[:string, "key"], [:colon, ":"], [:string, "test"]], tokens

    tokens = PARSER.tokenize("key: 'v1, v2: v3'")
    assert_equal [[:string, "key"], [:colon, ":"], [:string, "v1, v2: v3"]], tokens

    tokens = PARSER.tokenize('key: "v1, v2: v3"')
    assert_equal [[:string, "key"], [:colon, ":"], [:string, "v1, v2: v3"]], tokens
  end

  def test_tokenizer_with_smart_quotes
    expected = [[:string, "param"], [:comma, ","], [:string, "key"], [:colon, ":"], [:string, "value"]]

    tokens = PARSER.tokenize("'param', 'key': 'value'")
    assert_equal expected, tokens

    tokens = PARSER.tokenize('"param", "key": "value"')
    assert_equal expected, tokens

    tokens = PARSER.tokenize("“param”, “key”: “value”")
    assert_equal expected, tokens

    tokens = PARSER.tokenize("‘param’, ‘key’: ‘value’")
    assert_equal expected, tokens
  end

  def test_tokenizer_with_bad_input
    message = "Unexpected char: %"
    assert_exception_raised PARSER::Error, message do
      PARSER.tokenize("%")
    end
  end

  def test_split_on_commas
    tokens = [[:string, "a"], [:comma, ","], [:string, "b"]]
    token_groups = PARSER.split_on_commas(tokens)
    assert_equal [[[:string, "a"]], [[:string, "b"]]], token_groups
  end

  def test_parse_token_groups
    token_groups = [[[:string, "a"]]]
    params = PARSER.parse_token_groups(token_groups)
    assert_equal ["a"], params

    token_groups = [[[:string, "a"], [:colon, ":"], [:string, "b"]]]
    params = PARSER.parse_token_groups(token_groups)
    assert_equal [{ "a" => "b" }], params
  end

  def test_parse_token_groups_with_bad_input
    message = "Unexpected tokens found: [[:string, \"a\"], [:string, \"b\"]]"
    token_groups = [[[:string, "a"], [:string, "b"]]]
    assert_exception_raised PARSER::Error, message do
      PARSER.parse_token_groups(token_groups)
    end
  end

  def test_parse_string_param
    assert_equal "a", PARSER.parse_string_param([:string, "a"])
  end

  def test_parse_string_param_with_bad_input
    message = "Unexpected token: [:invalid, \"a\"]"
    assert_exception_raised PARSER::Error, message do
      PARSER.parse_string_param([:invalid, "a"])
    end
  end

  def test_parse_key_value_param
    tokens = [[:string, "a"], [:colon, ":"], [:string, "b"]]
    assert_equal({ "a" => "b" }, PARSER.parse_key_value_param(tokens))
  end

  def test_parse_key_value_param_with_bad_input
    message = "Unexpected tokens: [[:string, \"a\"], [:invalid, \":\"], [:string, \"b\"]]"
    assert_exception_raised PARSER::Error, message do
      PARSER.parse_key_value_param(
        [[:string, "a"], [:invalid, ":"], [:string, "b"]]
      )
    end
  end

  def test_parse
    text = "param_a, param_b, key_a: val_a, key_b: val_b, param_c, key_c: val_c"
    params = PARSER.parse(text)
    assert_equal [
      "param_a",
      "param_b",
      { "key_a" => "val_a", "key_b" => "val_b" },
      "param_c",
      { "key_c" => "val_c" }
    ], params
  end

end
