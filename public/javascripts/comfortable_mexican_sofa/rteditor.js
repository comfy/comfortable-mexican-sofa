$.CMS.RTEditor = function(){
  $(document).ready(function() {
    $.CMS.RTEditor.init();
  });
  
  return {
    init: function() {
  		$('textarea.richText').tinymce({
  			// General options
  			theme : "advanced",
  			// Plugins
  			plugins: "",
  			// Theme options
  			theme_advanced_buttons1 : "bold,italic,underline,strikethrough,|,justifyleft,justifycenter,justifyright,justifyfull,|,cut,copy,paste,pastetext,pasteword,|,bullist,numlist,|,outdent,indent,blockquote,|,undo,redo,|,link,unlink,anchor,image,code",
  			theme_advanced_buttons2 : "",
  			theme_advanced_buttons3 : "",
  			theme_advanced_buttons4 : "",
  			theme_advanced_toolbar_location : "top",
  			theme_advanced_toolbar_align : "left",
  			theme_advanced_statusbar_location : "bottom",
  			theme_advanced_resizing : true,
  	  })
  	}
  }
}();
