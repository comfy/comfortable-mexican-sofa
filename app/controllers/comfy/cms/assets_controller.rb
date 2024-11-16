# frozen_string_literal: true

class Comfy::Cms::AssetsController < Comfy::Cms::BaseController
  skip_before_action :verify_authenticity_token, raise: false

  before_action :load_cms_layout,
                :use_null_session

  after_action :set_cache_control_header

  def render_css
    render body: @cms_layout.css, content_type: 'text/css'
  end

  def render_js
    render body: @cms_layout.js, content_type: 'application/javascript'
  end

protected

  def load_cms_layout
    @cms_layout = @cms_site.layouts.find_by_identifier!(params[:identifier])
  rescue ActiveRecord::RecordNotFound
    render body: nil, status: 404
  end

  # null_session avoids cookies and flash updates
  def use_null_session
    ActionController::RequestForgeryProtection::ProtectionMethods::NullSession.new(self)
      .handle_unverified_request
  end

  def set_cache_control_header
    return unless params[:cache_buster].present?

    response.headers['Cache-Control'] = "public, max-age=#{1.year.to_i}"
  end
end
