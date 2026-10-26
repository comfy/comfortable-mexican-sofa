# frozen_string_literal: true

require "rails_helper"

RSpec.describe Comfy::Cms::Layout do
  let(:site) { comfy_cms_sites(:default) }

  it_behaves_like "model with valid fixture data"
  it_behaves_like "model with presence validations", :site, :identifier, :label
end
