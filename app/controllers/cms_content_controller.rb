class CmsContentController < ApplicationController

  before_filter :load_cms_site
  before_filter :load_fixtures
  before_filter :load_cms_page,   :only => :render_html
  before_filter :load_cms_layout, :only => [:render_css, :render_js]
  
  def render_html(status = 200)
    if layout = @cms_page.layout
      app_layout = layout.app_layout.blank?? false : layout.app_layout
      render :inline => @cms_page.content, :layout => app_layout, :status => status
    else
      render :text => I18n.t('cms.content.layout_not_found'), :status => 404
    end
  end

  def render_css
    render :text => @cms_layout.css, :content_type => 'text/css'
  end

  def render_js
    render :text => @cms_layout.js, :content_type => 'text/javascript'
  end

protected

  def load_fixtures
    return unless ComfortableMexicanSofa.config.enable_fixtures
    ComfortableMexicanSofa::Fixtures.import_all(@cms_site.hostname)
  end
  
  def load_cms_site
    if params[:site_id]
      @cms_site ||= Cms::Site.find_by_id(params[:site_id])
    else
      @cms_site ||= Cms::Site.first if Cms::Site.count == 1
      Cms::Site.find_all_by_hostname(request.host.downcase).each do |site|
        if site.path.blank?
          @cms_site = site
        elsif "#{request.fullpath}/".match /^\/#{Regexp.escape(site.path.to_s)}\//
          @cms_site = site
          break
        end
      end unless @cms_site
    end
    
    if @cms_site
      params[:cms_path].to_s.gsub!(/^#{@cms_site.path}/, '').gsub!(/^\//, '')
      I18n.locale = @cms_site.locale
    else
      I18n.locale = I18n.default_locale
      render :text => I18n.t('cms.content.site_not_found'), :status => 404
    end
  end
  
  def load_fixtures
    return unless ComfortableMexicanSofa.config.enable_fixtures
    ComfortableMexicanSofa::Fixtures.import_all(@cms_site.hostname)
  end

  def load_cms_page
    @cms_page = @cms_site.pages.published.find_by_full_path!("/#{params[:cms_path]}")
    return redirect_to(@cms_page.target_page.full_path) if @cms_page.target_page

  rescue ActiveRecord::RecordNotFound
    if @cms_page = @cms_site.pages.published.find_by_full_path('/404')
      render_html(404)
    else
      render :text => I18n.t('cms.content.page_not_found'), :status => 404
    end
  end

  def load_cms_layout
    @cms_layout = @cms_site.layouts.find_by_slug!(params[:layout_slug])
  rescue ActiveRecord::RecordNotFound
    render :nothing => true, :status => 404
  end

end
