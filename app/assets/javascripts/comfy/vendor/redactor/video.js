(function($R)
{
    $R.add('plugin', 'video', {
        translations: {
            en: {
                "video": "Video",
                "video-html-code": "Video Embed Code or Youtube/Vimeo Link"
            }
        },
        modals: {
            'video':
                '<form action=""> \
                    <div class="form-item"> \
                        <label for="modal-video-input">## video-html-code ##</label> \
                        <textarea id="modal-video-input" name="video" style="height: 160px;"></textarea> \
                    </div> \
                </form>'
        },
        init: function(app)
        {
            this.app = app;
            this.lang = app.lang;
            this.opts = app.opts;
            this.toolbar = app.toolbar;
            this.component = app.component;
            this.insertion = app.insertion;
            this.inspector = app.inspector;
        },
        // messages
        onmodal: {
            video: {
                opened: function($modal, $form)
                {
                    $form.getField('video').focus();
                },
                insert: function($modal, $form)
                {
                    var data = $form.getData();
                    this._insert(data);
                }
            }
        },
        oncontextbar: function(e, contextbar)
        {
            var data = this.inspector.parse(e.target)
            if (data.isComponentType('video'))
            {
                var node = data.getComponent();
                var buttons = {
                    "remove": {
                        title: this.lang.get('delete'),
                        api: 'plugin.video.remove',
                        args: node
                    }
                };

                contextbar.set(e, node, buttons, 'bottom');
            }

        },

        // public
        start: function()
        {
            var obj = {
                title: this.lang.get('video'),
                api: 'plugin.video.open'
            };

            var $button = this.toolbar.addButtonAfter('image', 'video', obj);
            $button.setIcon('<i class="re-icon-video"></i>');
        },
        open: function()
		{
            var options = {
                title: this.lang.get('video'),
                width: '600px',
                name: 'video',
                handle: 'insert',
                commands: {
                    insert: { title: this.lang.get('insert') },
                    cancel: { title: this.lang.get('cancel') }
                }
            };

            this.app.api('module.modal.build', options);
		},
        remove: function(node)
        {
            this.component.remove(node);
        },

        // private
		_insert: function(data)
		{
    		this.app.api('module.modal.close');

    		if (data.video.trim() === '')
    		{
        	    return;
    		}

            // parsing
            data.video = this._matchData(data.video);

            // inserting
            if (this._isVideoIframe(data.video))
            {
                var $video = this.component.create('video', data.video);
                this.insertion.insertHtml($video);
            }
		},

		_isVideoIframe: function(data)
		{
            return (data.match(/<iframe|<video/gi) !== null);
		},
		_matchData: function(data)
		{
			var iframeStart = '<iframe style="width: 500px; height: 281px;" src="';
			var iframeEnd = '" frameborder="0" allowfullscreen></iframe>';

            if (this._isVideoIframe(data))
			{
				var allowed = ['iframe', 'video', 'source'];
				var tags = /<\/?([a-z][a-z0-9]*)\b[^>]*>/gi;

                data = data.replace(/<p(.*?[^>]?)>([\w\W]*?)<\/p>/gi, '');
			    data = data.replace(tags, function ($0, $1)
			    {
			        return (allowed.indexOf($1.toLowerCase()) === -1) ? '' : $0;
			    });
			}
            else
            {
    			if (data.match(this.opts.regex.youtube))
    			{
    				data = data.replace(this.opts.regex.youtube, iframeStart + '//www.youtube.com/embed/$1' + iframeEnd);
    			}
    			else if (data.match(this.opts.regex.vimeo))
    			{

    				data = data.replace(this.opts.regex.vimeo, iframeStart + '//player.vimeo.com/video/$2' + iframeEnd);
    			}
			}


			return data;
		}
    });
})(Redactor);