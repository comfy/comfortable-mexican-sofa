# Set a custom mime type to identify requests from plupload.
#
#   respond_to do |format|
#     format.plupload { render :nothing => true, :status => :created }
#   end

unless Mime::Type.lookup_by_extension(:plupload)
  Mime::Type.register 'text/plupload', :plupload
end
