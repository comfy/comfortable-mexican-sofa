# Internal: Authenticate with Devise. Remember this provides /no/
# authorization. It allows any registered user to sign in to the admin
# panel.
module ComfortableMexicanSofa::DeviseAuth

  def authenticate
    unless current_cms_admin_user
      redirect_to new_cms_admin_user_session_path
    end
  end

end
