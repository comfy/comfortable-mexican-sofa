(function($R)
{
    $R.add('plugin', 'filemanager', {
        translations: {
    		en: {
    			"choose": "Choose"
    		}
        },
        init: function(app)
        {
            this.app = app;
            this.lang = app.lang;
            this.opts = app.opts;
        },
        // messages
         onmodal: {
            file: {
                open: function($modal, $form)
                {
                    if (!this.opts.fileManagerJson) return;
                    this._load($modal)
                }
            }
        },

		// private
		_load: function($modal)
		{
			var $body = $modal.getBody();

			this.$box = $R.dom('<div>');
			this.$box.attr('data-title', this.lang.get('choose'));
			this.$box.addClass('redactor-modal-tab');
			this.$box.hide();
			this.$box.css({
    			overflow: 'auto',
    			height: '300px',
    			'line-height': 1
			});

			$body.append(this.$box);

			$R.ajax.get({
        		url: this.opts.fileManagerJson,
        		success: this._parse.bind(this)
    		});
		},
		_parse: function(data)
		{
            var $ul = $R.dom('<ul id="redactor-filemanager-list">');
            for (var key in data)
            {
                var obj = data[key];
                if (typeof obj !== 'object') continue;

                var $li = $R.dom('<li>');
                var $item = $R.dom('<a>');
                $item.attr('href', '#');
                $item.addClass('redactor-file-manager-link');
                $item.attr('data-params', encodeURI(JSON.stringify(obj)));
                $item.text(obj.title || obj.name);
				$item.on('click', this._insert.bind(this));

                var $name = $R.dom('<span>');
                $name.addClass('r-file-name');
                $name.text(obj.name);
                $item.append($name);

                var $size = $R.dom('<span>');
                $size.addClass('r-file-size');
                $size.text('(' + obj.size + ')');
                $item.append($size);

				$li.append($item);
				$ul.append($li);
            }

            this.$box.append($ul);
		},
		_insert: function(e)
		{
			e.preventDefault();

			var $el = $R.dom(e.target).closest('.redactor-file-manager-link');
			var data = JSON.parse(decodeURI($el.attr('data-params')));

			this.app.api('module.file.insert', { file: data });
		}
    });
})(Redactor);