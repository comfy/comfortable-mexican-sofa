require_relative "../../test_helper"

class ContentParamsParserTest < ActiveSupport::TestCase

  def test_tokenizer
    tokens = ComfortableMexicanSofa::Content::ParamsParser.tokenize("param")
    assert_equal [[:string, "param"]], tokens
  end

  def test_tokenizer_with_integer
    tokens = ComfortableMexicanSofa::Content::ParamsParser.tokenize("123")
    assert_equal [[:string, "123"]], tokens
  end

  def test_tokenizer_with_commas
    tokens = ComfortableMexicanSofa::Content::ParamsParser.tokenize("param_a, param_b, param_c")
    assert_equal [
      [:string, "param_a"], [:comma, ","], [:string, "param_b"], [:comma, ","], [:string, "param_c"]
    ], tokens
  end

  def test_tokenizer_with_columns
    tokens = ComfortableMexicanSofa::Content::ParamsParser.tokenize("key: value")
    assert_equal [[:string, "key"], [:column, ":"], [:string, "value"]], tokens
  end

  def test_tokenizer_with_quoted_value
    tokens = ComfortableMexicanSofa::Content::ParamsParser.tokenize("key: ''")
    assert_equal [[:string, "key"], [:column, ":"], [:string, ""]], tokens

    tokens = ComfortableMexicanSofa::Content::ParamsParser.tokenize("key: 'test'")
    assert_equal [[:string, "key"], [:column, ":"], [:string, "test"]], tokens

    tokens = ComfortableMexicanSofa::Content::ParamsParser.tokenize("key: 'v1, v2: v3'")
    assert_equal [[:string, "key"], [:column, ":"], [:string, "v1, v2: v3"]], tokens

    tokens = ComfortableMexicanSofa::Content::ParamsParser.tokenize('key: "v1, v2: v3"')
    assert_equal [[:string, "key"], [:column, ":"], [:string, "v1, v2: v3"]], tokens
  end

  def test_tokenizer_with_bad_input
    message = "Unexpected char: %"
    assert_exception_raised ComfortableMexicanSofa::Content::ParamsParser::Error, message do
      ComfortableMexicanSofa::Content::ParamsParser.tokenize("%")
    end
  end

  def test_slice
    tokens = [[:string, "a"], [:comma, ","], [:string, "b"]]
    token_groups = ComfortableMexicanSofa::Content::ParamsParser.slice(tokens)
    assert_equal [[[:string, "a"]], [[:string, "b"]]], token_groups
  end

  def test_parameterize
    token_groups = [[[:string, "a"]]]
    params = ComfortableMexicanSofa::Content::ParamsParser.parameterize(token_groups)
    assert_equal ["a"], params

    token_groups = [[[:string, "a"], [:column, ":"], [:string, "b"]]]
    params = ComfortableMexicanSofa::Content::ParamsParser.parameterize(token_groups)
    assert_equal [{ "a" => "b" }], params
  end

  def test_parameterize_with_bad_input
    message = "Unexpected tokens found: [[:string, \"a\"], [:string, \"b\"]]"
    token_groups = [[[:string, "a"], [:string, "b"]]]
    assert_exception_raised ComfortableMexicanSofa::Content::ParamsParser::Error, message do
      ComfortableMexicanSofa::Content::ParamsParser.parameterize(token_groups)
    end
  end

  def test_collect_param_for_string!
    params = []
    ComfortableMexicanSofa::Content::ParamsParser.collect_param_for_string!(params, [:string, "a"])
    assert_equal ["a"], params
  end

  def test_collect_param_for_string_with_bad_input
    message = "Unexpected token: [:invalid, \"a\"]"
    assert_exception_raised ComfortableMexicanSofa::Content::ParamsParser::Error, message do
      ComfortableMexicanSofa::Content::ParamsParser.collect_param_for_string!([], [:invalid, "a"])
    end
  end

  def test_collect_param_for_hash!
    params = []
    tokens = [[:string, "a"], [:column, ":"], [:string, "b"]]
    ComfortableMexicanSofa::Content::ParamsParser.collect_param_for_hash!(params, tokens)
    assert_equal [{ "a" => "b" }], params
  end

  def test_collect_param_for_hash_with_trailing_hash
    params = ["x", { "y" => "z" }]
    tokens = [[:string, "a"], [:column, ":"], [:string, "b"]]
    ComfortableMexicanSofa::Content::ParamsParser.collect_param_for_hash!(params, tokens)
    assert_equal ["x", { "y" => "z", "a" => "b" }], params
  end

  def test_collect_param_for_hash_with_trailing_param
    params = ["x", { "y" => "z" }, "k"]
    tokens = [[:string, "a"], [:column, ":"], [:string, "b"]]
    ComfortableMexicanSofa::Content::ParamsParser.collect_param_for_hash!(params, tokens)
    assert_equal ["x", { "y" => "z" }, "k", { "a" => "b" }], params
  end

  def test_collect_param_for_hash_with_bad_input
    message = "Unexpected tokens: [[:string, \"a\"], [:invalid, \":\"], [:string, \"b\"]]"
    assert_exception_raised ComfortableMexicanSofa::Content::ParamsParser::Error, message do
      tokens = [[:string, "a"], [:invalid, ":"], [:string, "b"]]
      ComfortableMexicanSofa::Content::ParamsParser.collect_param_for_hash!([], tokens)
    end
  end

  def test_parse
    text = "param_a, param_b, key_a: val_a, key_b: val_b, param_c, key_c: val_c"
    params = ComfortableMexicanSofa::Content::ParamsParser.parse(text)
    assert_equal [
      "param_a",
      "param_b",
      { "key_a" => "val_a", "key_b" => "val_b" },
      "param_c",
      { "key_c" => "val_c" }
    ], params
  end

end
