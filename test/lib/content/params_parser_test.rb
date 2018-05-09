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

  def test_params_simple_list
    assert_equal ["a", "b", "foo bar", "c"], PARSER.new("a, b, 'foo bar', c").params
  end

  def test_params_simple_hash
    assert_equal [{ "a" => "b" }],              PARSER.new("a: b").params
    assert_equal [{ "a" => "b" }],              PARSER.new("{a: b}").params
    assert_equal [{ "a" => "b", "c" => "d" }],  PARSER.new("a: b, c: d").params
    assert_equal [{ "a" => "b", "c" => "d" }],  PARSER.new("{a: b, c: d}").params
  end

  def test_params_nested_hash
    assert_equal [
      { "a" => { "b" => { "c" => "d", "e" => "f" } }, "g" => { "h" => "i" } }
    ], PARSER.new("a: {b: {c: d, e: f}}, g: {h: i}").params
  end

  def test_params_invalid_hash
    message = "Invalid params: a: b: c:"
    assert_exception_raised PARSER::Error, message do
      PARSER.new("a: b: c:").params
    end
  end

  def test_params_invalid_hash_element
    message = "Invalid params: {a: b, c}"
    assert_exception_raised PARSER::Error, message do
      PARSER.new("{a: b, c}").params
    end
  end

  def test_params_array
    assert_equal [["a", "b", "foo bar", "c"]], PARSER.new("[a, b, 'foo bar', c]").params
  end

  def test_params_nested_array
    assert_equal ["a", ["b", %w[c d]]], PARSER.new("a, [b, [c, d]]").params
  end

  def test_params_array_unclosed
    message = "Unclosed array param: [a, b"
    assert_exception_raised PARSER::Error, message do
      PARSER.new("[a, b").params
    end
  end

  def test_params_mixed
    assert_equal ["a", "b", { "c" => "d", "e" => "f" }], PARSER.new("a, b, c: d, e: f").params
  end

  def test_params_mixed_separate_hashes
    assert_equal ["a", { "b" => "c" }, { "d" => "e" }], PARSER.new("a, {b: c}, {d: e}").params
  end

  def test_params_mixed_invalid
    message = "Invalid params: a, b: c, d"
    assert_exception_raised PARSER::Error, message do
      PARSER.new("a, b: c, d").params
    end

    assert_equal ["a", { "b" => "c" }, "d"], PARSER.new("a, {b: c}, d").params
  end

  def test_params_mixed_complex
    string = "a, b: [{c: {d: {e: f, g: h}}, i: j}, k], l: m"
    assert_equal [
      "a",
      {
        "b" => [
          { "c" => { "d" => { "e" => "f", "g" => "h" } }, "i" => "j" },
          "k"
        ],
        "l" => "m"
      }
    ], PARSER.new(string).params
  end

  def test_params_with_erb_injection
    string = %q("a#{:a}", key: "va#{:l}ue") # rubocop:disable Lint/InterpolationCheck
    assert_equal ["a\#{:a}", { "key" => "va\#{:l}ue" }], PARSER.new(string).params
  end

end
