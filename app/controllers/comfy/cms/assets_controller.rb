class Comfy::Cms::AssetsController < Comfy::Cms::BaseController
  before_action :load_cms_layout

  def render_css
    render :text => @cms_layout.css, :content_type => 'text/css'
    cache_control_header
  end

  def render_js
    render :text => @cms_layout.js, :content_type => 'text/javascript'
    cache_control_header
  end

protected

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