# Internal: Authenticate with Devise. Remember this provides /no/
# authorization. It allows any registered user to sign in to the admin
# panel.
module ComfortableMexicanSofa::DeviseAuth

  def authenticate
    unless current_admin_cms_user
      redirect_to new_admin_cms_user_session_path
    end
  end

end
