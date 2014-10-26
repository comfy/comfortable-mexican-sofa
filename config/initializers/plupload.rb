# Set a custom mime type to identify reuests from plupload.
#
#   respond_to do |format|
#     format.plupload { render nothing: true, status: :created }
#   end

Mime::Type.register 'text/plupload', :plupload unless Mime::Type.lookup_by_extension(:plupload)
