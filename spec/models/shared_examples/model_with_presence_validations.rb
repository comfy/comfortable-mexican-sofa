# frozen_string_literal: true

RSpec.shared_examples "model with presence validations" do |*attrs|
  describe "presence validations" do
    it "checks for attribute presence" do
      object = described_class.new
      expect(object).to be_invalid
      expect(object.errors.attribute_names).to match_array(attrs)
    end
  end
end
