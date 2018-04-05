# frozen_string_literal: true

require_relative "../../test_helper"

class ContentParamsParserTest < ActiveSupport::TestCase

  PARSER = ComfortableMexicanSofa::Content::ParamsParser

  def test_tokenizer
    tokens = PARSER.new.send(:tokenize, "param")
    assert_equal [[:string, "param"]], tokens
  end

  def test_tokenizer_with_integer
    tokens = PARSER.new.send(:tokenize, "123")
    assert_equal [[:string, "123"]], tokens
  end

  def test_tokenizer_with_commas
    tokens = PARSER.new.send(:tokenize, "param_a, param_b, param_c")
    assert_equal [
      [:string, "param_a"],
      [:string, "param_b"],
      [:string, "param_c"]
    ], tokens
  end

  def test_tokenizer_with_hash_keys
    tokens = PARSER.new.send(:tokenize, "key: value")
    assert_equal [
      [:hash_key, "key"],
      [:string,   "value"]
    ], tokens
  end

  def test_tokenizer_with_hashes
    tokens = PARSER.new.send(:tokenize, "k: {x: {y: z}}")
    assert_equal [
      [:hash_key,   "k"],
      [:hash_open,  "{"],
      [:hash_key,   "x"],
      [:hash_open,  "{"],
      [:hash_key,   "y"],
      [:string,     "z"],
      [:hash_close, "}"],
      [:hash_close, "}"]
    ], tokens
  end

  def test_tokenizer_with_arrays
    tokens = PARSER.new.send(:tokenize, "k: [a, b, c]")
    assert_equal [
      [:hash_key,     "k"],
      [:array_open,   "["],
      [:string,       "a"],
      [:string,       "b"],
      [:string,       "c"],
      [:array_close,  "]"]
    ], tokens
  end

  def test_tokenizer_with_quoted_value
    tokens = PARSER.new.send(:tokenize, "key: ''")
    assert_equal [[:hash_key, "key"], [:string, ""]], tokens

    tokens = PARSER.new.send(:tokenize, "key: 'test'")
    assert_equal [[:hash_key, "key"], [:string, "test"]], tokens

    tokens = PARSER.new.send(:tokenize, "key: 'v1, v2: v3'")
    assert_equal [[:hash_key, "key"], [:string, "v1, v2: v3"]], tokens

    tokens = PARSER.new.send(:tokenize, 'key: "v1, v2: v3"')
    assert_equal [[:hash_key, "key"], [:string, "v1, v2: v3"]], tokens
  end

  def test_tokenizer_with_smart_quotes
    expected = [[:string, "param"], [:hash_key, "key"], [:string, "value"]]

    tokens = PARSER.new.send(:tokenize, "'param', key: 'value'")
    assert_equal expected, tokens

    tokens = PARSER.new.send(:tokenize, '"param", key: "value"')
    assert_equal expected, tokens

    tokens = PARSER.new.send(:tokenize, "“param”, key: “value”")
    assert_equal expected, tokens

    tokens = PARSER.new.send(:tokenize, "‘param’, key: ‘value’")
    assert_equal expected, tokens
  end

  def test_tokenizer_with_bad_input
    message = "Unexpected char: %"
    assert_exception_raised PARSER::Error, message do
      PARSER.new.send(:tokenize, "%")
    end
  end

  def test_params_from_string
    string = "a, b, c"
    assert_equal %w[a b c], PARSER.new(string).params
  end

  def test_params_from_string_with_hashes
    string = "a: b"
    assert_equal [{ "a" => "b" }], PARSER.new(string).params

    string = "a: b, c: d"
    assert_equal [{ "a" => "b", "c" => "d" }], PARSER.new(string).params
  end

  def test_params_from_string_mixed
    text = "param_a, param_b, key_a: val_a, key_b: val_b, param_c, key_c: val_c"
    params = PARSER.new(text).params
    assert_equal [
      "param_a",
      "param_b",
      { "key_a" => "val_a", "key_b" => "val_b" },
      "param_c",
      { "key_c" => "val_c" }
    ], params
  end

end
