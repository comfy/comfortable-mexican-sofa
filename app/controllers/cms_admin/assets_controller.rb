class CmsAdmin::AssetsController < CmsAdmin::BaseController
  before_filter :load_cms_asset,
    :only => :destroy
  
  def index
    render :update do |page|
      page << "$('#assets_list').html(\"#{ escape_javascript(render(:partial => 'cms_admin/assets/index')) }\")"
    end
  end
  
  def create
    @cms_asset = CmsAsset.create!(:uploaded_file => params[:file])
    render :nothing => true
  end
  
  def destroy
    @cms_asset.destroy
    render :update do |page|
      page << "$('##{dom_id(@cms_asset)}').fadeOut('slow')"
    end
  end

protected
  def load_cms_asset
    @cms_asset = CmsAsset.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render :nothing => true
  end
end
