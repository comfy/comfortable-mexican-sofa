# frozen_string_literal: true

require_relative '../test_helper'

class VersionTest < ActiveSupport::TestCase
  def test_version
    assert_equal 'constant', defined?(ComfortableMediaSurfer::VERSION)
    refute_empty ComfortableMediaSurfer::VERSION
  end
end
