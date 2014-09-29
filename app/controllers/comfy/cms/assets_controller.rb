class Comfy::Cms::AssetsController < Comfy::Cms::BaseController
  
  skip_before_action :verify_authenticity_token
  
  before_action :use_null_session
  before_action :load_cms_layout
  
  def render_css
    render :text => @cms_layout.css, :content_type => 'text/css'
    cache_control_header
  end

  def render_js
    render :text => @cms_layout.js, :content_type => 'application/javascript'
    cache_control_header
  end

protected
  # null_session avoids cookies and flash updates
  def use_null_session
    # using protect_from_forgery :with => :null_session results in ugly warnings
    ActionController::RequestForgeryProtection::ProtectionMethods::NullSession.new(self).handle_unverified_request
  end

  def cache_control_header
    if params[:cache_buster].present?
      response.headers['Cache-Control'] = "public, max-age=#{1.year.to_i}"
    end
  end

  def load_cms_layout
    @cms_layout = @cms_site.layouts.find_by_identifier!(params[:identifier])
  rescue ActiveRecord::RecordNotFound
    render :nothing => true, :status => 404
  end
end