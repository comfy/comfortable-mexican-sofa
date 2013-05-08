class CmsAdmin::UsersController < CmsAdmin::BaseController
  load_and_authorize_resource class: "Cms::User", except: :create

  skip_before_filter  :load_admin_site,
                      :load_fixtures

  def index; end
  def new; end
  def edit; end

  def create
    @user = Cms::User.new params[:user], as: :admin
    @user.save!
    flash[:success] = I18n.t('cms.users.created')
    redirect_to cms_admin_users_path
  rescue ActiveRecord::RecordInvalid
    logger.detailed_error($!)
    flash.now[:error] = I18n.t('cms.users.creation_failure')
    render :action => :new
  end

  def update
    # Don't update the password
    params[:user].delete("password") if params[:user][:password].blank?

    @user.update_attributes!(params[:user], as: :admin)
    flash[:success] = I18n.t('cms.users.updated')
    redirect_to :action => :edit, :id => @user
  rescue ActiveRecord::RecordInvalid
    logger.detailed_error($!)
    flash.now[:error] = I18n.t('cms.users.update_failure')
    render :action => :edit
  end

end
