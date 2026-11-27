# frozen_string_literal: true

RSpec.shared_examples "model with valid fixture data" do
  describe "fixture data" do
    it "is valid" do
      described_class.find_each do |instance|
        expect(instance).to be_valid
      end
    end
  end
end
