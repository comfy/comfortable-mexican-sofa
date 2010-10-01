$.CMS.Uploader = function(){
  $(document).ready(function() {
    if($('#upload_container').get(0)) $.CMS.Uploader.init();
  });
  
  return {
    init: function() {
      auth_token = $("meta[name=csrf-token]").attr('content');
      var uploader = new plupload.Uploader({
        container: 'upload_container',
        browse_button: 'pickfiles',
      	runtimes: 'html5,html4',
      	unique_names: true, 
      	multipart: true,  
        multipart_params: { authenticity_token: auth_token, format: 'js' },
      	url: '/cms-admin/uploads'
      });

    	uploader.init();

    	uploader.bind('FilesAdded', function(up, files) {
    		$.each(files, function(i, file) {
    			$('#filelist').append('<div id="' + file.id + '">' + file.name + ' (' + plupload.formatSize(file.size) + ')<div class="progressbar"></div></div>');
    			$( "#"+file.id+' .progressbar' ).progressbar();
    		});
    		uploader.start();
    	});

    	uploader.bind('UploadProgress', function(up, file) {
    	  $( "#"+file.id+' .progressbar' ).progressbar({ value: file.percent });
    	});

    	uploader.bind('Error', function(up, err) {
    	  alert(err.file.name+": "+err.message)
    	});
    	
    	uploader.bind('FileUploaded', function(up, file, response){
    	  $('#uploads_list').append(response.response);
    	  $('#'+file.id).fadeOut(4000, function() {
          $('#'+file.id).remove();
    	  });
    	})
  	}
  }
}();
