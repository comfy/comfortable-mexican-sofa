class FileSweeper < ActionController::Caching::Sweeper
  observe Cms::File

  def expire(file)
    expire_fragment('all_uploaded_files_' + file.site.id.to_s)
  end

  alias_method :after_create, :expire
  alias_method :after_update, :expire
  alias_method :after_destroy, :expire
end
