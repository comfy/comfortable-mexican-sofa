if (!RedactorPlugins) var RedactorPlugins = {};

(function($)
{
	RedactorPlugins.comfyImagemanager = function()
	{
		return {
			init: function()
			{
				var button = this.button.add('comfy-imagemanager', 'Insert Image');
				this.button.addCallback(button, this.comfyImagemanager.show);
			},
			show: function()
			{
				window.CMS.filesLibrary.open({ mode: 'select', type: 'image', onSelect: this.comfyImagemanager.insert });
			},
			insert: function(file, options)
			{
				this.image.insert('<img src="' + file.fileUrl + '" alt="' + file.fileLabel + '">');
			}
		};
	};
})(jQuery);
