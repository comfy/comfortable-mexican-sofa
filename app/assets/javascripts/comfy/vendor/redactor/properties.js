(function($R)
{
    $R.add('plugin', 'properties', {
        modals: {
            'properties':
                '<form action=""> \
                    <div class="form-item"> \
                        <label>Id</label> \
                        <input type="text" name="id"> \
                    </div> \
                    <div class="form-item"> \
                        <label>Class</label> \
                        <input type="text" name="classname"> \
                    </div> \
                </form>'
        },
        translations: {
    		en: {
    			"properties": "Properties"
    		}
        },
        init: function(app)
        {
            this.app = app;
            this.opts = app.opts;
            this.lang = app.lang;
            this.$body = app.$body;
            this.toolbar = app.toolbar;
            this.inspector = app.inspector;
            this.selection = app.selection;

            // local
    		this.labelStyle = {
        		'font-family': 'monospace',
    			'position': 'absolute',
    			'padding': '2px 5px',
    			'line-height': 1,
    			'border-radius': '3px',
    			'font-size': '11px',
    			'color': 'rgba(255, 255, 255, .9)'
    		};
        },
        // messages
        onmodal: {
            properties: {
                open: function($modal, $form)
                {
                    if (this.$block)
                    {
                        var blockData = this._getData(this.$block);
                        $form.setData(blockData);
                    }
                },
                opened: function($modal, $form)
                {
                    $form.getField('id').focus();
                },
                save: function($modal, $form)
                {
                    var data = $form.getData();
                    this._save(data);
                }
            }
        },
        onbutton: {
            properties: {
                observe: function(button)
                {
                    this._observeButton(button);
                }
            }
        },

        // public
        start: function()
        {
            var data = {
                title: this.lang.get('properties'),
                api: 'plugin.properties.open',
                observe: 'properties'
            };

            var $button = this.toolbar.addButton('properties', data);
            $button.setIcon('<i class="re-icon-properties"></i>');

            this._createLabel();
        },
        stop: function()
        {
            this._removeLabel();
        },
        open: function()
		{
           var block = this.selection.getBlock();
           if (!block) return;

           this.$block = $R.dom(block);

           var options = {
                title: this.lang.get('properties'),
                width: '500px',
                name: 'properties',
                handle: 'save',
                commands: {
                    save: { title: this.lang.get('save') },
                    cancel: { title: this.lang.get('cancel') }
                }
            };

            this.app.api('module.modal.build', options);
		},

		// private
		_save: function(data)
		{
    		this.app.api('module.modal.close');

    		if (data.id === '') this.$block.removeAttr('id');
    		else this.$block.attr('id', data.id);

    		if (data.classname === '') this.$block.removeAttr('class');
    		else this.$block.attr('class', data.classname);
		},
		_getData: function(block)
		{
    	    var $block = $R.dom(block);
    	    var data = {
        	    id: $block.attr('id'),
        	    classname: $block.attr('class')
    	    };

    	    return data;
		},
		_showData: function(block, data)
		{
    		var str = '';
    		if (data.id) str += '#' + data.id + ' ';
    		if (data.classname) str += '.' + data.classname;


            if (str !== '')
            {
                var $block = $R.dom(block);
                var pos = $block.offset();

                this.$label.css({
                    top: (pos.top - 12) + 'px',
                    left: pos.left + 'px',
                    'z-index': (this.opts.zindex) ? (this.opts.zindex + 3) : 'auto'
                });
                this.$label.html(str);
                this.$label.show();
            }
            else
            {
                this.$label.hide();
            }
		},
		_createLabel: function()
		{
            this.$label = $R.dom('<span />');
            this.$label.hide();
			this.$label.css(this.labelStyle).css('background', 'rgba(229, 57, 143, .7)');

			this.$body.append(this.$label);
		},
		_removeLabel: function()
		{
            if (this.$label) this.$label.remove();
		},
		_observeButton: function(button)
		{
    		var block = this.selection.getBlock();
    		var data = this.inspector.parse(block);

    		if (block && !data.isComponent())
    		{
        		var blockData = this._getData(block);

                this._showData(block, blockData);
        	    button.enable();
    		}
    		else
    		{
        	    button.disable();
        	    if (this.$label) this.$label.hide();
    		}
		}
    });
})(Redactor);