class Admin::Cms::UsersController < Admin::Cms::BaseController
  load_and_authorize_resource class: "Cms::User"

  skip_before_filter :load_fixtures

  def index; end
  def new; end
  def edit; end

  def create
    @user.save!
    redirect_to admin_cms_users_path, success: I18n.t('cms.users.created')
  rescue ActiveRecord::RecordInvalid
    logger.detailed_error($!)
    flash.now[:error] = I18n.t('cms.users.creation_failure')
    render action: 'new'
  end

  def update
    # Don't update the password
    params[:user].delete("password") if params[:user][:password].blank?

    @user.update user_params
    redirect_to admin_cms_users_path, success: I18n.t('cms.users.updated')
  rescue ActiveRecord::RecordInvalid
    logger.detailed_error($!)
    flash.now[:error] = I18n.t('cms.users.update_failure')
    render action: 'edit'
  end

  def destroy
    @user.destroy!
    flash[:success] = I18n.t('cms.users.deleted')
    redirect_to admin_cms_users_path
  end

  private

  def user_params
    if current_admin_cms_user && current_admin_cms_user.super_admin?
      params.require(:user).permit(:email, :password, :site_tokens, :super_admin)
    else
      params.require(:user).permit(:email, :password)
    end
  end

end
