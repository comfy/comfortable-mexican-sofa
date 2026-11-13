# frozen_string_literal: true

require "rails_helper"

RSpec.describe "I18n locale files" do
  def locale_keys
    collect_combined_keys = lambda do |hash, ns = nil|
      return unless hash.is_a?(Hash)

      hash.flat_map do |k, v|
        [
          "#{ns}.#{k}",
          *collect_combined_keys.call(v, "#{ns}.#{k}")
        ]
      end
    end

    locales_path = File.expand_path("../../config/locales", __dir__)
    locales = Dir.glob("#{locales_path}/*.yml").collect do |file_path|
      File.basename(file_path, ".yml")
    end

    # collecting all locales
    locales.each_with_object({}) do |locale, locales|
      translations = YAML.load_file("#{locales_path}/#{locale}.yml")
      locales[locale] = collect_combined_keys.call(translations[locale])
    end
  end

  it "has consistent locale yml files" do
    reference = locale_keys["en"]
    expect(reference).to be_present, "Cannot find en.yml"

    locale_keys.each do |locale, keys|
      missing = reference - keys
      expect(missing).to be_blank, "#{locale} locale is missing: #{missing.join(', ')}"

      extra = keys - reference
      expect(extra).to be_blank, "#{locale} locale has extra: #{extra.join(', ')}"
    end
  end
end
