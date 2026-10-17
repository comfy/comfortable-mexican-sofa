# frozen_string_literal: true

require "rails_helper"

RSpec.describe ComfortableMexicanSofa::Content::ParamsParser do

  describe "#params" do
    it "returns simple list" do
      parser = described_class.new("a, b, 'foo bar', c")
      expect(parser.params).to eq(["a", "b", "foo bar", "c"])
    end

    it "returns simple hash" do
      parser = described_class.new("a:b")
      expect(parser.params).to eq([{ "a" => "b" }])

      parser = described_class.new("{a: b}")
      expect(parser.params).to eq([{ "a" => "b" }])

      parser = described_class.new("a: b, c: d")
      expect(parser.params).to eq([{ "a" => "b", "c" => "d" }])

      parser = described_class.new("{a: b, c: d}")
      expect(parser.params).to eq([{ "a" => "b", "c" => "d" }])
    end

    it "returns nested hash" do
      parser = described_class.new("a: {b: {c: d, e: f}}, g: {h: i}")
      expect(parser.params).to eq([{
        "a" => { "b" => { "c" => "d", "e" => "f" } },
        "g" => { "h" => "i" }
      }])
    end

    it "errors out on hash without value" do
      parser = described_class.new("a: b: c:")
      expect do
        parser.params
      end.to raise_error(described_class::Error, "Invalid params: a: b: c:")
    end

    it "errors out on hash with malformed value" do
      parser = described_class.new("{a: b, c}")
      expect do
        parser.params
      end.to raise_error(described_class::Error, "Invalid params: {a: b, c}")
    end

    it "returns simple array" do
      parser = described_class.new("[a, b, 'foo bar', c]")
      expect(parser.params).to eq([["a", "b", "foo bar", "c"]])
    end

    it "returns nested array" do
      parser = described_class.new("a, [b, [c, d]]")
      expect(parser.params).to eq(["a", ["b", %w[c d]]])
    end

    it "errors out on malformed array" do
      parser = described_class.new("[a, b")
      expect do
        parser.params
      end.to raise_error(described_class::Error, "Unclosed array param: [a, b")
    end

    it "returns mix of array and hash" do
      parser = described_class.new("a, b, c: d, e: f")
      expect(parser.params).to eq(["a", "b", { "c" => "d", "e" => "f" }])
    end

    it "returns mix of array and multiple hashes" do
      parser = described_class.new("a, {b: c}, {d: e}")
      expect(parser.params).to eq(["a", { "b" => "c" }, { "d" => "e" }])
    end

    it "handles hash in the middle" do
      parser = described_class.new("a, {b: c}, d")
      expect(parser.params).to eq(["a", { "b" => "c" }, "d"])
    end

    it "errors out on an unwrapped hash in the middle" do
      parser = described_class.new("a, b: c, d")
      expect do
        parser.params
      end.to raise_error(described_class::Error, "Invalid params: a, b: c, d")
    end

    it "returns values for a complex mix" do
      parser = described_class.new("a, b: [{c: {d: {e: f, g: h}}, i: j}, k], l: m")
      expect(parser.params).to eq([
        "a",
        {
          "b" => [
            { "c" => { "d" => { "e" => "f", "g" => "h" } }, "i" => "j" },
            "k"
          ],
          "l" => "m"
        }
      ])
    end

    it "does not interpolate strings" do
      parser = described_class.new(%q("a#{:a}", key: "va#{:l}ue"))
      expect(parser.params).to eq(["a\#{:a}", { "key" => "va\#{:l}ue" }])
    end
  end

  describe "private methods" do
    describe ".tokenize" do
      it "tokenizes value" do
        tokens = described_class.new.send(:tokenize, "foo")
        expect(tokens).to eq([[:string, "foo"]])
      end

      it "tokenizes integer" do
        tokens = described_class.new.send(:tokenize, "123")
        expect(tokens).to eq([[:string, "123"]])
      end

      it "tokenizes comma-separated values" do
        tokens = described_class.new.send(:tokenize, "eggs, ham, bacon")
        expect(tokens).to eq([
          [:string, "eggs"],
          [:string, "ham"],
          [:string, "bacon"]
        ])
      end

      it "tokenizes hashes" do
        tokens = described_class.new.send(:tokenize, "foo: bar")
        expect(tokens).to eq([
          [:hash_key, "foo"],
          [:string,   "bar"]
        ])
      end

      it "tokenizes nested hashes" do
        tokens = described_class.new.send(:tokenize, "k: {x: {y: z}}")
        expect(tokens).to eq([
          [:hash_key,   "k"],
          [:hash_open,  "{"],
          [:hash_key,   "x"],
          [:hash_open,  "{"],
          [:hash_key,   "y"],
          [:string,     "z"],
          [:hash_close, "}"],
          [:hash_close, "}"]
        ])
      end

      it "tokenizes hash with array value" do
        tokens = described_class.new.send(:tokenize, "k: [a, b, c]")
        expect(tokens).to eq([
          [:hash_key,     "k"],
          [:array_open,   "["],
          [:string,       "a"],
          [:string,       "b"],
          [:string,       "c"],
          [:array_close,  "]"]
        ])
      end

      it "tokenizes hash with quoted value" do
        tokens = described_class.new.send(:tokenize, "key: ''")
        expect(tokens).to eq([[:hash_key, "key"], [:string, ""]])

        tokens = described_class.new.send(:tokenize, "key: 'test'")
        expect(tokens).to eq([[:hash_key, "key"], [:string, "test"]])

        tokens = described_class.new.send(:tokenize, "key: 'v1, v2: v3'")
        expect(tokens).to eq([[:hash_key, "key"], [:string, "v1, v2: v3"]])

        tokens = described_class.new.send(:tokenize, 'key: "v1, v2: v3"')
        expect(tokens).to eq([[:hash_key, "key"], [:string, "v1, v2: v3"]])
      end

      it "tokenizes values with smart quotes" do
        expected = [
          [:string,   "param"],
          [:hash_key, "key"],
          [:string,   "value"]
        ]

        tokens = described_class.new.send(:tokenize, "'param', key: 'value'")
        expect(tokens).to eq(expected)

        tokens = described_class.new.send(:tokenize, '"param", key: "value"')
        expect(tokens).to eq(expected)

        tokens = described_class.new.send(:tokenize, "“param”, key: “value”")
        expect(tokens).to eq(expected)

        tokens = described_class.new.send(:tokenize, "‘param’, key: ‘value’")
        expect(tokens).to eq(expected)
      end

      it "errors out on bad input" do
        expect do
          described_class.new.send(:tokenize, "%")
        end.to raise_error(described_class::Error, "Unexpected char: %")
      end
    end
  end
end
