# frozen_string_literal: true

require_relative "../../../test_helper"

class AnotherTestController < ApplicationController; end

class Comfy::Cms::BaseControllerTest < ActionDispatch::IntegrationTest

  reset

  setup do
    @existing = ComfortableMexicanSofa.configuration.base_cms_controller
    ComfortableMexicanSofa.configuration.base_cms_controller = "AnotherTestController"
  end

  teardown do
    ComfortableMexicanSofa.configuration.base_cms_controller = @existing
  end

  def test_base_class_configuration
    get comfy_cms_render_page_path(cms_path: "")
    assert @controller.kind_of? AnotherTestController
  end

end
