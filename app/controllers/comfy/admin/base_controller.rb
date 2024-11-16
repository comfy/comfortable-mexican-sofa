# frozen_string_literal: true

class Comfy::Admin::BaseController < ComfortableMediaSurfer.config.admin_base_controller.to_s.constantize
  include Comfy::Paginate

  # Authentication module must have `authenticate` method
  include ComfortableMediaSurfer.config.admin_auth.to_s.constantize

  # Authorization module must have `authorize` method
  include ComfortableMediaSurfer.config.admin_authorization.to_s.constantize

  helper Comfy::Admin::CmsHelper
  helper Comfy::CmsHelper

  protect_from_forgery with: :exception

  before_action :authenticate

  layout 'comfy/admin/cms'
end
