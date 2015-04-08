class Comfy::Admin::Cms::TranslationsController < Comfy::Admin::Cms::BaseController
  before_action :load_translateable
  before_action :build_translation,    :only => [:new, :create]
  before_action :load_translation,     :only => [:edit, :update, :destroy]
  before_action :preview_translation,  :only => [:create, :update]
  before_action :build_file,           :only => [:new, :edit]

  def new
    render
  end

  def edit
    render
  end

  def create
    @translation.save!
    flash[:success] = I18n.t('comfy.admin.cms.translations.created')
    redirect_to :action => :edit, :id => @translation
  rescue ActiveRecord::RecordInvalid
    flash.now[:danger] = I18n.t('comfy.admin.cms.translations.creation_failure')
    render :action => :new
  end

  def update
    @translation.save!
    flash[:success] = I18n.t('comfy.admin.cms.translations.updated')
    redirect_to :action => :edit, :id => @translation
  rescue ActiveRecord::RecordInvalid
    flash.now[:danger] = I18n.t('comfy.admin.cms.translations.update_failure')
    render :action => :edit
  end

  def destroy
    @translation.destroy
    flash[:success] = I18n.t('comfy.admin.cms.translations.deleted')
    redirect_to_translateable
  end

  protected
    def load_translateable
      @translateable = if params[:layout_id]
        ::Comfy::Cms::Layout.find(params[:layout_id])
      elsif params[:page_id]
        ::Comfy::Cms::Page.find(params[:page_id])
      elsif params[:snippet_id]
        ::Comfy::Cms::Snippet.find(params[:snippet_id])
      end
    rescue ActiveRecord::RecordNotFound
      flash[:danger] = I18n.t('comfy.admin.cms.translations.not_found')
      redirect_to comfy_admin_cms_path
    end

    def build_translation
      @translation = @translateable.translations.new(translation_params)
    end

    def load_translation
      @translation = @translateable.translations.find(params[:id])
      @translation.attributes = translation_params
    rescue ActiveRecord::RecordNotFound
      flash[:danger] = I18n.t('comfy.admin.cms.translations.not_found')
      redirect_to_translateable
    end

    def build_file
      @file = Comfy::Cms::File.new
    end

    def preview_translation
      if params[:preview]
        layout = @translation.layout.app_layout.blank? ? false : @translation.layout.app_layout
        @cms_site   = @translation.site
        @cms_layout = @translation.layout
        @cms_page   = @translation

        # Chrome chokes on content with iframes. Issue #434
        response.headers['X-XSS-Protection'] = '0'

        render :inline => @translation.render, :layout => layout, :content_type => 'text/html'
      end
    end

    def redirect_to_translateable
      redirect_to case @translateable
        when ::Comfy::Cms::Page    then edit_comfy_admin_cms_site_page_path(@site, @translateable)
        # when ::Comfy::Cms::Layout  then edit_comfy_admin_cms_site_layout_path(@site, @translateable)
        # when ::Comfy::Cms::Snippet then edit_comfy_admin_cms_site_snippet_path(@site, @translateable)
      end
    end

    def translation_params
      params.fetch(:translation, {}).permit!
    end

end
