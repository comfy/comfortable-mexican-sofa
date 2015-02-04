if (!RedactorPlugins) var RedactorPlugins = {};

(function($)
{
  RedactorPlugins.comfyFilemanager = function()
  {
    return {
      init: function()
      {
        var button = this.button.add('comfy-filemanager', 'Insert File');
        this.button.addCallback(button, this.comfyFilemanager.show);
      },
      show: function()
      {
        window.CMS.filesLibrary.open({ mode: 'select', onSelect: this.comfyFilemanager.insert });
      },
      insert: function(file, options)
      {
        this.file.insert('<a href="' + file.fileUrl + '">' + file.fileLabel + '</a>');
      }
    };
  };
})(jQuery);
