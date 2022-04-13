(function($R)
{
    $R.add('plugin', 'handle', {
        init: function(app)
        {
            this.app = app;
            this.opts = app.opts;
            this.$doc = app.$doc;
            this.$body = app.$body;
            this.editor = app.editor;
            this.marker = app.marker;
            this.keycodes = app.keycodes;
            this.container = app.container;
            this.selection = app.selection;

            // local
            this.handleTrigger = (typeof this.opts.handleTrigger !== 'undefined') ? this.opts.handleTrigger : '@';
            this.handleStart = (typeof this.opts.handleStart !== 'undefined') ? this.opts.handleStart : 0;
            this.handleStr = '';
            this.handleLen = this.handleStart;
        },
        // public
        start: function()
        {
            if (!this.opts.handle) return;

            var $editor = this.editor.getElement();
			$editor.on('keyup.redactor-plugin-handle', this._handle.bind(this));
		},
		stop: function()
		{
            var $editor = this.editor.getElement();

			$editor.off('.redactor-plugin-handle');
            this.$doc.off('.redactor-plugin-handle');

            var $list = $R.dom('#redactor-handle-list');
            $list.remove();
		},

		// private
		_handle: function(e)
		{
    		var key = e.which;
			var ctrl = e.ctrlKey || e.metaKey;
			var arrows = [37, 38, 39, 40];

            if (key === this.keycodes.BACKSPACE)
            {
                if (this._isShown() && (this.handleLen > this.handleStart))
                {
                    this.handleLen = this.handleLen - 2;
                    if (this.handleLen <= this.handleStart)
                    {
                        this._hide();
                    }
                }
                else
                {
                    return;
                }
            }

			if (key === this.keycodes.DELETE
			    || key === this.keycodes.ESC
			    || key === this.keycodes.SHIFT
			    || ctrl
			    || (arrows.indexOf(key) !== -1)
			)
			{
				return;
			}

            var re = new RegExp('^' + this.handleTrigger);
            this.handleStr = this.selection.getTextBeforeCaret(this.handleLen + 1);

            // detect
            if (re.test(this.handleStr))
            {
                this.handleStr = this.handleStr.replace(this.handleTrigger, '');
                this.handleLen++;

                this._load();
            }
		},
		_load: function()
		{
    		$R.ajax.post({
        		url: this.opts.handle,
        		data: 'handle=' + this.handleStr,
        		success: this._parse.bind(this)
    		});
		},
		_parse: function(json)
		{
    		if (json === '') return;

            var data = (typeof json === 'object') ? json : JSON.parse(json);

            this._build();
            this._buildData(data);
		},
		_build: function()
		{
            this.$list = $R.dom('#redactor-handle-list');
            if (this.$list.length === 0)
            {
                this.$list = $R.dom('<div id="redactor-handle-list">');
                this.$body.append(this.$list);
            }
        },
        _buildData: function(data)
        {
            this.data = data;

            this._update();
            this._show();
        },
        _update: function()
        {
            this.$list.html('');

            for (var key in this.data)
            {
                var $item = $R.dom('<a href="#">');
                $item.html(this.data[key].item);
                $item.attr('data-key', key);
                $item.on('click', this._replace.bind(this));

                this.$list.append($item);
            }

            // position
    		var $container = this.container.getElement();
            var containerOffset = $container.offset();
            var pos = this.selection.getPosition();

            this.$list.css({
                top: (pos.top + pos.height + this.$doc.scrollTop()) + 'px',
                left: pos.left + 'px'
            });
        },
        _isShown: function()
        {
            return (this.$list && this.$list.hasClass('open'));
        },
        _show: function()
        {
            this.$list.addClass('open');
            this.$list.show();

            this.$doc.off('.redactor-plugin-handle');
            this.$doc.on('click.redactor-plugin-handle keydown.redactor-plugin-handle', this._hide.bind(this));
        },
        _hide: function(e)
        {
            var hidable = false;
            var key = (e && e.which);

            if (!e) hidable = true;
            else if (e.type === 'click' || key === this.keycodes.ESC || key === this.keycodes.ENTER || key === this.keycodes.SPACE) hidable = true;

            if (hidable)
            {
                this.$list.removeClass('open');
                this.$list.hide();
                this._reset();
            }
        },
        _reset: function()
        {
            this.handleStr = '';
            this.handleLen = this.handleStart;
        },
		_replace: function(e)
		{
    		e.preventDefault();

    		var $item = $R.dom(e.target);
    		var key = $item.attr('data-key');
    		var replacement = this.data[key].replacement;

    		var marker = this.marker.insert('start');
    		var $marker = $R.dom(marker);
            var current = marker.previousSibling;
            var currentText = current.textContent;
            var re = new RegExp('@' + this.handleStr + '$');

        	currentText = currentText.replace(re, '');
        	current.textContent = currentText;

            $marker.before(replacement);

 			this.selection.restoreMarkers();

            return;
		}
    });
})(Redactor);