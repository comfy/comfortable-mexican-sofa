/*
    Redactor
    Version 3.1.8
    Updated: April 3, 2019

    http://imperavi.com/redactor/

    Copyright (c) 2009-2019, Imperavi Ltd.
    License: http://imperavi.com/redactor/license/
*/
(function() {
var Ajax = {};

Ajax.settings = {};
Ajax.post = function(options) { return new AjaxRequest('post', options); };
Ajax.get = function(options) { return new AjaxRequest('get', options); };

var AjaxRequest = function(method, options)
{
    var defaults = {
        method: method,
        url: '',
        before: function() {},
        success: function() {},
        error: function() {},
        data: false,
        async: true,
        headers: {}
    };

    this.p = this.extend(defaults, options);
    this.p = this.extend(this.p, Ajax.settings);
    this.p.method = this.p.method.toUpperCase();

    this.prepareData();

    this.xhr = new XMLHttpRequest();
    this.xhr.open(this.p.method, this.p.url, this.p.async);

    this.setHeaders();

    var before = (typeof this.p.before === 'function') ? this.p.before(this.xhr) : true;
    if (before !== false)
    {
        this.send();
    }
};

AjaxRequest.prototype = {
    extend: function(obj1, obj2)
    {
        if (obj2) for (var name in obj2) { obj1[name] = obj2[name]; }
        return obj1;
    },
    prepareData: function()
    {
        if (this.p.method === 'POST' && !this.isFormData()) this.p.headers['Content-Type'] = 'application/x-www-form-urlencoded';
        if (typeof this.p.data === 'object' && !this.isFormData()) this.p.data = this.toParams(this.p.data);
        if (this.p.method === 'GET') this.p.url = (this.p.data) ? this.p.url + '?' + this.p.data : this.p.url;
    },
    setHeaders: function()
    {
        this.xhr.setRequestHeader('X-Requested-With', this.p.headers['X-Requested-With'] || 'XMLHttpRequest');
        for (var name in this.p.headers)
        {
            this.xhr.setRequestHeader(name, this.p.headers[name]);
        }
    },
    isFormData: function()
    {
        return (typeof window.FormData !== 'undefined' && this.p.data instanceof window.FormData);
    },
    isComplete: function()
    {
        return !(this.xhr.status < 200 || this.xhr.status >= 300 && this.xhr.status !== 304);
    },
    send: function()
    {
        if (this.p.async)
        {
            this.xhr.onload = this.loaded.bind(this);
            this.xhr.send(this.p.data);
        }
        else
        {
            this.xhr.send(this.p.data);
            this.loaded.call(this);
        }
    },
    loaded: function()
    {
        if (this.isComplete())
        {
            var response = this.xhr.response;
            var json = this.parseJson(response);
            response = (json) ? json : response;

            if (typeof this.p.success === 'function') this.p.success(response, this.xhr);
        }
        else
        {
            if (typeof this.p.error === 'function') this.p.error(this.xhr.statusText);
        }
    },
    parseJson: function(str)
    {
        try {
            var o = JSON.parse(str);
            if (o && typeof o === 'object')
            {
                return o;
            }

        } catch (e) {}

        return false;
    },
    toParams: function (obj)
    {
        return Object.keys(obj).map(
            function(k){ return encodeURIComponent(k) + '=' + encodeURIComponent(obj[k]); }
        ).join('&');
    }
};
var DomCache = [0];
var DomExpando = 'data' + new Date().getTime();
var DomHClass = 'is-hidden';
var DomHMClass = 'is-hidden-mobile';

var Dom = function(selector, context)
{
    return this.parse(selector, context);
};

Dom.ready = function(fn)
{
    if (document.readyState != 'loading') fn();
    else document.addEventListener('DOMContentLoaded', fn);
};

Dom.prototype = {
    get dom()
    {
        return true;
    },
    get length()
    {
        return this.nodes.length;
    },
    parse: function(selector, context)
    {
        var nodes;
        var reHtmlTest = /^\s*<(\w+|!)[^>]*>/;

        if (!selector)
        {
            nodes = [];
        }
        else if (selector.dom)
        {
            this.nodes = selector.nodes;
            return selector;
        }
        else if (typeof selector !== 'string')
        {
            if (selector.nodeType && selector.nodeType === 11)
            {
                nodes = selector.childNodes;
            }
            else
            {
                nodes = (selector.nodeType || selector === window) ? [selector] : selector;
            }
        }
        else if (reHtmlTest.test(selector))
        {
            nodes = this.create(selector);
        }
        else
        {
            nodes = this._query(selector, context);
        }

        this.nodes = this._slice(nodes);
    },
    create: function(html)
    {
        if (/^<(\w+)\s*\/?>(?:<\/\1>|)$/.test(html))
        {
            return [document.createElement(RegExp.$1)];
        }

        var elements = [];
        var container = document.createElement('div');
        var children = container.childNodes;

        container.innerHTML = html;

        for (var i = 0, l = children.length; i < l; i++)
        {
            elements.push(children[i]);
        }

        return elements;
    },

    // add
    add: function(nodes)
    {
        this.nodes = this.nodes.concat(this._toArray(nodes));
    },

    // get
    get: function(index)
    {
        return this.nodes[(index || 0)] || false;
    },
    getAll: function()
    {
        return this.nodes;
    },
    eq: function(index)
    {
        return new Dom(this.nodes[index]);
    },
    first: function()
    {
        return new Dom(this.nodes[0]);
    },
    last: function()
    {
        return new Dom(this.nodes[this.nodes.length - 1]);
    },
    contents: function()
    {
        return this.get().childNodes;
    },

    // loop
    each: function(callback)
    {
        var len = this.nodes.length;
        for (var i = 0; i < len; i++)
        {
            callback.call(this, (this.nodes[i].dom) ? this.nodes[i].get() : this.nodes[i], i);
        }

        return this;
    },

    // traversing
    is: function(selector)
    {
        return (this.filter(selector).length > 0);
    },
    filter: function (selector)
    {
        var callback;
        if (selector === undefined)
        {
            return this;
        }
        else if (typeof selector === 'function')
        {
            callback = selector;
        }
        else
        {
            callback = function(node)
            {
                if (selector instanceof Node)
                {
                    return (selector === node);
                }
                else if (selector && selector.dom)
                {
                    return ((selector.nodes).indexOf(node) !== -1);
                }
                else
                {
                    node.matches = node.matches || node.msMatchesSelector || node.webkitMatchesSelector;
                    return (node.nodeType === 1) ? node.matches(selector || '*') : false;
                }
            };
        }

        return new Dom(this.nodes.filter(callback));
    },
    not: function(filter)
    {
        return this.filter(function(node)
        {
            return !new Dom(node).is(filter || true);
        });
    },
    find: function(selector)
    {
        var nodes = [];
        this.each(function(node)
        {
            var ns = this._query(selector || '*', node);
            for (var i = 0; i < ns.length; i++)
            {
                nodes.push(ns[i]);
            }
        });

        return new Dom(nodes);
    },
    children: function(selector)
    {
        var nodes = [];
        this.each(function(node)
        {
            if (node.children)
            {
                var ns = node.children;
                for (var i = 0; i < ns.length; i++)
                {
                    nodes.push(ns[i]);
                }
            }
        });

        return new Dom(nodes).filter(selector);
    },
    parent: function(selector)
    {
        var nodes = [];
        this.each(function(node)
        {
            if (node.parentNode) nodes.push(node.parentNode);
        });

        return new Dom(nodes).filter(selector);
    },
    parents: function(selector, context)
    {
        context = this._getContext(context);

        var nodes = [];
        this.each(function(node)
        {
            var parent = node.parentNode;
            while (parent && parent !== context)
            {
                if (selector)
                {
                    if (new Dom(parent).is(selector)) { nodes.push(parent); }
                }
                else
                {
                    nodes.push(parent);
                }

                parent = parent.parentNode;
            }
        });

        return new Dom(nodes);
    },
    closest: function(selector, context)
    {
        context = this._getContext(context);
        selector = (selector.dom) ? selector.get() : selector;

        var nodes = [];
        var isNode = (selector && selector.nodeType);
        this.each(function(node)
        {
            do {
                if ((isNode && node === selector) || new Dom(node).is(selector)) return nodes.push(node);
            } while ((node = node.parentNode) && node !== context);
        });

        return new Dom(nodes);
    },
    next: function(selector)
    {
         return this._getSibling(selector, 'nextSibling');
    },
    nextElement: function(selector)
    {
        return this._getSibling(selector, 'nextElementSibling');
    },
    prev: function(selector)
    {
        return this._getSibling(selector, 'previousSibling');
    },
    prevElement: function(selector)
    {
        return this._getSibling(selector, 'previousElementSibling');
    },

    // css
    css: function(name, value)
    {
        if (value === undefined && (typeof name !== 'object'))
        {
            var node = this.get();
            if (name === 'width' || name === 'height')
            {
                return (node.style) ? this._getHeightOrWidth(name, node, false) + 'px' : undefined;
            }
            else
            {
                return (node.style) ? getComputedStyle(node, null)[name] : undefined;
            }
        }

        // set
        return this.each(function(node)
        {
            var obj = {};
            if (typeof name === 'object') obj = name;
            else obj[name] = value;

            for (var key in obj)
            {
                if (node.style) node.style[key] = obj[key];
            }
        });
    },

    // attr
    attr: function(name, value, data)
    {
        data = (data) ? 'data-' : '';

        if (value === undefined && (typeof name !== 'object'))
        {
            var node = this.get();
            if (node && node.nodeType !== 3)
            {
                return (name === 'checked') ? node.checked : this._getBooleanFromStr(node.getAttribute(data + name));
            }
            else return;
        }

        // set
        return this.each(function(node)
        {
            var obj = {};
            if (typeof name === 'object') obj = name;
            else obj[name] = value;

            for (var key in obj)
            {
                if (node.nodeType !== 3)
                {
                    if (key === 'checked') node.checked = obj[key];
                    else node.setAttribute(data + key, obj[key]);
                }
            }
        });
    },
    data: function(name, value)
    {
        if (name === undefined)
        {
            var reDataAttr = /^data\-(.+)$/;
            var attrs = this.get().attributes;

            var data = {};
            var replacer = function (g) { return g[1].toUpperCase(); };

            for (var key in attrs)
            {
                if (attrs[key] && reDataAttr.test(attrs[key].nodeName))
                {
                    var dataName = attrs[key].nodeName.match(reDataAttr)[1];
                    var val = attrs[key].value;
                    dataName = dataName.replace(/-([a-z])/g, replacer);

                    if (this._isObjectString(val)) val = this._toObject(val);
                    else val = (this._isNumber(val)) ? parseFloat(val) : this._getBooleanFromStr(val);

                    data[dataName] = val;
                }
            }

            return data;
        }

        return this.attr(name, value, true);
    },
    val: function(value)
    {
        if (value === undefined)
        {
            var el = this.get();
            if (el.type && el.type === 'checkbox') return el.checked;
            else return el.value;
        }

        return this.each(function(node)
        {
            node.value = value;
        });
    },
    removeAttr: function(value)
    {
        return this.each(function(node)
        {
            var rmAttr = function(name) { if (node.nodeType !== 3) node.removeAttribute(name); };
            value.split(' ').forEach(rmAttr);
        });
    },
    removeData: function(value)
    {
        return this.each(function(node)
        {
            var rmData = function(name) { if (node.nodeType !== 3) node.removeAttribute('data-' + name); };
            value.split(' ').forEach(rmData);
        });
    },

    // dataset/dataget
    dataset: function(key, value)
    {
        return this.each(function(node)
        {
            DomCache[this.dataindex(node)][key] = value;
        });
    },
    dataget: function(key)
    {
        return DomCache[this.dataindex(this.get())][key];
    },
    dataindex: function(el)
    {
        var cacheIndex = el[DomExpando];
        var nextCacheIndex = DomCache.length;

        if (!cacheIndex)
        {
            cacheIndex = el[DomExpando] = nextCacheIndex;
            DomCache[cacheIndex] = {};
        }

        return cacheIndex;
    },


    // class
    addClass: function(value)
    {
        return this._eachClass(value, 'add');
    },
    removeClass: function(value)
    {
        return this._eachClass(value, 'remove');
    },
    toggleClass: function(value)
    {
        return this._eachClass(value, 'toggle');
    },
    hasClass: function(value)
    {
        return this.nodes.some(function(node)
        {
            return (node.classList) ? node.classList.contains(value) : false;
        });
    },

    // html & text
    empty: function()
    {
        return this.each(function(node)
        {
            node.innerHTML = '';
        });
    },
    html: function(html)
    {
        return (html === undefined) ? (this.get().innerHTML || '') : this.empty().append(html);
    },
    text: function(text)
    {
        return (text === undefined) ? (this.get().textContent || '') : this.each(function(node) { node.textContent = text; });
    },

    // manipulation
    after: function(html)
    {
        return this._inject(html, function(frag, node)
        {
            if (typeof frag === 'string')
            {
                node.insertAdjacentHTML('afterend', frag);
            }
            else
            {
                var elms = (frag instanceof Node) ? [frag] : this._toArray(frag).reverse();
                for (var i = 0; i < elms.length; i++)
                {
                    node.parentNode.insertBefore(elms[i], node.nextSibling);
                }
            }

            return node;

        });
    },
    before: function(html)
    {
        return this._inject(html, function(frag, node)
        {
            if (typeof frag === 'string')
            {
                node.insertAdjacentHTML('beforebegin', frag);
            }
            else
            {
                var elms = (frag instanceof Node) ? [frag] : this._toArray(frag);
                for (var i = 0; i < elms.length; i++)
                {
                    node.parentNode.insertBefore(elms[i], node);
                }
            }

            return node;
        });
    },
    append: function(html)
    {
        return this._inject(html, function(frag, node)
        {
            if (typeof frag === 'string' || typeof frag === 'number')
            {
                node.insertAdjacentHTML('beforeend', frag);
            }
            else
            {
                var elms = (frag instanceof Node) ? [frag] : this._toArray(frag);
                for (var i = 0; i < elms.length; i++)
                {
                    node.appendChild(elms[i]);
                }
            }

            return node;
        });
    },
    prepend: function(html)
    {
        return this._inject(html, function(frag, node)
        {
            if (typeof frag === 'string' || typeof frag === 'number')
            {
                node.insertAdjacentHTML('afterbegin', frag);
            }
            else
            {
                var elms = (frag instanceof Node) ? [frag] : this._toArray(frag).reverse();
                for (var i = 0; i < elms.length; i++)
                {
                    node.insertBefore(elms[i], node.firstChild);
                }
            }

            return node;
        });
    },
    wrap: function(html)
    {
        return this._inject(html, function(frag, node)
        {
            var wrapper = (typeof frag === 'string' || typeof frag === 'number') ? this.create(frag)[0] : (frag instanceof Node) ? frag : this._toArray(frag)[0];

            if (node.parentNode)
            {
                node.parentNode.insertBefore(wrapper, node);
            }

            wrapper.appendChild(node);

            return new Dom(wrapper);

        });
    },
    unwrap: function()
    {
        return this.each(function(node)
        {
            var $node = new Dom(node);

            return $node.replaceWith($node.contents());
        });
    },
    replaceWith: function(html)
    {
        return this._inject(html, function(frag, node)
        {
            var docFrag = document.createDocumentFragment();
            var elms = (typeof frag === 'string' || typeof frag === 'number') ? this.create(frag) : (frag instanceof Node) ? [frag] : this._toArray(frag);

            for (var i = 0; i < elms.length; i++)
            {
                docFrag.appendChild(elms[i]);
            }

            var result = docFrag.childNodes[0];
            node.parentNode.replaceChild(docFrag, node);

            return result;

        });
    },
    remove: function()
    {
        return this.each(function(node)
        {
            if (node.parentNode) node.parentNode.removeChild(node);
        });
    },
    clone: function(events)
    {
        var nodes = [];
        this.each(function(node)
        {
            var copy = this._clone(node);
            if (events) copy = this._cloneEvents(node, copy);
            nodes.push(copy);
        });

        return new Dom(nodes);
    },

    // show/hide
    show: function()
    {
        return this.each(function(node)
        {
            if (!node.style || !this._hasDisplayNone(node)) return;

            var target = node.getAttribute('domTargetShow');
            var isHidden = (node.classList) ? node.classList.contains(DomHClass) : false;
            var isHiddenMobile = (node.classList) ? node.classList.contains(DomHMClass) : false;
            var type;

            if (isHidden)
            {
                type = DomHClass;
                node.classList.remove(DomHClass);
            }
            else if (isHiddenMobile)
            {
                type = DomHMClass;
                node.classList.remove(DomHMClass);
            }
            else
            {
                node.style.display = (target) ? target : 'block';
            }

            if (type) node.setAttribute('domTargetHide', type);
            node.removeAttribute('domTargetShow');

        }.bind(this));
    },
    hide: function()
    {
        return this.each(function(node)
        {
            if (!node.style || this._hasDisplayNone(node)) return;

            var display = node.style.display;
            var target = node.getAttribute('domTargetHide');

            if (target === DomHClass)
            {
                node.classList.add(DomHClass);
            }
            else if (target === DomHMClass)
            {
                node.classList.add(DomHMClass);
            }
            else
            {
                if (display !== 'block') node.setAttribute('domTargetShow', display);
                node.style.display = 'none';
            }

            node.removeAttribute('domTargetHide');

        });
    },

    // dimensions
    scrollTop: function(value)
    {
        var node = this.get();
        var isWindow = (node === window);
        var isDocument = (node.nodeType === 9);
        var el = (isDocument) ? (document.scrollingElement || document.body.parentNode || document.body || document.documentElement) : node;

        if (value !== undefined)
        {
            if (isWindow) window.scrollTo(0, value);
            else el.scrollTop = value;
            return;
        }

        if (isDocument)
        {
            return (typeof window.pageYOffset != 'undefined') ? window.pageYOffset : ((document.documentElement.scrollTop) ? document.documentElement.scrollTop : ((document.body.scrollTop) ? document.body.scrollTop : 0));
        }
        else
        {
            return (isWindow) ? window.pageYOffset : el.scrollTop;
        }
    },
    offset: function()
    {
        return this._getDim('Offset');
    },
    position: function()
    {
        return this._getDim('Position');
    },
    width: function(value, adjust)
    {
        return this._getSize('width', 'Width', value, adjust);
    },
    height: function(value, adjust)
    {
        return this._getSize('height', 'Height', value, adjust);
    },
    outerWidth: function()
    {
        return this._getInnerOrOuter('width', 'outer');
    },
    outerHeight: function()
    {
        return this._getInnerOrOuter('height', 'outer');
    },
    innerWidth: function()
    {
        return this._getInnerOrOuter('width', 'inner');
    },
    innerHeight: function()
    {
        return this._getInnerOrOuter('height', 'inner');
    },

    // events
    click: function()
    {
        return this._triggerEvent('click');
    },
    focus: function()
    {
        return this._triggerEvent('focus');
    },
    trigger: function(names)
    {
        return this.each(function(node)
        {
            var events = names.split(' ');
            for (var i = 0; i < events.length; i++)
            {
                var ev;
                var opts = { bubbles: true, cancelable: true };

                try {
                    ev = new window.CustomEvent(events[i], opts);
                } catch(e) {
                    ev = document.createEvent('CustomEvent');
                    ev.initCustomEvent(events[i], true, true);
                }

                node.dispatchEvent(ev);
            }
        });
    },
    on: function(names, handler, one)
    {
        return this.each(function(node)
        {
            var events = names.split(' ');
            for (var i = 0; i < events.length; i++)
            {
                var event = this._getEventName(events[i]);
                var namespace = this._getEventNamespace(events[i]);

                handler = (one) ? this._getOneHandler(handler, names) : handler;
                node.addEventListener(event, handler);

                node._e = node._e || {};
                node._e[namespace] = node._e[namespace] || {};
                node._e[namespace][event] = node._e[namespace][event] || [];
                node._e[namespace][event].push(handler);
            }

        });
    },
    one: function(events, handler)
    {
        return this.on(events, handler, true);
    },
    off: function(names, handler)
    {
        var testEvent = function(name, key, event) { return (name === event); };
        var testNamespace = function(name, key, event, namespace) { return (key === namespace); };
        var testEventNamespace = function(name, key, event, namespace) { return (name === event && key === namespace); };
        var testPositive = function() { return true; };

        if (names === undefined)
        {
            // ALL
            return this.each(function(node)
            {
                this._offEvent(node, false, false, handler, testPositive);
            });
        }

        return this.each(function(node)
        {
            var events = names.split(' ');

            for (var i = 0; i < events.length; i++)
            {
                var event = this._getEventName(events[i]);
                var namespace = this._getEventNamespace(events[i]);

                // 1) event without namespace
                if (namespace === '_events') this._offEvent(node, event, namespace, handler, testEvent);
                // 2) only namespace
                else if (!event && namespace !== '_events') this._offEvent(node, event, namespace, handler, testNamespace);
                // 3) event + namespace
                else this._offEvent(node, event, namespace, handler, testEventNamespace);
            }
        });
    },

    // form
    serialize: function(asObject)
    {
        var obj = {};
        var elms = this.get().elements;
        for (var i = 0; i < elms.length; i++)
        {
            var el = elms[i];
            if (/(checkbox|radio)/.test(el.type) && !el.checked) continue;
            if (!el.name || el.disabled || el.type === 'file') continue;

            if (el.type === 'select-multiple')
            {
                for (var z = 0; z < el.options.length; z++)
                {
                    var opt = el.options[z];
                    if (opt.selected) obj[el.name] = opt.value;
                }
            }

            obj[el.name] = (this._isNumber(el.value)) ? parseFloat(el.value) : this._getBooleanFromStr(el.value);
        }

        return (asObject) ? obj : this._toParams(obj);
    },
    ajax: function(success, error)
    {
        if (typeof AjaxRequest !== 'undefined')
        {
            var method = this.attr('method') || 'post';
            var options = {
                url: this.attr('action'),
                data: this.serialize(),
                success: success,
                error: error
            };

            return new AjaxRequest(method, options);
        }
    },

    // private
    _queryContext: function(selector, context)
    {
        context = this._getContext(context);

        return (context.nodeType !== 3 && typeof context.querySelectorAll === 'function') ? context.querySelectorAll(selector) : [];
    },
    _query: function(selector, context)
    {
        if (context)
        {
            return this._queryContext(selector, context);
        }
        else if (/^[.#]?[\w-]*$/.test(selector))
        {
            if (selector[0] === '#')
            {
                var element = document.getElementById(selector.slice(1));
                return element ? [element] : [];
            }

            if (selector[0] === '.')
            {
                return document.getElementsByClassName(selector.slice(1));
            }

            return document.getElementsByTagName(selector);
        }

        return document.querySelectorAll(selector);
    },
    _getContext: function(context)
    {
        context = (typeof context === 'string') ? document.querySelector(context) : context;

        return (context && context.dom) ? context.get() : (context || document);
    },
    _inject: function(html, fn)
    {
        var len = this.nodes.length;
        var nodes = [];
        while (len--)
        {
            var res = (typeof html === 'function') ? html.call(this, this.nodes[len]) : html;
            var el = (len === 0) ? res : this._clone(res);
            var node = fn.call(this, el, this.nodes[len]);

            if (node)
            {
                if (node.dom) nodes.push(node.get());
                else nodes.push(node);
            }
        }

        return new Dom(nodes);
    },
    _cloneEvents: function(node, copy)
    {
        var events = node._e;
        if (events)
        {
            copy._e = events;
            for (var name in events._events)
            {
                for (var i = 0; i < events._events[name].length; i++)
                {
                    copy.addEventListener(name, events._events[name][i]);
                }
            }
        }

        return copy;
    },
    _clone: function(node)
    {
        if (typeof node === 'undefined') return;
        if (typeof node === 'string') return node;
        else if (node instanceof Node || node.nodeType) return node.cloneNode(true);
        else if ('length' in node)
        {
            return [].map.call(this._toArray(node), function(el) { return el.cloneNode(true); });
        }
    },
    _slice: function(obj)
    {
        return (!obj || obj.length === 0) ? [] : (obj.length) ? [].slice.call(obj.nodes || obj) : [obj];
    },
    _eachClass: function(value, type)
    {
        return this.each(function(node)
        {
            if (value)
            {
                var setClass = function(name) { if (node.classList) node.classList[type](name); };
                value.split(' ').forEach(setClass);
            }
        });
    },
    _triggerEvent: function(name)
    {
        var node = this.get();
        if (node && node.nodeType !== 3) node[name]();
        return this;
    },
    _getOneHandler: function(handler, events)
    {
        var self = this;
        return function()
        {
            handler.apply(this, arguments);
            self.off(events);
        };
    },
    _getEventNamespace: function(event)
    {
        var arr = event.split('.');
        var namespace = (arr[1]) ? arr[1] : '_events';
        return (arr[2]) ? namespace + arr[2] : namespace;
    },
    _getEventName: function(event)
    {
        return event.split('.')[0];
    },
    _offEvent: function(node, event, namespace, handler, condition)
    {
        for (var key in node._e)
        {
            for (var name in node._e[key])
            {
                if (condition(name, key, event, namespace))
                {
                    var handlers = node._e[key][name];
                    for (var i = 0; i < handlers.length; i++)
                    {
                        if (typeof handler !== 'undefined' && handlers[i].toString() !== handler.toString())
                        {
                            continue;
                        }

                        node.removeEventListener(name, handlers[i]);
                        node._e[key][name].splice(i, 1);

                        if (node._e[key][name].length === 0) delete node._e[key][name];
                        if (Object.keys(node._e[key]).length === 0) delete node._e[key];
                    }
                }
            }
        }
    },
    _getInnerOrOuter: function(method, type)
    {
        return this[method](undefined, type);
    },
    _getDocSize: function(node, type)
    {
        var body = node.body, html = node.documentElement;
        return Math.max(body['scroll' + type], body['offset' + type], html['client' + type], html['scroll' + type], html['offset' + type]);
    },
    _getSize: function(type, captype, value, adjust)
    {
        if (value === undefined)
        {
            var el = this.get();
            if (el.nodeType === 3)      value = 0;
            else if (el.nodeType === 9) value = this._getDocSize(el, captype);
            else if (el === window)     value = window['inner' + captype];
            else                        value = this._getHeightOrWidth(type, el, adjust || 'normal');

            return Math.round(value);
        }

        return this.each(function(node)
        {
            value = parseFloat(value);
            value = value + this._adjustResultHeightOrWidth(type, node, adjust || 'normal');

            new Dom(node).css(type, value + 'px');

        }.bind(this));
    },
    _getHeightOrWidth: function(type, el, adjust)
    {
        if (!el) return 0;

        var name = type.charAt(0).toUpperCase() + type.slice(1);
        var result = 0;
        var style = getComputedStyle(el, null);
        var $el = new Dom(el);
        var $targets = $el.parents().filter(function(node)
        {
            return (node.nodeType === 1 && getComputedStyle(node, null).display === 'none') ? node : false;
        });

        if (style.display === 'none') $targets.add(el);
        if ($targets.length !== 0)
        {
            var fixStyle = 'visibility: hidden !important; display: block !important;';
            var tmp = [];

            $targets.each(function(node)
            {
                var $node = new Dom(node);
                var thisStyle = $node.attr('style');
                if (thisStyle !== null) tmp.push(thisStyle);
                $node.attr('style', (thisStyle !== null) ? thisStyle + ';' + fixStyle : fixStyle);
            });

            result = $el.get()['offset' + name] - this._adjustResultHeightOrWidth(type, el, adjust);

            $targets.each(function(node, i)
            {
                var $node = new Dom(node);
                if (tmp[i] === undefined) $node.removeAttr('style');
                else $node.attr('style', tmp[i]);
            });
        }
        else
        {
            result = el['offset' + name] - this._adjustResultHeightOrWidth(type, el, adjust);
        }

        return result;
    },
    _adjustResultHeightOrWidth: function(type, el, adjust)
    {
        if (!el || adjust === false) return 0;

        var fix = 0;
        var style = getComputedStyle(el, null);
        var isBorderBox = (style.boxSizing === "border-box");

        if (type === 'height')
        {
            if (adjust === 'inner' || (adjust === 'normal' && isBorderBox))
            {
                fix += (parseFloat(style.borderTopWidth) || 0) + (parseFloat(style.borderBottomWidth) || 0);
            }

            if (adjust === 'outer') fix -= (parseFloat(style.marginTop) || 0) + (parseFloat(style.marginBottom) || 0);
        }
        else
        {
            if (adjust === 'inner' || (adjust === 'normal' && isBorderBox))
            {
                fix += (parseFloat(style.borderLeftWidth) || 0) + (parseFloat(style.borderRightWidth) || 0);
            }

            if (adjust === 'outer') fix -= (parseFloat(style.marginLeft) || 0) + (parseFloat(style.marginRight) || 0);
        }

        return fix;
    },
    _getDim: function(type)
    {
        var node = this.get();
        return (node.nodeType === 3) ? { top: 0, left: 0 } : this['_get' + type](node);
    },
    _getPosition: function(node)
    {
        return { top: node.offsetTop, left: node.offsetLeft };
    },
    _getOffset: function(node)
    {
        var rect = node.getBoundingClientRect();
        var doc = node.ownerDocument;
		var docElem = doc.documentElement;
		var win = doc.defaultView;

		return {
			top: rect.top + win.pageYOffset - docElem.clientTop,
			left: rect.left + win.pageXOffset - docElem.clientLeft
		};
    },
    _getSibling: function(selector, method)
    {
        selector = (selector && selector.dom) ? selector.get() : selector;

        var isNode = (selector && selector.nodeType);
        var sibling;

        this.each(function(node)
        {
            while (node = node[method])
            {
                if ((isNode && node === selector) || new Dom(node).is(selector))
                {
                    sibling = node;
                    return;
                }
            }
        });

        return new Dom(sibling);
    },
    _toArray: function(obj)
    {
        if (obj instanceof NodeList)
        {
            var arr = [];
            for (var i = 0; i < obj.length; i++)
            {
                arr[i] = obj[i];
            }

            return arr;
        }
        else if (obj === undefined) return [];
        else
        {
            return (obj.dom) ? obj.nodes : obj;
        }
    },
    _toParams: function(obj)
    {
        var params = '';
        for (var key in obj)
        {
            params += '&' + this._encodeUri(key) + '=' + this._encodeUri(obj[key]);
        }

        return params.replace(/^&/, '');
    },
    _toObject: function(str)
    {
        return (new Function("return " + str))();
    },
    _encodeUri: function(str)
    {
        return encodeURIComponent(str).replace(/!/g, '%21').replace(/'/g, '%27').replace(/\(/g, '%28').replace(/\)/g, '%29').replace(/\*/g, '%2A').replace(/%20/g, '+');
    },
    _isNumber: function(str)
    {
        return !isNaN(str) && !isNaN(parseFloat(str));
    },
    _isObjectString: function(str)
    {
        return (str.search(/^{/) !== -1);
    },
    _getBooleanFromStr: function(str)
    {
        if (str === 'true') return true;
        else if (str === 'false') return false;

        return str;
    },
    _hasDisplayNone: function(el)
    {
        return (el.style.display === 'none') || ((el.currentStyle) ? el.currentStyle.display : getComputedStyle(el, null).display) === 'none';
    }
};
// Unique ID
var uuid = 0;

// Wrapper
var $R = function(selector, options)
{
    return RedactorApp(selector, options, [].slice.call(arguments, 2));
};

// Globals
$R.app = [];
$R.version = '3.1.8';
$R.options = {};
$R.modules = {};
$R.services = {};
$R.classes = {};
$R.plugins = {};
$R.mixins = {};
$R.modals = {};
$R.lang = {};
$R.dom = function(selector, context) { return new Dom(selector, context); };
$R.ajax = Ajax;
$R.Dom = Dom;
$R.keycodes = {
	BACKSPACE: 8,
	DELETE: 46,
	UP: 38,
	DOWN: 40,
	ENTER: 13,
	SPACE: 32,
	ESC: 27,
	TAB: 9,
	CTRL: 17,
	META: 91,
	SHIFT: 16,
	ALT: 18,
	RIGHT: 39,
	LEFT: 37
};
$R.env = {
    'plugin': 'plugins',
    'module': 'modules',
    'service': 'services',
    'class': 'classes',
    'mixin': 'mixins'
};

// jQuery Wrapper
/*eslint-env jquery*/
if (typeof jQuery !== 'undefined')
{
    (function($) { $.fn.redactor = function(options) { return RedactorApp(this.toArray(), options, [].slice.call(arguments, 1)); }; })(jQuery);
}

// Class
var RedactorApp = function(selector, options, args)
{
    var namespace = 'redactor';
    var nodes = (Array.isArray(selector)) ? selector : (selector && selector.nodeType) ? [selector] : document.querySelectorAll(selector);
    var isApi = (typeof options === 'string' || typeof options === 'function');
    var value = [];
    var instance;

    for (var i = 0; i < nodes.length; i++)
    {
        var el = nodes[i];
        var $el = $R.dom(el);

        instance = $el.dataget(namespace);
        if (!instance && !isApi)
        {
            // Initialization
            instance = new App(el, options, uuid);
            $el.dataset(namespace, instance);
            $R.app[uuid] = instance;
            uuid++;
        }

        // API
        if (instance && isApi)
        {
            var isDestroy = (options === 'destroy');
            options = (isDestroy) ? 'stop' : options;

            var methodValue;
            if (typeof options === 'function')
            {
                methodValue = options.apply(instance, args);
            }
            else
            {
                args.unshift(options);
                methodValue = instance.api.apply(instance, args);
            }
            if (methodValue !== undefined) value.push(methodValue);

            if (isDestroy) $el.dataset(namespace, false);
        }
    }

    return (value.length === 0 || value.length === 1) ? ((value.length === 0) ? instance : value[0]) : value;
};

// add
$R.add = function(type, name, obj)
{
    if (typeof $R.env[type] === 'undefined') return;

    // translations
    if (obj.translations)
    {
        $R.lang = $R.extend(true, {}, $R.lang, obj.translations);
    }

    // modals
    if (obj.modals)
    {
        $R.modals = $R.extend(true, {}, $R.modals, obj.modals);
    }

    // mixin
    if (type === 'mixin')
    {
        $R[$R.env[type]][name] = obj;
    }
    else
    {
        // prototype
        var F = function() {};
        F.prototype = obj;

        // mixins
        if (obj.mixins)
        {
            for (var i = 0; i < obj.mixins.length; i++)
            {
                $R.inherit(F, $R.mixins[obj.mixins[i]]);
            }
        }

        $R[$R.env[type]][name] = F;
    }
};

// add lang
$R.addLang = function(lang, obj)
{
    if (typeof $R.lang[lang] === 'undefined')
    {
        $R.lang[lang] = {};
    }

    $R.lang[lang] = $R.extend($R.lang[lang], obj);
};

// create
$R.create = function(name)
{
    var arr = name.split('.');
    var args = [].slice.call(arguments, 1);

    var type = 'classes';
    if (typeof $R.env[arr[0]] !== 'undefined')
    {
        type = $R.env[arr[0]];
        name = arr.slice(1).join('.');
    }

    // construct
    var instance = new $R[type][name]();

    // init
    if (instance.init)
    {
        var res = instance.init.apply(instance, args);

        return (res) ? res : instance;
    }

    return instance;
};

// inherit
$R.inherit = function(current, parent)
{
    var F = function () {};
    F.prototype = parent;
    var f = new F();

    for (var prop in current.prototype)
    {
        if (current.prototype.__lookupGetter__(prop)) f.__defineGetter__(prop, current.prototype.__lookupGetter__(prop));
        else f[prop] = current.prototype[prop];
    }

    current.prototype = f;
    current.prototype.super = parent;

    return current;
};

// error
$R.error = function(exception)
{
    throw exception;
};

// extend
$R.extend = function()
{
    var extended = {};
    var deep = false;
    var i = 0;
    var length = arguments.length;

    if (Object.prototype.toString.call( arguments[0] ) === '[object Boolean]')
    {
        deep = arguments[0];
        i++;
    }

    var merge = function(obj)
    {
        for (var prop in obj)
        {
            if (Object.prototype.hasOwnProperty.call(obj, prop))
            {
                if (deep && Object.prototype.toString.call(obj[prop]) === '[object Object]') extended[prop] = $R.extend(true, extended[prop], obj[prop]);
                else extended[prop] = obj[prop];
            }
        }
    };

    for (; i < length; i++ )
    {
        var obj = arguments[i];
        merge(obj);
    }

    return extended;
};
$R.opts = {
    animation: true,
    lang: 'en',
    direction: 'ltr',
    spellcheck: true,
    structure: false,
    scrollTarget: false,
    styles: true,
    stylesClass: 'redactor-styles',
    placeholder: false,

    source: true,
    showSource: false,

    inline: false,

    breakline: false,
    markup: 'p',
    enterKey: true,

    clickToEdit: false,
    clickToSave: false,
    clickToCancel: false,

    focus: false,
    focusEnd: false,

    minHeight: false, // string, '100px'
    maxHeight: false, // string, '100px'
    maxWidth: false, // string, '700px'

    plugins: [], // array
    callbacks: {},

    // pre & tab
    preClass: false, // string
    preSpaces: 4, // or false
    tabindex: false, // int
    tabAsSpaces: false, // true or number of spaces
    tabKey: true,

    // autosave
    autosave: false, // false or url
    autosaveName: false,
    autosaveData: false,

    // toolbar
    toolbar: true,
    toolbarFixed: true,
    toolbarFixedTarget: document,
    toolbarFixedTopOffset: 0, // pixels
    toolbarExternal: false, // ID selector
    toolbarContext: true,

    // air
    air: false,

    // formatting
    formatting: ['p', 'blockquote', 'pre', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6'],
    formattingAdd: false,
    formattingHide: false,

    // buttons
    buttons: ['html', 'format', 'bold', 'italic', 'deleted', 'lists', 'image', 'file', 'link'],
    // + 'line', 'redo', 'undo', 'underline', 'ol', 'ul', 'indent', 'outdent'
    buttonsTextLabeled: false,
    buttonsAdd: [],
    buttonsAddFirst: [],
    buttonsAddAfter: false,
    buttonsAddBefore: false,
    buttonsHide: [],
    buttonsHideOnMobile: [],

    // image
    imageUpload: false,
    imageUploadParam: 'file',
    imageData: false,
    imageEditable: true,
    imageCaption: true,
    imageLink: true,
    imagePosition: false,
    imageResizable: false,
    imageFloatMargin: '10px',
    imageFigure: true,

    // file
    fileUpload: false,
    fileUploadParam: 'file',
    fileData: false,
    fileAttachment: false,

    // upload opts
    uploadData: false,
    dragUpload: true,
    multipleUpload: true,
    clipboardUpload: true,
    uploadBase64: false,

    // link
    linkTarget: false,
    linkTitle: false,
    linkNewTab: false,
    linkNofollow: false,
    linkSize: 30,
    linkValidation: true,

    // clean
    cleanOnEnter: true,
    cleanInlineOnEnter: false,
    paragraphize: true,
    removeScript: true,
    removeNewLines: false,
    removeComments: true,
    replaceTags: {
        'b': 'strong',
        'i': 'em',
        'strike': 'del'
    },

    // paste
    pastePlainText: false,
    pasteLinkTarget: false,
    pasteImages: true,
    pasteLinks: true,
    pasteClean: true,
    pasteKeepStyle: [],
    pasteKeepClass: [],
    pasteKeepAttrs: ['td', 'th'],
    pasteBlockTags: ['pre', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'table', 'tbody', 'thead', 'tfoot', 'th', 'tr', 'td', 'ul', 'ol', 'li', 'blockquote', 'p', 'figure', 'figcaption'],
    pasteInlineTags: ['a', 'img', 'br', 'strong', 'ins', 'code', 'del', 'span', 'samp', 'kbd', 'sup', 'sub', 'mark', 'var', 'cite', 'small', 'b', 'u', 'em', 'i', 'abbr'],

    // active buttons
    activeButtons: {
        b: 'bold',
        strong: 'bold',
        i: 'italic',
        em: 'italic',
        del: 'deleted',
        strike: 'deleted',
        u: 'underline'
    },
    activeButtonsAdd: {},
    activeButtonsObservers: {},

    // autoparser
    autoparse: true,
    autoparseStart: true,
    autoparsePaste: true,
    autoparseLinks: true,
    autoparseImages: true,
    autoparseVideo: true,

    // shortcodes
    shortcodes: {
        'p.': { format: 'p' },
        'quote.': { format: 'blockquote' },
        'pre.': { format: 'pre' },
        'h1.': { format: 'h1' },
        'h2.': { format: 'h2' },
        'h3.': { format: 'h3' },
        'h4.': { format: 'h4' },
        'h5.': { format: 'h5' },
        'h6.': { format: 'h6' },
        //'1.': { format: 'ol' },
        '*.': { format: 'ul' }
    },
    shortcodesAdd: false, // object

    // shortcuts
    shortcuts: {
        'ctrl+shift+m, meta+shift+m': { api: 'module.inline.clearformat' },
        'ctrl+b, meta+b': { api: 'module.inline.format', args: 'b' },
        'ctrl+i, meta+i': { api: 'module.inline.format', args: 'i' },
        'ctrl+u, meta+u': { api: 'module.inline.format', args: 'u' },
        'ctrl+h, meta+h': { api: 'module.inline.format', args: 'sup' },
        'ctrl+l, meta+l': { api: 'module.inline.format', args: 'sub' },
        'ctrl+k, meta+k': { api: 'module.link.open' },
        'ctrl+alt+0, meta+alt+0': { api: 'module.block.format', args: 'p' },
        'ctrl+alt+1, meta+alt+1': { api: 'module.block.format', args: 'h1' },
        'ctrl+alt+2, meta+alt+2': { api: 'module.block.format', args: 'h2' },
        'ctrl+alt+3, meta+alt+3': { api: 'module.block.format', args: 'h3' },
        'ctrl+alt+4, meta+alt+4': { api: 'module.block.format', args: 'h4' },
        'ctrl+alt+5, meta+alt+5': { api: 'module.block.format', args: 'h5' },
        'ctrl+alt+6, meta+alt+6': { api: 'module.block.format', args: 'h6' },
        'ctrl+shift+7, meta+shift+7': { api: 'module.list.toggle', args: 'ol' },
        'ctrl+shift+8, meta+shift+8': { api: 'module.list.toggle', args: 'ul' }
    },
    shortcutsAdd: false, // object

    // misc
    grammarly: true,
    notranslate: false,

    // private
    bufferLimit: 100,
    emptyHtml: '<p></p>',
    markerChar: '\ufeff',
    imageTypes: ['image/png', 'image/jpeg', 'image/gif'],
    inlineTags: ['a', 'span', 'strong', 'strike', 'b', 'u', 'em', 'i', 'code', 'del', 'ins', 'samp', 'kbd', 'sup', 'sub', 'mark', 'var', 'cite', 'small', 'abbr'],
    blockTags: ['pre', 'ul', 'ol', 'li', 'p', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6',  'dl', 'dt', 'dd', 'div', 'table', 'tbody', 'thead', 'tfoot', 'tr', 'th', 'td', 'blockquote', 'output', 'figcaption', 'figure', 'address', 'section', 'header', 'footer', 'aside', 'article', 'iframe'],
    regex: {
        youtube: /https?:\/\/(?:[0-9A-Z-]+\.)?(?:youtu\.be\/|youtube\.com\S*[^\w\-\s])([\w\-]{11})(?=[^\w\-]|$)(?![?=&+%\w.-]*(?:['"][^<>]*>|<\/a>))[?=&+%\w.-]*/gi,
        vimeo: /(http|https)?:\/\/(?:www.|player.)?vimeo.com\/(?:channels\/(?:\w+\/)?|groups\/(?:[^\/]*)\/videos\/|album\/(?:\d+)\/video\/|video\/|)(\d+)(?:[a-zA-Z0-9_-]+)?/gi,
        imageurl: /((https?|www)[^\s]+\.)(jpe?g|png|gif)(\?[^\s-]+)?/gi,
        url: /(https?:\/\/(?:www\.|(?!www))[^\s\.]+\.[^\s]{2,}|www\.[^\s]+\.[^\s]{2,})/gi
    },
    input: true,
    zindex: false,
    modes: {
        "inline": {
            pastePlainText: true,
            pasteImages: false,
            enterKey: false,
            toolbar: false,
            autoparse: false,
            source: false,
            showSource: false,
            styles: false,
            air: false
        },
        "original": {
            styles: false
        }
    }
};
$R.lang['en'] = {
    "format": "Format",
    "image": "Image",
    "file": "File",
    "link": "Link",
    "bold": "Bold",
    "italic": "Italic",
    "deleted": "Strikethrough",
    "underline": "Underline",
    "superscript": "Superscript",
    "subscript": "Subscript",
    "bold-abbr": "B",
    "italic-abbr": "I",
    "deleted-abbr": "S",
    "underline-abbr": "U",
    "superscript-abbr": "Sup",
    "subscript-abbr": "Sub",
    "lists": "Lists",
    "link-insert": "Insert Link",
    "link-edit": "Edit Link",
    "link-in-new-tab": "Open link in new tab",
    "unlink": "Unlink",
    "cancel": "Cancel",
    "close": "Close",
    "insert": "Insert",
    "save": "Save",
    "delete": "Delete",
    "text": "Text",
    "edit": "Edit",
    "title": "Alt",
    "paragraph": "Normal text",
    "quote": "Quote",
    "code": "Code",
    "heading1": "Heading 1",
    "heading2": "Heading 2",
    "heading3": "Heading 3",
    "heading4": "Heading 4",
    "heading5": "Heading 5",
    "heading6": "Heading 6",
    "filename": "Name",
    "optional": "optional",
    "unorderedlist": "Unordered List",
    "orderedlist": "Ordered List",
    "outdent": "Outdent",
    "indent": "Indent",
    "horizontalrule": "Line",
    "upload": "Upload",
    "upload-label": "Drop files here or click to upload",
    "accessibility-help-label": "Rich text editor",
    "caption": "Caption",
    "bulletslist": "Bullets",
    "numberslist": "Numbers",
    "image-position": "Position",
    "none": "None",
    "left": "Left",
    "right": "Right",
    "center": "Center",
    "undo": "Undo",
    "redo": "Redo"
};
$R.buttons = {
    html: {
        title: 'HTML',
        icon: true,
        api: 'module.source.toggle'
    },
    undo: {
        title: '## undo ##',
        icon: true,
        api: 'module.buffer.undo'
    },
    redo: {
        title: '## redo ##',
        icon: true,
        api: 'module.buffer.redo'
    },
    format: {
        title: '## format ##',
        icon: true,
        dropdown: {
            p: {
                title: '## paragraph ##',
                api: 'module.block.format',
                args: {
                    tag: 'p'
                }
            },
            blockquote: {
                title: '## quote ##',
                api: 'module.block.format',
                args: {
                    tag: 'blockquote'
                }
            },
            pre: {
                title: '## code ##',
                api: 'module.block.format',
                args: {
                    tag: 'pre'
                }
            },
            h1: {
                title: '## heading1 ##',
                api: 'module.block.format',
                args: {
                    tag: 'h1'
                }
            },
            h2: {
                title: '## heading2 ##',
                api: 'module.block.format',
                args: {
                    tag: 'h2'
                }
            },
            h3: {
                title: '## heading3 ##',
                api: 'module.block.format',
                args: {
                    tag: 'h3'
                }
            },
            h4: {
                title: '## heading4 ##',
                api: 'module.block.format',
                args: {
                    tag: 'h4'
                }
            },
            h5: {
                title: '## heading5 ##',
                api: 'module.block.format',
                args: {
                    tag: 'h5'
                }
            },
            h6: {
                title: '## heading6 ##',
                api: 'module.block.format',
                args: {
                    tag: 'h6'
                }
            }
        }
    },
    bold: {
        title: '## bold-abbr ##',
        icon: true,
        tooltip: '## bold ##',
        api: 'module.inline.format',
        args: {
            tag: 'b'
        }
    },
    italic: {
        title: '## italic-abbr ##',
        icon: true,
        tooltip: '## italic ##',
        api: 'module.inline.format',
        args: {
            tag: 'i'
        }
    },
    deleted: {
        title: '## deleted-abbr ##',
        icon: true,
        tooltip: '## deleted ##',
        api: 'module.inline.format',
        args: {
            tag: 'del'
        }
    },
    underline: {
        title: '## underline-abbr ##',
        icon: true,
        tooltip: '## underline ##',
        api: 'module.inline.format',
        args: {
            tag: 'u'
        }
    },
    sup: {
        title: '## superscript-abbr ##',
        icon: true,
        tooltip: '## superscript ##',
        api: 'module.inline.format',
        args: {
            tag: 'sup'
        }
    },
    sub: {
        title: '## subscript-abbr ##',
        icon: true,
        tooltip: '## subscript ##',
        api: 'module.inline.format',
        args: {
            tag: 'sub'
        }
    },
    lists: {
        title: '## lists ##',
        icon: true,
        observe: 'list',
        dropdown: {
            observe: 'list',
            unorderedlist: {
                title: '&bull; ## unorderedlist ##',
                api: 'module.list.toggle',
                args: 'ul'
            },
            orderedlist: {
                title: '1. ## orderedlist ##',
                api: 'module.list.toggle',
                args: 'ol'
            },
            outdent: {
                title: '< ## outdent ##',
                api: 'module.list.outdent'
            },
            indent: {
                title: '> ## indent ##',
                api: 'module.list.indent'
            }
        }
    },
    ul: {
        title: '&bull; ## bulletslist ##',
        icon: true,
        api: 'module.list.toggle',
        observe: 'list',
        args: 'ul'
    },
    ol: {
        title: '1. ## numberslist ##',
        icon: true,
        api: 'module.list.toggle',
        observe: 'list',
        args: 'ol'
    },
    outdent: {
        title: '## outdent ##',
        icon: true,
        api: 'module.list.outdent',
        observe: 'list'
    },
    indent: {
        title: '## indent ##',
        icon: true,
        api: 'module.list.indent',
        observe: 'list'
    },
    image: {
        title: '## image ##',
        icon: true,
        api: 'module.image.open'
    },
    file: {
        title: '## file ##',
        icon: true,
        api: 'module.file.open'
    },
    link: {
        title: '## link ##',
        icon: true,
        observe: 'link',
        dropdown: {
            observe: 'link',
            link: {
                title: '## link-insert ##',
                api: 'module.link.open'
            },
            unlink: {
                title: '## unlink ##',
                api: 'module.link.unlink'
            }
        }
    },
    line: {
        title: '## horizontalrule ##',
        icon: true,
        api: 'module.line.insert'
    }
};
var App = function(element, options, uuid)
{
    this.module = {};
    this.plugin = {};
    this.instances = {};

    // start/stop
    this.started = false;
    this.stopped = false;

    // environment
    this.uuid = uuid;
    this.rootElement = element;
    this.rootOpts = options;
    this.dragInside = false;
    this.dragComponentInside = false;
    this.keycodes = $R.keycodes;
    this.namespace = 'redactor';
    this.$win = $R.dom(window);
    this.$doc = $R.dom(document);
    this.$body = $R.dom('body');
    this.editorReadOnly = false;

    // core services
    this.opts = $R.create('service.options', options, element);
    this.lang = $R.create('service.lang', this);

    // build
    this.buildServices();
    this.buildModules();
    this.buildPlugins();

    // start
    this.start();
};

App.prototype = {
    start: function()
    {
        // start
        this.stopped = false;
        this.broadcast('start');
        this.broadcast('startcode');

        if (this.opts.clickToEdit)
        {
            this.broadcast('startclicktoedit');
        }
        else
        {
            this.broadcast('enable');
            if (this.opts.showSource) this.broadcast('startcodeshow');
            this.broadcast('enablefocus');
        }

        // started
        this.broadcast('started');
        this.started = true;
    },
    stop: function()
    {
        this.started = false;
        this.stopped = true;

        this.broadcast('stop');
        this.broadcast('disable');
        this.broadcast('stopped');
    },

    // started & stopped
    isStarted: function()
    {
        return this.started;
    },
    isStopped: function()
    {
        return this.stopped;
    },

    // build
    buildServices: function()
    {
        var core = ['options', 'lang'];
        var bindable = ['uuid', 'keycodes', 'opts', 'lang', '$win', '$doc', '$body'];
        var services = [];
        for (var name in $R.services)
        {
            if (core.indexOf(name) === -1)
            {
                this[name] = $R.create('service.' + name, this);
                services.push(name);
                bindable.push(name);
            }
        }

        // binding
        for (var i = 0; i < services.length; i++)
        {
            var service = services[i];
            for (var z = 0; z < bindable.length; z++)
            {
                var inj = bindable[z];
                if (service !== inj)
                {
                    this[service][inj] = this[inj];
                }
            }
        }
    },
    buildModules: function()
    {
        for (var name in $R.modules)
        {
            this.module[name] = $R.create('module.' + name, this);
            this.instances[name] = this.module[name];
        }
    },
    buildPlugins: function()
    {
        var plugins = this.opts.plugins;
        for (var i = 0; i < plugins.length; i++)
        {
            var name = plugins[i];
            if (typeof $R.plugins[name] !== 'undefined')
            {
                this.plugin[name] = $R.create('plugin.' + name, this);
                this.instances[name] = this.plugin[name];
            }
        }
    },

    // draginside
    isDragInside: function()
    {
        return this.dragInside;
    },
    setDragInside: function(dragInside)
    {
        this.dragInside = dragInside;
    },
    isDragComponentInside: function()
    {
        return this.dragComponentInside;
    },
    setDragComponentInside: function(dragInside)
    {
        this.dragComponentInside = dragInside;
    },
    getDragComponentInside: function()
    {
        return this.dragComponentInside;
    },

    // readonly
    isReadOnly: function()
    {
        return this.editorReadOnly;
    },
    enableReadOnly: function()
    {
        this.editorReadOnly = true;
        this.broadcast('enablereadonly');
        this.component.clearActive();
        this.toolbar.disableButtons();
    },
    disableReadOnly: function()
    {
        this.editorReadOnly = false;
        this.broadcast('disablereadonly');
        this.toolbar.enableButtons();
    },

    // messaging
    callMessageHandler: function(instance, name, args)
    {
        var arr = name.split('.');
        if (arr.length === 1)
        {
            if (typeof instance['on' + name] === 'function')
            {
                instance['on' + name].apply(instance, args);
            }
        }
        else
        {
            arr[0] = 'on' + arr[0];

            var func = this.utils.checkProperty(instance, arr);
            if (typeof func === 'function')
            {
                func.apply(instance, args);
            }
        }
    },
    broadcast: function(name)
    {
        var args = [].slice.call(arguments, 1);
        for (var moduleName in this.instances)
        {
            this.callMessageHandler(this.instances[moduleName], name, args);
        }

        // callback
        return this.callback.trigger(name, args);
    },

    // callback
    on: function(name, func)
    {
        this.callback.add(name, func);
    },
    off: function(name, func)
    {
        this.callback.remove(name, func);
    },

    // api
    api: function(name)
    {
        if (!this.isStarted() && name !== 'start') return;
        if (this.isReadOnly() && name !== 'disableReadOnly') return;

        this.broadcast('state');

        var args = [].slice.call(arguments, 1);
        var arr = name.split('.');

        var isApp = (arr.length === 1);
        var isCallback = (arr[0] === 'on' || arr[0] === 'off');
        var isService = (!isCallback && arr.length === 2);
        var isPlugin = (arr[0] === 'plugin');
        var isModule = (arr[0] === 'module');

        // app
        if (isApp)
        {
            if (typeof this[arr[0]] === 'function')
            {
                return this.callInstanceMethod(this, arr[0], args);
            }
        }
        // callback
        else if (isCallback)
        {
            return (arr[0] === 'on') ? this.on(arr[1], args[0]) : this.off(arr[1], args[0] || undefined);
        }
        // service
        else if (isService)
        {
            if (this.isInstanceExists(this, arr[0]))
            {
                return this.callInstanceMethod(this[arr[0]], arr[1], args);
            }
            else
            {
                $R.error(new Error('Service "' + arr[0] + '" not found'));
            }
        }
        // plugin
        else if (isPlugin)
        {
            if (this.isInstanceExists(this.plugin, arr[1]))
            {
                return this.callInstanceMethod(this.plugin[arr[1]], arr[2], args);
            }
            else
            {
                $R.error(new Error('Plugin "' + arr[1] + '" not found'));
            }
        }
        // module
        else if (isModule)
        {
            if (this.isInstanceExists(this.module, arr[1]))
            {
                return this.callInstanceMethod(this.module[arr[1]], arr[2], args);
            }
            else
            {
                $R.error(new Error('Module "' + arr[1] + '" not found'));
            }
        }

    },
    isInstanceExists: function(obj, name)
    {
        return (typeof obj[name] !== 'undefined');
    },
    callInstanceMethod: function(instance, method, args)
    {
        if (typeof instance[method] === 'function')
        {
            return instance[method].apply(instance, args);
        }
    }
};
$R.add('mixin', 'formatter', {

    // public
    buildArgs: function(args)
    {
        this.args = {
            'class': args['class'] || false,
            'style': args['style'] || false,
            'attr': args['attr'] || false
        };

        if (!this.args['class'] && !this.args['style'] && !this.args['attr'])
        {
            this.args = false;
        }
    },
    applyArgs: function(nodes, selection)
    {
        if (this.args)
        {
            nodes = this[this.type](this.args, false, nodes, selection);
        }
        else
        {
            nodes = this._clearAll(nodes, selection);
        }

        return nodes;
    },
    clearClass: function(tags, nodes)
    {
        this.selection.save();

        var $elements = (nodes) ? $R.dom(nodes) : this.getElements(tags, true);
        $elements.removeAttr('class');

        nodes = this._unwrapSpanWithoutAttr($elements.getAll());

        this.selection.restore();

        return nodes;
    },
    clearStyle: function(tags, nodes)
    {
        this.selection.save();

        var $elements = (nodes) ? $R.dom(nodes) : this.getElements(tags, true);
        $elements.removeAttr('style');

        nodes = this._unwrapSpanWithoutAttr($elements.getAll());

        this.selection.restore();

        return nodes;
    },
    clearAttr: function(tags, nodes)
    {
        this.selection.save();

        var $elements = (nodes) ? $R.dom(nodes) : this.getElements(tags, true);
        this._removeAllAttr($elements);

        nodes = this._unwrapSpanWithoutAttr($elements.getAll());

        this.selection.restore();

        return nodes;
    },
    set: function(args, tags, nodes, selection)
    {
        if (selection !== false) this.selection.save();

        var $elements = (nodes) ? $R.dom(nodes) : this.getElements(tags);

        if (args['class'])
        {
            $elements.removeAttr('class');
            $elements.addClass(args['class']);
        }

        if (args['style'])
        {
            $elements.removeAttr('style');
            $elements.css(args['style']);
            $elements.each(function(node)
            {
                var $node = $R.dom(node);
                $node.attr('data-redactor-style-cache', $node.attr('style'));
            });
        }

        if (args['attr'])
        {
            this._removeAllAttr($elements);
            $elements.attr(args['attr']);
        }

        if (selection !== false) this.selection.restore();

        return $elements.getAll();
    },
    toggle: function(args, tags, nodes, selection)
    {
        if (selection !== false) this.selection.save();

        var $elements = (nodes) ? $R.dom(nodes) : this.getElements(tags);

        if (args['class'])
        {
            $elements.toggleClass(args['class']);
            $elements.each(function(node)
            {
                if (node.className === '') node.removeAttribute('class');
            });
        }

        var params;
        if (args['style'])
        {
            params = args['style'];
            $elements.each(function(node)
            {
                var $node = $R.dom(node);
                for (var key in params)
                {
                    var newVal = params[key];
                    var oldVal = $node.css(key);

                    oldVal = (this.utils.isRgb(oldVal)) ? this.utils.rgb2hex(oldVal) : oldVal.replace(/"/g, '');
                    newVal = (this.utils.isRgb(newVal)) ? this.utils.rgb2hex(newVal) : newVal.replace(/"/g, '');

                    oldVal = this.utils.hex2long(oldVal);
                    newVal = this.utils.hex2long(newVal);

                    var compareNew = (typeof newVal === 'string') ? newVal.toLowerCase() : newVal;
                    var compareOld = (typeof oldVal === 'string') ? oldVal.toLowerCase() : oldVal;

                    if (compareNew === compareOld) $node.css(key, '');
                    else $node.css(key, newVal);
                }

                this._convertStyleQuotes($node);
                if (this.utils.removeEmptyAttr(node, 'style'))
                {
                    $node.removeAttr('data-redactor-style-cache');
                }
                else
                {
                    $node.attr('data-redactor-style-cache', $node.attr('style'));
                }

            }.bind(this));
        }

        if (args['attr'])
        {
            params = args['attr'];
            $elements.each(function(node)
            {
                var $node = $R.dom(node);
                for (var key in params)
                {
                    if ($node.attr(key)) $node.removeAttr(key);
                    else $node.attr(key, params[key]);
                }
            });

        }

        if (selection !== false) this.selection.restore();

        return $elements.getAll();
    },
    add: function(args, tags, nodes, selection)
    {
        if (selection !== false) this.selection.save();

        var $elements = (nodes) ? $R.dom(nodes) : this.getElements(tags);

        if (args['class'])
        {
            $elements.addClass(args['class']);
        }

        if (args['style'])
        {
            var params = args['style'];
            $elements.each(function(node)
            {
                var $node = $R.dom(node);
                $node.css(params);
                $node.attr('data-redactor-style-cache', $node.attr('style'));

                this._convertStyleQuotes($node);

            }.bind(this));
        }

        if (args['attr'])
        {
            $elements.attr(args['attr']);
        }

        if (selection !== false) this.selection.restore();

        return $elements.getAll();
    },
    remove: function(args, tags, nodes, selection)
    {
        if (selection !== false) this.selection.save();

        var $elements = (nodes) ? $R.dom(nodes) : this.getElements(tags);

        if (args['class'])
        {
            $elements.removeClass(args['class']);
            $elements.each(function(node)
            {
                if (node.className === '') node.removeAttribute('class');
            });
        }

        if (args['style'])
        {
            var name = args['style'];
            $elements.each(function(node)
            {
                var $node = $R.dom(node);
                $node.css(name, '');

                if (this.utils.removeEmptyAttr(node, 'style'))
                {
                    $node.removeAttr('data-redactor-style-cache');
                }
                else
                {
                    $node.attr('data-redactor-style-cache', $node.attr('style'));
                }

            }.bind(this));
        }

        if (args['attr'])
        {
            $elements.removeAttr(args['attr']);
        }

        nodes = this._unwrapSpanWithoutAttr($elements.getAll());

        if (selection !== false) this.selection.restore();

        return nodes;
    },

    // private
    _removeAllAttr: function($elements)
    {
        $elements.each(function(node)
        {
            for (var i = node.attributes.length; i-->0;)
            {
                var nodeAttr = node.attributes[i];
                var name = nodeAttr.name;
                if (name !== 'style' && name !== 'class')
                {
                    node.removeAttributeNode(nodeAttr);
                }
            }
        });
    },
    _convertStyleQuotes: function($node)
    {
        var style = $node.attr('style');
        if (style) $node.attr('style', style.replace(/"/g, '\''));
    },
    _clearAll: function(nodes, selection)
    {
        if (selection !== false) this.selection.save();

        for (var i = 0; i < nodes.length; i++)
        {
            var node = nodes[i];
            while (node.attributes.length > 0)
            {
                node.removeAttribute(node.attributes[0].name);
            }
        }

        nodes = this._unwrapSpanWithoutAttr(nodes);

        if (selection !== false) this.selection.restore();

        return nodes;
    },
    _unwrapSpanWithoutAttr: function(nodes)
    {
        var finalNodes = [];
        for (var i = 0; i < nodes.length; i++)
        {
            var node = nodes[i];
            var len = node.attributes.length;
            if (len <= 0 && node.nodeType !== 3 && node.tagName === 'SPAN')
            {
                $R.dom(node).unwrap();
            }
            else
            {
                finalNodes.push(node);
            }
        }

        return finalNodes;
    }
});
$R.add('mixin', 'dom', $R.Dom.prototype);
$R.add('mixin', 'component', {
    get cmnt()
    {
        return true;
    }
});
$R.add('service', 'options', {
    init: function(options, element)
    {
        var $el = $R.dom(element);
        var opts = $R.extend({}, $R.opts, (element) ? $el.data() : {}, $R.options);
        opts = $R.extend(true, opts, options);

        return opts;
    }
});
$R.add('service', 'lang', {
    init: function(app)
    {
        this.app = app;
        this.opts = app.opts;

        // build
        this.vars = this._build(this.opts.lang);
    },

    // public
    rebuild: function(lang)
    {
        this.opts.lang = lang;
        this.vars = this._build(lang);
    },
    extend: function(obj)
    {
        this.vars = $R.extend(this.vars, obj);
    },
    parse: function(str)
    {
        if (str === undefined)
        {
            return '';
        }

        var matches = str.match(/## (.*?) ##/g);
        if (matches)
        {
            for (var i = 0; i < matches.length; i++)
            {
                var key = matches[i].replace(/^##\s/g, '').replace(/\s##$/g, '');
                str = str.replace(matches[i], this.get(key));
            }
        }

        return str;
    },
    get: function(name)
    {
        var str = '';
        if (typeof this.vars[name] !== 'undefined')
        {
            str = this.vars[name];
        }
        else if (this.opts.lang !== 'en' && typeof $R.lang['en'][name] !== 'undefined')
        {
            str = $R.lang['en'][name];
        }

        return str;
    },

    // private
    _build: function(lang)
    {
        var vars = $R.lang['en'];
        if (lang !== 'en')
        {
            vars = ($R.lang[lang] !== undefined) ? $R.lang[lang] : vars;
        }

        return vars;
    }
});
$R.add('service', 'callback', {
    init: function(app)
    {
        this.app = app;
        this.opts = app.opts;

        // local
        this.callbacks = {};

        // build
        if (this.opts.callbacks)
        {
            this._set(this.opts.callbacks, '');
        }
    },
    stop: function()
    {
        this.callbacks = {};
    },
    add: function(name, handler)
    {
        if (!this.callbacks[name]) this.callbacks[name] = [];
        this.callbacks[name].push(handler);
    },
    remove: function(name, handler)
    {
        if (handler === undefined)
        {
            delete this.callbacks[name];
        }
        else
        {
            for (var i = 0; i < this.callbacks[name].length; i++)
            {
                this.callbacks[name].splice(i, 1);
            }

            if (Object.keys(this.callbacks[name]).length === 0) delete this.callbacks[name];
        }
    },
    trigger: function(name, args)
    {
        var value = this._loop(name, args, this.callbacks);
        return (typeof value === 'undefined' && args && args[0] !== false) ? args[0] : value;
    },

    // private
    _set: function(obj, name)
    {
        for (var key in obj)
        {
            var path = (name === '') ? key : name + '.' + key;
            if (typeof obj[key] === 'object')
            {
                this._set(obj[key], path);
            }
            else
            {
                this.callbacks[path] = [];
                this.callbacks[path].push(obj[key]);
            }
        }
    },
    _loop: function(name, args, obj)
    {
        var value;
        for (var key in obj)
        {
            if (name === key)
            {
                for (var i = 0; i < obj[key].length; i++)
                {
                    value = obj[key][i].apply(this.app, args);
                }
            }
        }

        return value;
    }
});
$R.add('service', 'animate', {
    init: function(app)
    {
        this.animationOpt = app.opts.animation;
    },
    start: function(element, animation, options, callback)
    {
        var defaults = {
            duration: false,
            iterate: false,
            delay: false,
            timing: false,
            prefix: 'redactor-'
        };

        defaults = (typeof options === 'function') ? defaults : $R.extend(defaults, options);
        callback = (typeof options === 'function') ? options : callback;

        // play
        return new $R.AnimatePlay(element, animation, defaults, callback, this.animationOpt);
    },
    stop: function(element)
    {
        this.$el = $R.dom(element);
        this.$el.removeClass('redactor-animated');

        var effect = this.$el.attr('redactor-animate-effect');
        this.$el.removeClass(effect);

        this.$el.removeAttr('redactor-animate-effect');
        var hide = this.$el.attr('redactor-animate-hide');
        if (hide)
        {
            this.$el.addClass(hide).removeAttr('redactor-animate-hide');
        }

        this.$el.off('animationend webkitAnimationEnd');
    }
});

$R.AnimatePlay = function(element, animation, defaults, callback, animationOpt)
{
    this.hidableEffects = ['fadeOut', 'flipOut', 'slideUp', 'zoomOut', 'slideOutUp', 'slideOutRight', 'slideOutLeft'];
    this.prefixes = ['', '-webkit-'];

    this.$el = $R.dom(element);
    this.$body = $R.dom('body');
    this.callback = callback;
    this.animation = (!animationOpt) ? this.buildAnimationOff(animation) : animation;
    this.defaults = defaults;

    if (this.animation === 'slideUp')
    {
        this.$el.height(this.$el.height());
    }

    // animate
    return (this.isInanimate()) ? this.inanimate() : this.animate();
};

$R.AnimatePlay.prototype = {
    buildAnimationOff: function(animation)
    {
        return (this.isHidable(animation)) ? 'hide' : 'show';
    },
    buildHideClass: function()
    {
        return 'redactor-animate-hide';
    },
    isInanimate: function()
    {
        return (this.animation === 'show' || this.animation === 'hide');
    },
    isAnimated: function()
    {
        return this.$el.hasClass('redactor-animated');
    },
    isHidable: function(effect)
    {
        return (this.hidableEffects.indexOf(effect) !== -1);
    },
    inanimate: function()
    {
        this.defaults.timing = 'linear';

        var hide;
        if (this.animation === 'show')
        {
            hide = this.buildHideClass();
            this.$el.attr('redactor-animate-hide', hide);
            this.$el.removeClass(hide);
        }
        else
        {
            hide = this.$el.attr('redactor-animate-hide');
            this.$el.addClass(hide).removeAttr('redactor-animate-hide');
        }

        if (typeof this.callback === 'function') this.callback(this);

        return this;
    },
    animate: function()
    {
        var delay = (this.defaults.delay) ? this.defaults.delay : 0;
        setTimeout(function()
        {
            this.$body.addClass('no-scroll-x');
            this.$el.addClass('redactor-animated');
            if (!this.$el.attr('redactor-animate-hide'))
            {
                var hide = this.buildHideClass();
                this.$el.attr('redactor-animate-hide', hide);
                this.$el.removeClass(hide);
            }

            this.$el.addClass(this.defaults.prefix + this.animation);
            this.$el.attr('redactor-animate-effect', this.defaults.prefix + this.animation);

            this.set(this.defaults.duration + 's', this.defaults.iterate, this.defaults.timing);
            this.complete();

        }.bind(this), delay * 1000);

        return this;
    },
    set: function(duration, iterate, timing)
    {
        var len = this.prefixes.length;

        while (len--)
        {
            if (duration !== false || duration === '') this.$el.css(this.prefixes[len] + 'animation-duration', duration);
            if (iterate !== false || iterate === '') this.$el.css(this.prefixes[len] + 'animation-iteration-count', iterate);
            if (timing !== false || timing === '') this.$el.css(this.prefixes[len] + 'animation-timing-function', timing);
        }
    },
    clean: function()
    {
        this.$body.removeClass('no-scroll-x');
        this.$el.removeClass('redactor-animated');
        this.$el.removeClass(this.defaults.prefix + this.animation);
        this.$el.removeAttr('redactor-animate-effect');

        this.set('', '', '');
    },
    complete: function()
    {
        this.$el.one('animationend webkitAnimationEnd', function()
        {
            if (this.$el.hasClass(this.defaults.prefix + this.animation)) this.clean();
            if (this.isHidable(this.animation))
            {
                var hide = this.$el.attr('redactor-animate-hide');
                this.$el.addClass(hide).removeAttr('redactor-animate-hide');
            }

            if (this.animation === 'slideUp') this.$el.height('');
            if (typeof this.callback === 'function') this.callback(this.$el);

        }.bind(this));
    }
};
$R.add('service', 'caret', {
    init: function(app)
    {
        this.app = app;
    },

    // set
    setStart: function(el)
    {
        this._setCaret('Start', el);
    },
    setEnd: function(el)
    {
        this._setCaret('End', el);
    },
    setBefore: function(el)
    {
        this._setCaret('Before', el);
    },
    setAfter: function(el)
    {
        this._setCaret('After', el);
    },

    // is
    isStart: function(el)
    {
        return this._isStartOrEnd(el, 'First');
    },
    isEnd: function(el)
    {
        return this._isStartOrEnd(el, 'Last');
    },

    // set side
    setAtEnd: function(node)
    {
        var data = this.inspector.parse(node);
        var tag = data.getTag();
        var range = document.createRange();
        if (this._isInPage(node))
        {
            if (tag === 'a')
            {
                var textNode = this.utils.createInvisibleChar();
                $R.dom(node).after(textNode);

                range.selectNodeContents(textNode);
                range.collapse(true);
            }
            else
            {
                range.selectNodeContents(node);
                range.collapse(false);
            }

            this.selection.setRange(range);
        }
    },
    setAtStart: function(node)
    {
		var range = document.createRange();
		var data = this.inspector.parse(node);
        if (this._isInPage(node))
        {
            range.setStart(node, 0);
            range.collapse(true);

            if (data.isInline() || this.utils.isEmpty(node))
            {
                var textNode = this.utils.createInvisibleChar();
                range.insertNode(textNode);
                range.selectNodeContents(textNode);
                range.collapse(false);
            }

            this.selection.setRange(range);
        }
    },
    setAtBefore: function(node)
    {
        var data = this.inspector.parse(node);
        var range = document.createRange();
        if (this._isInPage(node))
        {
            range.setStartBefore(node);
            range.collapse(true);

            if (data.isInline())
            {
                var textNode = this.utils.createInvisibleChar();
                node.parentNode.insertBefore(textNode, node);
                range.selectNodeContents(textNode);
                range.collapse(false);
            }

            this.selection.setRange(range);
        }
    },
    setAtAfter: function(node)
    {

        var range = document.createRange();
        if (this._isInPage(node))
        {
            range.setStartAfter(node);
            range.collapse(true);

            var textNode = this.utils.createInvisibleChar();
            range.insertNode(textNode);
            range.selectNodeContents(textNode);
            range.collapse(false);

            this.selection.setRange(range);
        }
    },
    setAtPrev: function(node)
    {
        var prev = node.previousSibling;
        if (prev)
        {
            prev = (prev.nodeType === 3 && this._isEmptyTextNode(prev)) ? prev.previousElementSibling : prev;
            if (prev) this.setEnd(prev);
        }
    },
    setAtNext: function(node)
    {
        var next = node.nextSibling;
        if (next)
        {
            next = (next.nodeType === 3 && this._isEmptyTextNode(next)) ? next.nextElementSibling : next;
            if (next) this.setStart(next);
        }
    },

    // private
    _setCaret: function(type, el)
    {
        var data = this.inspector.parse(el);
        var node = data.getNode();

        if (node)
        {
            this.component.clearActive();
            this['_set' + type](node, data, data.getTag());
        }
    },
    _setStart: function(node, data, tag)
    {
        // 1. text
        if (data.isText())
        {
            this.editor.focus();
            return this.setAtStart(node);
        }
        // 2. ul, ol
        else if (tag === 'ul' || tag === 'ol')
        {
            node = data.findFirstNode('li');

            var item = this.utils.getFirstElement(node);
            var dataItem = this.inspector.parse(item);
            if (item && dataItem.isComponent())
            {
                return this.setStart(dataItem.getComponent());
            }
        }
        // 3. dl
        else if (tag === 'dl')
        {
            node = data.findFirstNode('dt');
        }
        // 4. br / hr
        else if (tag === 'br' || tag === 'hr')
        {
            return this.setBefore(node);
        }
        // 5. th, td
        else if (tag === 'td' || tag === 'th')
        {
            var el = data.getFirstElement(node);
            if (el)
            {
                return this.setStart(el);
            }
        }
        // 6. table
        else if (tag === 'table' || tag === 'tr')
        {
            return this.setStart(data.findFirstNode('th, td'));
        }
        // 7. figure code
        else if (data.isComponentType('code') && !data.isFigcaption())
        {
            var code = data.findLastNode('pre, code');

            this.editor.focus();
            return this.setAtStart(code);
        }
        // 8. table component
        else if (tag === 'figure' && data.isComponentType('table'))
        {
            var table = data.getTable();
            var tableData = this.inspector.parse(table);

            return this.setStart(tableData.findFirstNode('th, td'));
        }
        // 9. non editable components
        else if (!data.isComponentType('table') && data.isComponent() && !data.isFigcaption())
        {
            return this.component.setActive(node);
        }

        this.editor.focus();

        // set
        if (!this._setInline(node, 'Start'))
        {
            this.setAtStart(node);
        }
    },
    _setEnd: function(node, data, tag)
    {
        // 1. text
        if (data.isText())
        {
            this.editor.focus();
            return this.setAtEnd(node);
        }
        // 2. ul, ol
        else if (tag === 'ul' || tag === 'ol')
        {
            node = data.findLastNode('li');

            var item = this.utils.getLastElement(node);
            var dataItem = this.inspector.parse(item);
            if (item && dataItem.isComponent())
            {
                return this.setEnd(dataItem.getComponent());
            }
        }
        // 3. dl
        else if (tag === 'dl')
        {
            node = data.findLastNode('dd');
        }
        // 4. br / hr
        else if (tag === 'br' || tag === 'hr')
        {
            return this.setAfter(node);
        }
        // 5. th, td
        else if (tag === 'td' || tag === 'th')
        {
            var el = data.getLastElement();
            if (el)
            {
                return this.setEnd(el);
            }
        }
        // 6. table
        else if (tag === 'table' || tag === 'tr')
        {
            return this.setEnd(data.findLastNode('th, td'));
        }
        // 7. figure code
        else if (data.isComponentType('code') && !data.isFigcaption())
        {
            var code = data.findLastNode('pre, code');

            this.editor.focus();
            return this.setAtEnd(code);
        }
        // 8. table component
        else if (tag === 'figure' && data.isComponentType('table'))
        {
            var table = data.getTable();
            var tableData = this.inspector.parse(table);

            return this.setEnd(tableData.findLastNode('th, td'));
        }
        // 9. non editable components
        else if (!data.isComponentType('table') && data.isComponent() && !data.isFigcaption())
        {
            return this.component.setActive(node);
        }

        this.editor.focus();

        // set
        if (!this._setInline(node, 'End'))
        {
            // is element empty
            if (this.utils.isEmpty(node))
            {
                return this.setStart(node);
            }

            this.setAtEnd(node);
        }
    },
    _setBefore: function(node, data, tag)
    {
        // text
        if (node.nodeType === 3)
        {
            return this.setAtBefore(node);
        }
        // inline
        else if (data.isInline())
        {
            return this.setAtBefore(node);
        }
        // td / th
        else if (data.isFirstTableCell())
        {
            return this.setAtPrev(data.getComponent());
        }
        else if (tag === 'td' || tag === 'th')
        {
            return this.setAtPrev(node);
        }
        // li
        else if (data.isFirstListItem())
        {
            return this.setAtPrev(data.getList());
        }
        // figcaption
        else if (data.isFigcaption())
        {
            return this.setStart(data.getComponent());
        }
        // component
        else if (!data.isComponentType('table') && data.isComponent())
        {
            return this.setAtPrev(data.getComponent());
        }
        // block
        else if (data.isBlock())
        {
            return this.setAtPrev(node);
        }

        this.editor.focus();
        this.setAtBefore(node);

    },
    _setAfter: function(node, data, tag)
    {
        // text
        if (node.nodeType === 3)
        {
            return this.setAtAfter(node);
        }
        // inline
        else if (data.isInline())
        {
            return this.setAtAfter(node);
        }
        // td / th
        else if (data.isLastTableCell())
        {
            return this.setAtNext(data.getComponent());
        }
        else if (tag === 'td' || tag === 'th')
        {
            return this.setAtNext(node);
        }
        // li
        else if (data.isFirstListItem())
        {
            return this.setAtNext(data.getList());
        }
        // component
        else if (!data.isComponentType('table') && data.isComponent())
        {
            return this.setAtNext(data.getComponent());
        }
        // block
        else if (data.isBlock())
        {
            return this.setAtNext(node);
        }

        this.editor.focus();
        this.setAtAfter(node);
    },
    _setInline: function(node, type)
    {
        // is first element inline (FF only)
        var inline = this._hasInlineChild(node, (type === 'Start') ? 'first' : 'last');
        if (inline)
        {
            if (type === 'Start')
            {
                this.setStart(inline);
            }
            else
            {
                this.setEnd(inline);
            }

            return true;
        }
    },
    _isStartOrEnd: function(el, type)
    {
        var node = this.utils.getNode(el);
        if (!node) return false;

        var data = this.inspector.parse(node);
        node = this._getStartEndNode(node, data, type);

        if (node && (node.nodeType !== 3 && node.tagName !== 'LI'))
        {
            var html = (node.nodeType === 3) ? node.textContent : node.innerHTML;
            html = this.utils.trimSpaces(html);
            if (html === '') return true;
        }

        if (!data.isFigcaption() && data.isComponent() && !data.isComponentEditable())
        {
            return true;
        }

        var offset = this.offset.get(node, true);
        if (offset)
        {
            return (type === 'First') ? (offset.start === 0) : (offset.end === this.offset.size(node, true));
        }
        else
        {
            return false;
        }
    },
    _isInPage: function(node)
    {
        if (node && node.nodeType)
        {
            return (node === document.body) ? false : document.body.contains(node);
        }
        else
        {
            return false;
        }
    },
    _hasInlineChild: function(el, pos)
    {
        var data = this.inspector.parse(el);
        var node = (pos === 'first') ? data.getFirstNode() : data.getLastNode();
        var $node = $R.dom(node);

        if (node && node.nodeType !== 3
            && this.inspector.isInlineTag(node.tagName)
            && !$node.hasClass('redactor-component')
             && !$node.hasClass('non-editable'))
        {
            return node;
        }
    },
    _isEmptyTextNode: function(node)
    {
        var text = node.textContent.trim().replace(/\n/, '');
        text = this.utils.removeInvisibleChars(text);

        return (text === '');
    },
    _getStartEndNode: function(node, data, type)
    {
        if (data.isFigcaption())
        {
            node = data.getFigcaption();
        }
        else if (data.isTable())
        {
            node = data['find' + type + 'Node']('th, td');
        }
        else if (data.isList())
        {
            node = data['find' + type + 'Node']('li');
        }
        else if (data.isComponentType('code'))
        {
            node = data.findLastNode('pre, code');
        }

        return node;
    }
});
$R.add('service', 'selection', {
    init: function(app)
    {
        this.app = app;
    },
    // is
    is: function()
    {
        var sel = this.get();
        if (sel)
        {
            var node = sel.anchorNode;
            var data = this.inspector.parse(node);

            return (data.isInEditor() || data.isEditor());
        }

        return false;
    },
    isCollapsed: function()
    {
        var sel = this.get();
        var range = this.getRange();

        if (sel && sel.isCollapsed) return true;
        else if (range && range.toString().length === 0) return true;

        return false;
    },
    isBackwards: function()
    {
        var backwards = false;
        var sel = this.get();

        if (sel && !sel.isCollapsed)
        {
            var range = document.createRange();
            range.setStart(sel.anchorNode, sel.anchorOffset);
            range.setEnd(sel.focusNode, sel.focusOffset);
            backwards = range.collapsed;
            range.detach();
        }

        return backwards;
    },
    isIn: function(el)
    {
        var node = $R.dom(el).get();
        var current = this.getCurrent();

        return (current && node) ? node.contains(current) : false;
    },
    isText: function()
    {
        var sel = this.get();
        if (sel)
        {
            var el = sel.anchorNode;
            var block = this.getBlock(el);
            var blocks = this.getBlocks();

            // td, th or hasn't block
            if ((block && this.inspector.isTableCellTag(block.tagName)) || (block === false && blocks.length === 0))
            {
                return true;
            }
        }

        return false;
    },
    isAll: function(el)
    {
        var node = this.utils.getNode(el);
        if (!node) return false;

        var isEditor = this.editor.isEditor(node);
        var data = this.inspector.parse(node);

        // component
        if (!data.isFigcaption() && this.component.isNonEditable(node) && this.component.isActive(node))
        {
            return true;
        }

        if (isEditor)
        {
            var $editor = this.editor.getElement();
            var output = $editor.html().replace(/<p><\/p>$/i, '');
            var htmlLen = this.getHtml(false).length;
            var outputLen = output.length;

            if (htmlLen !== outputLen)
            {
                return false;
            }
        }

        // editor empty or collapsed
        if ((isEditor && this.editor.isEmpty()) || this.isCollapsed())
        {
            return false;
        }

        // all
        var offset = this.offset.get(node, true);
        var size = this.offset.size(node, true);

        // pre, table, or pre/code in figure
        if (!isEditor && data.isComponentType('code'))
        {
            size = this.getText().trim().length;
        }

        if (offset && offset.start === 0 && offset.end === size)
        {
            return true;
        }

        return false;
    },

    // has
    hasNonEditable: function()
    {
        var selected = this.getHtml();
        var $wrapper = $R.dom('<div>').html(selected);

        return (!this.isCollapsed() && $wrapper.find('.non-editable').length !== 0);
    },

    // set
    setRange: function(range)
    {
        var sel = window.getSelection();
        sel.removeAllRanges();
        sel.addRange(range);
    },
    setAll: function(el)
    {
        var node = this.utils.getNode(el);
        if (!node) return;

        var data = this.inspector.parse(node);

        this.component.clearActive();

        this.editor.focus();
        this.editor.saveScroll();
        this.editor.disableNonEditables();

        if (node && node.tagName === 'TABLE')
        {
            var first = data.findFirstNode('td, th');
            var last = data.findLastNode('td, th');

            $R.dom(first).prepend(this.marker.build('start'));
            $R.dom(last).append(this.marker.build('end'));

            this.restoreMarkers();
        }
        else if (!data.isFigcaption() && this.component.isNonEditable(node))
        {
            this.component.setActive(node);
        }
        else
        {
            if (data.isComponentType('code'))
            {
                node = data.getComponentCodeElement();
                node.focus();
            }

            var range = document.createRange();
            range.selectNodeContents(node);

            this.setRange(range);
        }

        this.editor.enableNonEditables();
        this.editor.restoreScroll();
    },

    // get
    get: function()
    {
        var sel = window.getSelection();
        return (sel.rangeCount > 0) ? sel : null;
    },
    getRange: function()
    {
        var sel = this.get();
        return (sel) ? ((sel.getRangeAt(0)) ? sel.getRangeAt(0) : null) : null;
    },
    getTextBeforeCaret: function(num)
    {
        num = (typeof num === 'undefined') ? 1 : num;

        var el = this.editor.getElement().get();
        var range = this.getRange();
        var text = false;
        if (range)
        {
            range = range.cloneRange();
            range.collapse(true);
            range.setStart(el, 0);
            text = range.toString().slice(-num);
        }

        return text;
    },
    getTextAfterCaret: function(num)
    {
        num = (typeof num === 'undefined') ? 1 : num;

        var el = this.editor.getElement().get();
        var range = this.getRange();
        var text = false;
        if (range)
        {
            var clonedRange = range.cloneRange();
            clonedRange.selectNodeContents(el);
            clonedRange.setStart(range.endContainer, range.endOffset);

            text = clonedRange.toString().slice(0, num);
        }

        return text;
    },
    getPosition: function()
    {
        var range = this.getRange();
        var pos = { top: 0, left: 0, width: 0, height: 0 };
        if (window.getSelection && range.getBoundingClientRect)
        {
            range = range.cloneRange();
            var offset = (range.startOffset-1);
            range.setStart(range.startContainer, (offset < 0) ? 0 : offset);
            var rect = range.getBoundingClientRect();
            pos = { top: rect.top, left: rect.left, width: (rect.right - rect.left) , height: (rect.bottom - rect.top) };
        }

        return pos;
    },
    getCurrent: function()
    {
        var node = false;
        var sel = this.get();
        var component = this.component.getActive();

        if (component)
        {
            node = component;
        }
        else if (sel && this.is())
        {
            var data = this.inspector.parse(sel.anchorNode);
            node = (!data.isEditor()) ? sel.anchorNode : false;
        }

        return node;
    },
    getParent: function()
    {
        var node = false;
        var current = this.getCurrent();
        if (current)
        {
            var parent = current.parentNode;
            var data = this.inspector.parse(parent);

            node = (!data.isEditor()) ? parent : false;
        }

        return node;
    },
    getElement: function(el)
    {
        var node = el || this.getCurrent();
        while (node)
        {
            var data = this.inspector.parse(node);
            if (data.isElement() && data.isInEditor())
            {
                return node;
            }

            node = node.parentNode;
        }

        return false;
    },
    getInline: function(el)
    {
        var node = el || this.getCurrent();
        var inline = false;
        while (node)
        {
            if (this._isInlineNode(node))
            {
                inline = node;
            }

            node = node.parentNode;
        }

        return inline;
    },
    getInlineFirst: function(el)
    {
        var node = el || this.getCurrent();
        while (node)
        {
            if (this._isInlineNode(node))
            {
                return node;
            }

            node = node.parentNode;
        }

        return false;
    },
    getInlineAll: function(el)
    {
        var node = el || this.getCurrent();
        var inlines = [];
        while (node)
        {
            if (this._isInlineNode(node))
            {
                inlines.push(node);
            }

            node = node.parentNode;
        }

        return inlines;
    },
    getBlock: function(el)
    {
        var node = el || this.getCurrent();
        while (node)
        {
            var data = this.inspector.parse(node);
            var isBlock = this.inspector.isBlockTag(node.tagName);

            if (isBlock && data.isInEditor(node))
            {
                return node;
            }

            node = node.parentNode;
        }

        return false;
    },
    getInlinesAllSelected: function(options)
    {
        if (this.isAll()) return [];

        var inlines = this.getInlines({ all: true });
        var textNodes = this.getNodes({ textnodes: true, inline: false });
        var selected = this.getText().replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&");
        var finalNodes = [];

        if (textNodes.length !== 0)
        {
            return finalNodes;
        }

        if (selected === '')
        {
            finalNodes = inlines;
        }
        else if (inlines.length > 1)
        {
            for (var i = 0; i < inlines.length; i++)
            {
                if (this._isTextSelected(inlines[i], selected))
                {
                    finalNodes.push(inlines[i]);
                }
            }
        }
        else if (inlines.length === 1)
        {
            if (this._isTextSelected(inlines[0], selected))
            {
                finalNodes = inlines;
            }
        }

        finalNodes = (options && options.tags) ? this._filterNodesByTags(finalNodes, options.tags) : finalNodes;

        return finalNodes;
    },
    getInlines: function(options)
    {
        var nodes = this.getNodes();
        var filteredNodes = [];
        for (var i = 0; i < nodes.length; i++)
        {
            var node;
            if (options && options.all)
            {
                node = nodes[i];
                while (node)
                {
                    if (this._isInlineNode(node) && !this._isInNodesArray(filteredNodes, node))
                    {
                        filteredNodes.push(node);
                    }

                    node = node.parentNode;
                }
            }
            else
            {
                node = this.getInline(nodes[i]);
                if (node && !this._isInNodesArray(filteredNodes, node))
                {
                    filteredNodes.push(node);
                }
            }
        }

        // filter
        filteredNodes = (options && options.tags) ? this._filterNodesByTags(filteredNodes, options.tags) : filteredNodes;
        filteredNodes = (options && options.inside) ? this._filterInlinesInside(filteredNodes, options) : filteredNodes;

        return filteredNodes;
    },
    getBlocks: function(options)
    {
        var nodes = this.getNodes();
        var block = this.getBlock();
        nodes = (nodes.length === 0 && block) ? [block] : nodes;

        var filteredNodes = [];
        for (var i = 0; i < nodes.length; i++)
        {
            var node = this.getBlock(nodes[i]);
            var $node = $R.dom(node);
            if ($node.hasClass('non-editable')) continue;

            if (node && !this._isInNodesArray(filteredNodes, node))
            {
                filteredNodes.push(node);
            }
        }

        // filter
        filteredNodes = (options && options.tags) ? this._filterNodesByTags(filteredNodes, options.tags) : filteredNodes;
        filteredNodes = (options && options.first) ? this._filterBlocksFirst(filteredNodes, options) : filteredNodes;

        return filteredNodes;
    },
    getElements: function(options)
    {
        var nodes = this.getNodes({ textnodes: false });
        var block = this.getBlock();
        nodes = (nodes.length === 0 && block) ? [block] : nodes;

        var filteredNodes = [];
        for (var i = 0; i < nodes.length; i++)
        {
            if (!this._isInNodesArray(filteredNodes, nodes[i]))
            {
                filteredNodes.push(nodes[i]);
            }
        }

        // filter
        filteredNodes = (options && options.tags) ? this._filterNodesByTags(filteredNodes, options.tags) : filteredNodes;

        return filteredNodes;
    },
    getNodes: function(options)
    {
        var nodes = [];
        var activeComponent = this.component.getActive();
        if (activeComponent)
        {
            nodes = this._getNodesComponent(activeComponent);
        }
        else if (this.isCollapsed())
        {
            var current = this.getCurrent();
            nodes = (current) ? [current] : [];
        }
        else if (this.is() && !activeComponent)
        {
            nodes = this._getRangeSelectedNodes();
        }

        // filter
        nodes = this._filterServicesNodes(nodes);
        nodes = this._filterEditor(nodes);

        // options
        nodes = (options && options.tags) ? this._filterNodesByTags(nodes, options.tags) : nodes;
        nodes = (options && options.textnodes) ? this._filterNodesTexts(nodes, options) : nodes;
        nodes = (options && !options.textnodes) ? this._filterNodesElements(nodes) : nodes;

        return nodes;
    },

    // text & html
    getText: function()
    {
        var sel = this.get();
        return (sel) ? this.utils.removeInvisibleChars(sel.toString()) : '';
    },
    getHtml: function(clean)
    {
        var html = '';
        var sel = this.get();
        if (sel)
        {
            var container = document.createElement('div');
            var len = sel.rangeCount;
            for (var i = 0; i < len; ++i)
            {
                container.appendChild(sel.getRangeAt(i).cloneContents());
            }

            html = container.innerHTML;
            html = (clean !== false) ? this.cleaner.output(html) : html;
            html = html.replace(/<p><\/p>$/i, '');
        }

        return html;
    },

    // clear
    clear: function()
    {
        this.component.clearActive();
        this.get().removeAllRanges();
    },

    // collapse
    collapseToStart: function()
    {
        var sel = this.get();
        if (sel && !sel.isCollapsed) sel.collapseToStart();
    },
    collapseToEnd: function()
    {
        var sel = this.get();
        if (sel && !sel.isCollapsed) sel.collapseToEnd();
    },

    // save
    saveActiveComponent: function()
    {
        var activeComponent = this.component.getActive();
        if (activeComponent)
        {
            this.savedComponent = activeComponent;
            return true;
        }

        return false;
    },
    restoreActiveComponent: function()
    {
        if (this.savedComponent)
        {
            this.component.setActive(this.savedComponent);
            return true;
        }

        return false;
    },
    save: function()
    {
        this._clearSaved();

        var el = this.getElement();
        var tags = ['TD', 'TH', 'P', 'DIV', 'PRE', 'H1', 'H2', 'H3', 'H4', 'H5', 'H6', 'LI', 'BLOCKQUOTE'];
        if (el && (tags.indexOf(el.tagName) !== -1) && (el.innerHTML === '' || el.innerHTML === '<br>'))
        {
            this.savedElement = el;
        }
        else if (!this.saveActiveComponent())
        {
            this.saved = this.offset.get();
        }
    },
    restore: function()
    {
        if (!this.saved && !this.savedComponent && !this.savedElement) return;

        this.editor.saveScroll();

        if (this.savedElement)
        {
            this.caret.setStart(this.savedElement);
        }
        else if (!this.restoreActiveComponent())
        {
            this.offset.set(this.saved);
        }

        this._clearSaved();
        this.editor.restoreScroll();
    },
    saveMarkers: function()
    {
        this._clearSaved();

        if (!this.saveActiveComponent())
        {
            this.marker.insert();
        }
    },
    restoreMarkers: function()
    {
        this.editor.saveScroll();

        if (!this.restoreActiveComponent())
        {
            this.marker.restore();
        }

        this._clearSaved();
        this.editor.restoreScroll();
    },

    // private
    _getNextNode: function(node)
    {
        if (node.hasChildNodes()) return node.firstChild;

        while (node && !node.nextSibling)
        {
            node = node.parentNode;
        }

        if (!node) return null;

        return node.nextSibling;
    },
    _getNodesComponent: function(component)
    {
        var current = this.getCurrent();
        var data = this.inspector.parse(current);

        return (data.isFigcaption()) ? [data.getFigcaption()] : [component];
    },
    _getRangeSelectedNodes: function()
    {
        var nodes = [];
        var range = this.getRange();
        var node = range.startContainer;
        var startNode = range.startContainer;
        var endNode = range.endContainer;
        var $editor = this.editor.getElement();

        // editor
        if (startNode === $editor.get() && this.isAll())
        {
            nodes = this.utils.getChildNodes($editor);
        }
        // single node
        else if (node == endNode)
        {
            nodes = [node];
        }
        else
        {
            while (node && node != endNode)
            {
                nodes.push(node = this._getNextNode(node));
            }

            node = range.startContainer;
            while (node && node != range.commonAncestorContainer)
            {
                nodes.unshift(node);
                node = node.parentNode;
            }
        }

        return nodes;
    },
    _isInNodesArray: function(nodes, node)
    {
        return (nodes.indexOf(node) !== -1);
    },
    _filterEditor: function(nodes)
    {
        var filteredNodes = [];
        for (var i = 0; i < nodes.length; i++)
        {
            var data = this.inspector.parse(nodes[i]);
            if (data.isInEditor())
            {
                filteredNodes.push(nodes[i]);
            }
        }

        return filteredNodes;
    },
    _filterServicesNodes: function(nodes)
    {
        var filteredNodes = [];
        for (var i = 0; i < nodes.length; i++)
        {
            var $el = $R.dom(nodes[i]);
            var skip = false;

            if (nodes[i] && nodes[i].nodeType === 3 && this.utils.isEmpty(nodes[i])) skip = true;
            if ($el.hasClass('redactor-script-tag')
                || $el.hasClass('redactor-component-caret')
                || $el.hasClass('redactor-selection-marker')
                || $el.hasClass('non-editable')) skip = true;

            if (!skip)
            {
                filteredNodes.push(nodes[i]);
            }
        }

        return filteredNodes;
    },
    _filterNodesTexts: function(nodes, options)
    {
        var filteredNodes = [];
        for (var i = 0; i < nodes.length; i++)
        {
            if (nodes[i].nodeType === 3 || (options.keepbr && nodes[i].tagName === 'BR'))
            {
                var inline = this.getInline(nodes[i]);
                var isInline = (inline && options && options.inline === false);
                if (!isInline)
                {
                    filteredNodes.push(nodes[i]);
                }
            }
        }

        return filteredNodes;
    },
    _filterNodesElements: function(nodes)
    {
        var filteredNodes = [];
        for (var i = 0; i < nodes.length; i++)
        {
            if (nodes[i].nodeType !== 3)
            {
                filteredNodes.push(nodes[i]);
            }
        }

        return filteredNodes;
    },
    _filterNodesByTags: function(nodes, tags, passtexts)
    {
        var filteredNodes = [];
        for (var i = 0; i < nodes.length; i++)
        {
            if (passtexts && nodes[i].nodeType === 3)
            {
                filteredNodes.push(nodes[i]);
            }
            else if (nodes[i].nodeType !== 3)
            {
                var nodeTag = nodes[i].tagName.toLowerCase();
                if (tags.indexOf(nodeTag.toLowerCase()) !== -1)
                {
                    filteredNodes.push(nodes[i]);
                }
            }
        }

        return filteredNodes;
    },
    _filterBlocksFirst: function(nodes)
    {
        var filteredNodes = [];
        for (var i = 0; i < nodes.length; i++)
        {
            var $node = $R.dom(nodes[i]);
            var parent = $node.parent().get();
            var isFirst = ($node.parent().hasClass('redactor-in'));
            var isCellParent = (parent && (parent.tagName === 'TD' || parent.tagName === 'TH'));
            if (isFirst || isCellParent)
            {
                filteredNodes.push(nodes[i]);
            }
        }

        return filteredNodes;
    },
    _filterInlinesInside: function(nodes)
    {
        var filteredNodes = [];
        for (var i = 0; i < nodes.length; i++)
        {
            if (window.getSelection().containsNode(nodes[i], true))
            {
                filteredNodes.push(nodes[i]);
            }
        }

        return filteredNodes;
    },
    _isTextSelected: function(node, selected)
    {
        var text = this.utils.removeInvisibleChars(node.textContent);

        return (
            selected === text
            || text.search(selected) !== -1
            || selected.search(new RegExp('^' + text)) !== -1
            || selected.search(new RegExp(text + '$')) !== -1
        );
    },
    _isInlineNode: function(node)
    {
        var data = this.inspector.parse(node);

        return (this.inspector.isInlineTag(node.tagName) && data.isInEditor());
    },
    _clearSaved: function()
    {
        this.saved = false;
        this.savedComponent = false;
        this.savedElement = false;
    }
});
$R.add('service', 'element', {
    init: function(app)
    {
        this.app = app;
        this.rootElement = app.rootElement;

        // local
        this.$element = {};
        this.type = 'inline';
    },
    start: function()
    {
        this._build();
        this._buildType();
    },

    // public
    isType: function(type)
    {
        return (type === this.type);
    },
    getType: function()
    {
        return this.type;
    },
    getElement: function()
    {
        return this.$element;
    },

    // private
    _build: function()
    {
        this.$element = $R.dom(this.rootElement);
    },
    _buildType: function()
    {
        var tag = this.$element.get().tagName;

        this.type = (tag === 'TEXTAREA') ? 'textarea' : this.type;
        this.type = (tag === 'DIV') ? 'div' : this.type;
        this.type = (this.opts.inline) ? 'inline' : this.type;
    }
});
$R.add('service', 'editor', {
    init: function(app)
    {
        this.app = app;

        // local
        this.scrolltop = false;
        this.pasting = false;
    },

    // start
    start: function()
    {
        this._build();
    },

    // focus
    focus: function()
    {
        if (!this.isFocus() && !this._isContenteditableFocus())
        {
            this.saveScroll();
            this.$editor.focus();
            this.restoreScroll();
        }
    },
    startFocus: function()
    {
        this.caret.setStart(this.getFirstNode());
    },
    endFocus: function()
    {
        this.caret.setEnd(this.getLastNode());
    },

    // pasting
    isPasting: function()
    {
        return this.pasting;
    },
    enablePasting: function()
    {
        this.pasting = true;
    },
    disablePasting: function()
    {
        this.pasting = false;
    },

    // scroll
    saveScroll: function()
    {
        this.scrolltop = this._getScrollTarget().scrollTop();
    },
    restoreScroll: function()
    {
        if (this.scrolltop !== false)
        {
            this._getScrollTarget().scrollTop(this.scrolltop);
            this.scrolltop = false;
        }
    },

    // non editables
    disableNonEditables: function()
    {
        this.$noneditables = this.$editor.find('[contenteditable=false]');
        this.$noneditables.attr('contenteditable', true);
    },
    enableNonEditables: function()
    {
        if (this.$noneditables)
        {
            setTimeout(function() { this.$noneditables.attr('contenteditable', false); }.bind(this), 1);
        }
    },

    // nodes
    getFirstNode: function()
    {
        return this.$editor.contents()[0];
    },
    getLastNode: function()
    {
        var nodes = this.$editor.contents();

        return nodes[nodes.length-1];
    },

    // utils
    isSourceMode: function()
    {
        var $source = this.source.getElement();

        return $source.hasClass('redactor-source-open');
    },
    isEditor: function(el)
    {
        var node = $R.dom(el).get();

        return (node === this.$editor.get());
    },
    isEmpty: function(keeplists)
    {
        return this.utils.isEmptyHtml(this.$editor.html(), false, keeplists);
    },
    isFocus: function()
    {
        var $active = $R.dom(document.activeElement);
        var isComponentSelected = (this.$editor.find('.redactor-component-active').length !== 0);

        return (isComponentSelected || $active.closest('.redactor-in-' + this.uuid).length !== 0);
    },
    setEmpty: function()
    {
        this.$editor.html(this.opts.emptyHtml);
    },

    // element
    getElement: function()
    {
        return this.$editor;
    },

    // private
    _build: function()
    {
        var $element = this.element.getElement();
        var editableElement = (this.element.isType('textarea')) ? '<div>' : $element.get();

        this.$editor = $R.dom(editableElement);
    },
    _getScrollTarget: function()
    {
        var $target = this.$doc;
        if (this.opts.toolbarFixedTarget !== document)
        {
            $target = $R.dom(this.opts.toolbarFixedTarget);
        }
        else
        {
            $target = (this.opts.scrollTarget) ? $R.dom(this.opts.scrollTarget) : $target;
        }

        return $target;
    },
    _isContenteditableFocus: function()
    {
        var block = this.selection.getBlock();
        var $blockParent = (block) ? $R.dom(block).closest('[contenteditable=true]').not('.redactor-in') : [];

        return ($blockParent.length !== 0);
    }
});
$R.add('service', 'container', {
    init: function(app)
    {
        this.app = app;
    },
    // public
    start: function()
    {
        this._build();
    },
    getElement: function()
    {
        return this.$container;
    },

    // private
    _build: function()
    {
        var tag = (this.element.isType('inline')) ? '<span>' : '<div>';
        this.$container = $R.dom(tag);
    }
});
$R.add('service', 'source', {
    init: function(app)
    {
        this.app = app;

        // local
        this.$source = {};
        this.content = '';
    },
    // public
    start: function()
    {
        this._build();
        this._buildName();
        this._buildStartedContent();
    },
    getElement: function()
    {
        return this.$source;
    },
    getCode: function()
    {
        return this.$source.val();
    },
    getName: function()
    {
        return this.$source.attr('name');
    },
    getStartedContent: function()
    {
        return this.content;
    },
    setCode: function(html)
    {
        return this.insertion.set(html, true, false);
    },
    isNameGenerated: function()
    {
        return (this.name);
    },
    rebuildStartedContent: function()
    {
        this._buildStartedContent();
    },

    // private
    _build: function()
    {
        var $element = this.element.getElement();
        var isTextarea = this.element.isType('textarea');
        var sourceElement = (isTextarea) ? $element.get() : '<textarea>';

        this.$source = $R.dom(sourceElement);
    },
    _buildName: function()
    {
        var $element = this.element.getElement();

        this.name = $element.attr('name');
        this.$source.attr('name', (this.name) ? this.name : 'content-' + this.uuid);
    },
    _buildStartedContent: function()
    {
        var $element = this.element.getElement();
        var content = (this.element.isType('textarea')) ? $element.val() : $element.html();

        this.content = content.trim();
    }
});
$R.add('service', 'statusbar', {
    init: function(app)
    {
        this.app = app;

        // local
        this.$statusbar = {};
        this.items = [];
    },
    // public
    start: function()
    {
        this.$statusbar = $R.dom('<ul>');
        this.$statusbar.attr('dir', this.opts.direction);
    },
    add: function(name, html)
    {
        return this.update(name, html);
    },
    update: function(name, html)
    {
        var $item;
        if (typeof this.items[name] !== 'undefined')
        {
            $item = this.items[name];
        }
        else
        {
            $item = $R.dom('<li>');
            this.$statusbar.append($item);
            this.items[name] = $item;
        }

        return $item.html(html);
    },
    get: function(name)
    {
        return (this.items[name]) ? this.items[name] : false;
    },
    remove: function(name)
    {
        if (this.items[name])
        {
            this.items[name].remove();
            delete this.items[name];
        }
    },
    getItems: function()
    {
        return this.items;
    },
    removeItems: function()
    {
        this.items = {};
        this.$statusbar.html('');
    },
    getElement: function()
    {
        return this.$statusbar;
    }
});
$R.add('service', 'toolbar', {
    init: function(app)
    {
        this.app = app;

        // local
        this.buttons = [];
        this.dropdownOpened = false;
        this.buttonsObservers = {};
    },
    // public
    start: function()
    {
        if (this.is())
        {
            this.opts.activeButtons = (this.opts.activeButtonsAdd) ? this._extendActiveButtons() : this.opts.activeButtons;
            this.create();
        }
    },
    stopObservers: function()
    {
        this.buttonsObservers = {};
    },
    create: function()
    {
        this.$wrapper = $R.dom('<div>');
        this.$toolbar = $R.dom('<div>');
    },
    observe: function()
    {
        if (!this.is()) return;

        this.setButtonsInactive();

        var button, observer;

        // observers
        for (var name in this.buttonsObservers)
        {
            observer = this.buttonsObservers[name];
            button = this.getButton(name);
            this.app.broadcast('button.' + observer + '.observe', button);
        }

        // inline buttons
        var buttons = this.opts.activeButtons;
        var inlines = this.selection.getInlinesAllSelected();
        var current = this.selection.getInline();
        if (this.selection.isCollapsed() && current)
        {
            inlines.push(current);
        }

        var tags = this._inlinesToTags(inlines);
        for (var key in buttons)
        {
            if (tags.indexOf(key) !== -1)
            {
                button = this.getButton(buttons[key]);
                button.setActive();
            }

        }
    },

    // is
    is: function()
    {
        return !(!this.opts.toolbar || (this.detector.isMobile() && this.opts.air));
    },
    isAir: function()
    {
        return (this.is()) ? this.$toolbar.hasClass('redactor-air') : false;
    },
    isFixed: function()
    {
        return (this.is()) ? this.$toolbar.hasClass('redactor-toolbar-fixed') : false;
    },
    isContextBar: function()
    {
        var $bar = this.$body.find('#redactor-context-toolbar-' + this.uuid);
        return $bar.hasClass('open');
    },
    isTarget: function()
    {
        return (this.opts.toolbarFixedTarget !== document);
    },

    // get
    getElement: function()
    {
        return this.$toolbar;
    },
    getWrapper: function()
    {
        return this.$wrapper;
    },
    getDropdown: function()
    {
        return this.dropdownOpened;
    },
    getTargetElement: function()
    {
        return $R.dom(this.opts.toolbarFixedTarget);
    },
    getButton: function(name)
    {
        var $btn = this._findButton('.re-' + name);

        return ($btn.length !== 0) ? $btn.dataget('data-button-instance') : false;
    },
    getButtonByIndex: function(index)
    {
        var $btn = this.$toolbar.find('.re-button').eq(index);

        return ($btn.length !== 0) ? $btn.dataget('data-button-instance') : false;
    },
    getButtons: function()
    {
        var buttons = [];
        this._findButtons().each(function(node)
        {
            var $node = $R.dom(node);
            buttons.push($node.dataget('data-button-instance'));
        });

        return buttons;
    },
    getButtonsKeys: function()
    {
        var keys = [];
        this._findButtons().each(function(node)
        {
            var $node = $R.dom(node);
            keys.push($node.attr('data-re-name'));
        });

        return keys;
    },

    // add
    addButton: function(name, btnObj, position, $el, start)
    {
        position = position || 'end';

        var index = this._getButtonIndex(name);
        var $button = $R.create('toolbar.button', this.app, name, btnObj);

        if (btnObj.observe)
        {
            this.opts.activeButtonsObservers[name] = { observe: btnObj.observe, button: $button };
        }

        // api added
        if (start !== true)
        {
            if (index === 0) position = 'first';
            else if (index !== -1)
            {
                var $elm = this.getButtonByIndex(index-1);
                if ($elm)
                {
                    position = 'after';
                    $el = $elm;
                }
            }
        }

        if (this.is())
        {
            if (position === 'first') this.$toolbar.prepend($button);
            else if (position === 'after') $el.after($button);
            else if (position === 'before') $el.before($button);
            else this.$toolbar.append($button);
        }

        return $button;
    },
    addButtonFirst: function(name, btnObj)
    {
        return this.addButton(name, btnObj, 'first');
    },
    addButtonAfter: function(after, name, btnObj)
    {
        var $btn = this.getButton(after);

        return ($btn) ? this.addButton(name, btnObj, 'after', $btn) : this.addButton(name, btnObj);
    },
    addButtonBefore: function(before, name, btnObj)
    {
        var $btn = this.getButton(before);

        return ($btn) ? this.addButton(name, btnObj, 'before', $btn) : this.addButton(name, btnObj);
    },
    addButtonObserver: function(name, observer)
    {
        this.buttonsObservers[name] = observer;
    },

    // set
    setButtons: function(buttons)
    {
        this.buttons = buttons;
    },
    setDropdown: function(dropdown)
    {
        this.dropdownOpened = dropdown;
    },
    setButtonsInactive: function()
    {
        var $buttons = this.getButtons();
        for (var i = 0; i < $buttons.length; i++)
        {
            $buttons[i].setInactive();
        }
    },
    setButtonsActive: function()
    {
        var $buttons = this.getButtons();
        for (var i = 0; i < $buttons.length; i++)
        {
            $buttons[i].setActive();
        }
    },

    // disable & enable
    disableButtons: function()
    {
        var $buttons = this.getButtons();
        for (var i = 0; i < $buttons.length; i++)
        {
            $buttons[i].disable();
        }
    },
    enableButtons: function()
    {
        var $buttons = this.getButtons();
        for (var i = 0; i < $buttons.length; i++)
        {
            $buttons[i].enable();
        }

    },

    // private
    _getButtonIndex: function(name)
    {
        var index = this.buttons.indexOf(name);

        return (index === -1) ? false : index;
    },
    _findButton: function(selector)
    {
        return (this.is()) ? this.$toolbar.find(selector) : $R.dom();
    },
    _findButtons: function()
    {
        return (this.is()) ? this.$toolbar.find('.re-button') : $R.dom();
    },
    _extendActiveButtons: function()
    {
        return $R.extend({}, this.opts.activeButtons, this.opts.activeButtonsAdd);
    },
    _inlinesToTags: function(inlines)
    {
        var tags = [];
        for (var i = 0; i < inlines.length; i++)
        {
            tags.push(inlines[i].tagName.toLowerCase());
        }

        return tags;
    }
});
$R.add('class', 'toolbar.button', {
    mixins: ['dom'],
    init: function(app, name, btnObj)
    {
        this.app = app;
        this.opts = app.opts;
        this.lang = app.lang;
        this.$body = app.$body;
        this.toolbar = app.toolbar;
        this.detector = app.detector;

        // local
        this.obj = btnObj;
        this.name = name;
        this.dropdown = false;
        this.tooltip = false;

        // init
        this._init();
    },
    // is
    isActive: function()
    {
        return this.hasClass('redactor-button-active');
    },
    isDisabled: function()
    {
        return this.hasClass('redactor-button-disabled');
    },

    // has
    hasIcon: function()
    {
        return (this.obj.icon && !this.opts.buttonsTextLabeled);
    },

    // set
    setDropdown: function(dropdown)
    {
        this.obj.dropdown = dropdown;
        this.obj.message = false;
        this.dropdown = $R.create('toolbar.dropdown', this.app, this.name, this.obj.dropdown);
        this.attr('data-dropdown', true);
    },
    setMessage: function(message, args)
    {
        this.obj.message = message;
        this.obj.args = args;
        this.obj.dropdown = false;
    },
    setApi: function(api, args)
    {
        this.obj.api = api;
        this.obj.args = args;
        this.obj.dropdown = false;
    },
    setTitle: function(title)
    {
        this.obj.title = this.lang.parse(title);
        this.obj.tooltip = this.obj.title;

        this.attr({ 'alt': this.obj.tooltip, 'aria-label': this.obj.tooltip });
        if (!this.attr('data-re-icon')) this.html(this.obj.title);
    },
    setTooltip: function(tooltip)
    {
        this.obj.tooltip = this.lang.parse(tooltip);
        this.attr({ 'alt': this.obj.tooltip, 'aria-label': this.obj.tooltip });
    },
    setIcon: function(icon)
    {
        if (this.opts.buttonsTextLabeled) return;

        this.obj.icon = true;
        this.$icon = $R.dom(icon);

        this.html('');
        this.append(this.$icon);
        this.attr('data-re-icon', true);
        this.addClass('re-button-icon');
        this.setTooltip(this.obj.title);
        this._buildTooltip();
    },
    setActive: function()
    {
        this.addClass('redactor-button-active');
    },
    setInactive: function()
    {
        this.removeClass('redactor-button-active');
    },

    // hide
    hideTooltip: function()
    {
        this.$body.find('.re-button-tooltip').remove();
    },

    // get
    getDropdown: function()
    {
        return this.dropdown;
    },

    // enable & disable
    disable: function()
    {
        this.addClass('redactor-button-disabled');
    },
    enable: function()
    {
        this.removeClass('redactor-button-disabled');
    },

    // toggle
    toggle: function(e)
    {
        if (e) e.preventDefault();
        if (this.isDisabled()) return;

        if (this.obj.dropdown)
        {
            this.dropdown.toggle(e);
        }
        else if (this.obj.api)
        {
            // broadcast
            this.app.api(this.obj.api, this.obj.args, this.name);
        }
        else if (this.obj.message)
        {
            // broadcast
            this.app.broadcast(this.obj.message, this.obj.args, this.name);
        }

        this.hideTooltip();
    },

    // private
    _init: function()
    {
        // parse
        this._parseTitle();
        this._parseTooltip();

        // build
        this._build();
        this._buildCallback();
        this._buildAttributes();
        this._buildObserver();

        if (this.hasIcon())
        {
            this._buildIcon();
            this._buildTooltip();
        }
        else
        {
            this.html(this.obj.title);
        }
    },
    _parseTooltip: function()
    {
        this.obj.tooltip = (this.obj.tooltip) ? this.lang.parse(this.obj.tooltip) : this.obj.title;
    },
    _parseTitle: function()
    {
        this.obj.title = this.lang.parse(this.obj.title);
    },
    _build: function()
    {
        this.parse('<a>');
        this.addClass('re-button re-' + this.name);
        this.attr('data-re-name', this.name);
        this.dataset('data-button-instance', this);

        if (this.obj.dropdown) this.setDropdown(this.obj.dropdown);
    },
    _buildCallback: function()
    {
        this.on('click', this.toggle.bind(this));
    },
    _buildAttributes: function()
    {
        var attrs = {
            'href': '#',
            'alt': this.obj.tooltip,
            'rel': this.name,
            'role': 'button',
            'aria-label': this.obj.tooltip,
            'tabindex': '-1'
        };

        this.attr(attrs);
    },
    _buildObserver: function()
    {
        if (typeof this.obj.observe !== 'undefined')
        {
            this.toolbar.addButtonObserver(this.name, this.obj.observe);
        }
    },
    _buildIcon: function()
    {
        var icon = this.obj.icon;
        var isHtml = (/(<([^>]+)>)/ig.test(icon));

        this.$icon = (isHtml) ? $R.dom(icon) : $R.dom('<i>');
        if (!isHtml) this.$icon.addClass('re-icon-' + this.name);

        this.append(this.$icon);
        this.attr('data-re-icon', true);
        this.addClass('re-button-icon');
    },
    _buildTooltip: function()
    {
        if (this.detector.isDesktop())
        {
            this.tooltip = $R.create('toolbar.button.tooltip', this.app, this);
        }
    }
});
$R.add('class', 'toolbar.button.tooltip', {
    mixins: ['dom'],
    init: function(app, $button)
    {
        this.app = app;
        this.uuid = app.uuid;
        this.opts = app.opts;
        this.$body = app.$body;
        this.toolbar = app.toolbar;

        // local
        this.$button = $button;
        this.created = false;

        // init
        this._init();
    },
    open: function()
    {
        if (this.$button.hasClass('redactor-button-disabled') || this.$button.hasClass('redactor-button-active')) return;

        this.created = true;
        this.parse('<span>');
        this.addClass('re-button-tooltip re-button-tooltip-' + this.uuid);
        this.$body.append(this);
        this.html(this.$button.attr('alt'));

        var offset = this.$button.offset();
        var position = 'absolute';
        var height = this.$button.height();
        var width = this.$button.width();
        var arrowOffset = 4;

        this.css({
            top: (offset.top + height + arrowOffset) + 'px',
            left: (offset.left + width/2 - this.width()/2) + 'px',
            position: position
        });

        this.show();
    },
    close: function()
    {
        if (!this.created || this.$button.hasClass('redactor-button-disabled')) return;

        this.remove();
        this.created = false;
    },

    // private
    _init: function()
    {
        this.$button.on('mouseover', this.open.bind(this));
        this.$button.on('mouseout', this.close.bind(this));
    }
});
$R.add('class', 'toolbar.dropdown', {
    mixins: ['dom'],
    init: function(app, name, items)
    {
        this.app = app;
        this.uuid = app.uuid;
        this.opts = app.opts;
        this.$win = app.$win;
        this.$doc = app.$doc;
        this.$body = app.$body;
        this.animate = app.animate;
        this.toolbar = app.toolbar;

        // local
        this.name = name;
        this.started = false;
        this.items = items;
        this.$items = [];
    },
    // public
    toggle: function(e)
    {
        if (!this.started)
        {
            this._build();
        }

        // toggle
        if (this.isOpened() && this.isActive())
        {
            this.close(false);
        }
        else
        {
            this.open(e);
        }
    },
    isOpened: function()
    {
        var $dropdown = this.$body.find('.redactor-dropdown-' + this.uuid + '.open');

        return ($dropdown.length !== 0 && $dropdown.attr('data-re-name') === this.name);
    },
    isActive: function()
    {
        var $dropdown = this.$body.find('#redactor-dropdown-' + this.uuid + '-' + this.name + '.open');
        return ($dropdown.length !== 0);
    },
    getName: function()
    {
        return this.attr('data-re-name');
    },
    getItem: function(name)
    {
        return this.$items[name];
    },
    getItemsByClass: function(classname)
    {
        var result = [];
        for (var key in this.$items)
        {
            if (typeof this.$items[key] === 'object' && this.$items[key].hasClass(classname))
            {
                result.push(this.$items[key]);
            }
        }

        return result;
    },
    open: function(e)
    {
        this._closeAll();

        this.$btn = this.toolbar.getButton(this.name);
        this.app.broadcast('dropdown.open', e, this, this.$btn);
        this.toolbar.setDropdown(this);

        this.show();
        this.removeClass('redactor-animate-hide');
        this.addClass('open');
        this._observe();

        this.$btn.hideTooltip();
        this.$btn.setActive();

        this.$doc.on('keyup.redactor.dropdown-' + this.uuid, this._handleKeyboard.bind(this));
        this.$doc.on('click.redactor.dropdown-' + this.uuid, this.close.bind(this));

        this.updatePosition();
        this.app.broadcast('dropdown.opened', e, this, this.$btn);

    },
    close: function(e, animate)
    {
        if (e)
        {
            var $el = $R.dom(e.target);
            if (this._isButton(e) || $el.hasClass('redactor-dropdown-not-close') || $el.hasClass('redactor-dropdown-item-disabled'))
            {
                e.preventDefault();
                return;
            }
        }

        this.app.broadcast('dropdown.close', this, this.$btn);
        this.toolbar.setDropdown(false);

        this.$btn.setInactive();
        if (animate === false)
        {
            this._close();
        }
        else
        {
            this.animate.start(this, 'fadeOut', this._close.bind(this));
        }
    },
    updatePosition: function()
    {
        var isFixed = this.toolbar.isFixed();
        var pos = this.$btn.offset();
        pos.top = (isFixed) ? this.$btn.position().top : pos.top;

        var btnHeight = this.$btn.height();
        var btnWidth = this.$btn.width();
        var position = (isFixed) ? 'fixed' : 'absolute';
        var topOffset = (isFixed) ? (2 + this.opts.toolbarFixedTopOffset) : 2;
        var leftOffset = 0;
        var left = (pos.left + leftOffset);
        var width = parseFloat(this.css('width'));
        var winWidth = this.$win.width();
        var leftFix = (winWidth < (left + width)) ? (width - btnWidth) : 0;
        var leftPos = (left - leftFix);
        leftPos = (leftPos < 0) ? 4 : leftPos;

        this.css({ position: position, top: (pos.top + btnHeight + topOffset) + 'px', left: leftPos + 'px' });
    },

    // private
    _build: function()
    {
        this.parse('<div>');
        this.attr('dir', this.opts.direction);
        this.attr('id', 'redactor-dropdown-' + this.uuid + '-' + this.name);
        this.attr('data-re-name', this.name);

        this.addClass('redactor-dropdown redactor-dropdown-' + this.uuid + ' redactor-dropdown-' + this.name);
        this.dataset('data-dropdown-instance', this);
        var isDom = (this.items.dom || typeof this.items === 'string');

        if (isDom) this._buildDom();
        else this._buildItems();

        this.$body.append(this);
        this.started = true;
    },
    _buildDom: function()
    {
        this.html('').append($R.dom(this.items));
    },
    _buildItems: function()
    {
        this.items = (this.name === 'format') ? this._buildFormattingItems() : this.items;

        for (var key in this.items)
        {
            var obj = this.items[key];

            if (key === 'observe')
            {
                this.attr('data-observe', this.items[key]);
            }
            else
            {
                var $item = $R.create('toolbar.dropdown.item', this.app, key, obj, this);

                this.$items[key] = $item;
                this.append($item);
            }
        }
    },
    _buildFormattingItems: function()
    {
        // build the format set
        for (var key in this.items)
        {
            if (this.opts.formatting.indexOf(key) === -1) delete this.items[key];
        }

        // remove from the format set
        if (this.opts.formattingHide)
        {
            for (var key in this.items)
            {
                if (this.opts.formattingHide.indexOf(key) !== -1) delete this.items[key];
            }
        }

        // add to the format set
        if (this.opts.formattingAdd)
        {
            for (var key in this.opts.formattingAdd)
            {
                this.items[key] = this.opts.formattingAdd[key];
            }
        }

        return this.items;
    },
    _handleKeyboard: function(e)
    {
        if (e.which === 27) this.close();
    },
    _isButton: function(e)
    {
        var $el = $R.dom(e.target);
        var $btn = $el.closest('.re-button');

        return ($btn.get() === this.$btn.get());
    },
    _close: function()
    {
        this.$btn.setInactive();
        this.$doc.off('.redactor.dropdown-' + this.uuid);
        this.removeClass('open');
        this.addClass('redactor-animate-hide');
        this.app.broadcast('dropdown.closed', this, this.$btn);
    },
    _closeAll: function()
    {
        this.$body.find('.redactor-dropdown-' + this.uuid + '.open').each(function(node)
        {
            var $node = $R.dom(node);
            var instance =  $node.dataget('data-dropdown-instance');
            instance._close();
        });
    },
    _observe: function()
    {
        var observer = this.attr('data-observe');
        if (observer)
        {
            this.app.broadcast('dropdown.' + observer + '.observe', this);
        }
    }
});
$R.add('class', 'toolbar.dropdown.item', {
    mixins: ['dom'],
    init: function(app, name, obj, dropdown)
    {
        this.app = app;
        this.lang = app.lang;

        // local
        this.dropdown = dropdown;
        this.name = name;
        this.obj = obj;

        // init
        this._init();
    },
    setTitle: function(html)
    {
        this.$span.html(html);
    },
    getTitle: function()
    {
        return this.$span.html();
    },
    enable: function()
    {
        this.removeClass('redactor-dropdown-item-disabled');
    },
    disable: function()
    {
        this.addClass('redactor-dropdown-item-disabled');
    },
    toggle: function(e)
    {
        if (e) e.preventDefault();
        if (this.hasClass('redactor-dropdown-item-disabled')) return;

        if (this.obj.message)
        {
            // broadcast
            this.app.broadcast(this.obj.message, this.obj.args, this.name);
        }
        else if (this.obj.api)
        {
            this.app.api(this.obj.api, this.obj.args, this.name);
        }
    },

    // private
    _init: function()
    {
        this.parse('<a>');
        this.attr('href', '#');
        this.addClass('redactor-dropdown-item-' + this.name);

        if (this.obj.classname)
        {
            this.addClass(this.obj.classname);
        }

        this.attr('data-re-name', this.name);
        this.on('click', this.toggle.bind(this));

        this.$span = $R.dom('<span>');
        this.append(this.$span);
        this.setTitle(this.lang.parse(this.obj.title));
    }
});
$R.add('service', 'cleaner', {
    init: function(app)
    {
        this.app = app;
        this.opts = app.opts;

        // local
        this.storedComponents = [];
        this.storedImages = [];
        this.storedLinks = [];
        this.deniedTags = ['font', 'html', 'head', 'link', 'title', 'body', 'meta', 'applet'];
        this.convertRules = {};
        this.unconvertRules = {};

        // regex
        this.reComments = /<!--[\s\S]*?-->/g;
        this.reSpacedEmpty = /^(||\s||<br\s?\/?>||&nbsp;)$/i;
        this.reScriptTag = /<script(.*?[^>]?)>([\w\W]*?)<\/script>/gi;
    },
    // public
    addConvertRules: function(name, func)
    {
        this.convertRules[name] = func;
    },
    addUnconvertRules: function(name, func)
    {
        this.unconvertRules[name] = func;
    },
    input: function(html, paragraphize, started)
    {
        // pre/code
        html = this.encodePreCode(html);

        // converting entity
        html = html.replace(/\$/g, '&#36;');
        html = html.replace(/&amp;/g, '&');

        // convert to figure
        var converter = $R.create('cleaner.figure', this.app);
        html = converter.convert(html, this.convertRules);

        // store components
        html = this.storeComponents(html);

        // clean
        html = this.replaceTags(html, this.opts.replaceTags);
        html = this._setSpanAttr(html);
        html = this._setStyleCache(html);
        html = this.removeTags(html, this.deniedTags);
        //html = (this.opts.removeScript) ? this._removeScriptTag(html) : this._replaceScriptTag(html);
        html = (this.opts.removeScript) ? this._removeScriptTag(html) : html;
        html = (this.opts.removeComments) ? this.removeComments(html) : html;
        html = (this._isSpacedEmpty(html)) ? this.opts.emptyHtml : html;

        // restore components
        html = this.restoreComponents(html);

        // clear wrapped components
        html = this._cleanWrapped(html);

        // paragraphize
        html = (paragraphize) ? this.paragraphize(html) : html;

        return html;
    },
    output: function(html, removeMarkers)
    {
        html = this.removeInvisibleSpaces(html);

        // empty
        if (this._isSpacedEmpty(html)) return '';
        if (this._isParagraphEmpty(html)) return '';

        html = this.removeServiceTagsAndAttrs(html, removeMarkers);

        // store components
        html = this.storeComponents(html);

        html = this.removeSpanWithoutAttributes(html);
        html = this.removeFirstBlockBreaklineInHtml(html);

        html = (this.opts.removeScript) ? html : this._unreplaceScriptTag(html);
        html = (this.opts.preClass) ? this._setPreClass(html) : html;
        html = (this.opts.linkNofollow) ? this._setLinkNofollow(html) : html;
        html = (this.opts.removeNewLines) ? this.cleanNewLines(html) : html;

        // restore components
        html = this.restoreComponents(html);

        // convert to figure
        var converter = $R.create('cleaner.figure', this.app);
        html = converter.unconvert(html, this.unconvertRules);

        // final clean up
        html = this.removeEmptyAttributes(html, ['style', 'class', 'rel', 'alt', 'title']);
        html = this.cleanSpacesInPre(html);
        html = this.tidy(html);

        // converting entity
        html = html.replace(/&amp;/g, '&');

        // check whitespaces
        html = (html.replace(/\n/g, '') === '') ? '' : html;

        return html;
    },
    paste: function(html)
    {
        // store components
        html = this.storeComponents(html);

        // remove tags
        var deniedTags = this.deniedTags.concat(['iframe']);
        html = this.removeTags(html, deniedTags);

        // remove doctype tag
        html = html.replace(new RegExp("<\!doctype([\\s\\S]+?)>", 'gi'), '');

        // remove style tag
        html = html.replace(new RegExp("<style([\\s\\S]+?)</style>", 'gi'), '');

        // remove br between
        html = html.replace(new RegExp("</p><br /><p", 'gi'), '</p><p');

        // gdocs & word
        var isMsWord = this._isHtmlMsWord(html);

        html = this._cleanGDocs(html);
        html = (isMsWord) ? this._cleanMsWord(html) : html;

        // do not clean
        if (!this.opts.pasteClean)
        {
            // restore components
            html = this.restoreComponents(html);

            return html;
        }

        // plain text
        if (this.opts.pastePlainText)
        {
            // restore components
            html = this.restoreComponents(html);

            return this.pastePlainText(html);
        }

        // remove tags
        var exceptedTags = this.opts.pasteBlockTags.concat(this.opts.pasteInlineTags);
        html = this.removeTagsExcept(html, exceptedTags);

        // links & images
        html = (this.opts.pasteLinks) ? html : this.removeTags(html, ['a']);
        html = (this.opts.pasteImages) ? html : this.removeTags(html, ['img']);

        // build wrapper
        var $wrapper = this.utils.buildWrapper(html);

        // clean attrs
        var $elms = $wrapper.find('*');

        // remove style
        var filterStyle = (this.opts.pasteKeepStyle.length !== 0) ? ',' + this.opts.pasteKeepStyle.join(',') : '';
        $elms.not('[data-redactor-style-cache]' + filterStyle).removeAttr('style');

        // remove class
        var filterClass = (this.opts.pasteKeepClass.length !== 0) ? ',' + this.opts.pasteKeepClass.join(',') : '';
        $elms.not('[data-redactor-style-cache], span.redactor-component' + filterClass).removeAttr('class');

        // remove attrs
        var filterAttrs = (this.opts.pasteKeepAttrs.length !== 0) ? ',' + this.opts.pasteKeepAttrs.join(',') : '';
        $elms.not('img, a, span.redactor-component, [data-redactor-style-cache]' + filterAttrs).each(function(node)
        {
            while(node.attributes.length > 0)
            {
                node.removeAttribute(node.attributes[0].name);
            }
        });

        // paste link target
        if (this.opts.pasteLinks && this.opts.pasteLinkTarget !== false)
        {
            $wrapper.find('a').attr('target', this.opts.pasteLinkTarget);
        }

        // keep style
        $wrapper.find('[data-redactor-style-cache]').each(function(node)
        {
            var style = node.getAttribute('data-redactor-style-cache');
            node.setAttribute('style', style);
        });

        // remove empty span
        $wrapper.find('span').each(function(node)
        {
            if (node.attributes.length === 0)
            {
                $R.dom(node).unwrap();
            }
        });

        // remove empty inline
        $wrapper.find(this.opts.inlineTags.join(',')).each(function(node)
        {
            if (node.attributes.length === 0 && this.utils.isEmptyHtml(node.innerHTML))
            {
                $R.dom(node).unwrap();
            }

        }.bind(this));

        // place ul/ol into li
        $wrapper.find('ul, ol').each(function(node)
        {
            var prev = node.previousSibling;
            if (prev && prev.tagName === 'LI')
            {
                var $li = $R.dom(prev);
                $li.find('p').unwrap();
                $li.append(node);
            }
        });

        // get wrapper
        html = this.utils.getWrapperHtml($wrapper);

        // remove paragraphs form lists (google docs bug)
        html = html.replace(/<li><p>/gi, '<li>');
        html = html.replace(/<\/p><\/li>/gi, '</li>');

        // clean empty p
        html = html.replace(/<p>&nbsp;<\/p>/gi, '<p></p>');
        html = html.replace(/<p><br\s?\/?><\/p>/gi, '<p></p>');

        if (isMsWord)
        {
            html = html.replace(/<p><\/p>/gi, '');
            html = html.replace(/<p>\s<\/p>/gi, '');
        }

        // restore components
        html = this.restoreComponents(html);

        return html;
    },
    pastePlainText: function(html)
    {
        html = (this.opts.pasteLinks) ? this.storeLinks(html) : html;
        html = (this.opts.pasteImages) ? this.storeImages(html) : html;

        html = this.getPlainText(html);
        html = this._replaceNlToBr(html);

        html = (this.opts.pasteLinks) ? this.restoreLinks(html) : html;
        html = (this.opts.pasteImages) ? this.restoreImages(html) : html;

        return html;
    },
    tidy: function(html)
    {
        return html;
    },
    paragraphize: function(html)
    {
        var paragraphize = $R.create('cleaner.paragraphize', this.app);

        return paragraphize.convert(html);
    },

    // get
    getFlatText: function(html)
    {
        var $div = $R.dom('<div>');

        if (!html.nodeType && !html.dom)
        {
            html = html.toString();
            html = html.trim();
            $div.html(html);
        }
        else
        {
            $div.append(html);
        }

        html = $div.get().textContent || $div.get().innerText || '';

        return (html === undefined) ? '' : html;
    },
	getPlainText: function(html)
	{
		html = html.replace(/<!--[\s\S]*?-->/gi, '');
		html = html.replace(/<style[\s\S]*?style>/gi, '');
        html = html.replace(/<p><\/p>/g, '');
		html = html.replace(/<\/div>|<\/li>|<\/td>/gi, '\n');
		html = html.replace(/<\/p>/gi, '\n\n');
		html = html.replace(/<\/H[1-6]>/gi, '\n\n');

		var tmp = document.createElement('div');
		tmp.innerHTML = html;

		html = tmp.textContent || tmp.innerText;

		return html.trim();
	},

    // replace
    replaceTags: function(html, tags)
    {
        if (tags)
        {
            var self = this;
            var keys = Object.keys(tags);
            var $wrapper = this.utils.buildWrapper(html);
            $wrapper.find(keys.join(',')).each(function(node)
            {
                self.utils.replaceToTag(node, tags[node.tagName.toLowerCase()]);
            });

            html = this.utils.getWrapperHtml($wrapper);
        }

        return html;
    },
    replaceNbspToSpaces: function(html)
    {
        return html.replace('&nbsp;', ' ');
    },
    replaceBlocksToBr: function(html)
    {
        html = html.replace(/<\/div>|<\/li>|<\/td>|<\/p>|<\/H[1-6]>/gi, '<br>');

        return html;
    },

    // clean
    cleanNewLines: function(html)
    {
        return html.replace(/\r?\n/g, "");
    },
    cleanSpacesInPre: function(html)
    {
        return html.replace('&nbsp;&nbsp;&nbsp;&nbsp;', '    ');
    },

    // remove
    removeInvisibleSpaces: function(html)
    {
        html = this.utils.removeInvisibleChars(html);
        html = html.replace(/&#65279;/gi, '');

        return html;
    },
    removeNl: function(html)
    {
        html = html.replace(/\n/g, " ");
        html = html.replace(/\s+/g, "\s");

        return html;
    },
    removeBrAtEnd: function(html)
    {
        html = html.replace(/<br\s?\/?>$/gi, ' ');
        html = html.replace(/<br\s?\/?><li/gi, '<li');

        return html;
    },
    removeTags: function(input, denied)
    {
        var re = (denied) ? /<\/?([a-z][a-z0-9]*)\b[^>]*>/gi : /(<([^>]+)>)/gi;
        var replacer = (!denied) ? '' : function ($0, $1)
        {
            return denied.indexOf($1.toLowerCase()) === -1 ? $0 : '';
        };

        return input.replace(re, replacer);
    },
    removeTagsExcept: function(input, except)
    {
        if (except === undefined) return input.replace(/(<([^>]+)>)/gi, '');

        var tags = /<\/?([a-z][a-z0-9]*)\b[^>]*>/gi;
        return input.replace(tags, function($0, $1)
        {
            return except.indexOf($1.toLowerCase()) === -1 ? '' : $0;
        });
    },
    removeComments: function(html)
    {
        return html.replace(this.reComments, '');
    },
    removeServiceTagsAndAttrs: function(html, removeMarkers)
    {
        var $wrapper = this.utils.buildWrapper(html);
        var self = this;
        if (removeMarkers !== false)
        {
            $wrapper.find('.redactor-selection-marker').each(function(node)
            {
                var $el = $R.dom(node);
                var text = self.utils.removeInvisibleChars($el.text());

                return (text === '') ? $el.remove() : $el.unwrap();
            });
        }

        $wrapper.find('[data-redactor-style-cache]').removeAttr('data-redactor-style-cache');

        return this.utils.getWrapperHtml($wrapper);
    },
    removeSpanWithoutAttributes: function(html)
    {
        var $wrapper = this.utils.buildWrapper(html);
        $wrapper.find('span').removeAttr('data-redactor-span data-redactor-style-cache').each(function(node)
        {
            if (node.attributes.length === 0) $R.dom(node).unwrap();
        });

        return this.utils.getWrapperHtml($wrapper);
    },
    removeFirstBlockBreaklineInHtml: function(html)
    {
        return html.replace(new RegExp('</li><br\\s?/?>', 'gi'), '</li>');
    },
    removeEmptyAttributes: function(html, attrs)
    {
        var $wrapper = this.utils.buildWrapper(html);
        for (var i = 0; i < attrs.length; i++)
        {
            $wrapper.find('[' + attrs[i] + '=""]').removeAttr(attrs[i]);
        }

        return this.utils.getWrapperHtml($wrapper);
    },

    // encode / decode
    encodeHtml: function(html)
    {
        html = html.replace(/<br\s?\/?>/g, "\n");
        html = html.replace(/&nbsp;/g, ' ');
        html = html.replace(/”/g, '"');
        html = html.replace(/“/g, '"');
        html = html.replace(/‘/g, '\'');
        html = html.replace(/’/g, '\'');
        html = this.encodeEntities(html);
        html = html.replace(/\$/g, '&#36;');

        if (this.opts.preSpaces)
        {
            html = html.replace(/\t/g, new Array(this.opts.preSpaces + 1).join(' '));
        }

        return html;
    },
    encodePreCode: function(html)
    {
        var matched = html.match(new RegExp('<code(.*?)>(.*?)<pre(.*?)>(.*?)</pre>(.*?)</code>', 'gi'));
        if (matched !== null)
        {
            for (var i = 0; i < matched.length; i++)
            {
                var arr = matched[i].match(new RegExp('<pre(.*?)>([\\w\\W]*?)</pre>', 'i'));
                html = html.replace(arr[0], this.encodeEntities(arr[0]));
            }
        }

        var $wrapper = this.utils.buildWrapper(html);

        $wrapper.find('code code').replaceWith(this._encodeOuter.bind(this));
        $wrapper.find('code pre').replaceWith(this._encodeOuter.bind(this));
        $wrapper.find('pre pre').replaceWith(this._encodeOuter.bind(this));
        $wrapper.find('code, pre').each(this._encodePreCodeLine.bind(this));

        html = this.utils.getWrapperHtml($wrapper);

        // restore markers
        html = this._decodeMarkers(html);

        return html;
    },
    encodeEntities: function(str)
    {
        str = this.decodeEntities(str);
        str = str.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');

        return str;
    },
    encodePhpCode: function(html)
    {
        html = html.replace('<?php', '&lt;?php');
        html = html.replace('<?', '&lt;?');
        html = html.replace('?>', '?&gt;');

        return html;
    },
    decodeEntities: function(str)
    {
        return String(str).replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&quot;/g, '"').replace(/&amp;/g, '&');
    },

    // store / restore
    storeComponents: function(html)
    {
        var matched = this.utils.getElementsFromHtml(html, 'figure', 'table');

        return this._storeMatched(html, matched, 'Components', 'figure');
    },
    restoreComponents: function(html)
    {
        return this._restoreMatched(html, 'Components', 'figure');
    },
    storeLinks: function(html)
    {
        var matched = this.utils.getElementsFromHtml(html, 'a');

        return this._storeMatched(html, matched, 'Links', 'a');
    },
    storeImages: function(html)
    {
        var matched = this.utils.getElementsFromHtml(html, 'img');

        return this._storeMatched(html, matched, 'Images', 'img');
    },
    restoreLinks: function(html)
    {
        return this._restoreMatched(html, 'Links', 'a');
    },
    restoreImages: function(html)
    {
        return this._restoreMatched(html, 'Images', 'img');
    },

    // PRIVATE

    // clean
    _cleanWrapped: function(html)
    {
        html = html.replace(new RegExp('<p><figure([\\w\\W]*?)</figure></p>', 'gi'), '<figure$1</figure>');

        return html;
    },
    _cleanGDocs: function(html)
    {
        // remove google docs markers
        html = html.replace(/<b\sid="internal-source-marker(.*?)">([\w\W]*?)<\/b>/gi, "$2");
        html = html.replace(/<b(.*?)id="docs-internal-guid(.*?)">([\w\W]*?)<\/b>/gi, "$3");

        html = html.replace(/<span[^>]*(font-style:\s?italic;\s?font-weight:\s?bold|font-weight:\s?bold;\s?font-style:\s?italic)[^>]*>([\w\W]*?)<\/span>/gi, '<b><i>$2</i></b>');
        html = html.replace(/<span[^>]*(font-style:\s?italic;\s?font-weight:\s?600|font-weight:\s?600;\s?font-style:\s?italic)[^>]*>([\w\W]*?)<\/span>/gi, '<b><i>$2</i></b>');
        html = html.replace(/<span[^>]*(font-style:\s?italic;\s?font-weight:\s?700|font-weight:\s?700;\s?font-style:\s?italic)[^>]*>([\w\W]*?)<\/span>/gi, '<b><i>$2</i></b>');
        html = html.replace(/<span[^>]*font-style:\s?italic[^>]*>([\w\W]*?)<\/span>/gi, '<i>$1</i>');
        html = html.replace(/<span[^>]*font-weight:\s?bold[^>]*>([\w\W]*?)<\/span>/gi, '<b>$1</b>');
        html = html.replace(/<span[^>]*font-weight:\s?700[^>]*>([\w\W]*?)<\/span>/gi, '<b>$1</b>');
        html = html.replace(/<span[^>]*font-weight:\s?600[^>]*>([\w\W]*?)<\/span>/gi, '<b>$1</b>');

        return html;
    },
    _cleanMsWord: function(html)
    {
        html = html.replace(/<!--[\s\S]+?-->/gi, '');
        html = html.replace(/<(!|script[^>]*>.*?<\/script(?=[>\s])|\/?(\?xml(:\w+)?|img|meta|link|style|\w:\w+)(?=[\s\/>]))[^>]*>/gi, '');
        html = html.replace(/<(\/?)s>/gi, "<$1strike>");
        html = html.replace(/&nbsp;/gi, ' ');
        html = html.replace(/<span\s+style\s*=\s*"\s*mso-spacerun\s*:\s*yes\s*;?\s*"\s*>([\s\u00a0]*)<\/span>/gi, function(str, spaces) {
            return (spaces.length > 0) ? spaces.replace(/./, " ").slice(Math.floor(spaces.length/2)).split("").join("\u00a0") : '';
        });

        // build wrapper
        var $wrapper = this.utils.buildWrapper(html);

        $wrapper.find('p').each(function(node)
        {
            var $node = $R.dom(node);
            var str = $node.attr('style');
            var matches = /mso-list:\w+ \w+([0-9]+)/.exec(str);
            if (matches)
            {
                $node.data('_listLevel',  parseInt(matches[1], 10));
            }
        });

        // parse Lists
        this._parseWordLists($wrapper);

        $wrapper.find('[align]').removeAttr('align');
        $wrapper.find('[name]').removeAttr('name');
        $wrapper.find('span').each(function(node)
        {
            var $node = $R.dom(node);
            var str = $node.attr('style');
            var matches = /mso-list:Ignore/.exec(str);

            if (matches) $node.remove();
            else $node.unwrap();

        });
        $wrapper.find('[style]').removeAttr('style');
        $wrapper.find("[class^='Mso']").removeAttr('class');
        $wrapper.find('a').filter(function(node) { return !node.hasAttribute('href'); }).unwrap();

        // get wrapper
        html = this.utils.getWrapperHtml($wrapper);
        html = html.replace(/<p[^>]*><\/p>/gi, '');
        html = html.replace(/<li>·/gi, '<li>');
        html = html.trim();

        // remove spaces between
        html = html.replace(/\/(p|ul|ol|h1|h2|h3|h4|h5|h6|blockquote)>\s+<(p|ul|ol|h1|h2|h3|h4|h5|h6|blockquote)/gi, '/$1>\n<$2');

        var result = '';
        var lines = html.split(/\n/);
        for (var i = 0; i < lines.length; i++)
        {
            var space = (lines[i] !== '' && lines[i].search(/>$/) === -1) ? ' ' : '\n';

            result += lines[i] + space;
        }

        return result;
    },
    _parseWordLists: function($wrapper)
    {
        var lastLevel = 0;
        var pnt = null;
        var $item = null;
        var setPnt = false;

        $wrapper.find('p').each(function(node)
        {
            var $node = $R.dom(node);
            var currentLevel = $node.data('_listLevel');

            if (currentLevel !== null)
            {
                var txt = $node.text();
                var listTag = '<ul></ul>';
                if (/^\s*\w+\./.test(txt))
                {
                    var matches = /([0-9])\./.exec(txt);
                    if (matches)
                    {
                        var start = parseInt(matches[1], 10);
                        listTag = (start > 1) ? '<ol start="' + start + '"></ol>' : '<ol></ol>';
                    }
                    else
                    {
                        listTag = '<ol></ol>';
                    }
                }

                if (currentLevel > lastLevel)
                {
                    if (lastLevel === 0)
                    {
                        $node.before(listTag);
                        pnt = $node.prev();
                    }
                    else
                    {
                        var $list = $R.dom(listTag);

                        if ($item)
                        {
                            $item.append($list);
                            pnt = $list;
                            setPnt = true;

                        }
                        else
                        {
                            pnt.append($list);
                        }

                    }
                }

                $node.find('span').first().unwrap();
                $item = $R.dom('<li>' + $node.html().trim() + '</li>');
                pnt.append($item);
                $node.remove();

                if (setPnt)
                {
                    pnt = pnt.parent();
                }

                lastLevel = currentLevel;
                setPnt = false;

            }
            else
            {
                lastLevel = 0;
            }
        });
    },

    // is
    _isSpacedEmpty: function(html)
    {
        return (html.search(this.reSpacedEmpty) !== -1);
    },
    _isParagraphEmpty: function(html)
    {
        return (html.search(/^<p><\/p>$/i) !== -1);
    },
    _isHtmlMsWord: function(html)
    {
        return html.match(/class="?Mso|style="[^"]*\bmso-|style='[^'']*\bmso-|w:WordDocument/i);
    },

    // set
    _setSpanAttr: function(html)
    {
        var $wrapper = this.utils.buildWrapper(html);
        $wrapper.find('span').attr('data-redactor-span', true);

        return this.utils.getWrapperHtml($wrapper);
    },
    _setStyleCache: function(html)
    {
        var $wrapper = this.utils.buildWrapper(html);
        $wrapper.find('[style]').each(function(node)
        {
            var $el = $R.dom(node);
            $el.attr('data-redactor-style-cache', $el.attr('style'));
        });

        return this.utils.getWrapperHtml($wrapper);
    },
    _setPreClass: function(html)
    {
        var $wrapper = this.utils.buildWrapper(html);
        $wrapper.find('pre').addClass(this.opts.preClass);

        return this.utils.getWrapperHtml($wrapper);
    },
    _setLinkNofollow: function(html)
    {
        var $wrapper = this.utils.buildWrapper(html);
        $wrapper.find('a').attr('rel', 'nofollow');

        return this.utils.getWrapperHtml($wrapper);
    },

    // replace
    _replaceScriptTag: function(html)
    {
        return html.replace(this.reScriptTag, '<pre class="redactor-script-tag" $1>$2</pre>');
    },
    _unreplaceScriptTag: function(html)
    {
        return html.replace(/<pre class="redactor-script-tag"(.*?[^>]?)>([\w\W]*?)<\/pre>/gi, '<script$1>$2</script>');
    },
	_replaceNlToBr: function(html)
	{
		return html.replace(/\n/g, '<br />');
	},

    // remove
    _removeScriptTag: function(html)
    {
        return html.replace(this.reScriptTag, '');
    },

    // private
    _storeMatched: function(html, matched, stored, name)
    {
        this['stored' + stored] = [];
        if (matched)
        {
            for (var i = 0; i < matched.length; i++)
            {
                this['stored' + stored][i] = matched[i];
                html = html.replace(matched[i], '####' + name + i + '####');
            }
        }

        return html;
    },
    _restoreMatched: function(html, stored, name)
    {
        if (this['stored' + stored])
        {
            for (var i = 0; i < this['stored' + stored].length; i++)
            {
                html = html.replace('####' + name + i + '####', this['stored' + stored][i]);
            }
        }

        return html;
    },
    _decodeMarkers: function(html)
    {
        var decodedMarkers = '<span id="selection-marker-$1" class="redactor-selection-marker">​</span>';
        return html.replace(/&lt;span\sid="selection-marker-(start|end)"\sclass="redactor-selection-marker"&gt;(.*?[^>]?)&lt;\/span&gt;/g, decodedMarkers);
    },
    _encodeOuter: function(node)
    {
        return this.encodeEntities(node.outerHTML);
    },
    _encodePreCodeLine: function(node)
    {
        var first = node.firstChild;
        if (node.tagName == 'PRE' && (first && first.tagName === 'CODE')) return;

        var encoded = this.decodeEntities(node.innerHTML);
        encoded = encoded.replace(/&nbsp;/g, ' ').replace(/<br\s?\/?>/g, '\n');
        encoded = (this.opts.preSpaces) ? encoded.replace(/\t/g, new Array(this.opts.preSpaces + 1).join(' ')) : encoded;

        node.textContent = encoded;
    }
});
$R.add('class', 'cleaner.figure', {
    init: function(app)
    {
        this.app = app;
        this.opts = app.opts;
        this.utils = app.utils;
        this.detector = app.detector;
    },
    // public
    convert: function(html, rules)
    {
        var $wrapper = this.utils.buildWrapper(html);

        // convert
        $wrapper.find('img').each(this._convertImage.bind(this));
        $wrapper.find('hr').each(this._convertLine.bind(this));
        $wrapper.find('iframe').each(this._convertIframe.bind(this));
        $wrapper.find('table').each(this._convertTable.bind(this));
        $wrapper.find('form').each(this._convertForm.bind(this));
        $wrapper.find('figure pre').each(this._convertCode.bind(this));

        // variables
        $wrapper.find('[data-redactor-type=variable]').addClass('redactor-component');

        // widgets
        $wrapper.find('figure').not('.redactor-component, .redactor-figure-code').each(this._convertWidget.bind(this));

        // contenteditable
        $wrapper.find('figure pre').each(this._setContenteditableCode.bind(this));
        $wrapper.find('.redactor-component, .non-editable').attr('contenteditable', false);

        if (this.detector.isIe())
        {
            $wrapper.find('[data-redactor-type=table]').removeAttr('contenteditable');
        }

        $wrapper.find('figcaption, td, th').attr('contenteditable', true);
        $wrapper.find('.redactor-component, figcaption').attr('tabindex', '-1');

        // extra rules
        this._acceptExtraRules($wrapper, rules);

        return this.utils.getWrapperHtml($wrapper);
    },
    unconvert: function(html, rules)
    {
        var $wrapper = this.utils.buildWrapper(html);

        // contenteditable
        $wrapper.find('th, td, figcaption, figure, pre, code, .redactor-component').removeAttr('contenteditable tabindex');

        // remove class
        $wrapper.find('figure').removeClass('redactor-component redactor-component-active redactor-uploaded-figure');

        // unconvert
        $wrapper.find('[data-redactor-type=variable]').removeClass('redactor-component redactor-component-active');
        $wrapper.find('figure[data-redactor-type=line]').unwrap();
        $wrapper.find('figure[data-redactor-type=widget]').each(this._unconvertWidget.bind(this));
        $wrapper.find('figure[data-redactor-type=form]').each(this._unconvertForm.bind(this));
        $wrapper.find('figure[data-redactor-type=table]').each(this._unconvertTable.bind(this));
        $wrapper.find('figure[data-redactor-type=image]').removeAttr('rel').each(this._unconvertImages.bind(this));

        $wrapper.find('img').removeAttr('data-redactor-type').removeClass('redactor-component');
        $wrapper.find('.non-editable').removeAttr('contenteditable');

        // remove types
        $wrapper.find('figure').each(this._removeTypes.bind(this));

        // remove caret
        $wrapper.find('span.redactor-component-caret').remove();

        if (this.opts.breakline)
        {
            $wrapper.find('[data-redactor-tag="br"]').each(function(node)
            {
                if (node.lastChild && node.lastChild.tagName !== 'BR')
                {
                    node.appendChild(document.createElement('br'));
                }
            }).unwrap();
        }

        // extra rules
        this._acceptExtraRules($wrapper, rules);

        html = this.utils.getWrapperHtml($wrapper);
        html = html.replace(/<br\s?\/?>$/, '');

        return html;
    },

    // private
    _convertImage: function(node)
    {
        var $node = $R.dom(node);
        if (this._isNonEditable($node)) return;

        // set id
        if (!$node.attr('data-image'))
        {
            $node.attr('data-image', this.utils.getRandomId());
        }

        var $link = $node.closest('a');
        var $figure = $node.closest('figure');
        var isImage = ($figure.children().not('a, img, br, figcaption').length === 0);
        if (!isImage) return;

        if ($figure.length === 0)
        {

            var $parent = ($link.length !== 0) ? $link.closest('p') : $node.closest('p');
            if (this.opts.imageFigure === false && $parent.length !== 0)
            {
                var $el = this.utils.replaceToTag($parent, 'figure');
                $figure = $el;
                $figure.addClass('redactor-replace-figure');
            }
            else
            {
                $figure = ($link.length !== 0) ? $link.wrap('<figure>') : $node.wrap('<figure>');
            }
        }
        else
        {
            if ($figure.hasClass('redactor-uploaded-figure'))
            {
                $figure.removeClass('redactor-uploaded-figure');
            }
            else
            {
                $figure.addClass('redactor-keep-figure');
            }
        }

        this._setFigure($figure, 'image');
    },
    _convertTable: function(node)
    {
        if (this._isNonEditable(node)) return;

        var $figure = this._wrapFigure(node);
        this._setFigure($figure, 'table');
    },
    _convertLine: function(node)
    {
        if (this._isNonEditable(node)) return;

        var $figure = this._wrapFigure(node);
        this._setFigure($figure, 'line');
    },
    _convertForm: function(node)
    {
        if (this._isNonEditable(node)) return;

        var $figure = this.utils.replaceToTag(node, 'figure');
        this._setFigure($figure, 'form');
    },
    _convertIframe: function(node)
    {
        if (this._isNonEditable(node)) return;

        var $node = $R.dom(node);
        if ($node.closest('.redactor-component').length !== 0) return;

        var src = node.getAttribute('src');
        var isVideo = (src && (src.match(this.opts.regex.youtube) || src.match(this.opts.regex.vimeo)));
        var $figure = this._wrapFigure(node);

        if (isVideo)
        {
            this._setFigure($figure, 'video');
        }
    },
    _convertCode: function(node)
    {
        if (this._isNonEditable(node)) return;

        var $figure = this._wrapFigure(node);
        this._setFigure($figure, 'code');
    },
    _convertWidget: function(node)
    {
        if (this._isNonEditable(node)) return;

        var $node = $R.dom(node);
        $node.addClass('redactor-component');
        $node.attr('data-redactor-type', 'widget');
        $node.attr('data-widget-code', encodeURI(node.innerHTML.trim()));
    },

    // unconvert
    _unconvertForm: function(node)
    {
        this.utils.replaceToTag(node, 'form');
    },
    _unconvertTable: function(node)
    {
        var $node = $R.dom(node);
        $node.unwrap();
    },
    _unconvertWidget: function(node)
    {
        var $node = $R.dom(node);
        $node.html(decodeURI($node.attr('data-widget-code')));
        $node.removeAttr('data-widget-code');
    },
    _unconvertImages: function(node)
    {
        var $node = $R.dom(node);
        $node.removeClass('redactor-component');

        var isList = ($node.closest('li').length !== 0);
        var isTable = ($node.closest('table').length !== 0);
        var hasFigcaption = ($node.find('figcaption').length !== 0);

        var style = $node.attr('style');
        var hasStyle = !(style === null || style === '');
        var hasClass = ($node.attr('class') !== '');

        if (isList || (isTable && !hasFigcaption && !hasStyle && !hasClass))
        {
            $node.unwrap();
        }
    },
    _removeTypes: function(node)
    {
        var $node = $R.dom(node);
        var type = $node.attr('data-redactor-type');
        var removed = ['image', 'widget', 'line', 'video', 'code', 'form', 'table'];
        if (type && removed.indexOf(type) !== -1)
        {
            $node.removeAttr('data-redactor-type');
        }

        // keep figure
        if ($node.hasClass('redactor-keep-figure'))
        {
            $node.removeClass('redactor-keep-figure');
        }

        // unwrap figure
        else if (type === 'image' && this.opts.imageFigure === false)
        {
            var hasFigcaption = ($node.find('figcaption').length !== 0);
            if (!hasFigcaption)
            {
                // replace
                if ($node.hasClass('redactor-replace-figure'))
                {
                    $node.removeClass('redactor-replace-figure');
                    this.utils.replaceToTag($node, 'p');
                }
                else
                {
                    $node.unwrap();
                }
            }
        }

        $node.removeClass('redactor-replace-figure');
    },

    // wrap
    _wrapFigure: function(node)
    {
        var $node = $R.dom(node);
        var $figure = $node.closest('figure');

        return ($figure.length === 0) ? $node.wrap('<figure>') : $figure;
    },

    // set
    _setFigure: function($figure, type)
    {
        $figure.addClass('redactor-component');
        $figure.attr('data-redactor-type', type);
    },
    _setContenteditableCode: function(node)
    {
        if (this._isNonEditable(node)) return;

        var $node = $R.dom(node);
        var $code = $node.children('code').first();

        var $el = ($code.length !== 0) ? $code : $node;
        $el.attr('contenteditable', true).attr('tabindex', '-1');
    },

    // utils
    _acceptExtraRules: function($wrapper, rules)
    {
        for (var key in rules)
        {
            if (typeof rules[key] === 'function')
            {
                rules[key]($wrapper);
            }
        }
    },
    _isNonEditable: function(node)
    {
        return ($R.dom(node).closest('.non-editable').length !== 0);
    }
});
$R.add('class', 'cleaner.paragraphize', {
    init: function(app)
    {
        this.app = app;
        this.opts = app.opts;
        this.utils = app.utils;
        this.element = app.element;

        // local
        this.stored = [];
        this.remStart = '#####replace';
        this.remEnd = '#####';
        this.paragraphizeTags = ['table', 'div', 'pre', 'form', 'ul', 'ol', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'dl', 'blockquote', 'figcaption',
                'address', 'section', 'header', 'footer', 'aside', 'article', 'object', 'style', 'script', 'iframe', 'select', 'input', 'textarea',
                'button', 'option', 'map', 'area', 'math', 'hr', 'fieldset', 'legend', 'hgroup', 'nav', 'figure', 'details', 'menu', 'summary', 'p'];
    },
    // public
    convert: function(html)
    {
        var value = this._isConverted(html);

        return (value === true) ? this._convert(html) : value;
    },

    // private
    _convert: function(html)
    {
        // build markup tag
        var markupTag = (this.opts.breakline) ? 'sdivtag' : this.opts.markup;

        // store tags
        html = this._storeTags(html);

        // store comments
        var storeComments = [];
        var commentsMatch = html.match(new RegExp('<!--([\\w\\W]*?)-->', 'gi'));
        if (commentsMatch !== null)
        {
            for (var i = 0; i < commentsMatch.length; i++)
            {
                html = html.replace(commentsMatch[i], '#####xstarthtmlcommentzz' + i + 'xendhtmlcommentzz#####');
                storeComments.push(commentsMatch[i]);
            }
        }

        // remove new lines
        html = html.trim();

        if (this.opts.breakline)
        {
            html = html.replace(new RegExp('\\n#####', 'gi'), 'xnonbreakmarkerz#####');
            html = html.replace(new RegExp('#####\\n\\n', 'gi'), "#####\nxnonbreakmarkerz");
            html = html.replace(new RegExp('#####\\n', 'gi'), "#####xnonbreakmarkerz");
            html = html.replace(/<br\s?\/?>\n/gi, "<br>");
            html = html.replace(/\n/g, "<br>");
            html = html.replace(/xnonbreakmarkerz/gi, "\n");
        }
        else
        {
            html = html.replace(/[\n]+/g, "\n");
        }

        html = this._trimEmptyLines(html);

        // paragraph and break markers
        html = (this.opts.breakline) ? html : html.replace(/<br\s?\/?>\n/gi, "xbreakmarkerz\n");
        html = html.replace(/(?:\r\n|\r|\n)/g, "xparagraphmarkerz");

        // replace markers
        html = html.replace(/xparagraphmarkerz/gi, "</" + markupTag + ">\n<" + markupTag + ">");
        html = (this.opts.breakline) ? html : html.replace(/xbreakmarkerz/gi, "<br>");

        // wrap all
        html = '<' + markupTag + '>' + html + '</' + markupTag + '>';

        // clean
        html = html.replace(new RegExp('<' + markupTag + '>#####', 'gi'), '#####');
        html = html.replace(new RegExp('#####</' + markupTag + '>', 'gi'), '#####');

        // restore tags
        html = this._restoreTags(html);

        // restore comments
        for (var i = 0; i < storeComments.length; i++)
        {
            html = html.replace('#####xstarthtmlcommentzz' + i + 'xendhtmlcommentzz#####', storeComments[i]);
        }

        // clean restored
        html = (this.opts.breakline) ? html : html.replace(new RegExp('<' + markupTag + '><br\\s?/?></' + markupTag + '>', 'gi'), '<' + markupTag + '></' + markupTag + '>');
        html = html.replace(new RegExp('<sdivtag>', 'gi'), '<div data-redactor-tag="br">');
        html = html.replace(new RegExp('sdivtag', 'gi'), 'div');

        return html;
    },
    _storeTags: function(html)
    {
        var self = this;
        var $wrapper = this.utils.buildWrapper(html);

        if (this.opts.breakline)
        {
            $wrapper.find('p').each(function(node)
            {
                var $node = $R.dom(node);
                var isUnwrap = ($node.closest('figure[data-redactor-type=widget],figure[data-redactor-type=form],.non-editable').length === 0);

                if (isUnwrap)
                {
                    $node.append('<br><br>');
                    $node.unwrap();
                }
            });
        }

        $wrapper.find(this.paragraphizeTags.join(', ')).each(function(node, i)
        {
            var replacement = document.createTextNode("\n" + self.remStart + i + self.remEnd + "\n");
            self.stored.push(node.outerHTML);
            node.parentNode.replaceChild(replacement, node);
        });

        return this.utils.getWrapperHtml($wrapper);
    },
    _restoreTags: function(html)
    {
        for (var i = 0; i < this.stored.length; i++)
        {
            this.stored[i] = this.stored[i].replace(/\$/g, '&#36;');
            html = html.replace(this.remStart + i + this.remEnd, this.stored[i]);
        }

        return html;
    },
    _trimEmptyLines: function(html)
    {
        var str = '';
        var arr = html.split("\n");
        for (var i = 0; i < arr.length; i++)
        {
            if (arr[i].trim() !== '')
            {
                str += arr[i] + "\n";
            }
        }

        return str.replace(/\n$/, '');
    },
    _isConverted: function(html)
    {
        if (this._isDisabled(html)) return html;
        else if (this._isEmptyHtml(html)) return this.opts.emptyHtml;
        else return true;
    },
    _isDisabled: function()
    {
        return (this.opts.paragraphize === false || this.element.isType('inline'));
    },
    _isEmptyHtml: function(html)
    {
        return (html === '' || html === '<p></p>' || html === '<div></div>');
    }
});
$R.add('service', 'detector', {
    init: function(app)
    {
        this.app = app;

        // local
        this.userAgent = navigator.userAgent.toLowerCase();
    },
	isWebkit: function()
	{
		return /webkit/.test(this.userAgent);
	},
	isFirefox: function()
	{
		return (this.userAgent.indexOf('firefox') > -1);
	},
	isIe: function(v)
	{
        if (document.documentMode || /Edge/.test(navigator.userAgent)) return 'edge';

		var ie;
		ie = RegExp('msie' + (!isNaN(v)?('\\s'+v):''), 'i').test(navigator.userAgent);
		if (!ie) ie = !!navigator.userAgent.match(/Trident.*rv[ :]*11\./);

		return ie;
	},
	isMobile: function()
	{
		return /(iPhone|iPod|Android)/.test(navigator.userAgent);
	},
	isDesktop: function()
	{
		return !/(iPhone|iPod|iPad|Android)/.test(navigator.userAgent);
	},
	isIpad: function()
	{
		return /iPad/.test(navigator.userAgent);
	}
});
$R.add('service', 'offset', {
    init: function(app)
    {
        this.app = app;
    },
    get: function(el, trimmed)
    {
        var offset = { start: 0, end: 0 };
        var node = this.utils.getNode(el);
        if (!node) return false;

        var isEditor = this.editor.isEditor(node);
        var isIn = (isEditor) ? true : this.selection.isIn(node);
        var range = this.selection.getRange();

        if (!isEditor && !isIn)
        {
            offset = false;
        }
        else if (this.selection.is() && isIn)
        {
            var $startNode = $R.dom(range.startContainer);
            var fix = ($startNode.hasClass('redactor-component')) ? range.startOffset : 0;
            var clonedRange = range.cloneRange();

            clonedRange.selectNodeContents(node);
            clonedRange.setEnd(range.startContainer, range.startOffset);

            var selection = this._getString(range, trimmed);

            offset.start = this._getString(clonedRange, trimmed).length - fix;
            offset.end = offset.start + selection.length + fix;
        }

        return offset;
    },
    set: function(offset, el)
    {
        if (this._setComponentOffset(el)) return;

        this.component.clearActive();
        var node = this.utils.getNode(el);
        if (!node) return;

        var size = this.size(node);
        var charIndex = 0, range = document.createRange();

        offset.end = (offset.end > size) ? size : offset.end;

        range.setStart(node, 0);
        range.collapse(true);

        var nodeStack = [node], foundStart = false, stop = false;
        while (!stop && (node = nodeStack.pop()))
        {
            if (node.nodeType == 3)
            {
                var nextCharIndex = charIndex + node.length;

                if (!foundStart && !this._isFigcaptionNext(node) && offset.start >= charIndex && offset.start <= nextCharIndex)
                {
                    range.setStart(node, offset.start - charIndex);
                    foundStart = true;
                }

                if (foundStart && offset.end >= charIndex && offset.end <= nextCharIndex)
                {
                    range.setEnd(node, offset.end - charIndex);
                    stop = true;
                }

                charIndex = nextCharIndex;
            }
            else
            {
                var i = node.childNodes.length;
                while (i--)
                {
                    nodeStack.push(node.childNodes[i]);
                }
            }
        }

        this.selection.setRange(range);
    },
    size: function(el, trimmed)
    {
        var node = this.utils.getNode(el);
        if (node)
        {
            var range = document.createRange();

            var clonedRange = range.cloneRange();
            clonedRange.selectNodeContents(node);

            return this._getString(clonedRange, trimmed).length;
        }

        return 0;
    },

    // private
    _getString: function(obj, trimmed)
    {
        var str = obj.toString();
        str = (this.editor.isEmpty()) ? str.replace(/\uFEFF/g, '') : str;
        str = (trimmed) ? str.trim() : str;

        return str;
    },
    _setComponentOffset: function(el)
    {
        return (this.component.isNonEditable(el)) ? this.component.setActive(el) : false;
    },
    _isFigcaptionNext: function(node)
    {
        var next = node.nextSibling;
        return (node.nodeValue.trim() === '' && next && next.tagName === 'FIGCAPTION');
    }
});
$R.add('service', 'inspector', {
    init: function(app)
    {
        this.app = app;
    },
    // parse
    parse: function(el)
    {
        return $R.create('inspector.parser', this.app, this, el);
    },

    // text detection
    isText: function(el)
    {
        if (typeof el === 'string' && !/^\s*<(\w+|!)[^>]*>/.test(el))
        {
            return true;
        }

        var node = $R.dom(el).get();
        return (node && node.nodeType === 3); //  && !this.selection.getBlock(el)
    },

    // tag detection
    isInlineTag: function(tag, extend)
    {
        var tags = this._extendTags(this.opts.inlineTags, extend);

        return (this._isTag(tag) && tags.indexOf(tag.toLowerCase()) !== -1);
    },
    isBlockTag: function(tag, extend)
    {
        var tags = this._extendTags(this.opts.blockTags, extend);

        return (this._isTag(tag) && tags.indexOf(tag.toLowerCase()) !== -1);
    },
    isTableCellTag: function(tag)
    {
        return (['td', 'th'].indexOf(tag.toLowerCase()) !== -1);
    },
    isHeadingTag: function(tag)
    {
        return (['h1', 'h2', 'h3', 'h4', 'h5', 'h6'].indexOf(tag.toLowerCase()) !== -1);
    },


    _isTag: function(tag)
    {
        return (tag !== undefined && tag);
    },
    _extendTags: function(tags, extend)
    {
        tags = tags.concat(tags);

        if (extend)
        {
            for (var i = 0 ; i < extend.length; i++)
            {
                tags.push(extend[i]);
            }
        }

        return tags;
    }
});
$R.add('class', 'inspector.parser', {
    init: function(app, inspector, el)
    {
        this.app = app;
        this.uuid = app.uuid;
        this.opts = app.opts;
        this.utils = app.utils;
        this.editor = app.editor;
        this.selection = app.selection;
        this.inspector = inspector;

        // local
        this.el = el;
        this.$el = $R.dom(this.el);
        this.node = this.$el.get();

        // comment node
        if (this.node && this.node.nodeType === 8)
        {
            this.node = false;
        }

        this.$component = this.$el.closest('.redactor-component', '.redactor-in');
    },
    // is
    isEditor: function()
    {
        return (this.node === this.editor.getElement().get());
    },
    isInEditor: function()
    {
        return (this.$el.parents('.redactor-in-' + this.uuid).length !== 0);
    },
    isComponent: function()
    {
        return (this.$component.length !== 0);
    },
    isComponentType: function(type)
    {
        return (this.getComponentType() === type);
    },
    isComponentActive: function()
    {
        return (this.isComponent() && this.$component.hasClass('redactor-component-active'));
    },
    isComponentEditable: function()
    {
        var types = ['code', 'table'];
        var type = this.getComponentType();

        return (this.isComponent() && types.indexOf(type) !== -1);
    },
    isFigcaption: function()
    {
        return this.getFigcaption();
    },
    isPre: function()
    {
        return this.getPre();
    },
    isCode: function()
    {
        var $code = this.$el.closest('code');
        var $parent = $code.parent('pre');

        return ($code.length !== 0 && $parent.length === 0);
    },
    isList: function()
    {
        return this.getList();
    },
    isFirstListItem: function()
    {
        return this._getLastOrFirstListItem('first');
    },
    isLastListItem: function()
    {
        return this._getLastOrFirstListItem('last');
    },
    isFirstTableCell: function()
    {
        return this._getLastOrFirstTableCell('first');
    },
    isLastTableCell: function()
    {
        return this._getLastOrFirstTableCell('last');
    },
    isTable: function()
    {
        return (this.isComponentType('table') || this.getTable());
    },
    isHeading: function()
    {
        return this.getHeading();
    },
    isBlockquote: function()
    {
        return this.getBlockquote();
    },
    isDl: function()
    {
        return this.getDl();
    },
    isParagraph: function()
    {
        return this.getParagraph();
    },
    isLink: function()
    {
        return this.getLink();
    },
    isFile: function()
    {
        return this.getFile();
    },
    isText: function()
    {
        return this.inspector.isText(this.el);
    },
    isInline: function()
    {
        var tags = this.opts.inlineTags;

        return (this.isElement()) ? (tags.indexOf(this.node.tagName.toLowerCase()) !== -1) : false;
    },
    isBlock: function()
    {
        var tags = this.opts.blockTags;

        return (this.isElement()) ? (tags.indexOf(this.node.tagName.toLowerCase()) !== -1) : false;
    },
    isElement: function()
    {
        return (this.node && this.node.nodeType && this.node.nodeType !== 3);
    },

    // has
    hasParent: function(tags)
    {
        return (this.$el.closest(tags.join(',')).length !== 0);
    },

    // get
    getNode: function()
    {
        return this.node;
    },
    getTag: function()
    {
        return (this.isElement()) ? this.node.tagName.toLowerCase() : false;
    },
    getComponent: function()
    {
        return (this.isComponent()) ? this.$component.get() : false;
    },
    getComponentType: function()
    {
        return (this.isComponent()) ? this.$component.attr('data-redactor-type') : false;
    },
    getFirstNode: function()
    {
        return this.utils.getFirstNode(this.node);
    },
    getLastNode: function()
    {
        return this.utils.getLastNode(this.node);
    },
    getFirstElement: function()
    {
        return this.utils.getFirstElement(this.node);
    },
    getLastElement: function()
    {
        return this.utils.getLastElement(this.node);
    },
    getFigcaption: function()
    {
        return this._getClosestNode('figcaption');
    },
    getPre: function()
    {
        return this._getClosestNode('pre');
    },
    getCode: function()
    {
        return this._getClosestNode('code');
    },
    getList: function()
    {
        return this._getClosestNode('ul, ol');
    },
    getParentList: function()
    {
        return this._getClosestUpNode('ul, ol');
    },
    getListItem: function()
    {
        return this._getClosestNode('li');
    },
    getTable: function()
    {
        if (this.getComponentType('table'))
        {
            return this.$component.find('table').get();
        }
        else
        {
            return this._getClosestNode('table');
        }
    },
    getTableCell: function()
    {
        var $td = this.$el.closest('td, th');

        return ($td.length !== 0) ? $td.get() : false;
    },
    getComponentCodeElement: function()
    {
        return (this.isComponentType('code')) ? this.$component.find('pre code, pre').last().get() : false;
    },
    getImageElement: function()
    {
        return (this.isComponentType('image')) ? this.$component.find('img').get() : false;
    },
    getParagraph: function()
    {
        return this._getClosestNode('p');
    },
    getHeading: function()
    {
        return this._getClosestNode('h1, h2, h3, h4, h5, h6');
    },
    getDl: function()
    {
        return this._getClosestNode('dl');
    },
    getBlockquote: function()
    {
        return this._getClosestNode('blockquote');
    },
    getLink: function()
    {
        var isComponent = (this.isComponent() && !this.isFigcaption());
        var isTable = this.isComponentType('table');

        if (isTable || !isComponent)
        {
            var $el = this._getClosestElement('a');

            return ($el && !$el.attr('data-file')) ? $el.get() : false;
        }

        return false;
    },
    getFile: function()
    {
        var isComponent = this.isComponent();
        var isTable = this.isComponentType('table');

        if (isTable || !isComponent)
        {
            var $el = this._getClosestElement('a');

            return ($el && $el.attr('data-file')) ? $el.get() : false;
        }

        return false;
    },

    // find
    findFirstNode: function(selector)
    {
        return this.$el.find(selector).first().get();
    },
    findLastNode: function(selector)
    {
        return this.$el.find(selector).last().get();
    },

    // private
    _getLastOrFirstListItem: function(type)
    {
        var list = this.getList();
        var tag = this.getTag();
        if (list && tag === 'li')
        {
            var item = $R.dom(list).find('li')[type]().get();
            if (item && this.node === item)
            {
                return true;
            }
        }

        return false;
    },
    _getLastOrFirstTableCell: function(type)
    {
        var table = this.getTable();
        var tag = this.getTag();
        if (table && (tag === 'td' || tag === 'th'))
        {
            var item = $R.dom(table).find('td, th')[type]().get();
            if (item && this.node === item)
            {
                return true;
            }
        }

        return false;
    },
    _getClosestUpNode: function(selector)
    {
        var $el = this.$el.parents(selector, '.redactor-in').last();

        return ($el.length !== 0) ? $el.get() : false;
    },
    _getClosestNode: function(selector)
    {
        var $el = this.$el.closest(selector, '.redactor-in');

        return ($el.length !== 0) ? $el.get() : false;
    },
    _getClosestElement: function(selector)
    {
        var $el = this.$el.closest(selector, '.redactor-in');

        return ($el.length !== 0) ? $el : false;
    }
});
$R.add('service', 'marker', {
    init: function(app)
    {
        this.app = app;
    },
    build: function(pos, html)
    {
        var marker = document.createElement('span');

        marker.id = 'selection-marker-' + this._getPos(pos);
        marker.className = 'redactor-selection-marker';
        marker.innerHTML = this.opts.markerChar;

        return (html) ? marker.outerHTML : marker;
    },
    buildHtml: function(pos)
    {
        return this.build(pos, true);
    },
    insert: function(side)
    {
        this.remove();

        var atStart = (side !== 'both' && (side === 'start' || this.selection.isCollapsed()));

        if (!this.selection.is()) this.editor.focus();

        var range = this.selection.getRange();
        if (range)
        {
            var start = this.build('start');
            var end = this.build('end');

            var cloned = range.cloneRange();

            if (!atStart)
            {
                cloned.collapse(false);
                cloned.insertNode(end);
            }

            cloned.setStart(range.startContainer, range.startOffset);
            cloned.collapse(true);
            cloned.insertNode(start);

            range.setStartAfter(start);

            if (!atStart)
            {
                range.setEndBefore(end);
            }

            this.selection.setRange(range);

            return start;
        }
    },
    find: function(pos, $context)
    {
        var $editor = this.editor.getElement();
        var $marker = ($context || $editor).find('span#selection-marker-' + this._getPos(pos));

        return ($marker.length !== 0) ? $marker.get() : false;
    },
    restore: function()
    {
        var start = this.find('start');
        var end = this.find('end');

        var range = this.selection.getRange();
        if (!range || !this.selection.is())
        {
            this.editor.focus();
            range = document.createRange();
        }

        if (start)
        {
            var prev = (end) ? end.previousSibling : false;
            var next = start.nextSibling;
            next = (next && next.nodeType === 3 && next.textContent.replace(/[\n\t]/g, '') === '') ? false : next;

            if (!end)
            {
                if (next)
                {
                    range.selectNodeContents(next);
                    range.collapse(true);
                }
                else
                {
                    this._restoreInject(range, start);
                }
            }
            else if (next && next.id === 'selection-marker-end')
            {
                this._restoreInject(range, start);
            }
            else
            {
                if (prev && next)
                {
                    range.selectNodeContents(prev);
                    range.collapse(false);
                    range.setStart(next, 0);
                }
                else if (prev && !next)
                {
                    range.selectNodeContents(prev);
                    range.collapse(false);
                    range.setStartAfter(start);
                }
                else
                {
                    range.setStartAfter(start);
                    range.setEndBefore(end);
                }
            }

            this.selection.setRange(range);

            if (start) start.parentNode.removeChild(start);
            if (end) end.parentNode.removeChild(end);
        }
    },
    remove: function()
    {
        var start = this.find('start');
        var end = this.find('end');

        if (start) start.parentNode.removeChild(start);
        if (end) end.parentNode.removeChild(end);
    },

    // private
    _getPos: function(pos)
    {
        return (pos === undefined) ? 'start' : pos;
    },
    _restoreInject: function(range, start)
    {
        var textNode = this.utils.createInvisibleChar();
        $R.dom(start).after(textNode);

        range.selectNodeContents(textNode);
        range.collapse(false);
    }
});
$R.add('service', 'component', {
    init: function(app)
    {
        this.app = app;

        // local
        this.activeClass = 'redactor-component-active';
    },
    create: function(type, el)
    {
        return $R.create(type + '.component', this.app, el);
    },
    build: function(el)
    {
        var $el = $R.dom(el);
        var component;
        var type = $el.attr('data-redactor-type');
        if (type)
        {
            component = this.create(type, el);
        }

        return (component) ? component : el;
    },
    remove: function(el, caret)
    {
        var $component = $R.dom(el).closest('.redactor-component');
        var type = $component.attr('data-redactor-type');
        var current = $component.parent();
        var data = this.inspector.parse(current);
        var prev = this.utils.findSiblings($component, 'prev');
        var next = this.utils.findSiblings($component, 'next');
        var stop = this.app.broadcast(type + '.delete', $component);
        if (stop !== false)
        {
            $component.remove();

            // callback
            this.app.broadcast(type + '.deleted', $component);
            this.app.broadcast('contextbar.close');
            this.app.broadcast('imageresizer.stop');

            if (caret !== false)
            {
                var cell = data.getTableCell();
                if (cell && this.utils.isEmptyHtml(cell.innerHTML))
                {
                    this.caret.setStart(cell);
                }
                else if (next) this.caret.setStart(next);
                else if (prev) this.caret.setEnd(prev);
                else
                {
                    this.editor.startFocus();
                }
            }

            // is empty
            if (this.editor.isEmpty())
            {
                this.editor.setEmpty();
                this.editor.startFocus();
                this.app.broadcast('empty');
            }
        }
    },
    isNonEditable: function(el)
    {
        var data = this.inspector.parse(el);
        return (data.isComponent() && !data.isComponentEditable());
    },
    isActive: function(el)
    {
        var $component;
        if (el)
        {
            var data = this.inspector.parse(el);
            $component = $R.dom(data.getComponent());

            return $component.hasClass(this.activeClass);
        }
        else
        {
            $component = this._find();

            return ($component.length !== 0);
        }
    },
    getActive: function(dom)
    {
        var $component = this._find();

        return ($component.length !== 0) ? ((dom) ? $component : $component.get()) : false;
    },
    setActive: function(el)
    {
        this.clearActive();
        this.editor.focus();

        var data = this.inspector.parse(el);
        var component = data.getComponent();
        var $component = $R.dom(component);

        if (!data.isFigcaption())
        {
            var $caret = $component.find('.redactor-component-caret');
            if ($caret.length === 0)
            {
                $caret = this._buildCaret();
                $component.prepend($caret);
            }

            this.caret.setAtStart($caret.get());
        }

        $component.addClass(this.activeClass);
    },
    clearActive: function()
    {
        var $component = this._find();

        $component.removeClass(this.activeClass);
        $component.find('.redactor-component-caret').remove();

        this.app.broadcast('imageresizer.stop');
    },
    setOnEvent: function(e, contextmenu)
    {
        this.clearActive();

        var data = this.inspector.parse(e.target);
        if (data.isFigcaption() || data.isComponentEditable())
        {
            return;
        }

        // component
        if (data.isComponent())
        {
            this.setActive(e.target);
            if (contextmenu !== true) e.preventDefault();
        }
    },
    executeScripts: function()
    {
        var $editor = this.editor.getElement();
        var scripts = $editor.find('[data-redactor-type]').find("script").getAll();

        for (var i = 0; i < scripts.length; i++)
        {
            if (scripts[i].src !== '')
            {
                var src = scripts[i].src;
                this.$doc.find('head script[src="' + src + '"]').remove();

                var $script = $R.dom('<script>');
                $script.attr('src', src);
                $script.attr('async defer');

                if (src.search('instagram') !== -1) $script.attr('onload', 'window.instgrm.Embeds.process()');

                var head = document.getElementsByTagName('head')[0];
                if (head) head.appendChild($script.get());
            }
            else
            {
                eval(scripts[i].innerHTML);
            }
        }
    },

    // private
    _find: function()
    {
        return this.editor.getElement().find('.' + this.activeClass);
    },
    _buildCaret: function()
    {
        var $caret = $R.dom('<span>');
        $caret.addClass('redactor-component-caret');
        $caret.attr('contenteditable', true);

        return $caret;
    }
});
$R.add('service', 'insertion', {
    init: function(app)
    {
        this.app = app;
    },
    set: function(html, clean, focus)
    {
        html = (clean !== false) ? this.cleaner.input(html) : html;
        html = (clean !== false) ? this.cleaner.paragraphize(html) : html;

        // set html
        var $editor = this.editor.getElement();
        $editor.html(html);

        // set focus at the end
        if (focus !== false) this.editor.endFocus();

        return html;
    },
    insertNode: function(node, caret)
    {
        this.editor.focus();
        var fragment = (this.utils.isFragment(node)) ? node : this.utils.createFragment(node);

        this._collapseSelection();
        this._insertFragment(fragment);
        this._setCaret(caret, fragment);

        return this._sendNodes(fragment.nodes);
    },
    insertBreakLine: function()
    {
        return this.insertNode(document.createElement('br'), 'after');
    },
    insertNewline: function()
    {
        return this.insertNode(document.createTextNode('\n'), 'after');
    },
    insertText: function(text)
    {
        return this.insertHtml(this.cleaner.getFlatText(text));
    },
    insertChar: function(charhtml)
    {
        return this.insertNode(charhtml, 'after');
    },
    insertRaw: function(html)
    {
        return this.insertHtml(html, false);
    },
    insertToEnd: function(lastNode, type)
    {
        if (!lastNode) return;
        if (lastNode.nodeType === 3 && lastNode.nodeValue.search(/^\n/) !== -1)
        {
            lastNode = lastNode.previousElementSibling;
        }

        var $lastNode = $R.dom(lastNode);
        if ($lastNode.attr('data-redactor-type') === type)
        {
            var tag = (this.opts.breakline) ? '<br>' : '<p>';
            var $newNode = $R.dom(tag);

            $lastNode.after($newNode);
            this.caret.setStart($newNode);
        }
    },
    insertPoint: function(e)
    {
        var range, data;
        var marker = this.marker.build('start');
        var markerInserted = false;
        var x = e.clientX, y = e.clientY;

        if (document.caretPositionFromPoint)
        {
            var pos = document.caretPositionFromPoint(x, y);
            var sel = document.getSelection();

            data = this.inspector.parse(pos.offsetNode);
            if (data.isInEditor())
            {
                range = sel.getRangeAt(0);
                range.setStart(pos.offsetNode, pos.offset);
                range.collapse(true);
                range.insertNode(marker);
                markerInserted = true;
            }
        }
        else if (document.caretRangeFromPoint)
        {
            range = document.caretRangeFromPoint(x, y);

            data = this.inspector.parse(range.startContainer);
            if (data.isInEditor())
            {
                range.insertNode(marker);
                markerInserted = true;
            }
        }

        return markerInserted;
    },
    insertToPoint: function(e, html, point)
    {
        var pointInserted = (point === true) ? true : this.insertPoint(e);
        if (!pointInserted)
        {
            var lastNode = this.editor.getLastNode();
            $R.dom(lastNode).after(this.marker.build('start'));
        }

        this.component.clearActive();
        this.selection.restoreMarkers();

        return this.insertHtml(html);
    },
    insertToOffset: function(start, html)
    {
        this.offset.set({ start: start, end: start });

        return this.insertHtml(html);
    },
    insertHtml: function(html, clean)
    {
        if (!this.opts.input) return;

        // parse
        var parsedInput = this.utils.parseHtml(html);

        // all selection
        if (this.selection.isAll())
        {
            return this._insertToAllSelected(parsedInput);
        }

        // there is no selection
        if (!this.selection.is())
        {
            var $el = $R.dom('<p>');
            var $editor = this.editor.getElement();

            $editor.append($el);
            this.caret.setStart($el);
        }

        // environment
        var isCollapsed = this.selection.isCollapsed();
        var isText = this.selection.isText();
        var current = this.selection.getCurrent();
        var dataCurrent = this.inspector.parse(current);

        // collapse air
        this._collapseSelection();

        // clean
        parsedInput = this._getCleanedInput(parsedInput, dataCurrent, clean);

        // input is figure or component span
        var isFigure = this._isFigure(parsedInput.html);
        var isComponentSpan = this._isComponentSpan(parsedInput.html);
        var isInsertedText = this.inspector.isText(parsedInput.html);
        var fragment, except;

        // empty editor
        if (this.editor.isEmpty())
        {
            return this._insertToEmptyEditor(parsedInput.html);
        }
        // to component
        else if (dataCurrent.isComponent() && !dataCurrent.isComponentEditable())
        {
            return this._insertToWidget(current, dataCurrent, parsedInput.html);
        }
        // component span
        else if (isComponentSpan)
        {
            return this.insertNode(parsedInput.nodes, 'end');
        }
        // inserting figure & split node
        else if (isFigure && !isText && !dataCurrent.isList())
        {
            if (dataCurrent.isInline())
            {
                return this._insertToInline(current, parsedInput);
            }

            fragment = this.utils.createFragment(parsedInput.html);

            this.utils.splitNode(current, fragment);
            this.caret.setEnd(fragment.last);

            return this._sendNodes(fragment.nodes);
        }
        // to code
        else if (dataCurrent.isCode())
        {
            return this._insertToCode(parsedInput, current, clean);
        }
        // to pre
        else if (dataCurrent.isPre())
        {
            return this._insertToPre(parsedInput, clean);
        }
        // to h1-h6 & figcaption
        else if (dataCurrent.isHeading() || dataCurrent.isFigcaption())
        {
            parsedInput.html = (clean !== false) ? this.cleaner.removeTagsExcept(parsedInput.html, ['a']) : parsedInput.html;
            parsedInput.html = (clean !== false) ? this.cleaner.replaceNbspToSpaces(parsedInput.html) : parsedInput.html;

            fragment = this.utils.createFragment(parsedInput.html);

            return this.insertNode(fragment, 'end');
        }
        // text inserting
        else if (isInsertedText)
        {
            if (!isText && this.opts.markup !== 'br' && this._hasBlocksAndImages(parsedInput.nodes))
            {
                parsedInput.html = (clean !== false) ? this.cleaner.paragraphize(parsedInput.html) : parsedInput.html;

                fragment = this.utils.createFragment(parsedInput.html);

                this.utils.splitNode(current, fragment);
                this.caret.setEnd(fragment.last);
                return this._sendNodes(fragment.nodes);
            }

            parsedInput.html = (clean !== false) ? parsedInput.html.replace(/\n/g, '<br>') : parsedInput.html;

            fragment = this.utils.createFragment(parsedInput.html);

            return this.insertNode(fragment.nodes, 'end');
        }
        // uncollapsed
        else if (!isCollapsed && !isFigure)
        {
            parsedInput.html = (clean !== false) ? this.cleaner.paragraphize(parsedInput.html) : parsedInput.html;

            fragment = this.utils.createFragment(parsedInput.html);

            return this.insertNode(fragment, 'end');
        }
        // to inline tag
        else if (dataCurrent.isInline() && !this._isPlainHtml(parsedInput.html))
        {
            return this._insertToInline(current, parsedInput);
        }
        // to blockquote or dt, dd
        else if (dataCurrent.isBlockquote() || dataCurrent.isDl())
        {
            except = this.opts.inlineTags;
            except.concat(['br']);

            parsedInput.html = (clean !== false) ? this.cleaner.replaceBlocksToBr(parsedInput.html) : parsedInput.html;
            parsedInput.html = (clean !== false) ? this.cleaner.removeTagsExcept(parsedInput.html, except) : parsedInput.html;

            fragment = this.utils.createFragment(parsedInput.html);

            return this.insertNode(fragment, 'end');
        }
        // to p
        else if (dataCurrent.isParagraph())
        {
            if (this._isPlainHtml(parsedInput.html))
            {
                return this.insertNode(parsedInput.nodes, 'end');
            }

            parsedInput.html = (clean !== false) ? this.cleaner.paragraphize(parsedInput.html) : parsedInput.html;

            fragment = this.utils.createFragment(parsedInput.html);

            this.utils.splitNode(current, fragment);
            this.caret.setEnd(fragment.last);

            return this._sendNodes(fragment.nodes);
        }
        // to li
        else if (dataCurrent.isList())
        {
            except = this.opts.inlineTags;
            except = except.concat(['br', 'li', 'ul', 'ol', 'img']);

            parsedInput.html = (clean !== false) ? this.cleaner.replaceBlocksToBr(parsedInput.html) : parsedInput.html;
            parsedInput.html = (clean !== false) ? this.cleaner.removeTagsExcept(parsedInput.html, except) : parsedInput.html;
            parsedInput.html = (clean !== false) ? this.cleaner.removeBrAtEnd(parsedInput.html) : parsedInput.html;

            fragment = this.utils.createFragment(parsedInput.html);
            parsedInput.nodes = fragment.nodes;

            if (this._containsTags(parsedInput.html, ['ul', 'ol', 'li']))
            {
                var element = this.selection.getElement(current);
                if (element && element.tagName === 'LI' && this.caret.isStart(element))
                {
                    parsedInput.nodes = $R.dom(fragment.nodes).unwrap('ul, ol').getAll();
                    $R.dom(element).before(parsedInput.nodes);

                    var lastNode = parsedInput.nodes[parsedInput.nodes.length-1];
                    this.caret.setEnd(lastNode);

                    return this._sendNodes(parsedInput.nodes);
                }
                else if (this._isPlainHtml(parsedInput.html))
                {
                    return this.insertNode(fragment, 'end');
                }
                else
                {
                    fragment = this._buildList(parsedInput, element, fragment);

                    this.utils.splitNode(current, fragment, true);
                    this.caret.setEnd(fragment.last);

                    return this._sendNodes(fragment.nodes);
                }
            }
        }

        // other cases
        return this.insertNode(parsedInput.nodes, 'end');
    },

    // private
    _insertToAllSelected: function(parsedInput)
    {
        var insertedHtml = this.set(parsedInput.html);
        var dataInserted = this.utils.parseHtml(insertedHtml);

        return this._sendNodes(dataInserted.nodes);
    },
    _insertToEmptyEditor: function(html)
    {
        html = this.cleaner.paragraphize(html);

        var fragment = this.utils.createFragment(html);
        var $editor = this.editor.getElement();

        $editor.html('');
        $editor.append(fragment.frag);

        this.caret.setEnd(fragment.last);

        return this._sendNodes(fragment.nodes);
    },
    _insertToInline: function(current, parsedInput)
    {
        var fragment = this.utils.createFragment(parsedInput.html);
        this.utils.splitNode(current, fragment, false, true);
        this.caret.setEnd(fragment.last);

        return this._sendNodes(fragment.nodes);
    },
    _insertToCode: function(parsedInput, current, clean)
    {
        parsedInput.html = (clean !== false) ? this.cleaner.encodeHtml(parsedInput.html) : parsedInput.html;
        parsedInput.html = (clean !== false) ? this.cleaner.removeNl(parsedInput.html) : parsedInput.html;

        var fragment = this.utils.createFragment(parsedInput.html);
        var nodes = this.insertNode(fragment, 'end');

        this.utils.normalizeTextNodes(current);

        return nodes;
    },
    _insertToPre: function(parsedInput, clean)
    {
        parsedInput.html = (clean !== false) ? this.cleaner.encodeHtml(parsedInput.html) : parsedInput.html;

        var fragment = this.utils.createFragment(parsedInput.html);

        return this.insertNode(fragment, 'end');
    },
    _insertToWidget: function(current, dataCurrent, html)
    {
        html = (this._isComponentSpan(html)) ? html : this.cleaner.paragraphize(html);

        var fragment = this.utils.createFragment(html);
        var component = dataCurrent.getComponent();
        var $component = $R.dom(component);

        $component.after(fragment.frag);
        $component.remove();

        this.caret.setEnd(fragment.last);

        return this._sendNodes(fragment.nodes);
    },
    _insertFragment: function(fragment)
    {
        var range = this.selection.getRange();
        if (range)
        {
            if (this.selection.isCollapsed())
            {
                var startNode = range.startContainer;
                if (startNode.nodeType !== 3 && startNode.tagName === 'BR')
                {
                    this.caret.setAfter(startNode);
                    startNode.parentNode.removeChild(startNode);
                }
            }
            else
            {
                range.deleteContents();
            }

            range.insertNode(fragment.frag);
        }
    },
    _sendNodes: function(nodes)
    {
        for (var i = 0; i < nodes.length; i++)
        {
            var el = nodes[i];
            var type = (el.nodeType !== 3 && typeof el.getAttribute === 'function') ? el.getAttribute('data-redactor-type') : false;
            if (type)
            {
                this.app.broadcast(type + '.inserted', this.component.build(el));
            }
        }

        if (this.detector.isIe())
        {
            this.editor.getElement().find('[data-redactor-type=table]').attr('contenteditable', true);
        }

        // callback
        this.app.broadcast('inserted', nodes);

        // widget's scripts
        this.component.executeScripts();

        return nodes;
    },
    _setCaret: function(caret, fragment)
    {
        var isLastInline = this._isLastInline(fragment);

        if (caret)
        {
            caret = (isLastInline && caret === 'end') ? 'after' : caret;
            this.caret['set' + this.utils.ucfirst(caret)](fragment.last);
        }
        else if (caret !== false)
        {
            if (isLastInline) this.caret.setAfter(fragment.last);
        }
    },
    _isLastInline: function(fragment)
    {
        if (fragment.last)
        {
            var data = this.inspector.parse(fragment.last);

            return data.isInline();
        }

        return false;
    },
    _getCleanedInput: function(parsedInput, dataCurrent, clean)
    {
        var isPreformatted = (dataCurrent.isCode() || dataCurrent.isPre());

        parsedInput.html = parsedInput.html.replace(/&nbsp;/g, ' ');
        parsedInput.html = (!isPreformatted && clean !== false) ? this.cleaner.input(parsedInput.html) : parsedInput.html;
        parsedInput = (!isPreformatted && clean !== false) ? this.utils.parseHtml(parsedInput.html) : parsedInput;

        return parsedInput;
    },
    _getContainer: function(nodes)
    {
        return $R.dom(this.utils.createTmpContainer(nodes));
    },
    _buildList: function(parsedInput, list, fragment)
    {
        var nodes = parsedInput.nodes;
        var first = nodes[0];

        if (first && first.nodeType !== 3 && first.tagName === 'li')
        {
            var $parent = $R.dom(list);
            var parentListTag = $parent.get().tagName.toLowerCase();
            var $list = $R.dom('<' + parentListTag + ' />');
            $list.append(fragment.nodes);

            return this.utils.createFragment($list.get().outerHTML);
        }

        return fragment;
    },
    _containsTags: function(html, tags)
    {
        return (this._getContainer(html).find(tags.join(',')).length !== 0);
    },
    _collapseSelection: function()
    {
        //if (this.app.isAirToolbar()) this.selection.collapseToEnd();
    },
    _hasFigureOrTable: function(nodes)
    {
        return (this._getContainer(nodes).find('figure, table').length !== 0);
    },
    _hasBlocks: function(nodes)
    {
        return (this._getContainer(nodes).find(this.opts.blockTags.join(',')).length !== 0);
    },
    _hasBlocksAndImages: function(nodes)
    {
        return (this._getContainer(nodes).find(this.opts.blockTags.join(',') + ',img').length !== 0);
    },
    _isPlainHtml: function(html)
    {
        return (this._getContainer(html).find(this.opts.blockTags.join(',') + ', img').length === 0);
    },
    _isFigure: function(html)
    {
        if (this._isHtmlString(html))
        {
            return ($R.dom(html).closest('figure').length !== 0);
        }
    },
    _isComponentSpan: function(html)
    {
        if (this._isHtmlString(html))
        {
            return ($R.dom(html).closest('span.redactor-component').length !== 0);
        }
    },
    _isHtmlString: function(html)
    {
        return !(typeof html === 'string' && !/^\s*<(\w+|!)[^>]*>/.test(html));
    }
});
$R.add('service', 'block', {
    mixins: ['formatter'],
    init: function(app)
    {
        this.app = app;
    },
    // public
    format: function(args)
    {
        // type of applying styles and attributes
        this.type = (args.type) ? args.type : 'set'; // add, remove, toggle

        // tag
        this.tag = (typeof args === 'string') ? args : args.tag;
        this.tag = this._prepareTag(this.tag);
        this.tag = this.tag.toLowerCase();

        if (typeof args === 'string') this.args = false;
        else this.buildArgs(args);

        // format
        return this._format();
    },
    getBlocks: function(tags)
    {
        return this.selection.getBlocks({ tags: tags || this._getTags(), first: true });
    },
    getElements: function(tags)
    {
        var block = this.selection.getBlock();
        if (!this.selection.isCollapsed() && block && (block.tagName === 'TD' || block.tagName === 'TH'))
        {
            return this._wrapInsideTable('div');
        }
        else
        {
            return $R.dom(this.getBlocks(tags));
        }
    },
    clearFormat: function(tags)
	{
		this.selection.save();

        var $elements = this.getElements(tags || this._getTags());
        $elements.each(function(node)
        {
            while(node.attributes.length > 0)
            {
                node.removeAttribute(node.attributes[0].name);
            }
        });

		this.selection.restore();

        return $elements.getAll();
	},

    // private
    _format: function()
    {
        this.selection.save();
        var blocks = this.getBlocks();
        var block = this.selection.getBlock();
        var nodes = [];
        var data, replacedTag, $wrapper, nextBr;

        // div break format
        if (blocks.length === 1 && blocks[0].tagName === 'DIV')
        {
            data = this._getTextNodesData();
            if (!data || data.nodes.length === 0)
            {
                nodes = this._replaceBlocks(blocks);
                nodes = this._sendNodes(nodes);

                setTimeout(function() { this.selection.restore(); }.bind(this), 0);

                return nodes;
            }

            replacedTag = this._getReplacedTag('set');
            $wrapper = $R.dom('<' + replacedTag + '>');

            nextBr = data.last.nextSibling;
            if (nextBr && nextBr.tagName === 'BR')
            {
                $R.dom(nextBr).remove();
            }

            for (var i = 0; i < data.nodes.length; i++)
            {
                $wrapper.append(data.nodes[i]);
            }

            this.utils.splitNode(blocks[0], [$wrapper.get()]);
            nodes = this._sendNodes([$wrapper.get()]);

            if (this.utils.isEmptyHtml($wrapper.html()))
            {
                this.caret.setStart($wrapper);
            }
            else
            {
                setTimeout(function() { this.selection.restore(); }.bind(this), 0);
            }

            return nodes;
        }
        // standard format
        else if (blocks.length > 0)
        {
            nodes = this._replaceBlocks(blocks);
            nodes = this._sendNodes(nodes);

            if (this.selection.isCollapsed() && blocks.length === 1 && this.utils.isEmpty(blocks[0]))
            {
                this.caret.setStart(nodes[0]);
            }
            else
            {
                setTimeout(function() { this.selection.restore(); }.bind(this), 1);
            }

            return nodes;
        }
        // td/th format uncollapsed
        else if (!this.selection.isCollapsed() && block && (block.tagName === 'TD' || block.tagName === 'TH'))
        {
            replacedTag = this._getReplacedTag('set');

            $wrapper = this._wrapInsideTable(replacedTag);

            this.selection.setAll($wrapper);

            return this._sendNodes([$wrapper.get()]);
        }
        // td/th format collapsed
        else if (this.selection.isCollapsed() && block && (block.tagName === 'TD' || block.tagName === 'TH'))
        {
            var textnodes = this._getChildTextNodes(block);

            replacedTag = this._getReplacedTag('set');
            var $wrapper = $R.dom('<' + replacedTag + '>');

            $R.dom(textnodes.first).before($wrapper);

            for (var i = 0; i < textnodes.nodes.length; i++)
            {
                $wrapper.append(textnodes.nodes[i]);
            }

            var nextBr = $wrapper.get().nextSibling;
            if (nextBr && nextBr.tagName === 'BR')
            {
                $R.dom(nextBr).remove();
            }

            return this._sendNodes([$wrapper.get()]);
        }

        return nodes;
    },
    _wrapInsideTable: function(replacedTag)
    {
        var data = this._getTextNodesData();
        var $wrapper = $R.dom('<' + replacedTag + '>');

        $R.dom(data.first).before($wrapper);

        for (var i = 0; i < data.nodes.length; i++)
        {
            $wrapper.append(data.nodes[i]);
        }

        var nextBr = $wrapper.get().nextSibling;
        if (nextBr && nextBr.tagName === 'BR')
        {
            $R.dom(nextBr).remove();
        }

        return $wrapper;
    },
    _prepareTag: function(tag)
    {
        return (typeof tag === 'undefined') ? this.opts.markup : tag;
    },
    _sendNodes: function(nodes)
    {
        if (nodes.length > 0)
        {
            // clean & appliyng styles and attributes
            nodes = this.applyArgs(nodes, false);
            nodes = this._combinePre(nodes);
            nodes = this._cleanBlocks(nodes);
        }

        return nodes;
    },
    _getTags: function()
    {
        return ['div', 'p', 'blockquote', 'pre', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6'];
    },
    _replaceBlocks: function(blocks)
    {
        var nodes = [];
        var type = (this._isToggleFormatType(blocks)) ? 'toggle' : 'set';
        var replacedTag = this._getReplacedTag(type);

        for (var i = 0; i < blocks.length; i++)
        {
            var $node = this.utils.replaceToTag(blocks[i], replacedTag);
            nodes.push($node.get());
        }

        return nodes;
    },
    _getReplacedTag: function(type)
    {
        var replacedTag = (type === 'toggle') ? this.opts.markup : this.tag;

        return (this.opts.breakline && replacedTag === 'p') ? 'div' : replacedTag;
    },
    _getChildTextNodes: function(el)
    {
        var nodes = el.childNodes;
        var firstNode = nodes[0];
        var finalNodes = [];
        for (var i = 0; i <= nodes.length; i++)
        {
            var node = nodes[i];
            if (node && node.nodeType !== 3 && this.inspector.isBlockTag(node.tagName))
            {
                break;
            }

            finalNodes.push(node);
        }

        return {
            nodes: finalNodes,
            first: firstNode
        };
    },
    _getTextNodesData: function()
    {
        var nodes = this.selection.getNodes({ textnodes: true, keepbr: true });
        if (nodes.length === 0) return false;

        var firstNode = nodes[0];
        var lastNode = nodes[nodes.length-1];
        var node = lastNode;
        var stop = false;

        while (!stop)
        {
            var inline = this.selection.getInline(node);
            node = (inline) ? inline.nextSibling : node.nextSibling;
            if (!node)
            {
                stop = true;
            }
            else if (node.nodeType !== 3 && (node.tagName === 'BR' || this.inspector.isBlockTag(node.tagName)))
            {
                stop = true;
            }
            else
            {
                nodes.push(node);
            }
        }

        return {
            nodes: nodes,
            first: firstNode,
            last: lastNode
        };
    },
    _isToggleFormatType: function(blocks)
    {
        var count = 0;
        var len = blocks.length;
        for (var i = 0; i < len; i++)
        {
            if (blocks[i] && this.tag === blocks[i].tagName.toLowerCase()) count++;
        }

        return (count === len);
    },
    _combinePre: function(nodes)
    {
        var combinedNodes = [];
        for (var i = 0; i < nodes.length; i++)
        {
            var next = nodes[i].nextElementSibling;
            if (next && nodes[i].tagName === 'PRE' && next.tagName === 'PRE')
            {
                var $current = $R.dom(nodes[i]);
                var $next = $R.dom(next);
                var newline = document.createTextNode('\n');

                $current.append(newline);
                $current.append($next);
                $next.unwrap('pre');
            }

            combinedNodes.push(nodes[i]);
        }

        return combinedNodes;
    },
    _cleanBlocks: function(nodes)
    {
        var headings = ['h1', 'h2', 'h3', 'h4', 'h5', 'h6'];
        var tags = this.opts.inlineTags;
        for (var i = 0; i < nodes.length; i++)
        {
            var tag = nodes[i].tagName.toLowerCase();
            var $node = $R.dom(nodes[i]);

            if (headings.indexOf(tag) !== - 1)
            {
                $node.find('span').not('.redactor-component, .non-editable, .redactor-selection-marker').unwrap();
            }
            else if (tag === 'pre')
            {
                $node.find(tags.join(',')).not('.redactor-selection-marker').unwrap();
            }

            // breakline attr
            if (this.opts.breakline && tag === 'div')
            {
                $node.attr('data-redactor-tag', 'br');
            }
            else
            {
                $node.removeAttr('data-redactor-tag');
            }

            this.utils.normalizeTextNodes(nodes[i]);
        }

        return nodes;
    }
});
$R.add('service', 'inline', {
    mixins: ['formatter'],
    init: function(app)
    {
        this.app = app;

        this.count = 0;
    },
    // public
    format: function(args)
    {
        if (!this._isFormat()) return [];

        // type of applying styles and attributes
        this.type = (args.type) ? args.type : 'set'; // add, remove, toggle
        // tag
        this.tag = (typeof args === 'string') ? args : args.tag;
        this.tag = this.tag.toLowerCase();
        this.tag = this.arrangeTag(this.tag);

        if (typeof args === 'string') this.args = false;
        else this.buildArgs(args);

        if (!this.detector.isIe())
        {
            this.editor.disableNonEditables();
        }

        // format
        var nodes = (this.selection.isCollapsed()) ? this.formatCollapsed() : this.formatUncollapsed();

        if (!this.detector.isIe())
        {
            this.editor.enableNonEditables();
        }

        return nodes;
    },

    // private
    _isFormat: function()
    {
        var current = this.selection.getCurrent();
        var data = this.inspector.parse(current);
        var isComponent = (data.isComponent() && !data.isComponentType('table') && !data.isFigcaption());

        if (current === false && this.selection.isAll())
        {
            return true;
        }
        else if (!current || data.isPre() || data.isCode() || isComponent)
        {
            return false;
        }

        return true;
    },
    arrangeTag: function(tag)
    {
        var replaced = this.opts.replaceTags;
        for (var key in replaced)
        {
            if (tag === key) tag = replaced[key];
        }

        return tag;
    },
    formatCollapsed: function()
    {
        var nodes = [];
        var inline = this.selection.getInlineFirst();
        var inlines = this.selection.getInlines({ all: true });
        var $inline = $R.dom(inline);
        var $parent, parent, $secondPart, extractedContent;

        // 1) not inline
        if (!inline)
        {
            nodes = this.insertInline(nodes);
        }
        else
        {
            var dataInline = this.inspector.parse(inline);
            var isEmpty = this.utils.isEmptyHtml(inline.innerHTML);

            // 2) inline is empty
            if (isEmpty)
            {
                // 2.1) has same tag
                if (inline.tagName.toLowerCase() === this.tag)
                {
                    // 2.1.1) has same args or hasn't args
                    if (this.hasSameArgs(inline))
                    {
                        this.caret.setAfter(inline);
                        $inline.remove();

                        var el = this.selection.getElement();
                        this.utils.normalizeTextNodes(el);
                    }
                    // 2.1.2) has different args and it is span tag
                    else if (this.tag === 'span')
                    {
                        nodes = this.applyArgs([inline], false);
                        this.caret.setStart(inline);
                    }
                    // 2.1.3) has different args and it is not span tag
                    else
                    {
                       nodes = this.insertInline(nodes);
                    }

                }
                // 2.2) has another tag
                else
                {
                    // 2.2.1) has parent
                    if (dataInline.hasParent([this.tag]))
                    {
                        $parent = $inline.closest(this.tag);
                        parent = $parent.get();
                        if (this.hasSameArgs(parent))
                        {
                            $parent.unwrap();
                            this.caret.setStart(inline);
                        }
                        else
                        {
                            nodes = this.insertInline(nodes);
                        }
                    }
                    // 2.2.2) hasn't parent
                    else
                    {
                        nodes = this.insertInline(nodes);
                    }
                }
            }
            // 3) inline isn't empty
            else
            {
                // 3.1) has same tag
                if (inline.tagName.toLowerCase() === this.tag)
                {
                    // 3.1.1) has same args or hasn't args
                    if (this.hasSameArgs(inline))
                    {
                        // insert break
                        extractedContent = this.utils.extractHtmlFromCaret(inline);
                        $secondPart = $R.dom('<' + this.tag + ' />');
                        $secondPart = this.utils.cloneAttributes(inline, $secondPart);

                        $inline.after($secondPart.append(extractedContent));

                        this.caret.setAfter(inline);
                    }
                    else
                    {
                        nodes = this.insertInline(nodes);
                    }
                }
                // 3.2) has another tag
                else
                {
                    // 3.2.1) has parent
                    if (dataInline.hasParent([this.tag]))
                    {
                        $parent = $inline.closest(this.tag);
                        parent = $parent.get();
                        if (this.hasSameArgs(parent))
                        {
                            // insert break
                            extractedContent = this.utils.extractHtmlFromCaret(parent, parent);
                            $secondPart = $R.dom('<' + this.tag + ' />');
                            $secondPart = this.utils.cloneAttributes(parent, $secondPart);

                            var $breaked, $last;
                            var z = 0;
                            inlines = inlines.reverse();
                            for (var i = 0; i < inlines.length; i++)
                            {
                                if (inlines[i] !== parent)
                                {
                                    $last = $R.dom('<' + inlines[i].tagName.toLowerCase() + '>');
                                    if (z === 0)
                                    {
                                        $breaked = $last;
                                    }
                                    else
                                    {
                                        $breaked.append($last);
                                    }

                                    z++;
                                }
                            }

                            $parent.after($secondPart.append(extractedContent));
                            $parent.after($breaked);

                            this.caret.setStart($last);
                        }
                        else
                        {
                            nodes = this.insertInline(nodes);
                        }
                    }
                    // 3.2.2) hasn't parent
                    else
                    {
                        nodes = this.insertInline(nodes);
                    }
                }
            }
        }

        return nodes;
    },
    insertInline: function(nodes)
    {
        var node = document.createElement(this.tag);
        nodes = this.insertion.insertNode(node, 'start');

        return this.applyArgs(nodes, false);
    },
    hasSameArgs: function(inline)
    {
        if (inline.attributes.length === 0 && this.args === false)
        {
            return true;
        }
        else
        {
            var same = true;
            if (this.args)
            {
                var count = 0;
                for (var key in this.args)
                {
                    var $node = $R.dom(inline);
                    var args = (this.args[key]);
                    var value = this.utils.toParams(args);
                    var nodeAttrValue = $node.attr(key);

                    if (args)
                    {
                        if (key === 'style')
                        {
                            value = value.trim().replace(/;$/, '');

                            var origRules = this.utils.styleToObj($node.attr('style'));
                            var rules = value.split(';');
                            var innerCount = 0;

                            for (var i = 0; i < rules.length; i++)
                            {
                                var arr = rules[i].split(':');
                                var ruleName = arr[0].trim();
                                var ruleValue = arr[1].trim();

                                if (ruleName.search(/color/) !== -1)
                                {
                                    var val = $node.css(ruleName);
                                    if (val && (val === ruleValue || this.utils.rgb2hex(val) === ruleValue))
                                    {
                                        innerCount++;
                                    }
                                }
                                else if ($node.css(ruleName) === ruleValue)
                                {
                                    innerCount++;
                                }
                            }

                            if (innerCount === rules.length && Object.keys(origRules).length === rules.length)
                            {
                                count++;
                            }
                        }
                        else
                        {
                            if (nodeAttrValue === value)
                            {
                                count++;
                            }
                        }
                    }
                    else
                    {
                        if (!nodeAttrValue || nodeAttrValue === '')
                        {
                            count++;
                        }
                    }
                }

                same = (count === Object.keys(this.args).length);
            }

            return same;
        }
    },
    formatUncollapsed: function()
    {
        var inlines = this.selection.getInlines({ all: true, inside: true });

        if (this.detector.isIe()) this.selection.saveMarkers();
        else this.selection.save();

        // convert del / u
        this._convertTags('u');
        this._convertTags('del');

        // convert target tags
        this._convertToStrike(inlines);

        if (this.detector.isIe()) this.selection.restoreMarkers();
        else this.selection.restore();

        // apply strike
        document.execCommand('strikethrough');

        // clear decoration
        this._clearDecoration();

        this.selection.save();

        // revert and set style
        var nodes = this._revertToInlines();
        nodes = this.applyArgs(nodes, false);

        // unwrap if attributes was removed
        for (var i = 0; i < nodes.length; i++)
        {
            var node = nodes[i];
            var tag = node.tagName.toLowerCase();
            var len = node.attributes.length;

            if (tag === this.tag && len === 0 && this.args)
            {
                $R.dom(node).unwrap();
                nodes.splice(i, 1);
            }
        }

        this.selection.restore();

        // clear and normalize
        this._clearEmptyStyle();
        nodes = this._normalizeBlocks(nodes);

        return nodes;
    },
    _convertTags: function(tag)
    {
        if (this.tag !== tag)
        {
            var $editor = this.editor.getElement();
            $editor.find(tag).each(function(node)
            {
                var $el = this.utils.replaceToTag(node, 'span');
                $el.addClass('redactor-convertable-' + tag);
            }.bind(this));
        }
    },
    _revertTags: function(tag)
    {
        var $editor = this.editor.getElement();

        $editor.find('span.redactor-convertable-' + tag).each(function(node)
        {
            var $el = this.utils.replaceToTag(node, tag);
            $el.removeClass('redactor-convertable-' + tag);
            if (this.utils.removeEmptyAttr($el, 'class')) $el.removeAttr('class');

        }.bind(this));
    },
    _convertToStrike: function(inlines)
    {
        var selected = this.selection.getText().replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&");

        for (var i = 0; i < inlines.length; i++)
        {
            var tag = this.arrangeTag(inlines[i].tagName.toLowerCase());
            var inline = inlines[i];
            var $inline = $R.dom(inline);
            var hasSameArgs = this.hasSameArgs(inline);

            if (tag === this.tag)
            {
                if (this.tag === 'span' && this._isTextSelected(inline, selected))
                {
                    $inline.addClass('redactor-convertable-apply');
                }
                else if (hasSameArgs && this.tag !== 'a')
                {
                    this._replaceToStrike($inline);
                }
                else if (this.tag === 'span')
                {
                    $inline.addClass('redactor-unconvertable-apply');
                }
                else if (!hasSameArgs)
                {
                    $inline.addClass('redactor-convertable-apply');
                }
            }
        }
    },
    _replaceToStrike: function($el)
    {
        $el.replaceWith(function()
        {
            return $R.dom('<strike>').append($el.contents());
        });
    },
    _revertToInlines: function()
    {
        var nodes = [];
        var $editor = this.editor.getElement();

        if (this.tag !== 'u') $editor.find('u').unwrap();

        // span convertable
        $editor.find('.redactor-convertable-apply').each(function(node)
        {
            var $node = $R.dom(node);
            $node.find('strike').unwrap();

            this._forceRemoveClass($node, 'redactor-convertable-apply');
            nodes.push(node);

        }.bind(this));

        // span unconvertable
        $editor.find('span.redactor-unconvertable-apply').each(function(node)
        {
            var $node = $R.dom(node);
            this._forceRemoveClass($node, 'redactor-unconvertable-apply');

        }.bind(this));

        // strike
        $editor.find('strike').each(function(node)
        {
            var $node = this.utils.replaceToTag(node, this.tag);
            nodes.push($node.get());

        }.bind(this));


        this._revertTags('u');
        this._revertTags('del');

        return nodes;
    },
    _normalizeBlocks: function(nodes)
    {
        var tags = this.opts.inlineTags;
        var blocks = this.selection.getBlocks();
        if (blocks)
        {
            for (var i = 0; i < blocks.length; i++)
            {
                if (blocks[i].tagName === 'PRE')
                {
                    var $node = $R.dom(blocks[i]);
                    $node.find(tags.join(',')).not('.redactor-selection-marker').each(function(inline)
                    {
                        if (nodes.indexOf(inline) !== -1)
                        {
                            nodes = this.utils.removeFromArrayByValue(nodes, inline);
                        }

                        $R.dom(inline).unwrap();
                    }.bind(this));
                }
            }
        }

        return nodes;
    },
    _clearDecoration: function()
    {
        var $editor = this.editor.getElement();
        $editor.find(this.opts.inlineTags.join(',')).each(function(node)
        {
            if (node.style.textDecoration === 'line-through' || node.style.textDecorationLine === 'line-through')
            {
                var $el = $R.dom(node);
                $el.css('textDecorationLine', '');
                $el.css('textDecoration', '');
                $el.wrap('<strike>');
            }
        });
    },
    _clearEmptyStyle: function()
    {
        var inlines = this.getInlines();
        for (var i = 0; i < inlines.length; i++)
        {
            this._clearEmptyStyleAttr(inlines[i]);

            var childNodes = inlines[i].childNodes;
            if (childNodes)
            {
                for (var z = 0; z < childNodes.length; z++)
                {
                    this._clearEmptyStyleAttr(childNodes[z]);
                }
            }
        }
    },
    _clearEmptyStyleAttr: function(node)
    {
        if (node.nodeType !== 3 && this.utils.removeEmptyAttr(node, 'style'))
        {
            node.removeAttribute('style');
            node.removeAttribute('data-redactor-style-cache');
        }
    },
    _forceRemoveClass: function($node, classname)
    {
        $node.removeClass(classname);
        if (this.utils.removeEmptyAttr($node, 'class')) $node.removeAttr('class');
    },
    _isTextSelected: function(node, selected)
    {
        var text = this.utils.removeInvisibleChars(node.textContent);

        return (selected === text || selected.search(new RegExp('^' + this.utils.escapeRegExp(text) + '$')) !== -1);
    },

    getInlines: function(tags)
    {
        return (tags) ? this.selection.getInlines({ tags: tags, all: true }) : this.selection.getInlines({ all: true });
    },
    getElements: function(tags)
    {
        return $R.dom(this.getInlines(tags));
    },
    clearFormat: function()
    {
        this.selection.save();

        var nodes = this.selection.getInlines({ all: true });
        for (var i = 0; i < nodes.length; i++)
        {
            var $el = $R.dom(nodes[i]);
            var inline = this.selection.getInline(nodes[i]);
            if (inline)
            {
                $el.unwrap();
            }
        }

        this.selection.restore();
    }
});
$R.add('service', 'autoparser', {
    init: function(app)
    {
        this.app = app;
    },
    observe: function()
    {
        var $editor = this.editor.getElement();
        var $objects = $editor.find('.redactor-autoparser-object').each(function(node)
        {
           var $node = $R.dom(node);
           $node.removeClass('redactor-autoparser-object');
           if ($node.attr('class') === '') $node.removeAttr('class');
        });

        if ($objects.length > 0)
        {
            $objects.each(function(node)
            {
                var type;
                var $object = false;
                var tag = node.tagName;

                if (tag === 'A') type = 'link';
                else if (tag === 'IMG') type = 'image';
                else if (tag === 'IFRAME') type = 'video';

                if (type)
                {
                    $object = $R.create(type + '.component', this.app, node);
                    this.app.broadcast(type + '.inserted', $object);
                    this.app.broadcast('autoparse', type, $object);
                }

            }.bind(this));
        }
    },
    format: function(e, key)
    {
        if (this._isKey(key))
        {
            this._format(key === this.keycodes.ENTER);
        }
    },
    parse: function(html)
    {
        var tags = ['figure', 'form', 'pre', 'iframe', 'code', 'a', 'img'];
        var stored = [];
        var z = 0;

        // encode
        html = this.cleaner.encodePreCode(html);

        // store tags
        for (var i = 0; i < tags.length; i++)
        {
            var reTags = (tags[i] === 'img') ? '<' + tags[i] + '[^>]*>' : '<' + tags[i] + '([\\w\\W]*?)</' + tags[i] + '>';
            var matched = html.match(new RegExp(reTags, 'gi'));

            if (matched !== null)
            {
                for (var y = 0; y < matched.length; y++)
                {
                    html = html.replace(matched[y], '#####replaceparse' + z + '#####');
                    stored.push(matched[y]);
                    z++;
                }
            }
        }

        // images
        if (this.opts.autoparseImages && html.match(this.opts.regex.imageurl))
        {
            var imagesMatches = html.match(this.opts.regex.imageurl);
            for (var i = 0; i < imagesMatches.length; i++)
            {
                html = html.replace(imagesMatches[i], '<img class="redactor-autoparser-object" src="' + imagesMatches[i] + '">');
            }
        }

        // video
        if (this.opts.autoparseVideo && (html.match(this.opts.regex.youtube) || html.match(this.opts.regex.vimeo)))
        {
            var iframeStart = '<iframe width="500" height="281" src="';
            var iframeEnd = '" frameborder="0" allowfullscreen></iframe>';

            var str, re;
            if (html.match(this.opts.regex.youtube))
            {
                str = '//www.youtube.com/embed/$1';
                re = this.opts.regex.youtube;
            }
            else if (html.match(this.opts.regex.vimeo))
            {
                str = '//player.vimeo.com/video/$2';
                re = this.opts.regex.vimeo;
            }

            var $video = this.component.create('video', iframeStart + str + iframeEnd);

            html = html.replace(re, $video.get().outerHTML);
        }

        // links
        if (this.opts.autoparseLinks && html.match(this.opts.regex.url))
        {
            html = this._formatLinks(html);
        }

        // restore
        html = this._restoreReplaced(stored, html);

        // repeat for nested tags
        html = this._restoreReplaced(stored, html);

        return html;
    },

    // private
    _isKey: function(key)
    {
        return (key === this.keycodes.ENTER || key === this.keycodes.SPACE);
    },
    _format: function(enter)
    {
        var parent = this.selection.getParent();
        var $parent = $R.dom(parent);

        var isNotFormatted = (parent && $parent.closest('figure, pre, code, img, a, iframe').length !== 0);
        if (isNotFormatted || !this.selection.isCollapsed())
        {
            return;
        }

        // add split marker
        var marker = this.utils.createInvisibleChar();
        var range = this.selection.getRange();
        range.insertNode(marker);

        var current = this.selection.getCurrent();
        var data = this.inspector.parse(current);
        var $current = $R.dom(current);

        // remove split marker
        marker.parentNode.removeChild(marker);

        if (current && current.nodeType === 3)
        {
            var content = current.textContent;
            var type;

            // images
            if (this.opts.autoparseImages && content.match(this._convertToRegExp(this.opts.regex.imageurl)))
            {
                var isList = data.isList();
                var matches = content.match(this.opts.regex.imageurl);
                var el = (isList) ? undefined : '<figure><img></figure>';

                var $img = this.component.create('image', el);
                $img.setSrc(matches[0]);
                $img.addClass('redactor-autoparser-object');

                content = content.replace(matches[0], $img.get().outerHTML);
                type = 'image';
            }
            // video
            else if (this.opts.autoparseVideo && (content.match(this._convertToRegExp(this.opts.regex.youtube)) || content.match(this._convertToRegExp(this.opts.regex.vimeo))))
            {
                var iframeStart = '<iframe width="500" height="281" src="';
                var iframeEnd = '" frameborder="0" allowfullscreen></iframe>';
                var str, re;

                if (content.match(this.opts.regex.youtube))
                {
                    str = '//www.youtube.com/embed/$1';
                    re = this.opts.regex.youtube;
                }
                else if (content.match(this.opts.regex.vimeo))
                {
                    str = '//player.vimeo.com/video/$2';
                    re = this.opts.regex.vimeo;
                }

                var $video = this.component.create('video', iframeStart + str + iframeEnd);
                $video.addClass('redactor-autoparser-object');

                content = content.replace(re, $video.get().outerHTML);
                type = 'video';
            }
            // links
            else if (this.opts.autoparseLinks && content.match(this._convertToRegExp(this.opts.regex.url)))
            {
                content = this._formatLinks(content, enter);
                type = 'link';
            }

            // replace
            if (type)
            {
                if (enter)
                {
                    this.selection.save();
                    $current.replaceWith(content);
                    this.selection.restore();
                }
                else
                {
                    $current.replaceWith(content);
                }

                // object
                var $editor = this.editor.getElement();
                var $object = $editor.find('.redactor-autoparser-object').removeClass('redactor-autoparser-object');
                $object = (type === 'link') ? $R.create('link.component', this.app, $object) : $object;

                // caret
                if (type === 'link')
                {
                    if (!enter) this.caret.setAfter($object);
                    this.app.broadcast('link.inserted', $object);
                }
                else
                {
                    this.caret.setAfter($object);

                    var $cloned = $object.clone();
                    $object.remove();
                    $object = this.insertion.insertHtml($cloned);
                    $object = this.component.build($object);
                }

                // callback
                this.app.broadcast('autoparse', type, $object);
            }
        }
    },
    _formatLinks: function(content, enter)
    {
        var matches = content.match(this.opts.regex.url);
        var obj = {};
        for (var i = 0; i < matches.length; i++)
        {
            if (enter && matches[i].search(/\.$/) !== -1)
            {
                matches[i] = matches[i].replace(/\.$/, '');
            }

            var href = matches[i], text = href;
            var linkProtocol = (href.match(/(https?|ftp):\/\//i) !== null) ? '' : 'http://';
            var regexB = (["/", "&", "="].indexOf(href.slice(-1)) !== -1) ? "" : "\\b";
            var target = (this.opts.pasteLinkTarget !== false) ? ' target="' + this.opts.pasteLinkTarget + '"' : '';

            text = (text.length > this.opts.linkSize) ? text.substring(0, this.opts.linkSize) + '...' : text;
            text = (text.search('%') === -1) ? decodeURIComponent(text) : text;

            // escaping url
            var regexp = '(' + href.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&") + regexB + ')';
            var classstr = ' class="redactor-autoparser-object"';

            obj[regexp] = '<a href="' + linkProtocol + href.trim() + '"' + target + classstr + '>' + text.trim() + '</a>';
        }

        // replace
        for (var key in obj)
        {
            content = content.replace(new RegExp(key, 'g'), obj[key]);
        }

        return content;
    },
    _restoreReplaced: function(stored, html)
    {
        for (var i = 0; i < stored.length; i++)
        {
            html = html.replace('#####replaceparse' + i + '#####', stored[i]);
        }

        return html;
    },
    _convertToRegExp: function(str)
    {
        return new RegExp(String(str).replace(/^\//, '').replace(/\/ig$/, '').replace(/\/gi$/, '') + '$', 'gi');
    }
});
$R.add('service', 'storage', {
    init: function(app)
    {
        this.app = app;

        // local
        this.data = [];
    },
    // public
    observeImages: function()
    {
        var $editor = this.editor.getElement();
        var $images = $editor.find('[data-image]');

        $images.each(this._addImage.bind(this));
    },
    observeFiles: function()
    {
        var $editor = this.editor.getElement();
        var $files = $editor.find('[data-file]');

		$files.each(this._addFile.bind(this));
    },
	setStatus: function(url, status)
	{
		this.data[url].status = status;
	},
    getChanges: function()
    {
        var $editor = this.editor.getElement();

        // check status
        for (var key in this.data)
		{
			var data = this.data[key];
			var $el = $editor.find('[data-' + data.type + '="' + data.id + '"]');

			this.setStatus(data.id, ($el.length === 0) ? false : true);
		}

        return this.data;
    },
	add: function(type, node)
	{
        var $node = $R.dom(node);
        var id = $node.attr('data-' + type);

        this.data[id] = { type: type, status: true, node: $node.get(), id: $node.attr('data-' + type) };
	},

    // private
    _addImage: function(node)
    {
        this.add('image', node);
    },
    _addFile: function(node)
    {
        this.add('file', node);
    }
});
$R.add('service', 'utils', {
    init: function(app)
    {
        this.app = app;
    },
    // empty
    isEmpty: function(el)
    {
        var isEmpty = false;
        el = $R.dom(el).get();
        if (el)
        {
            isEmpty = (el.nodeType === 3) ? (el.textContent.trim().replace(/\n/, '') === '') : (el.innerHTML === '');
        }

        return isEmpty;
    },
    isEmptyHtml: function(html, keepbr, keeplists)
    {
        html = this.removeInvisibleChars(html);
        html = html.replace(/&nbsp;/gi, '');
        html = html.replace(/<\/?br\s?\/?>/g, ((keepbr) ? 'br' : ''));
        html = html.replace(/\s/g, '');
        html = html.replace(/^<p>[^\W\w\D\d]*?<\/p>$/i, '');
        html = html.replace(/^<div>[^\W\w\D\d]*?<\/div>$/i, '');

        if (keeplists)
        {
            html = html.replace(/<ul(.*?[^>])>$/i, 'ul');
            html = html.replace(/<ol(.*?[^>])>$/i, 'ol');
        }

        html = html.replace(/<hr(.*?[^>])>$/i, 'hr');
        html = html.replace(/<iframe(.*?[^>])>$/i, 'iframe');
        html = html.replace(/<source(.*?[^>])>$/i, 'source');

        // remove empty tags
        html = html.replace(/<[^\/>][^>]*><\/[^>]+>/gi, '');
        html = html.replace(/<[^\/>][^>]*><\/[^>]+>/gi, '');

        // trim
        html = html.trim();

        return html === '';
    },
    trimSpaces: function(html)
    {
        return html = this.removeInvisibleChars(html.trim());
    },

    // invisible chars
    createInvisibleChar: function()
    {
        return document.createTextNode(this.opts.markerChar);
    },
    searchInvisibleChars: function(str)
    {
        return str.search(/^\uFEFF$/g);
    },
    removeInvisibleChars: function(html)
    {
        return html.replace(/\uFEFF/g, '');
    },
    trimInvisibleChars: function(direction)
    {
        if (!this.selection.isCollapsed()) return;

        var current = this.selection.getCurrent();
        var side = (direction === 'left') ? this.selection.getTextBeforeCaret() : this.selection.getTextAfterCaret();
        var isSpace = (current && current.nodeType === 3 && this.searchInvisibleChars(side) === 0);

        if (isSpace)
        {
            if (direction === 'left')
            {
                $R.dom(current).replaceWith(current.textContent.trim());
            }
            else
            {
                var offset = this.offset.get();
                this.offset.set({ start: offset.start + 1, end: offset.end + 1 });
            }
        }
    },

    // wrapper
    buildWrapper: function(html)
    {
        return $R.dom('<div>').html(html);
    },
    getWrapperHtml: function($wrapper)
    {
        var html = $wrapper.html();
        $wrapper.remove();

        return html;
    },

    // fragment
    createTmpContainer: function(html)
    {
        var $div = $R.dom('<div>');

        if (typeof html === 'string')
        {
            $div.html(html);
        }
        else
        {
            $div.append($R.dom(html).clone(true));
        }

        return $div.get();
    },
    createFragment: function(html)
    {
        var el = this.createTmpContainer(html);
        var frag = document.createDocumentFragment(), node, firstNode, lastNode;
        var nodes = [];
        var i = 0;
        while ((node = el.firstChild))
        {
            i++;
            var n = frag.appendChild(node);
            if (i === 1) firstNode = n;

            nodes.push(n);
            lastNode = n;
        }

        return { frag: frag, first: firstNode, last: lastNode, nodes: nodes };
    },
    isFragment: function(obj)
    {
        return (typeof obj === 'object' && obj.frag);
    },
    parseHtml: function(html)
    {
        var div = this.createTmpContainer(html);

        return { html: div.innerHTML, nodes: div.childNodes };
    },

    splitNode: function(current, nodes, isList, inline)
    {
        nodes = (this.isFragment(nodes)) ? nodes.frag : nodes;

        var element;
        if (inline)
        {
            element = (this.inspector.isInlineTag(current.tagName)) ? current : this.selection.getInline(current);
        }
        else
        {
            element = (this.inspector.isBlockTag(current.tagName)) ? current : this.selection.getBlock(current);
        }

        var $element = $R.dom(element);

        // replace is empty
        if (!inline && this.isEmptyHtml(element.innerHTML, true))
        {
            $element.after(nodes);
            $element.remove();

            return nodes;
        }

        var tag = $element.get().tagName.toLowerCase();
        var isEnd = this.caret.isEnd(element);
        var isStart = this.caret.isStart(element);

        if (!isEnd && !isStart)
        {
            var extractedContent = this.extractHtmlFromCaret(inline);

            var $secondPart = $R.dom('<' + tag + ' />');
            $secondPart = this.cloneAttributes(element, $secondPart);

            $element.after($secondPart.append(extractedContent));
        }

        if (isStart)
        {
            return $element.before(nodes);
        }
        else
        {
            if (isList)
            {
                return $element.append(nodes);
            }
            else
            {
                nodes = $element.after(nodes);

                var html = $element.html();
                html = this.removeInvisibleChars(html);
                html = html.replace(/&nbsp;/gi, '');

                if (html === '') $element.remove();

                return nodes;
            }
        }
    },
    extractHtmlFromCaret: function(inline, element)
    {
        var range = this.selection.getRange();
        if (range)
        {
            element = (element) ? element : ((inline) ? this.selection.getInline() : this.selection.getBlock());
            if (element)
            {
                var clonedRange = range.cloneRange();
                clonedRange.selectNodeContents(element);
                clonedRange.setStart(range.endContainer, range.endOffset);

                return clonedRange.extractContents();
            }
        }
    },
    createMarkup: function(el)
    {
        var markup = document.createElement(this.opts.markup);
        if (this.opts.breakline) markup.setAttribute('data-redactor-tag', 'br');

        var $el = $R.dom(el);

        $el.after(markup);
        this.caret.setStart(markup);
    },
    createMarkupBefore: function(el)
    {
        var markup = document.createElement(this.opts.markup);
        if (this.opts.breakline) markup.setAttribute('data-redactor-tag', 'br');

        var $el = $R.dom(el);

        $el.before(markup);
        this.caret.setEnd(markup);
    },
    getNode: function(el)
    {
        var node = $R.dom(el).get();
        var editor = this.editor.getElement().get();

        return (typeof el === 'undefined') ? editor : ((node) ? node : false);
    },
    findSiblings: function(node, type)
    {
        node = $R.dom(node).get();
        type = (type === 'next') ? 'nextSibling' : 'previousSibling';

        while (node = node[type])
        {
            if ((node.nodeType === 3 && node.textContent.trim() === '') || node.tagName === 'BR')
            {
                continue;
            }

            return node;
        }

        return false;
    },
    getElementsFromHtml: function(html, selector, exclude)
    {
        var div = document.createElement("div");
        div.innerHTML = html;

        var elems = div.querySelectorAll(selector);

        // array map polyfill
        var mapping = function(callback, thisArg)
        {
            if (typeof this.length !== 'number') return;
            if (typeof callback !== 'function') return;

            var newArr = [];
            if (typeof this == 'object')
            {
                for (var i = 0; i < this.length; i++)
                {
                    if (i in this) newArr[i] = callback.call(thisArg || this, this[i], i, this);
                    else return;
                }
            }

            return newArr;
        };

        return mapping.call(elems, function(el)
        {
            var type = el.getAttribute('data-redactor-type');
            if (exclude && type && type === exclude) {}
            else return el.outerHTML;
        });
    },

    // childnodes
    getChildNodes: function(el, recursive, elements)
    {
        el = (el && el.nodeType && el.nodeType === 11) ? el : $R.dom(el).get();

        var nodes = el.childNodes;
        var result = [];
        if (nodes)
        {
            for (var i = 0; i < nodes.length; i++)
            {
                if (elements === true && nodes[i].nodeType === 3) continue;
                else if (nodes[i].nodeType === 3 && this.isEmpty(nodes[i])) continue;

                result.push(nodes[i]);

                if (recursive !== false)
                {
                    var nestedNodes = this.getChildNodes(nodes[i], elements);
                    if (nestedNodes.length > 0)
                    {
                        result = result.concat(nestedNodes);
                    }
                }
            }
        }

        return result;
    },
    getChildElements: function(el)
    {
        return this.getChildNodes(el, true, true);
    },
    getFirstNode: function(el)
    {
        return this._getFirst(this.getChildNodes(el, false));
    },
    getLastNode: function(el)
    {
        return this._getLast(this.getChildNodes(el, false));
    },
    getFirstElement: function(el)
    {
        return this._getFirst(this.getChildNodes(el, false, true));
    },
    getLastElement: function(el)
    {
        return this._getLast(this.getChildNodes(el, false, true));
    },

    // replace
    replaceToTag: function(node, tag)
    {
        var $node = $R.dom(node);
        return $node.replaceWith(function(node)
        {
            var $replaced = $R.dom('<' + tag + '>').append($R.dom(node).contents());
            if (node.attributes)
            {
                var attrs = node.attributes;
                for (var i = 0; i < attrs.length; i++)
                {
                    $replaced.attr(attrs[i].nodeName, attrs[i].value);
                }
            }

            return $replaced;

        });
    },

    // string
    ucfirst: function(str)
    {
        return str.charAt(0).toUpperCase() + str.slice(1);
    },

    // array
    removeFromArrayByValue: function(arr, value)
    {
        var a = arguments, len = a.length, ax;
        while (len > 1 && arr.length)
        {
            value = a[--len];
            while ((ax= arr.indexOf(value)) !== -1)
            {
                arr.splice(ax, 1);
            }
        }

        return arr;
    },

    // attributes
    removeEmptyAttr: function(el, attr)
    {
        var $el = $R.dom(el);

        if (typeof $el.attr(attr) === 'undefined' || $el.attr(attr) === null) return true;
        else if ($el.attr(attr) === '')
        {
            $el.removeAttr(attr);
            return true;
        }

        return false;
    },
    cloneAttributes: function(elFrom, elTo)
    {
        elFrom = $R.dom(elFrom).get();
        elTo = $R.dom(elTo);

        var attrs = elFrom.attributes;
        var len = attrs.length;
        while (len--)
        {
            var attr = attrs[len];
            elTo.attr(attr.name, attr.value);
        }

        return elTo;
    },

    // object
    toParams: function(obj)
    {
        if (typeof obj !== 'object') return obj;

        var keys = Object.keys(obj);
        if (!keys.length) return '';
        var result = '';

        for (var i = 0; i < keys.length; i++)
        {
            var key = keys[i];
            result += key + ':' + obj[key] + ';';
        }

        return result;
    },
    styleToObj: function(str)
    {
        var obj = {};

        if (str)
        {
            var style = str.replace(/;$/, '').split(';');
            for (var i = 0; i < style.length; i++)
            {
                var rule = style[i].split(':');
                obj[rule[0].trim()] = rule[1].trim();
            }
        }

        return obj;
    },
    checkProperty: function(obj)
    {
        var args = (arguments[1] && Array.isArray(arguments[1])) ? arguments[1] : [].slice.call(arguments, 1);

        for (var i = 0; i < args.length; i++)
        {
            if (!obj || (typeof obj[args[i]] === 'undefined'))
            {
                return false;
            }

            obj = obj[args[i]];
        }

        return obj;
    },

    // data
    extendData: function(data, obj)
    {
        for (var key in obj)
        {
            if (key === 'elements')
            {
                var $elms = $R.dom(obj[key]);
                $elms.each(function(node)
                {
                    var $node = $R.dom(node);
                    if (node.tagName === 'FORM')
                    {
                        var serializedData = $node.serialize(true);
                        for (var z in serializedData)
                        {
                            data = this._setData(data, z, serializedData[z]);
                        }
                    }
                    else
                    {
                        var name = ($node.attr('name')) ? $node.attr('name') : $node.attr('id');
                        data = this._setData(data, name, $node.val());
                    }
                }.bind(this));
            }
            else
            {
                data = this._setData(data, key, obj[key]);
            }
        }

        return data;
    },
    _setData: function(data, name, value)
    {
        if (data instanceof FormData) data.append(name, value);
        else data[name] = value;

        return data;
    },

    // normalize
    normalizeTextNodes: function(el)
    {
        el = $R.dom(el).get();
        if (el) el.normalize();
    },

    // color
    isRgb: function(str)
    {
        return (str.search(/^rgb/i) === 0);
    },
    rgb2hex: function(rgb)
    {
        rgb = rgb.match(/^rgba?[\s+]?\([\s+]?(\d+)[\s+]?,[\s+]?(\d+)[\s+]?,[\s+]?(\d+)[\s+]?/i);

        return (rgb && rgb.length === 4) ? "#" +
        ("0" + parseInt(rgb[1],10).toString(16)).slice(-2) +
        ("0" + parseInt(rgb[2],10).toString(16)).slice(-2) +
        ("0" + parseInt(rgb[3],10).toString(16)).slice(-2) : '';
    },
    hex2long: function(val)
    {
        if (val.search(/^#/) !== -1 && val.length === 4)
        {
            val = '#' + val[1] + val[1] + val[2] + val[2] + val[3] + val[3];
        }

        return val;
    },

    // escape
    escapeRegExp: function(s)
    {
        return s.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&');
    },

    // random
    getRandomId: function()
    {
        var id = '';
        var possible = 'abcdefghijklmnopqrstuvwxyz0123456789';

        for (var i = 0; i < 12; i++)
        {
            id += possible.charAt(Math.floor(Math.random() * possible.length));
        }

        return id;
    },

    // private
    _getFirst: function(nodes)
    {
        return (nodes.length !== 0) ? nodes[0] : false;
    },
    _getLast: function(nodes)
    {
        return (nodes.length !== 0) ? nodes[nodes.length-1] : false;
    }
});
$R.add('service', 'progress', {
    init: function(app)
    {
        this.app = app;

        // local
        this.$box = null;
        this.$bar = null;
    },

    // public
    show: function()
    {
        if (!this._is()) this._build();
        this.$box.show();
    },
    hide: function()
    {
        if (this._is())
        {
            this.animate.start(this.$box, 'fadeOut', this._destroy.bind(this));
        }
    },
    update: function(value)
    {
        this.show();
        this.$bar.css('width', value + '%');
    },

    // private
    _is: function()
    {
        return (this.$box !== null);
    },
    _build: function()
    {
        this.$bar = $R.dom('<span />');
        this.$box = $R.dom('<div id="redactor-progress" />');

        this.$box.append(this.$bar);
        this.$body.append(this.$box);
    },
    _destroy: function()
    {
        if (this._is()) this.$box.remove();

        this.$box = null;
        this.$bar = null;
    }
});
$R.add('module', 'starter', {
    init: function(app)
    {
        this.app = app;
        this.opts = app.opts;
        this.plugin = app.plugin;
        this.module = app.module;
    },
    // messages
    onstart: function()
    {
        var services = ['element', 'container', 'source', 'editor', 'statusbar', 'toolbar'];
        var modules = ['element', 'container', 'source', 'editor', 'statusbar', 'contextbar', 'input'];

        this._startStop('start', this.app, services);
        this._startStop('start', this.module, modules);
    },
    onstop: function()
    {
        var modules = ['observer', 'element', 'container', 'source', 'editor', 'contextbar'];

        this._startStop('stop', this.module, modules);
    },
    onenable: function()
    {
        var modules = ['observer', 'toolbar'];
        var plugins = this.opts.plugins;

        this._startStop('start', this.module, modules);
        this._startStop('start', this.plugin, plugins);
    },
    ondisable: function()
    {
        var modules = ['observer', 'toolbar'];
        var plugins = this.opts.plugins;

        this._startStop('stop', this.module, modules);
        this._startStop('stop', this.plugin, plugins);
    },

    // private
    _startStop: function(type, obj, arr)
    {
        for (var i = 0; i < arr.length; i++)
        {
            if (typeof obj[arr[i]] !== 'undefined')
            {
                this.app.callInstanceMethod(obj[arr[i]], type);
            }
        }
    }
});
$R.add('module', 'element', {
    init: function(app)
    {
        this.app = app;
        this.uuid = app.uuid;
        this.opts = app.opts;
        this.namespace = app.namespace;
        this.element = app.element;
        this.rootOpts = $R.extend({}, true, $R.options, app.rootOpts);
    },
    // public
    start: function()
    {
        this._build();
        this._buildModes();
        this._buildMarkup();
    },
    stop: function()
    {
        var $element = this.element.getElement();
        $element.removeData(this.namespace + '-uuid');
    },

    // private
    _build: function()
    {
        var $element = this.element.getElement();
        $element.data(this.namespace + '-uuid', this.uuid);
    },
    _buildModes: function()
    {
        var type = this.element.getType();

        if (type === 'inline') this._redefineOptions(this.opts.modes['inline']);
        if (type === 'div') this._redefineOptions(this.opts.modes['original']);

        if (type !== 'inline')
        {
            if (this._isRootOption('styles') && this.rootOpts.styles) this.opts.styles = true;
            if (this._isRootOption('source') && !this.rootOpts.source) this.opts.showSource = false;
        }
    },
    _buildMarkup: function()
    {
        var type = this.element.getType();

        if (type === 'inline')
        {
            this.opts.emptyHtml = '';
        }
        else if (this.opts.breakline)
        {
            this.opts.markup = 'div';
            this.opts.emptyHtml = '<div data-redactor-tag="br">' + this.opts.markerChar + '</div>';
        }
        else
        {
            this.opts.emptyHtml = '<' + this.opts.markup + '></' + this.opts.markup + '>';
        }
    },
    _redefineOptions: function(opts)
    {
        for (var key in opts)
        {
            this.opts[key] = opts[key];
        }
    },
    _isRootOption: function()
    {
        return (typeof this.rootOpts['styles'] !== 'undefined');
    }
});
$R.add('module', 'editor', {
    init: function(app)
    {
        this.app = app;
        this.uuid = app.uuid;
        this.opts = app.opts;
        this.editor = app.editor;
        this.source = app.source;
        this.element = app.element;
        this.component = app.component;
        this.container = app.container;
        this.inspector = app.inspector;
        this.autoparser = app.autoparser;

        // local
        this.placeholder = false;
        this.events = false;
    },
    // messages
    onenable: function()
    {
        this.enable();
    },
    ondisable: function()
    {
        this.disable();
    },
    onenablefocus: function()
    {
        this._enableFocus();
    },
    oncontextmenu: function(e)
    {
        this.component.setOnEvent(e, true);
    },
    onclick: function(e)
    {
        this.component.setOnEvent(e);
    },
    onkeyup: function(e)
    {
        var data = this.inspector.parse(e.target);
        if (!data.isComponent())
        {
            this.component.clearActive();
        }
    },
    onenablereadonly: function()
    {
        this._enableReadOnly();
    },
    ondisablereadonly: function()
    {
        this._disableReadOnly();
    },
    onautoparseobserve: function()
    {
        this.autoparser.observe();
    },
    onplaceholder: {
        build: function()
        {
            this._buildPlaceholder();
        },
        toggle: function()
        {
            this._togglePlacehodler();
        }
    },

    // public
    start: function()
    {
        this._build();
        this._buildEvents();
        this._buildOptions();
        this._buildAccesibility();
    },
    stop: function()
    {
        var $editor = this.editor.getElement();
        var $container = this.container.getElement();

        var classesEditor = ['redactor-in', 'redactor-in-' + this.uuid, 'redactor-structure', 'redactor-placeholder', 'notranslate', this.opts.stylesClass];
        var classesContainer = ['redactor-focus', 'redactor-blur', 'redactor-over', 'redactor-styles-on',
                                'redactor-styles-off', 'redactor-toolbar-on', 'redactor-text-labeled-on', 'redactor-source-view'];

        $editor.removeAttr('spellcheck');
        $editor.removeAttr('dir');
        $editor.removeAttr('contenteditable');
        $editor.removeAttr('placeholder');
        $editor.removeAttr('data-gramm_editor');
        $editor.removeClass(classesEditor.join(' '));

        $container.removeClass(classesContainer.join(' '));

        this._destroyEvents();

        if ($editor.get().classList.length === 0) $editor.removeAttr('class');
    },
    enable: function()
    {
        var $editor = this.editor.getElement();
        var $container = this.container.getElement();

        $editor.addClass('redactor-in redactor-in-' + this.uuid);
        $editor.attr({ 'contenteditable': true });

        if (this.opts.structure)
        {
            $editor.addClass('redactor-structure');
        }

        if (this.opts.toolbar && !this.opts.air && !this.opts.toolbarExternal)
        {
            $container.addClass('redactor-toolbar-on');
        }

        // prevent editing
        this._disableBrowsersEditing();
    },
    disable: function()
    {
        var $editor = this.editor.getElement();
        var $container = this.container.getElement();

        $editor.removeClass('redactor-in redactor-in-' + this.uuid);
        $editor.removeClass('redactor-structure');
        $editor.removeAttr('contenteditable');

        $container.addClass('redactor-toolbar-on');
    },

    // private
    _build: function()
    {
        var $editor = this.editor.getElement();
        var $element = this.element.getElement();
        var $container = this.container.getElement();

        $container.addClass('redactor-blur');

        if (!this.opts.grammarly)
        {
            $editor.attr('data-gramm_editor', false);
        }

        if (this.opts.notranslate)
        {
            $editor.addClass('notranslate');
        }

        if (this.opts.styles)
        {
            $editor.addClass(this.opts.stylesClass);
            $container.addClass('redactor-styles-on');
        }
        else
        {
            $container.addClass('redactor-styles-off');
        }

        if (this.opts.buttonsTextLabeled)
        {
            $container.addClass('redactor-text-labeled-on');
        }

        if (this.element.isType('textarea')) $element.before($editor);
    },
    _buildEvents: function()
    {
        this.events = $R.create('editor.events', this.app);
    },
    _buildOptions: function()
    {
        var $editor = this.editor.getElement();

        $editor.attr('dir', this.opts.direction);

        if (this.opts.tabindex)  $editor.attr('tabindex', this.opts.tabindex);
        if (this.opts.minHeight) $editor.css('min-height', this.opts.minHeight);
        if (this.opts.maxHeight) $editor.css('max-height', this.opts.maxHeight);
        if (this.opts.maxWidth)  $editor.css({ 'max-width': this.opts.maxWidth, 'margin': 'auto' });
    },
    _buildAccesibility: function()
    {
        var $editor = this.editor.getElement();

        $editor.attr({ 'aria-labelledby': 'redactor-voice-' + this.uuid, 'role': 'presentation' });
    },
    _buildPlaceholder: function()
    {
        this.placeholder = $R.create('editor.placeholder', this.app);
    },
    _enableFocus: function()
    {
        if (this.opts.showSource) this._enableFocusSource();
        else this._enableFocusEditor();
    },
    _enableFocusSource: function()
    {
        var $source = this.source.getElement();

        if (this.opts.focus)
        {
            $source.focus();
            $source.get().setSelectionRange(0, 0);
        }
        else if (this.opts.focusEnd)
        {
            $source.focus();
        }
    },
    _enableFocusEditor: function()
    {
        if (this.opts.focus)
        {
            setTimeout(this.editor.startFocus.bind(this.editor), 100);
        }
        else if (this.opts.focusEnd)
        {
            setTimeout(this.editor.endFocus.bind(this.editor), 100);
        }
    },
    _togglePlacehodler: function()
    {
        if (this.placeholder) this.placeholder.toggle();
    },
    _disableBrowsersEditing: function()
    {
        try {
            // FF fix
            document.execCommand('enableObjectResizing', false, false);
            document.execCommand('enableInlineTableEditing', false, false);
            // IE prevent converting links
            document.execCommand("AutoUrlDetect", false, false);

            // IE disable image resizing
            var $editor = this.editor.getElement();
            var el = $editor.get();
            if (el.addEventListener) el.addEventListener('mscontrolselect', function(e) { e.preventDefault(); });
            else el.attachEvent('oncontrolselect', function(e) { e.returnValue = false; });

        } catch (e) {}
    },
    _destroyEvents: function()
    {
        if (this.events)
        {
            this.events.destroy();
        }
    },
    _enableReadOnly: function()
    {
        var $editor = this.editor.getElement();

        this._getEditables($editor).removeAttr('contenteditable');
        $editor.removeAttr('contenteditable');
        $editor.addClass('redactor-read-only');

        if (this.events) this.events.destroy();
    },
    _disableReadOnly: function()
    {
        var $editor = this.editor.getElement();

        this._getEditables($editor).attr({ 'contenteditable': true });
        $editor.removeClass('redactor-read-only');
        $editor.attr({ 'contenteditable': true });

        this._buildEvents();
    },
    _getEditables: function($editor)
    {
        return $editor.find('figcaption, td, th');
    }
});
$R.add('class', 'editor.placeholder', {
    init: function(app)
    {
        this.app = app;
        this.opts = app.opts;
        this.editor = app.editor;
        this.element = app.element;

        // build
        this.build();
    },
    build: function()
    {
        var $element = this.element.getElement();
        var $editor = this.editor.getElement();

        if (this.opts.placeholder !== false || $element.attr('placeholder'))
        {
            var text = (this.opts.placeholder !== false) ? this.opts.placeholder : $element.attr('placeholder');
            $editor.attr('placeholder', text);
            this.toggle();
        }
    },
    toggle: function()
    {
        return (this.editor.isEmpty(true)) ? this.show() : this.hide();
    },
    show: function()
    {
        var $editor = this.editor.getElement();
        $editor.addClass('redactor-placeholder');
    },
    hide: function()
    {
        var $editor = this.editor.getElement();
        $editor.removeClass('redactor-placeholder');
    }
});
$R.add('class', 'editor.events', {
    init: function(app)
    {
        this.app = app;
        this.opts = app.opts;
        this.$doc = app.$doc;
        this.uuid = app.uuid;
        this.source = app.source;
        this.editor = app.editor;
        this.cleaner = app.cleaner;
        this.container = app.container;
        this.insertion = app.insertion;
        this.inspector = app.inspector;
        this.selection = app.selection;
        this.component = app.component;

        // local
        this.blurNamespace = '.redactor-blur.' + this.uuid;
        this.eventsList = ['paste', 'click', 'contextmenu', 'keydown', 'keyup', 'mouseup', 'touchstart',
                           'cut', 'copy', 'dragenter', 'dragstart', 'drop', 'dragover', 'dragleave'];

        // init
        this._init();
    },
    destroy: function()
    {
        var $editor = this.editor.getElement();

        $editor.off('.redactor-focus');
        this.$doc.off('keyup' + this.blurNamespace + ' mousedown' + this.blurNamespace);

        // all events
        this._loop('off');
    },
    focus: function(e)
    {
        var $container = this.container.getElement();

        if (this.editor.isPasting() || $container.hasClass('redactor-focus')) return;

        $container.addClass('redactor-focus');
        $container.removeClass('redactor-blur');

        this.app.broadcast('observe', e);
        this.app.broadcast('focus', e);

        this.isFocused = true;
        this.isBlured = false;
    },
    blur: function(e)
    {
        var $container = this.container.getElement();
        var $target = $R.dom(e.target);
        var targets = ['.redactor-in-' + this.uuid,  '.redactor-toolbar', '.redactor-dropdown',
        '.redactor-context-toolbar', '#redactor-modal', '#redactor-image-resizer'];

        this.app.broadcast('originalblur', e);
        if (this.app.stopBlur) return;

        if (!this.app.isStarted() || this.editor.isPasting()) return;
        if ($target.closest(targets.join(',')).length !== 0) return;

        if (!this.isBlured && !$container.hasClass('redactor-blur'))
        {
            $container.removeClass('redactor-focus');
            $container.addClass('redactor-blur');
            this.app.broadcast('blur', e);

            this.isFocused = false;
            this.isBlured = true;
        }
    },
    cut: function(e)
    {
        var current = this.selection.getCurrent();
        var data = this.inspector.parse(current);

        this.app.broadcast('state', e);

        if (this.component.isNonEditable(current))
        {
            this._passSelectionToClipboard(e, data, true);
            e.preventDefault();
        }
    },
    copy: function(e)
    {
        var current = this.selection.getCurrent();
        var data = this.inspector.parse(current);

        this.app.broadcast('state', e);

        if (this.component.isNonEditable(current))
        {
            this._passSelectionToClipboard(e, data, false);
            e.preventDefault();
        }
    },
    drop: function(e)
    {
        e = e.originalEvent || e;
        e.stopPropagation();
        this._removeOverClass();

        if (this.opts.dragUpload === false)
        {
            e.preventDefault();
            return;
        }

        if (this.app.isDragComponentInside())
        {
            var $dragComponent = $R.dom(this.app.getDragComponentInside());
            var $component = $dragComponent.clone(true);
            this.insertion.insertToPoint(e, $component);

            $dragComponent.remove();

            this.app.setDragComponentInside(false);
            this.app.broadcast('state', e);
            this.app.broadcast('drop', e);
            this.app.broadcast('image.observe', e);

            e.preventDefault();

            return;
        }
        else if (this.app.isDragInside() && this.opts.input)
        {
            this.insertion.insertPoint(e);

            var dt = e.dataTransfer;
            var html = dt.getData('text/html');

            // clear selected
            var range = this.selection.getRange();
            if (range)
            {
                var blocks = this.selection.getBlocks();
                range.deleteContents();

                // remove empty blocks
                for (var i = 0; i < blocks.length; i++)
                {
                    if (blocks[i].innerHTML === '') $R.dom(blocks[i]).remove();
                }
            }

            // paste
            $R.create('input.paste', this.app, e, true, html, true);

            this.app.broadcast('state', e);
            this.app.broadcast('drop', e);

            this.app.setDragInside(false);
            e.preventDefault();

            return;
        }

        this.app.broadcast('state', e);
        this.app.broadcast('paste', e, e.dataTransfer);
        this.app.broadcast('drop', e);

    },
    dragenter: function(e)
    {
        e.preventDefault();
    },
    dragstart: function(e)
    {
        this.app.setDragComponentInside(false);
        this.app.setDragInside(false);

        var data = this.inspector.parse(e.target);
        if (data.isComponent() && !data.isComponentEditable() && !data.isFigcaption())
        {
            this.app.setDragComponentInside(data.getComponent());
        }
        else if (this.selection.is() && !this.selection.isCollapsed())
        {
            // drag starts inside editor
            this.app.setDragInside(true);
            this._setDragData(e);
        }

        this.app.broadcast('dragstart', e);
    },
    dragover: function(e)
    {
        this.app.broadcast('dragover', e);
    },
    dragleave: function(e)
    {
        this.app.broadcast('dragleave', e);
    },
    paste: function(e)
    {
        this.app.broadcast('paste', e);
    },
    contextmenu: function(e)
    {
        // chrome crashes fix
        this.editor.disableNonEditables();

        setTimeout(function()
        {
            this.editor.enableNonEditables();
            this.app.broadcast('contextmenu', e);

        }.bind(this), 0);
    },
    click: function(e)
    {
        // triple click selection
        if (e.detail === 3)
        {
            e.preventDefault();

            var block = this.selection.getBlock();
            var range = document.createRange();
            range.selectNodeContents(block);
            this.selection.setRange(range)
        }

        // observe bottom click
        var $target = $R.dom(e.target);
        if ($target.hasClass('redactor-in'))
        {
            var top = $target.offset().top;
            var pad = parseFloat($target.css('padding-bottom'));
            var height = $target.height();
            var posHeight = top + height - pad*2;

            if (posHeight < e.pageY)
            {
                this.app.broadcast('bottomclick', e);
            }
        }

        this.app.broadcast('state', e);
        this.app.broadcast('click', e);
    },
    keydown: function(e)
    {
        this.app.broadcast('state', e);
        var stop = this.app.broadcast('keydown', e);
        if (stop === false)
        {
            return e.preventDefault();
        }
    },
    keyup: function(e)
    {
        this.app.broadcast('keyup', e);
    },
    mouseup: function(e)
    {
        this.app.broadcast('observe', e);
        this.app.broadcast('state', e);
    },
    touchstart: function(e)
    {
        this.app.broadcast('observe', e);
        this.app.broadcast('state', e);
    },

    // private
    _init: function()
    {
        var $editor = this.editor.getElement();

        $editor.on('focus.redactor-focus click.redactor-focus', this.focus.bind(this));
        this.$doc.on('keyup' + this.blurNamespace + ' mousedown' + this.blurNamespace, this.blur.bind(this));

        // all events
        this._loop('on');
    },
    _removeOverClass: function()
    {
        var $editor = this.editor.getElement();
        $editor.removeClass('over');
    },
    _loop: function(func)
    {
        var $editor = this.editor.getElement();
        for (var i = 0; i < this.eventsList.length; i++)
        {
            var event = this.eventsList[i] + '.redactor-events';
            var method = this.eventsList[i];

            $editor[func](event, this[method].bind(this));
        }
    },
    _passAllToClipboard: function(e)
    {
        var clipboard = e.clipboardData;
        var content = this.source.getCode();

        clipboard.setData('text/html', content);
        clipboard.setData('text/plain', content.toString().replace(/\n$/, ""));
    },
    _passSelectionToClipboard: function(e, data, remove)
    {
        var clipboard = e.clipboardData;
        var node = data.getComponent();
        var $node = $R.dom(node);
        var $cloned = $node.clone();

        // clean
        $cloned.find('.redactor-component-caret').remove();
        $cloned.removeClass('redactor-component-active');
        $cloned.removeAttr('contenteditable');
        $cloned.removeAttr('tabindex');

        // html
        var content = $cloned.get().outerHTML;

        if (remove) this.component.remove(node);

        clipboard.setData('text/html', content);
        clipboard.setData('text/plain', content.toString().replace(/\n$/, ""));
    },
    _setDragData: function(e)
    {
        e = e.originalEvent || e;

        var dt = e.dataTransfer;
        dt.effectAllowed = 'move';
        dt.setData('text/Html', this.selection.getHtml());
    }
});
$R.add('module', 'container', {
    init: function(app)
    {
        this.app = app;
        this.uuid = app.uuid;
        this.opts = app.opts;
        this.lang = app.lang;
        this.element = app.element;
        this.container = app.container;
    },
    // public
    start: function()
    {
        this._build();
        this._buildAccesibility();
    },
    stop: function()
    {
        var $element = this.element.getElement();
        var $container = this.container.getElement();

        $container.after($element);
        $container.remove();
        $element.show();
    },

    // private
    _build: function()
    {
        var $element = this.element.getElement();
        var $container = this.container.getElement();

        $container.addClass('redactor-box');
        $container.attr('dir', this.opts.direction);

        if (this.element.isType('inline')) $container.addClass('redactor-inline');

        $element.after($container);
        $container.append($element);
    },
    _buildAccesibility: function()
    {
        var $container = this.container.getElement();
        var $label = $R.dom('<span />');

        $label.addClass('redactor-voice-label');
        $label.attr({ 'id': 'redactor-voice-' + this.uuid, 'aria-hidden': false });
        $label.html(this.lang.get('accessibility-help-label'));

        $container.prepend($label);
    }
});
$R.add('module', 'source', {
    init: function(app)
    {
        this.app = app;
        this.uuid = app.uuid;
        this.opts = app.opts;
        this.utils = app.utils;
        this.element = app.element;
        this.source = app.source;
        this.editor = app.editor;
        this.toolbar = app.toolbar;
        this.cleaner = app.cleaner;
        this.component = app.component;
        this.container = app.container;
        this.autoparser = app.autoparser;
        this.selection = app.selection;

        // local
        this.syncedHtml = '';
    },
    // messages
    onstartcode: function()
    {
        var sourceContent = this.source.getStartedContent();
        var $editor = this.editor.getElement();
        var $source = this.source.getElement();

        // autoparse
        if (this.opts.autoparse && this.opts.autoparseStart)
        {
            sourceContent = this.autoparser.parse(sourceContent);
        }

        // started content
        var startContent = this.cleaner.input(sourceContent, true, true);
        var syncContent = this.cleaner.output(startContent);

        // set content
        $editor.html(startContent);
        $source.val(syncContent);

        this.syncedHtml = syncContent;
        this.app.broadcast('placeholder.build');
        this.app.broadcast('autoparseobserve');

        // widget's scripts
        this.component.executeScripts();
    },
    onstartcodeshow: function()
    {
        this.show();
    },
    ontrytosync: function()
    {
        this.sync();
    },
    onhardsync: function()
    {
        var $editor = this.editor.getElement();
        var html = $editor.html();

        html = this.app.broadcast('syncBefore', html);
        html = this.cleaner.output(html);

        this._syncing(html);
    },

    // public
    start: function()
    {
        this._build();
        this._buildClasses();
    },
    stop: function()
    {
        var $element = this.element.getElement();
        var $source = this.source.getElement();

        $element.removeClass('redactor-source redactor-source-open');
        $source.off('input.redactor-source');
        $source.removeAttr('data-gramm_editor');

        if ($source.get().classList.length === 0) $source.removeAttr('class');
        if (!this.source.isNameGenerated()) $element.removeAttr('name');
        if (!this.element.isType('textarea')) $source.remove();

    },
    getCode: function()
    {
        return this.source.getCode();
    },

    // public
    toggle: function()
    {
        if (!this.opts.source) return;

        var $source = this.source.getElement();

        return ($source.hasClass('redactor-source-open')) ? this.hide() : this.show();
    },
    show: function()
    {
        if (!this.opts.source) return;

        var $editor = this.editor.getElement();
        var $source = this.source.getElement();
        var $container = this.container.getElement();

        var html = $source.val();

        if (this.app.isStarted()) html = this.app.broadcast('source.open', html);

        // insert markers
        var sourceSelection = $R.create('source.selection', this.app);

        var editorHtml = sourceSelection.insertMarkersToEditor();
        editorHtml = this.cleaner.output(editorHtml, false);
        editorHtml = editorHtml.trim();

        // get height
        var editorHeight = $editor.height();

        $editor.hide();
        $source.height(editorHeight);
        $source.val(html.trim());
        $source.show();
        $source.addClass('redactor-source-open');
        $source.on('input.redactor-source-events', this._onChangedSource.bind(this));
        $source.on('keydown.redactor-source-events', this._onTabKey.bind(this));
        $source.on('focus.redactor-source-events', this._onFocus.bind(this));

        $container.addClass('redactor-source-view');

        // offset markers
        sourceSelection.setSelectionOffsetSource(editorHtml);

        // buttons
        setTimeout(function()
        {
            this._disableButtons();
            this._setActiveSourceButton();

        }.bind(this), 100);

        if (this.app.isStarted()) this.app.broadcast('source.opened');
    },
    hide: function()
    {
        if (!this.opts.source) return;

        var $editor = this.editor.getElement();
        var $source = this.source.getElement();
        var $container = this.container.getElement();

        var html = $source.val();

        // insert markers
        var sourceSelection = $R.create('source.selection', this.app);
        html = sourceSelection.insertMarkersToSource(html);

        // clean
        html = this.cleaner.input(html, true);
        html = (this.utils.isEmptyHtml(html)) ? this.opts.emptyHtml : html;
        html = this.app.broadcast('source.close', html);

        // buttons
        this._enableButtons();
        this._setInactiveSourceButton();

        $source.hide();
        $source.removeClass('redactor-source-open');
        $source.off('.redactor-source-events');
        $editor.show();
        $editor.html(html);

        $container.removeClass('redactor-source-view');

        setTimeout(function()
        {
            if (sourceSelection.isOffset()) this.selection.restoreMarkers();
            else if (sourceSelection.isOffsetEnd()) this.editor.endFocus();
            else this.editor.startFocus();

            // widget's scripts
            this.component.executeScripts();

        }.bind(this), 0);

        this.app.broadcast('source.closed');
    },
    sync: function()
    {
        var self = this;
        var $editor = this.editor.getElement();
        var html = $editor.html();

        html = this.app.broadcast('syncBefore', html);
        html = this.cleaner.output(html);

        if (this._isSync(html))
        {
            if (this.timeout) clearTimeout(this.timeout);
            this.timeout = setTimeout(function() { self._syncing(html); }, 200);
        }
    },

    // private
    _build: function()
    {
        var $source = this.source.getElement();
        var $element = this.element.getElement();

        $source.hide();

        if (!this.opts.grammarly)
        {
            $source.attr('data-gramm_editor', false);
        }

        if (!this.element.isType('textarea'))
        {
            $element.after($source);
        }
    },
    _buildClasses: function()
    {
        var $source = this.source.getElement();

        $source.addClass('redactor-source');
    },
    _syncing: function(html)
    {
        html = this.app.broadcast('syncing', html);

        var $source = this.source.getElement();
        $source.val(html);

        this.app.broadcast('synced', html);
        this.app.broadcast('changed', html);
    },
    _isSync: function(html)
    {
        if (this.syncedHtml !== html)
        {
            this.syncedHtml = html;
            return true;
        }

        return false;
    },
    _onChangedSource: function()
    {
        var $source = this.source.getElement();
        var html = $source.val();

        this.app.broadcast('changed', html);
        this.app.broadcast('source.changed', html);
    },
    _onTabKey: function(e)
    {
        if (e.keyCode !== 9) return true;

        e.preventDefault();

        var $source = this.source.getElement();
        var el = $source.get();
        var start = el.selectionStart;

        $source.val($source.val().substring(0, start) + "    " + $source.val().substring(el.selectionEnd));
        el.selectionStart = el.selectionEnd = start + 4;
    },
    _onFocus: function()
    {
        this.app.broadcast('sourcefocus');
    },
    _disableButtons: function()
    {
        this.toolbar.disableButtons();
    },
    _enableButtons: function()
    {
        this.toolbar.enableButtons();
    },
    _setActiveSourceButton: function()
    {
        var $btn = this.toolbar.getButton('html');
        $btn.enable();
        $btn.setActive();
    },
    _setInactiveSourceButton: function()
    {
        var $btn = this.toolbar.getButton('html');
        $btn.setInactive();
    }
});
$R.add('class', 'source.selection', {
    init: function(app)
    {
        this.app = app;
        this.utils = app.utils;
        this.source = app.source;
        this.editor = app.editor;
        this.marker = app.marker;
        this.component = app.component;
        this.selection = app.selection;

        // local
        this.markersOffset = false;
        this.markersOffsetEnd = false;
    },
    insertMarkersToEditor: function()
    {
        var $editor = this.editor.getElement();
        var start = this.marker.build('start');
        var end = this.marker.build('end');
        var component = this.component.getActive();
        if (component)
        {
            this.marker.remove();
            var $component = $R.dom(component);

            $component.after(end);
            $component.after(start);
        }
        else if (window.getSelection && this.selection.is())
        {
            this.marker.insert('both');
        }

        return this._getHtmlAndRemoveMarkers($editor);
    },
    setSelectionOffsetSource: function(editorHtml)
    {
        var start = 0;
        var end = 0;
        var $source = this.source.getElement();
        if (editorHtml !== '')
        {
            var startMarker = this.utils.removeInvisibleChars(this.marker.buildHtml('start'));
            var endMarker = this.utils.removeInvisibleChars(this.marker.buildHtml('end'));

            start = this._strpos(editorHtml, startMarker);
            end = this._strpos(editorHtml, endMarker) - endMarker.toString().length - 2;

            if (start === false)
            {
                start = 0;
                end = 0;
            }
        }

        $source.get().setSelectionRange(start, end);
        $source.get().scrollTop = 0;

        setTimeout(function() { $source.focus(); }.bind(this), 0);
    },
    isOffset: function()
    {
        return this.markersOffset;
    },
    isOffsetEnd: function()
    {
        return this.markersOffsetEnd;
    },
    insertMarkersToSource: function(html)
    {
        var $source = this.source.getElement();
        var markerStart = this.marker.buildHtml('start');
        var markerEnd = this.marker.buildHtml('end');

        var markerLength = markerStart.toString().length;
        var startOffset = this._enlargeOffset(html, $source.get().selectionStart);
        var endOffset = this._enlargeOffset(html, $source.get().selectionEnd);
        var sizeOffset = html.length;

        if (startOffset === sizeOffset)
        {
            this.markersOffsetEnd = true;
        }
        else if (startOffset !== 0 && endOffset !== 0)
        {
            this.markersOffset = true;

            html = html.substr(0, startOffset) + markerStart + html.substr(startOffset);
            html = html.substr(0, endOffset + markerLength) + markerEnd + html.substr(endOffset + markerLength);
        }
        else
        {
            this.markersOffset = false;
        }

        return html;
    },

    // private
    _getHtmlAndRemoveMarkers: function($editor)
    {
        var html = $editor.html();
        $editor.find('.redactor-selection-marker').remove();

        return html;
    },
    _strpos: function(haystack, needle, offset)
    {
        var i = haystack.indexOf(needle, offset);
        return i >= 0 ? i : false;
    },
    _enlargeOffset: function(html, offset)
    {
        var htmlLength = html.length;
        var c = 0;

        if (html[offset] === '>')
        {
            c++;
        }
        else
        {
            for(var i = offset; i <= htmlLength; i++)
            {
                c++;

                if (html[i] === '>')
                {
                    break;
                }
                else if (html[i] === '<' || i === htmlLength)
                {
                    c = 0;
                    break;
                }
            }
        }

        return offset + c;
    }
});
$R.add('module', 'observer', {
    init: function(app)
    {
        this.app = app;
        this.editor = app.editor;

        // local
        this.observerUnit = false;
    },
    // public
    start: function()
    {
        if (window.MutationObserver)
        {
            var $editor = this.editor.getElement();
            var el = $editor.get();
            this.observerUnit = this._build(el);
            this.observerUnit.observe(el, {
                 attributes: true,
                 subtree: true,
                 childList: true,
                 characterData: true,
                 characterDataOldValue: true
            });
        }
    },
    stop: function()
    {
        if (this.observerUnit) this.observerUnit.disconnect();
    },

    // private
    _build: function(el)
    {
        var self = this;
        return new MutationObserver(function(mutations)
        {
            self._observe(mutations[mutations.length-1], el);
        });
    },
    _observe: function(mutation, el)
    {
        if (this.app.isReadOnly() || (mutation.type === 'attributes' && mutation.target === el))
        {
            return;
        }

        this.app.broadcast('observe');
        this.app.broadcast('trytosync');
        this.app.broadcast('placeholder.toggle');
    }
});
$R.add('module', 'clicktoedit', {
    init: function(app)
    {
        this.app = app;
        this.opts = app.opts;
        this.source = app.source;
        this.editor = app.editor;
        this.container = app.container;
        this.selection = app.selection;
    },
    // messages
    onstartclicktoedit: function()
    {
        this.start();
    },
    onenablereadonly: function()
    {
        if (!this._isEnabled()) this.stop();
    },
    ondisablereadonly: function()
    {
        if (!this._isEnabled()) this.start();
    },
    onstop: function()
    {
        this.stop();
    },

    // public
    start: function()
    {
        this._build();
    },
    stop: function()
    {
        if (this.buttonSave) this.buttonSave.stop();
        if (this.buttonCancel) this.buttonCancel.stop();

        this._destroy();
        this.app.broadcast('disable');
    },
    enable: function()
    {
        this.app.broadcast('clickStart');

        var isEmpty = this.editor.isEmpty();
        if (!isEmpty) this.selection.saveMarkers();

        this._setFocus();
        this._destroy();
        this.app.broadcast('enable');
        this.buttonSave.enable();
        this.buttonCancel.enable();

        if (!isEmpty) this.selection.restoreMarkers();
        if (isEmpty) this.editor.focus();

        var $container = this.container.getElement();
        $container.addClass('redactor-clicktoedit-enabled');

        this.source.rebuildStartedContent();

        this.app.broadcast('startcode');
        this.app.broadcast('image.observe');
    },
    save: function(e)
    {
        if (e) e.preventDefault();

        var html = this.source.getCode();

        this.app.broadcast('disable');
        this.app.broadcast('clickSave', html);
        this.app.broadcast('clickStop');
        this._build();
    },
    cancel: function(e)
    {
        if (e) e.preventDefault();

        var html = this.saved;
        var $editor = this.editor.getElement();
        $editor.html(html);

        this.saved = '';

        this.app.broadcast('disable');
        this.app.broadcast('clickCancel', html);
        this.app.broadcast('clickStop');
        this._build();
    },

    // private
    _build: function()
    {
        // buttons
        this.buttonSave = $R.create('clicktoedit.button', 'save', this.app, this);
        this.buttonCancel = $R.create('clicktoedit.button', 'cancel', this.app, this);

        this.buttonSave.stop();
        this.buttonCancel.stop();

        var $editor = this.editor.getElement();
        var $container = this.container.getElement();

        $editor.on('click.redactor-click-to-edit mouseup.redactor-click-to-edit', this.enable.bind(this));
        $container.addClass('redactor-over');
        $container.removeClass('redactor-clicktoedit-enabled');
    },
    _isEnabled: function()
    {
        return this.container.getElement().hasClass('redactor-clicktoedit-enabled');
    },
    _destroy: function()
    {
        var $editor = this.editor.getElement();
        var $container = this.container.getElement();

        $editor.off('.redactor-click-to-edit');
        $container.removeClass('redactor-over redactor-clicktoedit-enabled');
    },
    _setFocus: function()
    {
        this.saved = this.source.getCode();

        this.buttonSave.start();
        this.buttonCancel.start();
    }
});
$R.add('class', 'clicktoedit.button', {
    init: function(type, app, context)
    {
        this.app = app;
        this.opts = app.opts;
        this.toolbar = app.toolbar;
        this.context = context;

        // local
        this.type = type;
        this.name = (type === 'save') ? 'clickToSave' : 'clickToCancel';
        this.objected = false;
        this.enabled = false;
        this.namespace = '.redactor-click-to-edit';

        // build
        this._build();
    },
    enable: function()
    {
        if (!this.objected) return;

        var data = this.opts[this.name];
        data.api = 'module.clicktoedit.' + this.type;

        this.toolbar.addButton(this.type, data);
        this.enabled = true;
    },
    start: function()
    {
        if (this.objected) return;

        this.$button.off(this.namespace);
        this.$button.show();
        this.$button.on('click' + this.namespace, this.context[this.type].bind(this.context));
    },
    stop: function()
    {
        if (this.objected || !this.enabled) return;

        this.$button.hide();
    },

    // private
    _build: function()
    {
        this.objected = (typeof this.opts[this.name] === 'object');

        if (!this.objected)
        {
            this.$button = $R.dom(this.opts[this.name]);
            this.enabled = true;
        }
    }
});
$R.add('module', 'statusbar', {
    init: function(app)
    {
        this.app = app;
        this.opts = app.opts;
        this.element = app.element;
        this.statusbar = app.statusbar;
        this.container = app.container;
    },
    // public
    start: function()
    {
        if (!this.element.isType('inline'))
        {
            var $statusbar = this.statusbar.getElement();
            var $container = this.container.getElement();

            $statusbar.addClass('redactor-statusbar');
            $container.append($statusbar);
        }
    }
});
$R.add('module', 'contextbar', {
    init: function(app)
    {
        this.app = app;
        this.opts = app.opts;
        this.uuid = app.uuid;
        this.$win = app.$win;
        this.$doc = app.$doc;
        this.$body = app.$body;
        this.editor = app.editor;
        this.toolbar = app.toolbar;
        this.detector = app.detector;

        // local
        this.$target = (this.toolbar.isTarget()) ? this.toolbar.getTargetElement() : this.$body;
    },
    // messages
    onenablereadonly: function()
    {
        this.stop();
    },
    ondisablereadonly: function()
    {
        this.start();
    },
    oncontextbar: {
        close: function()
        {
            this.close();
        }
    },

    // public
    start: function()
    {
        if (this.opts.toolbarContext)
        {
            var $editor = this.editor.getElement();

            this._build();
            $editor.on('click.redactor-context mouseup.redactor-context', this.open.bind(this));

            if (this.opts.scrollTarget)
            {
                $R.dom(this.opts.scrollTarget).on('scroll.redactor-context', this.close.bind(this));
            }
            else if (this.opts.maxHeight !== false)
            {
                $editor.on('scroll.redactor-context', this.close.bind(this));
            }
        }
    },
    stop: function()
    {
        var $editor = this.editor.getElement();
        $editor.off('.redactor-context');

        this.$doc.off('.redactor-context');
        this.$win.off('.redactor-context');

        if (this.$contextbar) this.$contextbar.remove();
        if (this.opts.scrollTarget)
        {
            $R.dom(this.opts.scrollTarget).off('.redactor-context');
        }
    },
    is: function()
    {
        return (this.$contextbar && this.$contextbar.hasClass('open'));
    },
    set: function(e, node, buttons, position)
    {
        this.$contextbar.html('');
        this.$el = $R.dom(node);

        // buttons
        for (var key in buttons)
        {
            var $btn = $R.create('contextbar.button', this.app, buttons[key]);
            if ($btn.html() !== '')
            {
                this.$contextbar.append($btn);
            }
        }

        // show
        var pos = this._buildPosition(e, this.$el, position);

        this.$contextbar.css(pos);
        this.$contextbar.show();
        this.$contextbar.addClass('open');
        this.$doc.on('click.redactor-context mouseup.redactor-context', this.close.bind(this));
        this.$win.on('resize.redactor-context', this.close.bind(this));
    },
    open: function(e)
    {
        setTimeout(function()
        {
            this.app.broadcast('contextbar', e, this);
        }.bind(this), 0);
    },
    close: function(e)
    {
        if (!this.$contextbar) return;
        if (e)
        {
            var $target = $R.dom(e.target);
            if (this.$el && $target.closest(this.$el).length !== 0)
            {
                return;
            }
        }

        this.$contextbar.hide();
        this.$contextbar.removeClass('open');
        this.$doc.off('.redactor.context');
    },

    // private
    _build: function()
    {
        this.$contextbar = $R.dom('<div>');
        this.$contextbar.attr('id', 'redactor-context-toolbar-' + this.uuid);
        this.$contextbar.attr('dir', this.opts.direction);
        this.$contextbar.addClass('redactor-context-toolbar');
        this.$contextbar.hide();

        this.$target.append(this.$contextbar);
    },
    _buildPosition: function(e, $el, position)
    {
        var top, left;
        var isTarget = this.toolbar.isTarget();
        var offset = (isTarget) ? $el.position() : $el.offset();

        var width = $el.width();
        var height = $el.height();

        var barWidth = this.$contextbar.width();
        var barHeight = this.$contextbar.height();
        var docScrollTop = (isTarget) ? (this.$target.scrollTop() + this.$doc.scrollTop()) : this.$doc.scrollTop();

        var targetOffset = this.$target.offset();
        var leftFix = (isTarget) ? targetOffset.left : 0;
        var topFix = (isTarget) ? targetOffset.top : 0;

        if (!position)
        {
            top = (e.clientY + docScrollTop - barHeight);
            left = (e.clientX - barWidth/2);
        }
        else if (position === 'top')
        {
            top = (offset.top - barHeight);
            left = (offset.left + width/2 - barWidth/2);
        }
        else if (position === 'bottom')
        {
            top = (offset.top + height);
            left = (offset.left + width/2 - barWidth/2);
        }

        if (left < 0) left = 0;

        return { top: (top - topFix) + 'px', left: (left - leftFix) + 'px' };
    }
});
$R.add('class', 'contextbar.button', {
    mixins: ['dom'],
    init: function(app, obj)
    {
        this.app = app;

        // local
        this.obj = obj;

        // init
        this._init();
    },
    // private
    _init: function()
    {
        this.parse('<a>');

        if (typeof this.obj.title !== 'string')
        {
            this.attr('target', '_blank');
            this.attr('href', this.obj.title.attr('href'));
            this.html(this.obj.title.attr('href'));
        }
        else
        {
            this.attr('href', '#');

            this._buildTitle();
            this._buildMessage();
        }
    },
    _buildTitle: function()
    {
        this.html(this.obj.title);
    },
    _buildMessage: function()
    {
        if (typeof this.obj.message !== 'undefined' || typeof this.obj.api !== 'undefined')
        {
            this.on('click', this._toggle.bind(this));
        }
    },
    _toggle: function(e)
    {
        e.preventDefault();

        if (this.obj.message)
        {
            this.app.broadcast(this.obj.message, this.obj.args);
        }
        else if (this.obj.api)
        {
            this.app.api(this.obj.api, this.obj.args);
        }
    }
});
$R.add('module', 'toolbar', {
    init: function(app)
    {
        this.app = app;
        this.uuid = app.uuid;
        this.opts = app.opts;
        this.utils = app.utils;
        this.toolbar = app.toolbar;

        // local
        this.buttons = [];
        this.toolbarModule = false;
    },
    // messages
    onsource: {
        open: function()
        {
            if (!this.toolbar.isAir() && this.toolbar.isFixed())
            {
                this.toolbarModule.resetPosition();
            }
        },
        opened: function()
        {
            if (this.toolbar.isAir() && this.toolbarModule)
            {
                this.toolbarModule.createSourceHelper();
            }

            // hide tooltips
            setTimeout(function()
            {
                $R.dom('.re-button-tooltip-' + this.uuid).remove();
            }.bind(this), 100)

        },
        close: function()
        {
            if (this.toolbar.isAir() && this.toolbarModule)
            {
                this.toolbarModule.destroySourceHelper();
            }
        },
        closed: function()
        {
            if (this.toolbar.is() && this.opts.air)
            {
                this.toolbarModule.openSelected();
            }
        }
    },
    onobserve: function()
    {
        if (this.toolbar.is())
        {
            this.toolbar.observe();
        }
    },
    onfocus: function()
    {
        this._setExternalOnFocus();
    },
    onsourcefocus: function()
    {
        this._setExternalOnFocus();
    },
    onempty: function()
    {
        if (this.toolbar.isFixed())
        {
            this.toolbarModule.resetPosition();
        }
    },
    onenablereadonly: function()
    {
        if (this.toolbar.isAir())
        {
            this.toolbarModule.close();
        }
    },

    // public
    start: function()
    {
        if (this.toolbar.is())
        {
            this._buildButtons();
            this._initToolbar();
            this._initButtons();
        }
    },
    stop: function()
    {
        if (this.toolbarModule)
        {
            this.toolbarModule.stop();
        }

        // stop dropdowns
        $R.dom('.redactor-dropdown-' + this.uuid).remove();
    },

    // private
    _buildButtons: function()
    {
        this.buttons = this.opts.buttons.concat();

        this._buildImageButton();
        this._buildFileButton();
        this._buildSourceButton();
        this._buildAdditionalButtons();
        this._buildHiddenButtons();
    },
    _buildImageButton: function()
    {
        if (!this.opts.imageUpload) this.utils.removeFromArrayByValue(this.buttons, 'image');
    },
    _buildFileButton: function()
    {
        if (!this.opts.fileUpload) this.utils.removeFromArrayByValue(this.buttons, 'file');
    },
    _buildSourceButton: function()
    {
        if (!this.opts.source) this.utils.removeFromArrayByValue(this.buttons, 'html');
    },
    _buildAdditionalButtons: function()
    {
        // end
        if (this.opts.buttonsAdd.length !== 0)
        {
            this.opts.buttonsAdd = this._removeExistButtons(this.opts.buttonsAdd);
            this.buttons = this.buttons.concat(this.opts.buttonsAdd);
        }

        // beginning
        if (this.opts.buttonsAddFirst.length !== 0)
        {
            this.opts.buttonsAddFirst = this._removeExistButtons(this.opts.buttonsAddFirst);
            this.buttons.unshift(this.opts.buttonsAddFirst);
        }

        var index, btns;

        // after
        if (this.opts.buttonsAddAfter !== false)
        {
            index = this.buttons.indexOf(this.opts.buttonsAddAfter.after) + 1;
            btns = this.opts.buttonsAddAfter.buttons;
            for (var i = 0; i < btns.length; i++)
            {
                this.buttons.splice(index+i, 0, btns[i]);
            }
        }

        // before
        if (this.opts.buttonsAddBefore !== false)
        {
            index = this.buttons.indexOf(this.opts.buttonsAddBefore.before)+1;
            btns = this.opts.buttonsAddBefore.buttons;
            for (var i = 0; i < btns.length; i++)
            {
                this.buttons.splice(index-(1-i), 0, btns[i]);
            }
        }
    },
    _buildHiddenButtons: function()
    {
        if (this.opts.buttonsHide.length !== 0)
        {
            var buttons = this.opts.buttonsHide;
            for (var i = 0; i < buttons.length; i++)
            {
                this.utils.removeFromArrayByValue(this.buttons, buttons[i]);
            }
        }
    },
    _removeExistButtons: function(buttons)
    {
        for (var i = 0; i < buttons.length; i++)
        {
            if (this.opts.buttons.indexOf(buttons[i]) !== -1)
            {
                this.utils.removeFromArrayByValue(buttons, buttons[i]);
            }
        }

        return buttons;
    },
    _setExternalOnFocus: function()
    {
        if (!this.opts.air && this.opts.toolbarExternal)
        {
            this.toolbarModule.setExternal();
        }
    },
    _initToolbar: function()
    {
        this.toolbarModule = (this.opts.air) ? $R.create('toolbar.air', this.app) : $R.create('toolbar.standard', this.app);
    },
    _initButtons: function()
    {
        this.toolbar.setButtons(this.buttons);

        for (var i = 0; i < this.buttons.length; i++)
        {
            var name = this.buttons[i];
            if ($R.buttons[name])
            {
                this.toolbar.addButton(name, $R.buttons[name], false, false, true);
            }
        }
    }
});
$R.add('class', 'toolbar.air', {
    init: function(app)
    {
        this.app = app;
        this.uuid = app.uuid;
        this.$doc = app.$doc;
        this.$win = app.$win;
        this.utils = app.utils;
        this.editor = app.editor;
        this.animate = app.animate;
        this.toolbar = app.toolbar;
        this.container = app.container;
        this.inspector = app.inspector;
        this.selection = app.selection;

        // local
        this.clicks = 0;

        // init
        this._init();
    },
    // public
    stop: function()
    {
        var $wrapper = this.toolbar.getWrapper();
        $wrapper.remove();

        var $editor = this.editor.getElement();
        $editor.off('.redactor-air-trigger-' + this.uuid);

        this.$doc.off('.redactor-air-' + this.uuid);
        this.$doc.off('.redactor-air-trigger-' + this.uuid);

        this.toolbar.stopObservers();
    },
    createSourceHelper: function()
    {
        this.$airHelper = $R.dom('<span>');
        this.$airHelper.addClass('redactor-air-helper');
        this.$airHelper.html('<i class="re-icon-html"></i>');
        this.$airHelper.on('click', function(e)
        {
            e.preventDefault();
            this.app.api('module.source.hide');

        }.bind(this));

        var $container = this.container.getElement();
        $container.append(this.$airHelper);
    },
    destroySourceHelper: function()
    {
        if (this.$airHelper) this.$airHelper.remove();
    },
    openSelected: function()
    {
        setTimeout(function()
        {
            if (this._isSelection()) this._open(false);

        }.bind(this), 0);
    },
    close: function()
    {
        this.$doc.off('.redactor-air-' + this.uuid);

        var $toolbar = this.toolbar.getElement();
        $toolbar.removeClass('open');
        $toolbar.hide();
    },

    // private
    _init: function()
    {
        this.toolbar.create();

        var $wrapper = this.toolbar.getWrapper();
        var $toolbar = this.toolbar.getElement();
        var $editor = this.editor.getElement();
        var $container = this.container.getElement();

        $wrapper.addClass('redactor-toolbar-wrapper-air');
        $toolbar.addClass('redactor-air');
        //$toolbar.addClass('redactor-animate-hide');
        $toolbar.hide();

        $wrapper.append($toolbar);
        $container.prepend($wrapper);

        // open selected
        this.openSelected();

        // events
        this.$doc.on('mouseup.redactor-air-trigger-' + this.uuid, this._open.bind(this));
        $editor.on('keyup.redactor-air-trigger-' + this.uuid, this._openCmd.bind(this));
    },
    _isSelection: function()
    {
        return (this.selection.is() && !this.selection.isCollapsed());
    },
    _isOpened: function()
    {
        var $toolbar = this.toolbar.getElement();

        return $toolbar.hasClass('open');
    },
    _open: function(e)
    {
        var target = (e) ? e.target : false;
        var $el = (e) ? $R.dom(e.target) : false;
        var dataTarget = this.inspector.parse(target);
        var isComponent = (dataTarget.isComponent() && !dataTarget.isComponentType('table'));
        var isFigcaption = (dataTarget.isFigcaption());
        var isModalTarget = ($el && $el.closest('.redactor-modal').length !== 0);
        var isButtonCall = (e && $el.closest('.re-button').length !== 0);
        var isDropdownCall = (e && $el.closest('.redactor-dropdown').length !== 0);

        if (isDropdownCall || isButtonCall || isModalTarget || isFigcaption || isComponent || this.toolbar.isContextBar() || !this._isSelection())
        {
            return;
        }

        var pos = this.selection.getPosition();

        setTimeout(function()
        {
            if (this.app.isReadOnly()) return;
            if (this._isSelection()) this._doOpen(pos);

        }.bind(this), 1);

    },
    _openCmd: function()
    {
        if (this.selection.isAll())
        {
            var $toolbar = this.toolbar.getElement();
            var pos = this.selection.getPosition();

            pos.top = (pos.top < 20) ? 0 : pos.top - $toolbar.height();
            pos.height = 0;

            this._doOpen(pos);
        }
    },
    _doOpen: function(pos)
    {
        var $wrapper = this.toolbar.getWrapper();
        var $toolbar = this.toolbar.getElement();
        var $container = this.container.getElement();
        var containerOffset = $container.offset();
        var leftFix = 0;
        var winWidth = this.$win.width();
        var toolbarWidth = $toolbar.width();

        if (winWidth < (pos.left + toolbarWidth))
        {
            var selPos = this.selection.getPosition();
            leftFix = toolbarWidth - selPos.width;
        }

        $wrapper.css({
            left: (pos.left - containerOffset.left - leftFix) + 'px',
            top: (pos.top - containerOffset.top + pos.height + this.$doc.scrollTop()) + 'px'
        });

        this.app.broadcast('airOpen');
        $toolbar.addClass('open');
        $toolbar.show();

        this.$doc.on('click.redactor-air-' + this.uuid, this._close.bind(this));
        this.$doc.on('keydown.redactor-air-' + this.uuid, this._close.bind(this));
        this.app.broadcast('airOpened');
    },
    _close: function(e)
    {
        var $el = (e) ? $R.dom(e.target) : false;
        var isDropdownCall = (e && $el.closest('[data-dropdown], .redactor-dropdown-not-close').length !== 0);
        var isButtonCall = (!isDropdownCall && e && $el.closest('.re-button').length !== 0);

        if (!isButtonCall && (isDropdownCall || !this._isOpened()))
        {
            return;
        }

        // close
        this.app.broadcast('airClose');

        this.close();
        this.app.broadcast('airClosed');
    }
});
$R.add('class', 'toolbar.fixed', {
    init: function(app)
    {
        this.app = app;
        this.uuid = app.uuid;
        this.opts = app.opts;
        this.$doc = app.$doc;
        this.$win = app.$win;
        this.editor = app.editor;
        this.toolbar = app.toolbar;
        this.detector = app.detector;
        this.container = app.container;

        // init
        this._init();
    },
    // public
    stop: function()
    {
        this.$fixedTarget.off('.redactor-toolbar-' + this.uuid);
        this.$win.off('.redactor-toolbar-' + this.uuid);
    },
    reset: function()
    {
        var $toolbar = this.toolbar.getElement();
        var $wrapper = this.toolbar.getWrapper();

        $wrapper.css('height', '');
        $toolbar.removeClass('redactor-toolbar-fixed');
        $toolbar.css({ position: '', top: '', left: '', width: '' });

        var dropdown = this.toolbar.getDropdown();
        if (dropdown) dropdown.updatePosition();
    },

    // private
    _init: function()
    {
        this.$fixedTarget = (this.toolbar.isTarget()) ? this.toolbar.getTargetElement() : this.$win;
        this._doFixed();

        if (this.toolbar.isTarget())
        {
            this.$win.on('scroll.redactor-toolbar-' + this.uuid, this._doFixed.bind(this));
            this.$win.on('resize.redactor-toolbar-' + this.uuid, this._doFixed.bind(this));
        }

        this.$fixedTarget.on('scroll.redactor-toolbar-' + this.uuid, this._doFixed.bind(this));
        this.$fixedTarget.on('resize.redactor-toolbar-' + this.uuid, this._doFixed.bind(this));
    },
    _doFixed: function()
    {
        var $editor = this.editor.getElement();
        var $container = this.container.getElement();
        var $toolbar = this.toolbar.getElement();
        var $wrapper = this.toolbar.getWrapper();

        if (this.editor.isSourceMode())
        {
            return;
        }

        var $targets = $container.parents().filter(function(node)
        {
            return (getComputedStyle(node, null).display === 'none') ? node : false;
        });

        // has hidden parent
        if ($targets.length !== 0) return;

        var isHeight = ($editor.height() < 100);
        var isEmpty = this.editor.isEmpty();

        if (isHeight || isEmpty || this.editor.isSourceMode()) return;

        var toolbarHeight = $toolbar.height();
        var toleranceEnd = 60;
        var containerOffset = (this.toolbar.isTarget()) ? $container.position() : $container.offset();
        var boxOffset = containerOffset.top;
        var boxEnd = boxOffset + $container.height() - toleranceEnd;
        var scrollOffset = this.$fixedTarget.scrollTop() + this.opts.toolbarFixedTopOffset;
        var top = (!this.toolbar.isTarget()) ? 0 : this.$fixedTarget.offset().top - this.$win.scrollTop();


        if (scrollOffset > boxOffset && scrollOffset < boxEnd)
        {
            var position = (this.detector.isDesktop()) ? 'fixed' : 'absolute';
            top = (this.detector.isDesktop()) ? top : (scrollOffset - boxOffset);

            if (this.detector.isMobile())
            {
                if (this.fixedScrollTimeout)
                {
                    clearTimeout(this.fixedScrollTimeout);
                }

                $toolbar.hide();
                this.fixedScrollTimeout = setTimeout(function()
                {
                    $toolbar.show();
                }, 250);
            }

            $wrapper.height(toolbarHeight);
            $toolbar.addClass('redactor-toolbar-fixed');

            if ($container.hasClass('redactor-box-fullscreen'))
            {
                $toolbar.css({
                    position: position,
                    top: '0px',
                    width: $container.width() + 'px'
                });
            }
            else
            {
                $toolbar.css({
                    position: position,
                    top: (top + this.opts.toolbarFixedTopOffset) + 'px',
                    width: $container.width() + 'px'
                });
            }

            var dropdown = this.toolbar.getDropdown();
            if (dropdown) dropdown.updatePosition();

            this.app.broadcast('toolbar.fixed');
        }
        else
        {
            this.reset();
            this.app.broadcast('toolbar.unfixed');
        }
    }
});
$R.add('class', 'toolbar.standard', {
    init: function(app)
    {
        this.app = app;
        this.opts = app.opts;
        this.uuid = app.uuid;
        this.$body = app.$body;
        this.toolbar = app.toolbar;
        this.container = app.container;

        // local
        this.isExternalMultiple = false;
        this.toolbarFixed = false;

        // init
        this._init();
    },
    // public
    stop: function()
    {
        var $wrapper = this.toolbar.getWrapper();
        $wrapper.remove();

        if (this.toolbarFixed) this.toolbarFixed.stop();
        if (this.opts.toolbarExternal) this._findToolbars();

        this.toolbar.stopObservers();
        this.$body.find('.re-button-tooltip-' + this.uuid).remove();
    },
    setExternal: function()
    {
        this._findToolbars();
        if (this.isExternalMultiple)
        {
            this.$toolbars.hide();
            var $current = this.$external.find('.redactor-toolbar-external-' + this.uuid);
            $current.show();
        }
    },
    resetPosition: function()
    {
        if (this.toolbarFixed) this.toolbarFixed.reset();
    },

    // private
    _init: function()
    {
        this._build();

        if (this.opts.toolbarExternal)
        {
            this._buildExternal();
        }
        else
        {
            this._buildFixed();

            var $toolbar = this.toolbar.getElement();
            $toolbar.show();
        }
    },
    _build: function()
    {
        this.toolbar.create();

        var $wrapper = this.toolbar.getWrapper();
        var $toolbar = this.toolbar.getElement();

        $wrapper.addClass('redactor-toolbar-wrapper');
        $toolbar.addClass('redactor-toolbar');
        $toolbar.hide();
        $wrapper.append($toolbar);

        if (!this.opts.toolbarExternal)
        {
            var $container = this.container.getElement();
            $container.prepend($wrapper);
        }
    },
    _buildExternal: function()
    {
        this._initExternal();
        this._findToolbars();

        if (this.isExternalMultiple)
        {
            this._hideToolbarsExceptFirst();
        }
        else
        {
            var $toolbar = this.toolbar.getElement();
            $toolbar.show();
        }
    },
    _buildFixed: function()
    {
        if (this.opts.toolbarFixed)
        {
            this.toolbarFixed = $R.create('toolbar.fixed', this.app);
        }
    },
    _initExternal: function()
    {
        var $toolbar = this.toolbar.getElement();
        var $wrapper = this.toolbar.getElement();

        $toolbar.addClass('redactor-toolbar-external redactor-toolbar-external-' + this.uuid);

        this.$external = $R.dom(this.opts.toolbarExternal);
        this.$external.append($wrapper);

    },
    _findToolbars: function()
    {
        this.$toolbars = this.$external.find('.redactor-toolbar-external');
        this.isExternalMultiple = (this.$toolbars.length > 1);
    },
    _hideToolbarsExceptFirst: function()
    {
        this.$toolbars.hide();
        var $first = this.$toolbars.first();
        $first.show();
    }
});
$R.add('module', 'line', {
    init: function(app)
    {
        this.app = app;
        this.lang = app.lang;
        this.component = app.component;
        this.inspector = app.inspector;
        this.insertion = app.insertion;
    },
    // messages
    oncontextbar: function(e, contextbar)
    {
        var data = this.inspector.parse(e.target);
        if (data.isComponentType('line'))
        {
            var node = data.getComponent();
            var buttons = {
                "remove": {
                    title: this.lang.get('delete'),
                    api: 'module.line.remove',
                    args: node
                }
            };

            contextbar.set(e, node, buttons, 'bottom');
        }

    },

    // public
    insert: function()
    {
        var line = this.component.create('line');
        this.insertion.insertRaw(line);
    },
    remove: function(node)
    {
        this.component.remove(node);
    }
});
$R.add('class', 'line.component', {
    mixins: ['dom', 'component'],
    init: function(app, el)
    {
        this.app = app;

        // init
        return (el && el.cmnt !== undefined) ? el : this._init(el);
    },
    // private
    _init: function(el)
    {
        var wrapper, element;
        if (typeof el !== 'undefined')
        {
            var $node = $R.dom(el);
            var node = $node.get();

            if (node.tagName === 'HR') element = node;
            else if (node.tagName === 'FIGURE')
            {
                wrapper = node;
                element = $node.find('hr').get();
            }
        }

        this._buildWrapper(wrapper);
        this._buildElement(element);
        this._initWrapper();
    },
    _buildElement: function(node)
    {
        if (node)
        {
            this.$element = $R.dom(node);
        }
        else
        {
            this.$element = $R.dom('<hr>');
            this.append(this.$element);
        }
    },
    _buildWrapper: function(node)
    {
        node = node || '<figure>';

        this.parse(node);
    },
    _initWrapper: function()
    {
        this.addClass('redactor-component');
        this.attr({
            'data-redactor-type': 'line',
            'tabindex': '-1',
            'contenteditable': false
        });
    }
});
$R.add('module', 'link', {
    modals: {
        'link':
            '<form action=""> \
                <div class="form-item"> \
                    <label for="modal-link-url">URL <span class="req">*</span></label> \
                    <input type="text" id="modal-link-url" name="url"> \
                </div> \
                <div class="form-item"> \
                    <label for="modal-link-text">## text ##</label> \
                    <input type="text" id="modal-link-text" name="text"> \
                </div> \
                <div class="form-item form-item-title"> \
                    <label for="modal-link-title">## title ##</label> \
                    <input type="text" id="modal-link-title" name="title"> \
                </div> \
                <div class="form-item form-item-target"> \
                    <label class="checkbox"> \
                        <input type="checkbox" name="target"> ## link-in-new-tab ## \
                    </label> \
                </div> \
            </form>'
    },
    init: function(app)
    {
        this.app = app;
        this.opts = app.opts;
        this.lang = app.lang;
        this.caret = app.caret;
        this.utils = app.utils;
        this.inline = app.inline;
        this.editor = app.editor;
        this.inspector = app.inspector;
        this.insertion = app.insertion;
        this.selection = app.selection;

        // local
        this.isCurrentLink = false;
        this.currentText = false;
    },
    // messages
    onmodal: {
        link: {
            open: function($modal, $form)
            {
                this._setFormData($form, $modal);
            },
            opened: function($modal, $form)
            {
                this._setFormFocus($form);
            },
            update: function($modal, $form)
            {
                var data = $form.getData();
                if (this._validateData($form, data))
                {
                    this._update(data);
                }
            },
            insert: function($modal, $form)
            {
                var data = $form.getData();
                if (this._validateData($form, data))
                {
                    this._insert(data);
                }
            },
            unlink: function()
            {
                this._unlink();
            }
        }
    },
    onbutton: {
        link: {
            observe: function(button)
            {
                this._observeButton(button);
            }
        }
    },
    ondropdown: {
        link: {
            observe: function(dropdown)
            {
                this._observeUnlink(dropdown);
                this._observeEdit(dropdown);
            }
        }
    },
    oncontextbar: function(e, contextbar)
    {
        var current = this._getCurrent();
        var data = this.inspector.parse(current);
        if (data.isLink())
        {
            var node = data.getLink();
            var $el = $R.dom(node);

            var $point = $R.dom('<a>');
            var url = $el.attr('href');

            $point.text(this._truncateText(url));
            $point.attr('href', url);
            $point.attr('target', '_blank');

            var buttons = {
                "link": {
                    title: $point
                },
                "edit": {
                    title: this.lang.get('edit'),
                    api: 'module.link.open'
                },
                "unlink": {
                    title: this.lang.get('unlink'),
                    api: 'module.link.unlink'
                }
            };

            contextbar.set(e, node, buttons, 'bottom');
        }
    },

    // public
    open: function()
    {
        this.$link = this._buildCurrent();
        this.app.api('module.modal.build', this._getModalData());
    },
    insert: function(data)
    {
        this._insert(data);
    },
    update: function(data)
    {
        this._update(data);
    },
    unlink: function()
    {
        this._unlink();
    },

    // private
    _observeButton: function(button)
    {
        var current = this.selection.getCurrent();
        var data = this.inspector.parse(current);

        if (data.isPre() || data.isCode())
        {
            button.disable();
        }
        else
        {
            button.enable();
        }
    },
    _observeUnlink: function(dropdown)
    {
        var $item = dropdown.getItem('unlink');
        var links = this._getLinks();

        if (links.length === 0) $item.disable();
        else                    $item.enable();
    },
    _observeEdit: function(dropdown)
    {
        var current = this._getCurrent();
        var $item = dropdown.getItem('link');

        var data = this.inspector.parse(current);
        var title = (data.isLink()) ? this.lang.get('link-edit') : this.lang.get('link-insert');

        $item.setTitle(title);
    },
    _unlink: function()
    {
        this.app.api('module.modal.close');

        var elms = [];
        var nodes = this._getLinks();

        this.selection.save();
        for (var i = 0; i < nodes.length; i++)
        {
            var $link = $R.create('link.component', this.app, nodes[i]);
            elms.push(this.selection.getElement(nodes[i]));

            $link.unwrap();

            // callback
            this.app.broadcast('link.deleted', $link);
        }
        this.selection.restore();

        // normalize
        for (var i = 0; i < elms.length; i++)
        {
            var el = (elms[i]) ? elms[i] : this.editor.getElement();
            this.utils.normalizeTextNodes(el);
        }

        this._resetCurrent();
    },
    _update: function(data)
    {
        this.app.api('module.modal.close');

        var nodes = this._getLinks();
        this._setLinkData(nodes, data, 'updated');
        this._resetCurrent();
    },
    _insert: function(data)
    {
        this.app.api('module.modal.close');

        var links = this._getLinks();

        if (!this._insertSingle(links, data))
        {
            this._removeInSelection(links);
            this._insertMultiple(data);
        }

        this._resetCurrent();
    },
    _removeInSelection: function(links)
    {
        this.selection.save();
        for (var i = 0; i < links.length; i++)
        {
            var $link = $R.create('link.component', this.app, links[i]);
            var $clonedLink = $link.clone();
            $link.unwrap();

            // callback
            this.app.broadcast('link.deleted', $clonedLink);
        }
        this.selection.restore();
    },
    _insertMultiple: function(data)
    {
        var range = this.selection.getRange();
        if (range && this._isCurrentTextChanged(data))
        {
            this._deleteContents(range);
        }

        var nodes = this.inline.format({ tag: 'a' });

        this._setLinkData(nodes, data, 'inserted');
    },
    _insertSingle: function(links, data)
    {
        var inline = this.selection.getInline();
        if (links.length === 1 && (links[0].textContext === this.selection.getText()) || (inline && inline.tagName === 'A'))
        {
            var $link = $R.create('link.component', this.app, links[0]);

            $link.setData(data);
            this.caret.setAfter($link);

            // callback
            this.app.broadcast('link.inserted', $link);

            return true;
        }

        return false;
    },
    _setLinkData: function(nodes, data, type)
    {
        data.text = (data.text.trim() === '') ? this._truncateText(data.url) : data.text;

        var isTextChanged = (!this.currentText || this.currentText !== data.text);

        this.selection.save();
        for (var i = 0; i < nodes.length; i++)
        {
            var $link = $R.create('link.component', this.app, nodes[i]);
            var linkData = {};

            if (data.text && isTextChanged) linkData.text = data.text;
            if (data.url) linkData.url = data.url;
            if (data.title !== undefined) linkData.title = data.title;
            if (data.target !== undefined) linkData.target = data.target;

            $link.setData(linkData);

            // callback
            this.app.broadcast('link.' + type, $link);
        }

        setTimeout(this.selection.restore.bind(this.selection), 0);
    },
    _deleteContents: function(range)
    {
        var html = this.selection.getHtml();
        var parsed = this.utils.parseHtml(html);
        var first = parsed.nodes[0];

        if (first && first.nodeType !== 3)
        {
            var tag = first.tagName.toLowerCase();
            var container = document.createElement(tag);

            this.insertion.insertNode(container, 'start');
        }
        else
        {
            range.deleteContents();
        }
    },
    _getModalData: function()
    {
        var commands;
        if (this._isLink())
        {
           commands = {
                update: { title: this.lang.get('save') },
                unlink: { title: this.lang.get('unlink'), type: 'danger' },
                cancel: { title: this.lang.get('cancel') }
            };
        }
        else
        {
            commands = {
                insert: { title: this.lang.get('insert') },
                cancel: { title: this.lang.get('cancel') }
            };
        }

        var modalData = {
            name: 'link',
            title: (this._isLink()) ? this.lang.get('link-edit') : this.lang.get('link-insert'),
            handle: (this._isLink()) ? 'update' : 'insert',
            commands: commands
        };


        return modalData;
    },
    _isLink: function()
    {
        return this.currentLink;
    },
    _isCurrentTextChanged: function(data)
    {
        return (this.currentText && this.currentText !== data.text);
    },
    _buildCurrent: function()
    {
        var current = this._getCurrent();
        var data = this.inspector.parse(current);
        var $link;

        if (data.isLink())
        {
            this.currentLink = true;

            $link = data.getLink();
            $link = $R.create('link.component', this.app, $link);
        }
        else
        {
            this.currentLink = false;

            $link = $R.create('link.component', this.app);
            var linkData = {
                text: this.selection.getText()
            };

            $link.setData(linkData);
        }

        return $link;
    },
    _getCurrent: function()
    {
        return this.selection.getInlinesAllSelected({ tags: ['a'] })[0];
    },
    _getLinks: function()
    {
        var links = this.selection.getInlines({ all: true, tags: ['a'] });
        var arr = [];
        for (var i = 0; i < links.length; i++)
        {
            var data = this.inspector.parse(links[i]);
            if (data.isLink())
            {
                arr.push(links[i]);
            }
        }

        return arr;
    },
    _resetCurrent: function()
    {
        this.isCurrentLink = false;
        this.currentText = false;
    },
    _truncateText: function(url)
    {
        return (url && url.length > this.opts.linkSize) ? url.substring(0, this.opts.linkSize) + '...' : url;
    },
    _validateData: function($form, data)
    {
        return (data.url.trim() === '') ? $form.setError('url') : true;
    },
    _setFormFocus: function($form)
    {
        $form.getField('url').focus();
    },
    _setFormData: function($form, $modal)
    {
        var linkData = this.$link.getData();
        var data = {
            url: linkData.url,
            text: linkData.text,
            title: linkData.title,
            target: (this.opts.linkTarget || linkData.target)
        };

        if (!this.opts.linkNewTab) $modal.find('.form-item-target').hide();
        if (!this.opts.linkTitle) $modal.find('.form-item-title').hide();

        $form.setData(data);
        this.currentText = $form.getField('text').val();
    }
});
$R.add('class', 'link.component', {
    mixins: ['dom', 'component'],
    init: function(app, el)
    {
        this.app = app;
        this.opts = app.opts;

        // local
        this.reUrl = /^(?:(?:(?:https?|ftp):)?\/\/)?(?:\S+(?::\S*)?@)?(?:(?!(?:10|127)(?:\.\d{1,3}){3})(?!(?:169\.254|192\.168)(?:\.\d{1,3}){2})(?!172\.(?:1[6-9]|2\d|3[0-1])(?:\.\d{1,3}){2})(?:[1-9]\d?|1\d\d|2[01]\d|22[0-3])(?:\.(?:1?\d{1,2}|2[0-4]\d|25[0-5])){2}(?:\.(?:[1-9]\d?|1\d\d|2[0-4]\d|25[0-4]))|(?:(?:[a-z\u00a1-\uffff0-9]-*)*[a-z\u00a1-\uffff0-9]+)(?:\.(?:[a-z\u00a1-\uffff0-9]-*)*[a-z\u00a1-\uffff0-9]+)*(?:\.(?:[a-z\u00a1-\uffff]{2,})))(?::\d{2,5})?(?:[/?#]\S*)?$/i;

        // init
        return (el && el.cmnt !== undefined) ? el :  this._init(el);
    },

    // public
    setData: function(data)
    {
        for (var name in data)
        {
            this._set(name, data[name]);
        }
    },
    getData: function()
    {
        var names = ['url', 'text', 'target', 'title'];
        var data = {};

        for (var i = 0; i < names.length; i++)
        {
            data[names[i]] = this._get(names[i]);
        }

        return data;
    },

    // private
    _init: function(el)
    {
        var $el = $R.dom(el);
        if (el === undefined)
        {
            this.parse('<a>');
        }
        else
        {
            this.parse($el);
        }
    },
    _set: function(name, value)
    {
        this['_set_' + name](value);
    },
    _get: function(name)
    {
        return this['_get_' + name]();
    },
    _get_target: function()
    {
        return (this.attr('target')) ? this.attr('target') : false;
    },
    _get_url: function()
    {
        return this.attr('href');
    },
    _get_title: function()
    {
        return this.attr('title');
    },
    _get_text: function()
    {
        return this._getContext().text();
    },
    _getContext: function()
    {
        return this._findDeepestChild(this).element;
    },
    _set_target: function(target)
    {
        if (target === false) this.removeAttr('target');
        else if (target)
        {
            this.attr('target', (target === true) ? '_blank' : target);
        }
    },
    _set_text: function(text)
    {
        this._getContext().html(text);
    },
    _set_title: function(title)
    {
        if (!title || title === '') this.removeAttr('title');
        else this.attr('title', title);
    },
    _set_url: function(url)
    {
        if (this.opts.linkValidation)
        {
            url = this._cleanUrl(url);

            if (this._isMailto(url))
            {
                url = 'mailto:' + url.replace('mailto:', '');
            }
            else if (this._isUrl(url) && url.search(/^(ftp|https?)/i) === -1)
            {
                url = 'http://' + url.replace(/(ftp|https?):\/\//i, '');
            }
        }

        this.attr('href', url);
    },
    _isMailto: function(url)
    {
        return (url.search('@') !== -1 && /(ftp|https?):\/\//i.test(url) === false);
    },
    _isUrl: function(url)
    {
        return this.reUrl.test(url);
    },
    _cleanUrl: function(url)
    {
        return url.trim().replace(/[^\W\w\D\d+&\'@#/%?=~_|!:,.;\(\)]/gi, '');
    },
    _findDeepestChild: function(parent)
    {
        var result = {depth: 0, element: parent };

        parent.children().each(function(node)
        {
            var child = $R.dom(node);

            if (node.outerHTML !== parent.html())
            {
                return;
            }
            else
            {
                var childResult = this._findDeepestChild(child);
                if (childResult.depth + 1 > result.depth)
                {
                    result = {
                        depth: 1 + childResult.depth,
                        element: childResult.element
                    };
                }
            }
        }.bind(this));

        return result;
    }
});
$R.add('module', 'modal', {
    init: function(app)
    {
        this.app = app;
        this.lang = app.lang;
        this.$doc = app.$doc;
        this.$win = app.$win;
        this.$body = app.$body;
        this.utils = app.utils;
        this.editor = app.editor;
        this.animate = app.animate;
        this.detector = app.detector;
        this.selection = app.selection;

        // local
        this.$box = false;
        this.$modal = false;
        this.selectionMarkers = false;

        // defaults
        this.defaults = {
            name: false,
            url: false,
            title: false,
            width: '600px',
            height: false,
            handle: false,
            commands: false
        };
    },
    // public
    build: function(data)
    {
        this._open(data);
    },
    close: function()
    {
        this._close();
    },
    stop: function()
    {
        if (this.$box)
        {
            this.$box.remove();
            this.$box = false;
            this.$modal = false;

            this.$doc.off('.redactor.modal');
            this.$win.off('.redactor.modal');
        }

        if (this.$overlay)
        {
            this.$overlay.remove();
        }
    },
    resize: function()
    {
        this.$modal.setWidth(this.p.width);
        this.$modal.updatePosition();
    },

    // private
    _isOpened: function()
    {
        return (this.$modal && this.$modal.hasClass('open'));
    },
    _open: function(data)
    {
        this._buildDefaults(data);

        if (this.p.url) this._openUrl();
        else this._openTemplate();
    },
    _openUrl: function()
    {
        $R.ajax.post({
            url: this.p.url,
            success: this._doOpen.bind(this)
        });
    },
    _openTemplate: function()
    {
        if (typeof $R.modals[this.p.name] !== 'undefined')
        {
            var template = this.lang.parse($R.modals[this.p.name]);
            this._doOpen(template);
        }
    },
    _doOpen: function(template)
    {
        this.stop();

        if (this.selection.isCollapsed())
        {
            this.selection.save();
            this.selectionMarkers = false;
        }
        else
        {
            this.selection.saveMarkers();
            this.selectionMarkers = true;
        }

        if (!this.detector.isDesktop())
        {
            document.activeElement.blur();
        }

        this._createModal(template);

        this._buildModalBox();
        this._buildOverlay();
        this._buildModal();
        this._buildModalForm();
        this._buildModalCommands();

        this._broadcast('open');

        this.$modal.updatePosition();
        this._buildModalTabs();

        this.animate.start(this.$box, 'fadeIn', this._opened.bind(this));
        this.animate.start(this.$overlay, 'fadeIn');

    },
    _opened: function()
    {
        this.$modal.addClass('open');
        this.$box.on('mousedown.redactor.modal', this._close.bind(this));
        this.$doc.on('keyup.redactor.modal', this._handleEscape.bind(this));
        this.$win.on('resize.redactor.modal', this.resize.bind(this));
        this.$modal.getBody().find('input[type=text],input[type=url],input[type=email]').on('keydown.redactor.modal', this._handleEnter.bind(this));

        // fix bootstrap modal focus
        if (window.jQuery) jQuery(document).off('focusin.modal');

        this._broadcast('opened');
    },
    _close: function(e)
    {
        if (!this.$box || !this._isOpened()) return;

        if (e)
        {
            if (!this._needToClose(e.target))
            {
                return;
            }

            e.stopPropagation();
            e.preventDefault();
        }

        if (this.selectionMarkers) this.selection.restoreMarkers();
        else this.selection.restore();

        this.selectionMarkers = false;

        this._broadcast('close');

        this.animate.start(this.$box, 'fadeOut', this._closed.bind(this));
        this.animate.start(this.$overlay, 'fadeOut');
    },
    _closed: function()
    {
        this.$modal.removeClass('open');
        this.$box.off('.redactor.modal');
        this.$doc.off('.redactor.modal');
        this.$win.off('.redactor.modal');

        this._broadcast('closed');
    },
    _createModal: function(template)
    {
        this.$modal = $R.create('modal.element', this.app, template);
    },
    _broadcast: function(message)
    {
        this.app.broadcast('modal.' + message, this.$modal, this.$modalForm);
        this.app.broadcast('modal.' + this.p.name + '.' + message, this.$modal, this.$modalForm);
    },
    _buildDefaults: function(data)
    {
         this.p = $R.extend({}, this.defaults, data);
    },
    _buildModalBox: function()
    {
        this.$box = $R.dom('<div>');
        this.$box.attr('id', 'redactor-modal');
        this.$box.addClass('redactor-animate-hide');
        this.$box.html('');
        this.$body.append(this.$box);
    },
    _buildOverlay: function()
    {
        this.$overlay = $R.dom('#redactor-overlay');
        if (this.$overlay.length === 0)
        {
            this.$overlay = $R.dom('<div>');
            this.$overlay.attr('id', 'redactor-overlay');
            this.$overlay.addClass('redactor-animate-hide');
            this.$body.prepend(this.$overlay);
        }
    },
    _buildModal: function()
    {
        this.$box.append(this.$modal);

        this.$modal.setTitle(this.p.title);
        this.$modal.setHeight(this.p.height);
        this.$modal.setWidth(this.p.width);
    },
    _buildModalCommands: function()
    {
        if (this.p.commands)
        {
            var commands = this.p.commands;
            var $footer = this.$modal.getFooter();
            for (var key in commands)
            {
                var $btn = $R.dom('<button>');

                $btn.html(commands[key].title);
                $btn.attr('data-command', key);

                // cancel
                if (key === 'cancel')
                {
                    $btn.attr('data-action', 'close');
                    $btn.addClass('redactor-button-unstyled');
                }

                // danger
                if (typeof commands[key].type !== 'undefined' && commands[key].type === 'danger')
                {
                    $btn.addClass('redactor-button-danger');
                }

                $btn.on('click', this._handleCommand.bind(this));

                $footer.append($btn);
            }
        }
    },
    _buildModalTabs: function()
    {
        var $body = this.$modal.getBody();
        var $tabs = $body.find('.redactor-modal-tab');
        var $box = $body.find('.redactor-modal-tabs');

        if ($tabs.length > 1)
        {
            $box = ($box.length === 0) ? $R.dom('<div>') : $box.html('');
            $box.addClass('redactor-modal-tabs');

            $tabs.each(function(node, i)
            {
                var $node = $R.dom(node);
                var $item = $R.dom('<a>');
                $item.attr('href', '#');
                $item.attr('rel', i);
                $item.text($node.attr('data-title'));
                $item.on('click', this._showTab.bind(this));

                if (i === 0)
                {
                    $item.addClass('active');
                }

                $box.append($item);

            }.bind(this));

            $body.prepend($box);
        }
    },
    _buildModalForm: function()
    {
        this.$modalForm = $R.create('modal.form', this.app, this.$modal.getForm());
    },
    _showTab: function(e)
    {
        e.preventDefault();

        var $el = $R.dom(e.target);
        var index = $el.attr('rel');
        var $body = this.$modal.getBody();
        var $tabs = $body.find('.redactor-modal-tab');

        $tabs.hide();
        $tabs.eq(index).show();

        $body.find('.redactor-modal-tabs a').removeClass('active');
        $el.addClass('active');

    },
    _needToClose: function(el)
    {
        var $target = $R.dom(el);
        if ($target.attr('data-action') === 'close' || this.$modal.isCloseNode(el) || $target.closest('.redactor-modal').length === 0)
        {
            return true;
        }

        return false;
    },
    _handleCommand: function(e)
    {
        var $btn = $R.dom(e.target).closest('button');
        var command = $btn.attr('data-command');

        if (command !== 'cancel') e.preventDefault();

        this._broadcast(command);
    },
    _handleEnter: function(e)
    {
        if (e.which === 13)
        {
            if (this.p.handle)
            {
                e.preventDefault();
                this._broadcast(this.p.handle);
            }
        }
    },
    _handleEscape: function(e)
    {
        if (e.which === 27) this._close();
    }
});
$R.add('class', 'modal.element', {
    mixins: ['dom'],
    init: function(app, template)
    {
        this.app = app;
        this.opts = app.opts;
        this.$win = app.$win;

        // init
        this._init(template);
    },

    // get
    getForm: function()
    {
        return this.find('form');
    },
    getHeader: function()
    {
        return this.$modalHeader;
    },
    getBody: function()
    {
        return this.$modalBody;
    },
    getFooter: function()
    {
        return this.$modalFooter;
    },

    // set
    setTitle: function(title)
    {
        if (title) this.$modalHeader.html(title);
    },
    setWidth: function(width)
    {
        width = (parseInt(width) >= this.$win.width()) ? '96%' : width;

        this.css('max-width', width);
    },
    setHeight: function(height)
    {
        if (height !== false) this.$modalBody.css('height', height);
    },

    // update
    updatePosition: function()
    {
        var width = this.width();
        this.css({ 'left': '50%', 'margin-left': '-' + (width/2) + 'px' });

        var windowHeight = this.$win.height();
        var height = this.height();
        var marginTop = (windowHeight/2 - height/2);

        if (height < windowHeight && marginTop !== 0)
        {
            this.css('margin-top', marginTop + 'px');
        }
    },

    // is
    isCloseNode: function(el)
    {
        return (el === this.$modalClose.get());
    },

    // private
    _init: function(template)
    {
        this._build();
        this._buildClose();
        this._buildHeader();
        this._buildBody();
        this._buildFooter();
        this._buildTemplate(template);
    },
    _build: function()
    {
        this.parse('<div>');
        this.addClass('redactor-modal');
        this.attr('dir', this.opts.direction);
    },
    _buildClose: function()
    {
        this.$modalClose = $R.dom('<span>');
        this.$modalClose.addClass('redactor-close');

        this.append(this.$modalClose);
    },
    _buildHeader: function()
    {
        this.$modalHeader = $R.dom('<div>');
        this.$modalHeader.addClass('redactor-modal-header');

        this.append(this.$modalHeader);
    },
    _buildBody: function()
    {
        this.$modalBody = $R.dom('<div>');
        this.$modalBody.addClass('redactor-modal-body');

        this.append(this.$modalBody);
    },
    _buildFooter: function()
    {
        this.$modalFooter = $R.dom('<div>');
        this.$modalFooter.addClass('redactor-modal-footer');

        this.append(this.$modalFooter);
    },
    _buildTemplate: function(template)
    {
        this.$modalBody.html(template);
    }
});
$R.add('class', 'modal.form', {
    mixins: ['dom'],
    init: function(app, element)
    {
        this.app = app;

        // build
        this.build(element);
    },

    // public
    build: function(element)
    {
        this.parse(element);
    },
    getData: function()
    {
        var data = {};
        this.find('[name]').each(function(node)
        {
            var $node = $R.dom(node);
            data[$node.attr('name')] = $node.val();
        });

        return data;
    },
    setData: function(data)
    {
        this.find('[name]').each(function(node)
        {
            var $node = $R.dom(node);
            var name = $node.attr('name');
            if (data.hasOwnProperty(name))
            {
                if (node.type && node.type === 'checkbox') node.checked = data[name];
                else $node.val(data[name]);
            }
        });
    },
    getField: function(name)
    {
        return this.find('[name=' + name + ']');
    },
    setError: function(name)
    {
        var $el = this.getField(name);

        $el.addClass('error');
        $el.one(this._getFieldEventName($el.get()), this._clearError);

        return false;
    },

    // private
    _clearError: function()
    {
        return $R.dom(this).removeClass('error');
    },
    _getFieldEventName: function(el)
    {
        return (el.tagName === 'SELECT' || el.type === 'checkbox' || el.type === 'radio') ? 'change' : 'keyup';
    }
});
$R.add('module', 'block', {
    init: function(app)
    {
        this.app = app;
        this.block = app.block;
    },
    // public
    format: function(args)
    {
        var nodes = this.block.format(args);

        // callback
        this.app.broadcast('format', 'block', nodes);
    },
    clearformat: function()
    {
        this.block.clearFormat();
    },
    clearstyle: function()
    {
        this.block.clearStyle();
    },
    clearclass: function()
    {
        this.block.clearClass();
    },
    clearattr: function()
    {
        this.block.clearAttr();
    },
    add: function(args, tags)
    {
        this.block.add(args, tags);
    },
    toggle: function(args, tags)
    {
        this.block.toggle(args, tags);
    },
    set: function(args, tags)
    {
        this.block.set(args, tags);
    },
    remove: function(args, tags)
    {
        this.block.remove(args, tags);
    }
});
$R.add('module', 'inline', {
    init: function(app)
    {
        this.app = app;
        this.inline = app.inline;
    },
    format: function(args)
    {
        var nodes = this.inline.format(args);

        // callback
        this.app.broadcast('format', 'inline', nodes);
    },
    clearformat: function()
    {
        this.inline.clearFormat();
    },
    clearstyle: function()
    {
        this.inline.clearStyle();
    },
    clearclass: function()
    {
        this.inline.clearClass();
    },
    clearattr: function()
    {
        this.inline.clearAttr();
    },
    add: function(args, tags)
    {
        this.inline.add(args, tags);
    },
    toggle: function(args, tags)
    {
        this.inline.toggle(args, tags);
    },
    set: function(args, tags)
    {
        this.inline.set(args, tags);
    },
    remove: function(args, tags)
    {
        this.inline.remove(args, tags);
    }
});
$R.add('module', 'autosave', {
    init: function(app)
    {
        this.app = app;
        this.opts = app.opts;
        this.utils = app.utils;
        this.source = app.source;
    },
    // messages
    onsynced: function()
    {
        if (this.opts.autosave)
        {
            this._send();
        }
    },

    // private
    _send: function()
    {
        var name = (this.opts.autosaveName) ? this.opts.autosaveName : this.source.getName();

        var data = {};
        data[name] = this.source.getCode();
        data = this.utils.extendData(data, this.opts.autosaveData);

        $R.ajax.post({
            url: this.opts.autosave,
            data: data,
            success: function(response)
            {
                this._complete(response, name, data);
            }.bind(this)
        });
    },
    _complete: function(response, name, data)
    {
        var callback = (response && response.error) ? 'autosaveError' : 'autosave';
        this.app.broadcast(callback, name, data, response);
    }
});
$R.add('module', 'input', {
    init: function(app)
    {
        this.app = app;
        this.opts = app.opts;
        this.utils = app.utils;
        this.editor = app.editor;
        this.keycodes = app.keycodes;
        this.element = app.element;
        this.selection = app.selection;
        this.insertion = app.insertion;
        this.inspector = app.inspector;
        this.autoparser = app.autoparser;

        // local
        this.lastShiftKey = false;
    },
    // messages
    onpaste: function(e, dataTransfer)
    {
        if (!this.opts.input) return;

        return $R.create('input.paste', this.app, e, dataTransfer);
    },
    onkeydown: function(e)
    {
        if (!this.opts.input) return;

        // key
        var key = e.which;

        // shortcuts
        var shortcut = $R.create('input.shortcut', this.app, e);
        if (shortcut.is()) return;

        // select all
        if ((e.ctrlKey || e.metaKey) && !e.altKey && key === 65)
        {
            e.preventDefault();
            return this._selectAll();
        }

        // set empty if all selected
        var keys = [this.keycodes.ENTER, this.keycodes.SPACE, this.keycodes.BACKSPACE, this.keycodes.DELETE];
        var arrowKeys = [this.keycodes.UP, this.keycodes.DOWN, this.keycodes.LEFT, this.keycodes.RIGHT];
        var isKeys = (keys.indexOf(key) !== -1);
        var isArrowKeys = (arrowKeys.indexOf(key) !== -1);
        var isXKey = ((e.ctrlKey || e.metaKey) && key === 88); // x
        var isAlphaKeys = ((!e.ctrlKey && !e.metaKey) && ((key >= 48 && key <= 57) || (key >= 65 && key <= 90)));

        if (this.selection.isAll() && isArrowKeys && (isXKey || (!e.ctrlKey && !e.metaKey && !e.altKey && !e.shiftKey)))
        {
            if (isXKey)
            {
                this.editor.disableNonEditables();
                this.app.broadcast('empty');
                return;
            }

            if (this._isArrowKey(key)) return true;
            if (isKeys) e.preventDefault();

            if (this.element.isType('inline'))
            {
                var $editor = this.editor.getElement();
                $editor.html('');

                this.editor.startFocus();
            }
            else
            {
                this.insertion.set(this.opts.emptyHtml);
            }

            if (isKeys) return;
            else this.app.broadcast('empty');
        }

        // autoparse
        if (this.opts.autoparse)
        {
            this.autoparser.format(e, key);
        }

        // a-z, 0-9 - non editable
        if (isAlphaKeys)
        {
            // has non-editable
            if (this.selection.hasNonEditable())
            {
                e.preventDefault();
                return;
            }
        }

        // enter, shift/ctrl + enter
        if (key === this.keycodes.ENTER)
        {
            return $R.create('input.enter', this.app, e, key);
        }
        // cmd + [
        else if (e.metaKey && key === 219)
        {
            e.preventDefault();
            this.app.api('module.list.outdent');
            return;
        }
        // tab or cmd + ]
        else if (key === this.keycodes.TAB || e.metaKey && key === 221)
        {
            return $R.create('input.tab', this.app, e, key);
        }
        // space
        else if (key === this.keycodes.SPACE)
        {
            return $R.create('input.space', this.app, e, key, this.lastShiftKey);
        }
        // backspace or delete
        else if (this._isDeleteKey(key))
        {
            return $R.create('input.delete', this.app, e, key);
        }
        else if (this._isArrowKey(key))
        {
            return $R.create('input.arrow', this.app, e, key);
        }
    },
    onkeyup: function(e)
    {
        if (!this.opts.input) return;

        // key
        var key = e.which;

        // shift key
        this.lastShiftKey = e.shiftKey;

        // hide context toolbar
        this.app.broadcast('contextbar.close');

        // shortcode
        var shortcode = $R.create('input.shortcode', this.app, e, key);
        if (shortcode.is()) return;

        // is empty
        if (key === this.keycodes.BACKSPACE)
        {
            var $editor = this.editor.getElement();
            var html = this.utils.trimSpaces($editor.html());
            html = html.replace(/<br\s?\/?>/g, '');
            html = html.replace(/<div><\/div>/, '');

            if (html === '')
            {
                e.preventDefault();
                this.editor.setEmpty();
                this.editor.startFocus();
                return;
            }
        }

        if (this.editor.isEmpty())
        {
            this.app.broadcast('empty');
        }
    },

    // public
    start: function()
    {
        // extend shortcuts
        if (this.opts.shortcutsAdd)
        {
            this.opts.shortcuts = $R.extend({}, true, this.opts.shortcuts, this.opts.shortcutsAdd);
        }
    },

    // private
    _selectAll: function()
    {
        var current = this.selection.getCurrent();
        var data = this.inspector.parse(current);
        var el;

        if (data.isComponentType('table'))
        {
            el = data.getTable();
            this.selection.setAll(el);
            return;
        }
        else if (data.isComponentType('code'))
        {
            el = data.getComponentCodeElement();
            this.selection.setAll(el);
            return;
        }

        this.selection.setAll();
    },
    _isArrowKey: function(key)
    {
        return ([this.keycodes.UP, this.keycodes.DOWN, this.keycodes.RIGHT, this.keycodes.LEFT].indexOf(key) !== -1);
    },
    _isDeleteKey: function(key)
    {
        return (key === this.keycodes.BACKSPACE || key === this.keycodes.DELETE);
    }
});
$R.add('class', 'input.arrow', {
    init: function(app, e, key)
    {
        this.app = app;
        this.opts = app.opts;
        this.utils = app.utils;
        this.caret = app.caret;
        this.offset = app.offset;
        this.marker = app.marker;
        this.editor = app.editor;
        this.keycodes = app.keycodes;
        this.component = app.component;
        this.inspector = app.inspector;
        this.selection = app.selection;

        // local
        this.key = key;

        // init
        this._init(e);
    },
    // private
    _init: function(e)
    {
        if (this._isRightLeftKey() && this._isExitVariable(e)) return;

        if (this._isRightDownKey())
        {
            if (this._isExitOnDownRight(e)) return;
            if (this._selectComponent(e, 'End', 'next')) return;
        }

        if (this._isLeftUpKey())
        {
            if (this._isExitOnUpLeft(e)) return;
            if (this._selectComponent(e, 'Start', 'prev')) return;
        }

        if (this.key === this.keycodes.LEFT) this.utils.trimInvisibleChars('left');
        else if (this.key === this.keycodes.RIGHT) this.utils.trimInvisibleChars('right');

    },
    _isRightDownKey: function()
    {
        return ([this.keycodes.DOWN, this.keycodes.RIGHT].indexOf(this.key) !== -1);
    },
    _isLeftUpKey: function()
    {
        return ([this.keycodes.UP, this.keycodes.LEFT].indexOf(this.key) !== -1);
    },
    _isRightLeftKey: function()
    {
        return ([this.keycodes.RIGHT, this.keycodes.LEFT].indexOf(this.key) !== -1);
    },
    _isExitVariable: function(e)
    {
        var current = this.selection.getCurrent();
        var data = this.inspector.parse(current);
        var component = data.getComponent();
        if (data.isComponentType('variable') && data.isComponentActive())
        {
            e.preventDefault();
            var func = (this.key === this.keycodes.LEFT) ? 'setBefore' : 'setAfter';
            this.caret[func](component);
            return;
        }
    },
    _isExitOnUpLeft: function(e)
    {
        var current = this.selection.getCurrent();
        var block = this.selection.getBlock(current);
        var data = this.inspector.parse(current);
        var prev = block.previousElementSibling;
        var isStart = this.caret.isStart(block);

        // prev table
        if (isStart && prev && prev.tagName === 'TABLE')
        {
            e.preventDefault();
            this.caret.setEnd(prev);
            return true;
        }
        // figcaption
        else if (data.isFigcaption())
        {
            block = data.getFigcaption();
            isStart = this.caret.isStart(block);

            var $component = $R.dom(block).closest('.redactor-component');
            if (isStart && $component.length !== 0)
            {
                e.preventDefault();
                this.caret.setEnd($component);
                return true;
            }
        }
        // exit table
        else if (data.isTable() && isStart)
        {
            e.preventDefault();
            this.caret.setEnd(block.previousElementSibling);
            return true;
        }
        // component
        else if (!data.isComponentEditable() && data.isComponent() && !data.isComponentType('variable'))
        {
            var component = data.getComponent();
            if (!component.previousElementSibling)
            {
                e.preventDefault();
                this.component.clearActive();

                return this._exitPrevElement(e, data.getComponent());
            }
            else if (component.previousElementSibling)
            {
                e.preventDefault();
                this.component.clearActive();
                this.caret.setEnd(component.previousElementSibling);
                return true;
            }
        }
    },
    _isExitOnDownRight: function(e)
    {
        var $editor = this.editor.getElement();
        var current = this.selection.getCurrent();
        var data = this.inspector.parse(current);
        var isEndEditor = this.caret.isEnd();
        var block, isEnd;

        // table
        if (data.isTable())
        {
            if (isEnd || isEndEditor)
            {
                return this._exitNextElement(e, data.getComponent());
            }
        }
        // figcaption
        else if (data.isFigcaption())
        {
            block = data.getFigcaption();
            isEnd = this.caret.isEnd(block);

            if (isEnd || isEndEditor)
            {
                return this._exitNextElement(e, data.getComponent());
            }
        }
        // figure/code
        else if (data.isComponentType('code'))
        {
            var component = data.getComponent();
            var pre = $R.dom(data.getComponentCodeElement()).closest('pre');

            isEnd = this.caret.isEnd(block);

            var isNext = (pre && pre.get().nextElementSibling);
            if (isEnd && !isNext)
            {
                return this._exitNextElement(e, component);
            }
        }
        // pre & blockquote & dl
        else if (data.isPre() || data.isBlockquote() || data.isDl())
        {
            if (isEndEditor)
            {
                if (data.isPre()) return this._exitNextElement(e, data.getPre());
                else if (data.isBlockquote()) return this._exitNextElement(e, data.getBlockquote());
                else if (data.isDl()) return this._exitNextElement(e, data.getDl());
            }
        }
        // li
        else if (data.isList())
        {
            var $list = $R.dom(current).parents('ul, ol', $editor).last();
            isEnd = this.caret.isEnd($list);

            if (isEnd || isEndEditor)
            {
                return this._exitNextElement(e, $list.get());
            }
        }
        // component
        else if (data.isComponent() && !data.isComponentType('variable') && data.getTag() !== 'span')
        {
            this.component.clearActive();
            return this._exitNextElement(e, data.getComponent());
        }
    },
    _exitPrevElement: function(e, node)
    {
        e.preventDefault();

        if (node.previousElementSibling) this.caret.setEnd(node.previousElementSibling);
        else this.utils.createMarkupBefore(node);

        return true;
    },
    _exitNextElement: function(e, node)
    {
        e.preventDefault();

        if (node.nextElementSibling) this.caret.setStart(node.nextElementSibling);
        else this.utils.createMarkup(node);

        return true;
    },
    _selectComponent: function(e, caret, type)
    {
        var current = this.selection.getCurrent();
        var block = this.selection.getBlock(current);
        var sibling = this.utils.findSiblings(current, type);
        var siblingBlock = this.utils.findSiblings(block, type);

        if (sibling && this.caret['is' + caret](current))
        {
            this._selectComponentItem(e, sibling, caret);
        }
        else if (siblingBlock && this.caret['is' + caret](block))
        {
            this._selectComponentItem(e, siblingBlock, caret);
        }
    },
    _selectComponentItem: function(e, item, caret)
    {
        if (this.component.isNonEditable(item))
        {
            e.preventDefault();
            this.caret['set' + caret](item);
            return true;
        }
    }
});
$R.add('class', 'input.delete', {
    init: function(app, e, key)
    {
        this.app = app;
        this.opts = app.opts;
        this.caret = app.caret;
        this.utils = app.utils;
        this.editor = app.editor;
        this.marker = app.marker;
        this.keycodes = app.keycodes;
        this.component = app.component;
        this.inspector = app.inspector;
        this.selection = app.selection;
        this.insertion = app.insertion;

        // local
        this.key = key;

        // init
        this._init(e);
    },
    // private
    _init: function(e)
    {
        if (this._removeActiveComponent(e)) return;
        if (this._removeAllSelectedTable(e)) return;

        // is empty
        if (this.key === this.keycodes.BACKSPACE)
        {
            var $editor = this.editor.getElement();
            var html = this.utils.trimSpaces($editor.html());

            if (html === this.opts.emptyHtml)
            {
                e.preventDefault();
                return;
            }
        }

        // variable or non editable prev/next or selection
        if (this._detectVariableOrNonEditable() || this.selection.hasNonEditable())
        {
            e.preventDefault();
            return;
        }

        // all selected
        if (this.selection.isAll())
        {
            e.preventDefault();
            this.insertion.set(this.opts.emptyHtml);
            return;
        }

        // collapsed
        if (this.selection.isCollapsed())
        {
            // next / prev
            if (this.key === this.keycodes.BACKSPACE) this._traverseBackspace(e);
            else if (this.key === this.keycodes.DELETE) this._traverseDelete(e);
        }

        if (this.key === this.keycodes.BACKSPACE) this.utils.trimInvisibleChars('left');

        this._removeUnwantedStyles();
        this._removeEmptySpans();
        this._removeSpanTagsInHeadings();
        this._removeInlineTagsInPre();
    },
    _detectVariableOrNonEditable: function()
    {
        var block = this.selection.getBlock();
        var isBlockStart = this.caret.isStart(block);
        var isBlockEnd = this.caret.isEnd(block);
        var el;

        // backspace
        if (this.key === this.keycodes.BACKSPACE && isBlockStart)
        {
            el = block.previousSibling;
            if (this._isNonEditable(el)) return true;
        }
        // delete
        else if (this.key === this.keycodes.DELETE && isBlockEnd)
        {
            el = block.nextSibling;
            if (this._isNonEditable(el)) return true;
        }

        var current = this.selection.getCurrent();
        var isCurrentStart = this.caret.isStart(current);
        var isCurrentEnd = this.caret.isEnd(current);
        var isCurrentStartSpace = (this.selection.getTextBeforeCaret().trim() === '');
        var isCurrentEndSpace = (this.selection.getTextAfterCaret().trim() === '');

        // backspace
        if (this.key === this.keycodes.BACKSPACE && isCurrentStart && !isCurrentStartSpace)
        {
            el = current.previousSibling;
            if (this._isVariable(el))
            {
                this.caret.setEnd(el);
                return true;
            }
            else if (this._isNonEditable(el)) return true;
        }
        // delete
        else if (this.key === this.keycodes.DELETE && isCurrentEnd && !isCurrentEndSpace)
        {
            el = current.nextSibling;
            if (this._isVariable(el))
            {
                this.caret.setStart(el);
                return true;
            }
            else if (this._isNonEditable(el)) return true;
        }
    },
    _isVariable: function(node)
    {
        return ($R.dom(node).closest('[data-redactor-type="variable"]').length !== 0);
    },
    _isNonEditable: function(node)
    {
        return ($R.dom(node).closest('.non-editable').length !== 0);
    },
    _getBlock: function()
    {
        var $editor = this.editor.getElement();
        var block = this.selection.getBlock();
        var data = this.inspector.parse(block);

        block = (data.isList()) ? $R.dom(block).parents('ul, ol', $editor).last().get() : block;
        block = (data.isDl()) ? data.getDl() : block;
        block = (data.isTable()) ? data.getTable() : block;

        return block;
    },
    _traverseDelete: function(e)
    {
        var current = this.selection.getCurrent();
        var data = this.inspector.parse(current);
        var block, isEnd, $next;

        // figcaption
        if (data.isFigcaption())
        {
            block = data.getFigcaption();
            isEnd = this.caret.isEnd(block);

            if (isEnd)
            {
                e.preventDefault();
                return;
            }
        }
        // figure/code
        else if (data.isComponentType('code'))
        {
            block = data.getComponent();
            isEnd = this.caret.isEnd(block);

            if (isEnd)
            {
                e.preventDefault();
                return;
            }
        }

        // next
        block = this._getBlock();
        var next = this.utils.findSiblings(block, 'next');
        if (!next) return;

        isEnd = this.caret.isEnd(block);
        var dataNext = this.inspector.parse(next);
        var isNextBlock = (next.tagName === 'P' || next.tagName === 'DIV');

        // figure/code or table
        if (isEnd && dataNext.isComponentEditable())
        {
            e.preventDefault();
            this.component.remove(next, false);
            return;
        }
        // component
        else if (isEnd && dataNext.isComponent())
        {
            e.preventDefault();

            // select component
            this.caret.setStart(next);

            // remove current if empty
            if (this.utils.isEmptyHtml(block.innerHTML))
            {
                $R.dom(block).remove();
            }

            return;
        }
        // combine list
        else if (isEnd && dataNext.isList())
        {
            var $currentList = $R.dom(block);
            $next = $R.dom(next);

            // current list
            if (data.isList())
            {
                e.preventDefault();

                $currentList.append($next);
                $next.unwrap();

                return;
            }
            else
            {
                var $first = $next.children('li').first();
                var $lists = $first.find('ul, ol');

                if ($lists.length !== 0)
                {
                    e.preventDefault();

                    $next.prepend($lists);
                    $lists.unwrap();

                    $currentList.append($first);
                    $first.unwrap();

                    return;
                }
            }
        }
        // block
        else if (isEnd && !data.isList() && !data.isTable() && isNextBlock && !this.utils.isEmptyHtml(block.innerHTML))
        {
            e.preventDefault();

            var $current = $R.dom(block);
            $next = $R.dom(next);

            $current.append($next);
            $next.unwrap();

            return;
        }
    },
    _traverseBackspace: function(e)
    {
        var current = this.selection.getCurrent();
        var data = this.inspector.parse(current);
        var block, isStart, $prev, $currentList;

        // figcaption
        if (data.isFigcaption())
        {
            block = data.getFigcaption();
            isStart = this.caret.isStart(block);

            if (isStart)
            {
                e.preventDefault();
                return;
            }
        }
        // figure/code
        else if (data.isComponentType('code'))
        {
            block = data.getComponent();
            isStart = this.caret.isStart(block);

            if (isStart && block.previousElementSibling)
            {
                e.preventDefault();
                this.caret.setEnd(block.previousElementSibling);
                return true;
            }
        }

        // prev
        block = this._getBlock();
        var prev = this.utils.findSiblings(block, 'prev');

        if (!prev)
        {
            setTimeout(this._replaceBlock.bind(this), 1);
            return;
        }

        isStart = this.caret.isStart(block);
        var dataPrev = this.inspector.parse(prev);
        var isPrevBlock = (prev.tagName === 'P' || prev.tagName === 'DIV');

        // figure/code or table
        if (isStart && dataPrev.isComponentEditable())
        {
            e.preventDefault();
            this.component.remove(prev, false);
            return;
        }
        // component
        else if (isStart && dataPrev.isComponent())
        {
            e.preventDefault();

            // select component
            this.caret.setStart(prev);

            // remove current if empty
            if (this.utils.isEmptyHtml(block.innerHTML))
            {
                $R.dom(block).remove();
            }

            return;
        }
        // lists
        else if (isStart && data.isList())
        {
            e.preventDefault();

            $currentList = $R.dom(block);
            $prev = $R.dom(prev);

            if (dataPrev.isList())
            {
                $currentList.children('li').first().prepend(this.marker.build('start'));
                $prev.append($currentList);
                $currentList.unwrap();

                this.selection.restoreMarkers();
            }
            else
            {
                var $first = $currentList.children('li').first();
                var first = $first.get();
                var $lists = $first.find('ul, ol');

                var $newnode = this.utils.replaceToTag(first, this.opts.markup);
                if (this.opts.breakline) $newnode.attr('data-redactor-tag', 'br');
                $currentList.before($newnode);
                this.caret.setStart($newnode);

                if ($lists.length !== 0)
                {
                    $currentList.prepend($lists);
                    $lists.unwrap();
                }
            }

            return;
        }
        // block
        else if (isStart && isPrevBlock)
        {
            e.preventDefault();

            var textNode = this.utils.createInvisibleChar();
            var $current = $R.dom(block);
            $prev = $R.dom(prev);

            this.caret.setEnd($prev);

            $current.prepend(textNode);
            $prev.append($current.contents());
            $current.remove();

            return;
        }
    },
    _replaceBlock: function()
    {
        var block = this.selection.getBlock();
        var $block = $R.dom(block);

        if (this.opts.markup === 'p' && block && this._isNeedToReplaceBlock(block))
        {
            var markup = document.createElement(this.opts.markup);

            $block.replaceWith(markup);
            this.caret.setStart(markup);
        }

        if (this.opts.breakline && block && block.tagName === 'DIV')
        {
            $block.attr('data-redactor-tag', 'br');
        }
    },
    _isNeedToReplaceBlock: function(block)
    {
        return (block.tagName === 'DIV' && this.utils.isEmptyHtml(block.innerHTML));
    },
    _removeActiveComponent: function(e)
    {
        var current = this.selection.getCurrent();
        var data = this.inspector.parse(current);
        var component = data.getComponent();
        if (data.isComponent() && this.component.isActive(component))
        {
            e.preventDefault();
            this.component.remove(component);
            return true;
        }
    },
    _removeAllSelectedTable: function(e)
    {
        var current = this.selection.getCurrent();
        var data = this.inspector.parse(current);
        var table = data.getTable();
        if (table && this.selection.isAll(table))
        {
            e.preventDefault();
            this.component.remove(table);
            return true;
        }
    },
    _removeUnwantedStyles: function()
    {
        var $editor = this.editor.getElement();

        setTimeout(function()
        {
            var $tags = $editor.find('*[style]');
            $tags.not('img, figure, iframe, [data-redactor-style-cache], [data-redactor-span]').removeAttr('style');

        }, 0);
    },
    _removeEmptySpans: function()
    {
        var $editor = this.editor.getElement();

        setTimeout(function()
        {
            $editor.find('span').each(function(node)
            {
                if (node.attributes.length === 0)
                {
                    $R.dom(node).replaceWith(node.childNodes);
                }
            });

        }, 0);
    },
    _removeSpanTagsInHeadings: function()
    {
        var $editor = this.editor.getElement();

        setTimeout(function()
        {
            $editor.find('h1, h2, h3, h4, h5, h6').each(function(node)
            {
                var $node = $R.dom(node);
                if ($node.closest('figure').length === 0)
                {
                    $node.find('span').not('.redactor-component, .non-editable, .redactor-selection-marker, [data-redactor-style-cache], [data-redactor-span]').unwrap();
                }
            });

        }, 1);
    },
    _removeInlineTagsInPre: function()
    {
        var $editor = this.editor.getElement();
        var tags = this.opts.inlineTags;

        setTimeout(function()
        {
            $editor.find('pre').each(function(node)
            {
                var $node = $R.dom(node);
                if ($node.closest('figure').length === 0)
                {
                    $node.find(tags.join(',')).not('code, .redactor-selection-marker').unwrap();
                }
            });

        }, 1);
    }
});
$R.add('class', 'input.enter', {
    init: function(app, e)
    {
        this.app = app;
        this.opts = app.opts;
        this.utils = app.utils;
        this.caret = app.caret;
        this.editor = app.editor;
        this.insertion = app.insertion;
        this.selection = app.selection;
        this.inspector = app.inspector;

        // init
        this._init(e);
    },
    // private
    _init: function(e)
    {
        // turn off
        if (!this.opts.enterKey) return this._disable(e);

        // callback
        var stop = this.app.broadcast('enter', e);
        if (stop === false) return e.preventDefault();

        // has non-editable
        if (this.selection.hasNonEditable())
        {
            e.preventDefault();
            return;
        }

        // shift enter
        if (e.ctrlKey || e.shiftKey) return this._insertBreak(e);

        // enter & exit
        if (this._isExit(e)) return;

        // traverse
        this._traverse(e);
    },
    _disable: function(e)
    {
        e.preventDefault();
        var range = this.selection.getRange();
        if (range && !range.collapsed) range.deleteContents();
    },
    _insertBreak: function(e)
    {
        e.preventDefault();

        var current = this.selection.getCurrent();
        var data = this.inspector.parse(current);

        if ((data.isComponent() && !data.isComponentEditable()) || data.isCode()) return;
        else if (data.isPre()) this.insertion.insertNewline();
        else this.insertion.insertBreakLine();
    },
    _isExit: function(e)
    {
        var $editor = this.editor.getElement();
        var block = this.selection.getBlock();
        var data = this.inspector.parse(block);
        var isEnd = this.caret.isEnd(block);
        var current = this.selection.getCurrent();
        var prev = current.previousSibling;

        // blockquote
        if (data.isBlockquote())
        {
            var isParagraphExit = (isEnd && this._isExitableBlock(block, 'P'));
            var isBreaklineExit = (isEnd && this._isExitableDblBreak(prev));

            if (isParagraphExit || isBreaklineExit)
            {
                return this._exitFromElement(e, ((isBreaklineExit) ? prev : block), data.getBlockquote());
            }
        }
        // pre
        else if (!data.isComponentType('code') && data.isPre())
        {
            if (isEnd)
            {
                var html = block.innerHTML;
                html = this.utils.removeInvisibleChars(html);
                if (html.match(/(\n\n\n)$/) !== null)
                {
                    $R.dom(prev.previousSibling.previousSibling).remove();
                    return this._exitFromElement(e, prev, block);
                }
            }
        }
        // dl
        else if (data.isDl())
        {
            if (isEnd && this._isExitableBlock(block, 'DT'))
            {
                return this._exitFromElement(e, block, data.getDl());
            }
        }
        // li
        else if (data.isList())
        {
            var list = $R.dom(current).parents('ul, ol', $editor).last();

            isEnd = this.caret.isEnd(list);
            if (isEnd && this._isExitableBlock(block, 'LI'))
            {
                return this._exitFromElement(e, block, list);
            }
        }
        else if (data.isComponent() && data.isComponentActive() && !data.isFigcaption() && !data.isComponentEditable())
        {
            return this._exitFromElement(e, false, data.getComponent());
        }
    },
    _isExitableDblBreak: function(prev)
    {
        var next = (prev) ? prev.nextSibling : false;
        if (next)
        {
            var text = this.utils.removeInvisibleChars(next.textContent);

            return (next.nodeType === 3 && text.trim() === '');
        }
    },
    _isExitableBlock: function(block, tag)
    {
        return (block && block.tagName === tag && this.utils.isEmptyHtml(block.innerHTML));
    },
    _exitFromElement: function(e, prev, el)
    {
        e.preventDefault();
        if (prev) $R.dom(prev).remove();
        this.utils.createMarkup(el);

        return true;
    },
    _exitNextElement: function(e, node)
    {
        e.preventDefault();

        if (node.nextSibling) this.caret.setStart(node.nextSibling);
        else this.utils.createMarkup(node);

        return true;
    },
    _traverse: function(e)
    {
        var current = this.selection.getCurrent();
        var isText = this.selection.isText();
        var block = this.selection.getBlock();
        var data = this.inspector.parse(current);
        var blockTag = (block) ? block.tagName.toLowerCase() : false;

        // pre
        if (data.isPre())
        {
            e.preventDefault();
            return this.insertion.insertNewline();
        }
        // blockquote
        else if (data.isBlockquote())
        {
            block = this.selection.getBlock(current);
            if (block && block.tagName === 'BLOCKQUOTE')
            {
                e.preventDefault();
                return this.insertion.insertBreakLine();
            }
        }
        // figcaption
        else if (data.isFigcaption())
        {
            block = data.getFigcaption();
            var isEnd = this.caret.isEnd(block);
            var isEndEditor = this.caret.isEnd();
            if (isEnd || isEndEditor)
            {
                return this._exitNextElement(e, data.getComponent());
            }
            else
            {
                e.preventDefault();
                return;
            }
        }
        // dl
        else if (data.isDl())
        {
            e.preventDefault();
            return this._traverseDl(current);
        }
        // text
        else if (isText || (this.opts.breakline && blockTag === 'div'))
        {
            e.preventDefault();
            return this.insertion.insertBreakLine();
        }
        // div / p
        else
        {
            setTimeout(this._replaceBlock.bind(this), 1);
            return;
        }
    },
    _traverseDl: function(current)
    {
        var block = this.selection.getBlock(current);
        var data = this.inspector.parse(block);
        var tag = data.getTag();
        var $el = $R.dom(block);
        var next = $el.get().nextSibling || false;
        var $next = $R.dom(next);
        var nextDd = (next && $next.is('dd'));
        var nextDt = (next && $next.is('dt'));
        var isEnd = this.caret.isEnd(block);

        if (tag === 'dt' && !nextDd && isEnd)
        {
            var dd = document.createElement('dd');
            $el.after(dd);

            this.caret.setStart(dd);
            return;
        }
        else if (tag === 'dd' && !nextDt && isEnd)
        {
            var dt = document.createElement('dt');
            $el.after(dt);

            this.caret.setStart(dt);
            return;
        }

        return this.insertion.insertBreakLine();
    },
    _replaceBlock: function()
    {
        var block = this.selection.getBlock();
        var $block = $R.dom(block);

        if (this.opts.markup === 'p' && block && this._isNeedToReplaceBlock(block))
        {
            var markup = document.createElement(this.opts.markup);

            $block.replaceWith(markup);
            this.caret.setStart(markup);
        }
        else
        {
            if (block)
            {
                if (this.utils.isEmptyHtml(block.innerHTML))
                {
                    this._clearBlock($block, block);
                }
                else
                {
                    var first = this.utils.getFirstNode(block);
                    if (first && first.tagName === 'BR')
                    {
                        $R.dom(first).remove();
                        this.caret.setStart(block);
                    }
                }
            }
        }

        if (block && this._isNeedToCleanBlockStyle(block) && this.opts.cleanOnEnter)
        {
            $block.removeAttr('class style');
        }

        if (this.opts.breakline && block && block.tagName === 'DIV')
        {
            $block.attr('data-redactor-tag', 'br');
        }
    },
    _clearBlock: function($block, block)
    {
        if (this.opts.cleanInlineOnEnter || block.innerHTML === '<br>')
        {
            $block.html('');
        }

        this.caret.setStart(block);
    },
    _isNeedToReplaceBlock: function(block)
    {
        return (block.tagName === 'DIV' && this.utils.isEmptyHtml(block.innerHTML));
    },
    _isNeedToCleanBlockStyle: function(block)
    {
        return (block.tagName === 'P' && this.utils.isEmptyHtml(block.innerHTML));
    }
});
$R.add('class', 'input.paste', {
    init: function(app, e, dataTransfer, html, point)
    {
        this.app = app;
        this.opts = app.opts;
        this.editor = app.editor;
        this.cleaner = app.cleaner;
        this.container = app.container;
        this.inspector = app.inspector;
        this.insertion = app.insertion;
        this.selection = app.selection;
        this.autoparser = app.autoparser;

        // local
        this.pasteHtml = html;
        this.pointInserted = point;
        this.dataTransfer = dataTransfer;

        // init
        this._init(e);
    },
    // private
    _init: function(e)
    {
        var clipboard = this.dataTransfer || e.clipboardData;
        var current = this.selection.getCurrent();
        var dataCurrent = this.inspector.parse(current);

        this.dropPasted = this.dataTransfer;
        this.isRawCode = (dataCurrent.isPre() || dataCurrent.isCode());

        this.editor.enablePasting();
        this.editor.saveScroll();

        if (!this.dropPasted)
        {
            this.selection.saveMarkers();
        }

        if (this.isRawCode || !clipboard)
        {
            var text;
            if (!this.isRawCode && !clipboard && window.clipboardData)
            {
                text = window.clipboardData.getData("text");
            }
            else
            {
                text = clipboard.getData("text/plain");
            }

            e.preventDefault();
            this._insert(e, text);
            return;
        }
        else if (this.pasteHtml)
        {
            e.preventDefault();
            this._insert(e, this.pasteHtml);
        }
        else
        {
            // html / text
            var url = clipboard.getData('URL');
            var html = (this._isPlainText(clipboard)) ? clipboard.getData("text/plain") : clipboard.getData("text/html");

            // safari anchor links
            html = (!url || url === '') ? html : url;

            // file
            if (clipboard.files !== null && clipboard.files.length > 0 && html === '')
            {
                var files = [];
                for (var i = 0; i < clipboard.files.length; i++)
                {
                    var file = clipboard.files[i] || clipboard.items[i].getAsFile();
                    if (file) files.push(file);
                }

                if (files.length > 0)
                {
                    e.preventDefault();
                    this._insertFiles(e, files);
                    return;
                }
            }


            e.preventDefault();
            this._insert(e, html);
        }
    },
    _isPlainText: function(clipboard)
    {
        var text = clipboard.getData("text/plain");
        var html = clipboard.getData("text/html");

        if (text && html)
        {
            var element = document.createElement("div");
            element.innerHTML = html;

            if (element.textContent === text)
            {
                return !element.querySelector(":not(meta)");
            }
        }
        else
        {
            return (text !== null);
        }
    },
    _restoreSelection: function()
    {
        this.editor.restoreScroll();
        this.editor.disablePasting();
        if (!this.dropPasted)
        {
            this.selection.restoreMarkers();
        }
    },
    _insert: function(e, html)
    {
        // pasteBefore callback
        var returned = this.app.broadcast('pasteBefore', html);
        html = (returned === undefined) ? html : returned;

        // clean
        html = html.trim();
        html = (this.isRawCode) ? html : this.cleaner.paste(html);
        html = (this.isRawCode) ? this.cleaner.encodePhpCode(html) : html;

        // paste callback
        returned = this.app.broadcast('pasting', html);
        html = (returned === undefined) ? html : returned;

        this._restoreSelection();

        // stop input
        if (!this.opts.input) return;

        // autoparse
        if (this.opts.autoparse && this.opts.autoparsePaste)
        {
            html = this.autoparser.parse(html);
        }

        var nodes = (this.dropPasted) ? this.insertion.insertToPoint(e, html, this.pointInserted) : this.insertion.insertHtml(html);

        // pasted callback
        this.app.broadcast('pasted', nodes);
        this.app.broadcast('autoparseobserve');
    },
    _insertFiles: function(e, files)
    {
        this._restoreSelection();

        // drop or clipboard
        var isImage = (this.opts.imageTypes.indexOf(files[0].type) !== -1);
        var isClipboard = (typeof this.dropPasted === 'undefined');

        if (isImage) this.app.broadcast('dropimage', e, files, isClipboard);
        else this.app.broadcast('dropfile', e, files, isClipboard);
    }
});
$R.add('class', 'input.shortcode', {
    init: function(app, e, key)
    {
        this.app = app;
        this.opts = app.opts;
        this.utils = app.utils;
        this.marker = app.marker;
        this.keycodes = app.keycodes;
        this.selection = app.selection;

        // local
        this.worked = false;

        // init
        if (key === this.keycodes.SPACE) this._init();
    },
    // public
    is: function()
    {
        return this.worked;
    },
    // private
    _init: function()
    {
        var current = this.selection.getCurrent();
        if (current && current.nodeType === 3)
        {
            var text = this.utils.removeInvisibleChars(current.textContent);
            var shortcodes = this.opts.shortcodes;
            for (var name in shortcodes)
            {
                var re = new RegExp('^' + this.utils.escapeRegExp(name));
                var match = text.match(re);
                if (match !== null)
                {
                    if (typeof shortcodes[name].format !== 'undefined')
                    {
                        return this._format(shortcodes[name].format, current, re);
                    }
                }
            }
        }
    },
    _format: function(tag, current, re)
    {
        var marker = this.marker.insert('start');
        current = marker.previousSibling;

        var text = current.textContent;
        text = this.utils.trimSpaces(text);
        text = text.replace(re, '');
        current.textContent = text;

        var api = (tag === 'ul' || tag === 'ol') ? 'module.list.toggle' : 'module.block.format';

        this.app.api(api, tag);
        this.selection.restoreMarkers();

        this.worked = true;
    }
});
$R.add('class', 'input.shortcut', {
    init: function(app, e)
    {
        this.app = app;
        this.opts = app.opts;

        // local
        this.worked = false;

        // based on https://github.com/jeresig/jquery.hotkeys
        this.hotkeys = {
            8: "backspace", 9: "tab", 10: "return", 13: "return", 16: "shift", 17: "ctrl", 18: "alt", 19: "pause",
            20: "capslock", 27: "esc", 32: "space", 33: "pageup", 34: "pagedown", 35: "end", 36: "home",
            37: "left", 38: "up", 39: "right", 40: "down", 45: "insert", 46: "del", 59: ";", 61: "=",
            96: "0", 97: "1", 98: "2", 99: "3", 100: "4", 101: "5", 102: "6", 103: "7",
            104: "8", 105: "9", 106: "*", 107: "+", 109: "-", 110: ".", 111 : "/",
            112: "f1", 113: "f2", 114: "f3", 115: "f4", 116: "f5", 117: "f6", 118: "f7", 119: "f8",
            120: "f9", 121: "f10", 122: "f11", 123: "f12", 144: "numlock", 145: "scroll", 173: "-", 186: ";", 187: "=",
            188: ",", 189: "-", 190: ".", 191: "/", 192: "`", 219: "[", 220: "\\", 221: "]", 222: "'"
        };

        this.hotkeysShiftNums = {
            "`": "~", "1": "!", "2": "@", "3": "#", "4": "$", "5": "%", "6": "^", "7": "&",
            "8": "*", "9": "(", "0": ")", "-": "_", "=": "+", ";": ": ", "'": "\"", ",": "<",
            ".": ">",  "/": "?",  "\\": "|"
        };

        // init
        this._init(e);
    },
    // public
    is: function()
    {
        return this.worked;
    },
    // private
    _init: function(e)
    {
        // disable browser's hot keys for bold and italic if shortcuts off
        if (this.opts.shortcuts === false)
        {
            if ((e.ctrlKey || e.metaKey) && (e.which === 66 || e.which === 73)) e.preventDefault();
            return;
        }

        // build
        for (var key in this.opts.shortcuts)
        {
            this._build(e, key, this.opts.shortcuts[key]);
        }
    },
    _build: function(e, str, command)
    {
        var keys = str.split(',');
        var len = keys.length;
        for (var i = 0; i < len; i++)
        {
            if (typeof keys[i] === 'string')
            {
                this._handler(e, keys[i].trim(), command);
            }
        }
    },
    _handler: function(e, keys, command)
    {
        keys = keys.toLowerCase().split(" ");

        var special = this.hotkeys[e.keyCode];
        var character = String.fromCharCode(e.which).toLowerCase();
        var modif = "", possible = {};
        var cmdKeys = ["meta", "ctrl", "alt", "shift"];

        for (var i = 0; i < cmdKeys.length; i++)
        {
            var specialKey = cmdKeys[i];
            if (e[specialKey + 'Key'] && special !== specialKey)
            {
                modif += specialKey + '+';
            }
        }

        if (special) possible[modif + special] = true;
        if (character)
        {
            possible[modif + character] = true;
            possible[modif + this.hotkeysShiftNums[character]] = true;

            // "$" can be triggered as "Shift+4" or "Shift+$" or just "$"
            if (modif === "shift+")
            {
                possible[this.hotkeysShiftNums[character]] = true;
            }
        }

        var len = keys.length;
        for (var i = 0; i < len; i++)
        {
            if (possible[keys[i]])
            {

                e.preventDefault();
                this.worked = true;

                if (command.message)
                {
                    this.app.broadcast(command.message, command.args);
                    this.app.broadcast('buffer.trigger');
                }
                else if (command.api)
                {
                    this.app.api(command.api, command.args);
                    this.app.broadcast('buffer.trigger');
                }

                return;
            }
        }
    }
});
$R.add('class', 'input.space', {
    init: function(app, e, key, lastShiftKey)
    {
        this.app = app;
        this.keycodes = app.keycodes;
        this.insertion = app.insertion;
        this.selection = app.selection;

        // local
        this.key = key;
        this.lastShiftKey = lastShiftKey;

        // init
        this._init(e);
    },
    // private
    _init: function(e)
    {
        // has non-editable
        if (this.selection.hasNonEditable())
        {
            e.preventDefault();
            return;
        }

        // shift/ctrl + space
        if (!this.lastShiftKey && this.key === this.keycodes.SPACE && (e.ctrlKey || e.shiftKey) && !e.metaKey)
        {
            e.preventDefault();
            this.insertion.insertChar('&nbsp;');
            return;
        }
    }
});
$R.add('class', 'input.tab', {
    init: function(app, e)
    {
        this.app = app;
        this.opts = app.opts;
        this.inspector = app.inspector;
        this.insertion = app.insertion;
        this.selection = app.selection;

        // init
        this._init(e);
    },
    // private
    _init: function(e)
    {
        // turn off tab
        if (!this.opts.tabKey) return;

        // callback
        var stop = this.app.broadcast('tab', e);
        if (stop === false) return e.preventDefault();

        // traverse
        this._traverse(e);
    },
    _traverse: function(e)
    {
        var current = this.selection.getCurrent();
        var data = this.inspector.parse(current);

        // hard tab
        if (!data.isComponent() && e.shiftKey)
        {
            return this._insertHardTab(e, 4);
        }

        // list
        if (data.isList())
        {
            e.preventDefault();
            return this.app.api('module.list.indent');
        }
        // pre
        if (data.isPre() || (data.isComponentType('code') && !data.isFigcaption()))
        {
            return this._tabCode(e);
        }

        // tab as spaces
        if (this.opts.tabAsSpaces !== false)
        {
            return this._insertHardTab(e, this.opts.tabAsSpaces);
        }
    },
    _insertHardTab: function(e, num)
    {
        e.preventDefault();
        var node = document.createTextNode(Array(num + 1).join('\u00a0'));
        return this.insertion.insertNode(node, 'end');
    },
    _tabCode: function(e)
    {
        e.preventDefault();

        var node = (this.opts.preSpaces) ? document.createTextNode(Array(this.opts.preSpaces + 1).join('\u00a0')) : document.createTextNode('\t');

        return this.insertion.insertNode(node, 'end');
    }
});
$R.add('module', 'upload', {
    init: function(app)
    {
        this.app = app;
        this.opts = app.opts;
        this.lang = app.lang;
        this.utils = app.utils;
        this.editor = app.editor;
        this.progress = app.progress;

        // local
        this.defaults = {
            event: false,
            element: false,
            name: false,
            files: false,
            url: false,
            data: false,
            paramName: false
        };
    },
    // public
    build: function(options)
    {
        this.p = $R.extend(this.defaults, options);
        this.$el = $R.dom(this.p.element);

        if (this.$el.get().tagName === 'INPUT') this._buildInput();
        else                                    this._buildBox();
    },
    send: function(options)
    {
        this.p = $R.extend(this.defaults, options);
        this.$uploadbox = this.editor.getElement();
        this._send(this.p.event, this.p.files);
    },
    complete: function(response, e)
    {
        this._complete(response, e);
    },

    // private
    _buildInput: function()
    {
        this.box = false;
        this.prefix = '';

        this.$uploadbox = $R.dom('<div class="upload-redactor-box" />');

        this.$el.hide();
        this.$el.after(this.$uploadbox);

        if (this.opts.multipleUpload) this.$el.attr('multiple', 'multiple');
        else this.$el.removeAttr('multiple');

        if (this.p.name !== 'file')
        {
            this.$el.attr('accept', 'image/*');
        }

        this._buildPlaceholder();
        this._buildEvents();
    },
    _buildBox: function()
    {
        this.box = true;
        this.prefix = 'box-';

        this.$uploadbox = this.$el;
        this.$uploadbox.attr('ondragstart', 'return false;');

        // events
        this.$uploadbox.on('drop.redactor.upload', this._onDropBox.bind(this));
        this.$uploadbox.on('dragover.redactor.upload', this._onDragOver.bind(this));
        this.$uploadbox.on('dragleave.redactor.upload', this._onDragLeave.bind(this));
    },
    _buildPlaceholder: function()
    {
        this.$placeholder = $R.dom('<div class="upload-redactor-placeholder" />');
        this.$placeholder.html(this.lang.get('upload-label'));
        this.$uploadbox.append(this.$placeholder);
    },
    _buildEvents: function()
    {
        this.$el.on('change.redactor.upload', this._onChange.bind(this));
        this.$uploadbox.on('click.redactor.upload', this._onClick.bind(this));
        this.$uploadbox.on('drop.redactor.upload', this._onDrop.bind(this));
        this.$uploadbox.on('dragover.redactor.upload', this._onDragOver.bind(this));
        this.$uploadbox.on('dragleave.redactor.upload', this._onDragLeave.bind(this));
    },
    _onClick: function(e)
    {
        e.preventDefault();
        this.$el.click();
    },
    _onChange: function(e)
    {
        this._send(e, this.$el.get().files);
    },
    _onDrop: function(e)
    {
        e.preventDefault();

        this._clear();
        this._setStatusDrop();
        this._send(e);
    },
    _onDragOver: function(e)
    {
        e.preventDefault();
        this._setStatusHover();

        return false;
    },
    _onDragLeave: function(e)
    {
        e.preventDefault();
        this._removeStatusHover();

        return false;
    },
    _onDropBox: function(e)
    {
        e.preventDefault();

        this._clear();
        this._setStatusDrop();
        this._send(e);
    },
    _removeStatusHover: function()
    {
        this.$uploadbox.removeClass('upload-redactor-' + this.prefix + 'hover');
    },
    _setStatusDrop: function()
    {
        this.$uploadbox.addClass('upload-redactor-' + this.prefix + 'drop');
    },
    _setStatusHover: function()
    {
        this.$uploadbox.addClass('upload-redactor-' + this.prefix + 'hover');
    },
    _setStatusError: function()
    {
        this.$uploadbox.addClass('upload-redactor-' + this.prefix + 'error');
    },
    _setStatusSuccess: function()
    {
        this.$uploadbox.addClass('upload-redactor-' + this.prefix + 'success');
    },
    _clear: function()
    {
        var classes = ['drop', 'hover', 'error', 'success'];
        for (var i = 0; i < classes.length; i++)
        {
            this.$uploadbox.removeClass('upload-redactor-' + this.prefix + classes[i]);
        }

        this.$uploadbox.removeAttr('ondragstart');
    },
    _send: function(e, files)
    {
        e = e.originalEvent || e;

        files = (files) ? files : e.dataTransfer.files;

        var data = new FormData();
        var name = this._getUploadParam();

        data = this._buildData(name, files, data);
        data = this.utils.extendData(data, this.p.data);

        var stop = this.app.broadcast('upload.start', e, data, files);
        if (stop !== false)
        {
            this._sendData(data, files, e);
        }
    },
    _sendData: function(data, files, e)
    {
        this.progress.show();
        if (typeof this.p.url === 'function')
        {
            var res = this.p.url(data, files, e, this);
            if (!(res instanceof Promise))
            {
                this._complete(res, e);
            }
        }
        else
        {
            $R.ajax.post({
                url: this.p.url,
                data: data,
                before: function(xhr)
                {
                    return this.app.broadcast('upload.beforeSend', xhr);

                }.bind(this),
                success: function(response)
                {
                    this._complete(response, e);
                }.bind(this)
            });
        }
    },
    _getUploadParam: function()
    {
        return (this.p.paramName) ? this.p.paramName : 'file';
    },
    _buildData: function(name, files, data)
    {
        if (files.length === 1)
        {
            data.append(name + '[]', files[0]);
        }
        else if (files.length > 1 && this.opts.multipleUpload !== false)
        {
            for (var i = 0; i < files.length; i++)
            {
                data.append(name + '[]', files[i]);
            }
        }

        return data;
    },
    _complete: function(response, e)
    {
        this._clear();
        this.progress.hide();

        if (response && response.error)
        {
            this._setStatusError();

            this.app.broadcast('upload.' + this.p.name + '.error', response, e);
            this.app.broadcast('upload.error', response);
        }
        else
        {
            this._setStatusSuccess();

            this.app.broadcast('upload.' + this.p.name + '.complete', response, e);
            this.app.broadcast('upload.complete', response);

            setTimeout(this._clear.bind(this), 500);
        }
    }
});
$R.add('class', 'code.component', {
    mixins: ['dom', 'component'],
    init: function(app, el)
    {
        this.app = app;

        // init
        return (el && el.cmnt !== undefined) ? el : this._init(el);
    },

    // private
   _init: function(el)
    {
        var $pre;
        if (typeof el !== 'undefined')
        {
            var $node = $R.dom(el);
            var $wrapper = $node.closest('figure');
            if ($wrapper.length !== 0)
            {
                this.parse($wrapper);
            }
            else
            {
                this.parse('<figure>');
                this.append(el);
            }

            $pre = this.find('pre code, pre').last();
        }
        else
        {
            $pre = $R.dom('<pre>');

            this.parse('<figure>');
            this.append($pre);
        }

        this._initElement($pre);
        this._initWrapper();
    },
    _initElement: function($pre)
    {
        $pre.attr({
            'tabindex': '-1',
            'contenteditable': true
        });
    },
    _initWrapper: function()
    {
        this.addClass('redactor-component');
        this.attr({
            'data-redactor-type': 'code',
            'tabindex': '-1',
            'contenteditable': false
        });
    }
});
$R.add('module', 'form', {
    init: function(app)
    {
        this.app = app;
        this.lang = app.lang;
        this.component = app.component;
        this.inspector = app.inspector;
    },
    // messages
    onform: {
        remove: function(node)
        {
            this._remove(node);
        }
    },
    oncontextbar: function(e, contextbar)
    {
        var data = this.inspector.parse(e.target);
        if (data.isComponentType('form'))
        {
            var node = data.getComponent();
            var buttons = {
                "remove": {
                    title: this.lang.get('delete'),
                    api: 'module.form.remove',
                    args: node
                }
            };

            contextbar.set(e, node, buttons, 'top');
        }

    },

    // private
    _remove: function(node)
    {
        this.component.remove(node);
    }
});
$R.add('class', 'form.component', {
    mixins: ['dom', 'component'],
    init: function(app, el)
    {
        this.app = app;
        this.utils = app.utils;

        // init
        return (el && el.cmnt !== undefined) ? el : this._init(el);
    },
    // private
    _init: function(el)
    {
        if (typeof el !== 'undefined')
        {
            var $node = $R.dom(el);
            var $wrapper = $node.closest('form');
            if ($wrapper.length !== 0)
            {
                var $figure = this.utils.replaceToTag(el, 'figure');
                this.parse($figure);
            }
            else
            {
                this.parse('<figure>');
                this.append(el);
            }
        }
        else
        {
            this.parse('<figure>');
        }

        this._initWrapper();
    },
    _initWrapper: function()
    {
        this.addClass('redactor-component');
        this.attr({
            'data-redactor-type': 'form',
            'tabindex': '-1',
            'contenteditable': false
        });
    }
});
$R.add('module', 'image', {
    modals: {
        'image':
            '<div class="redactor-modal-tab" data-title="## upload ##"><form action=""> \
                <input type="file" name="file"> \
            </form></div>',
        'imageedit':
            '<div class="redactor-modal-group"> \
                <div id="redactor-modal-image-preview" class="redactor-modal-side"></div> \
                <form action="" class="redactor-modal-area"> \
                    <div class="form-item"> \
                        <label for="modal-image-title"> ## title ##</label> \
                        <input type="text" id="modal-image-title" name="title" /> \
                    </div> \
                    <div class="form-item form-item-caption"> \
                        <label for="modal-image-caption">## caption ##</label> \
                        <input type="text" id="modal-image-caption" name="caption" aria-label="## caption ##" /> \
                    </div> \
                    <div class="form-item form-item-align"> \
                        <label>## image-position ##</label> \
                        <select name="align" aria-label="## image-position ##"> \
                            <option value="none">## none ##</option> \
                            <option value="left">## left ##</option> \
                            <option value="center">## center ##</option> \
                            <option value="right">## right ##</option> \
                        </select> \
                    </div> \
                    <div class="form-item form-item-link"> \
                        <label for="modal-image-url">## link ##</label> \
                        <input type="text" id="modal-image-url" name="url" aria-label="## link ##" /> \
                    </div> \
                    <div class="form-item form-item-link"> \
                        <label class="checkbox"><input type="checkbox" name="target" aria-label="## link-in-new-tab ##"> ## link-in-new-tab ##</label> \
                    </div> \
                </form> \
            </div>'
    },
    init: function(app)
    {
        this.app = app;
        this.opts = app.opts;
        this.lang = app.lang;
        this.caret = app.caret;
        this.utils = app.utils;
        this.editor = app.editor;
        this.storage = app.storage;
        this.component = app.component;
        this.inspector = app.inspector;
        this.insertion = app.insertion;
        this.selection = app.selection;

        // local
        this.justResized = false;
    },
    // messages
    oninsert: function()
    {
        this._observeImages();
    },
    onstarted: function()
    {
        // storage observe
        this.storage.observeImages();

        // resize
        if (this.opts.imageResizable)
        {
            this.resizer = $R.create('image.resize', this.app);
        }

        // observe
        this._observeImages();
    },
    ondropimage: function(e, files, clipboard)
    {
        if (!this.opts.imageUpload) return;

        var options = {
            url: this.opts.imageUpload,
            event: (clipboard) ? false : e,
            files: files,
            name: 'imagedrop',
            data: this.opts.imageData,
            paramName: this.opts.imageUploadParam
        };

        this.app.api('module.upload.send', options);
    },
    onstop: function()
    {
        if (this.resizer) this.resizer.stop();
    },
    onbottomclick: function()
    {
        this.insertion.insertToEnd(this.editor.getLastNode(), 'image');
    },
    onimageresizer: {
        stop: function()
        {
            if (this.resizer) this.resizer.hide();
        }
    },
    onsource: {
        open: function()
        {
            if (this.resizer) this.resizer.hide();
        },
        closed: function()
        {
            this._observeImages();
            if (this.resizer) this.resizer.rebuild();
        }
    },
    onupload: {
        complete: function()
        {
            this._observeImages();
        },
        image: {
            complete: function(response)
            {
                this._insert(response);
            },
            error: function(response)
            {
                this._uploadError(response);
            }
        },
        imageedit: {
            complete: function(response)
            {
                this._change(response);
            },
            error: function(response)
            {
                this._uploadError(response);
            }
        },
        imagedrop: {
            complete: function(response, e)
            {
                this._insert(response, e);
            },
            error: function(response)
            {
                this._uploadError(response);
            }
        },
        imagereplace: {
            complete: function(response)
            {
                this._change(response, false);
            },
            error: function(response)
            {
                this._uploadError(response);
            }
        }
    },
    onmodal: {
        image: {
            open: function($modal, $form)
            {
                this._setUpload($form);
            }
        },
        imageedit: {
            open: function($modal, $form)
            {
                this._setFormData($modal, $form);
            },
            opened: function($modal, $form)
            {
                this._setFormFocus($form);
            },
            remove: function()
            {
                this._remove(this.$image);
            },
            save: function($modal, $form)
            {
                this._save($modal, $form);
            }
        }
    },
    onimage: {
        observe: function()
        {
            this._observeImages();
        },
        resized: function()
        {
            this.justResized = true;
        }
    },
    oncontextbar: function(e, contextbar)
    {
        if (this.justResized)
        {
            this.justResized = false;
            return;
        }

        var current = this.selection.getCurrent();
        var data = this.inspector.parse(current);

        if (!data.isFigcaption() && data.isComponentType('image'))
        {
            var node = data.getComponent();
            var buttons = {
                "edit": {
                    title: this.lang.get('edit'),
                    api: 'module.image.open'
                },
                "remove": {
                    title: this.lang.get('delete'),
                    api: 'module.image.remove',
                    args: node
                }
            };

            contextbar.set(e, node, buttons);
        }
    },

    // public
    open: function()
    {
        this.$image = this._getCurrent();
        this.app.api('module.modal.build', this._getModalData());
    },
    insert: function(data)
    {
        this._insert(data);
    },
    remove: function(node)
    {
        this._remove(node);
    },

    // private
    _getModalData: function()
    {
        var modalData;
        if (this._isImage() && this.opts.imageEditable)
        {
            modalData = {
                name: 'imageedit',
                width: '800px',
                title: this.lang.get('edit'),
                handle: 'save',
                commands: {
                    save: { title: this.lang.get('save') },
                    remove: { title: this.lang.get('delete'), type: 'danger' },
                    cancel: { title: this.lang.get('cancel') }
                }
            };
        }
        else
        {
            modalData = {
                name: 'image',
                title: this.lang.get('image')
            };
        }

        return modalData;
    },
    _isImage: function()
    {
        return this.$image;
    },
    _getCurrent: function()
    {
        var current = this.selection.getCurrent();
        var data = this.inspector.parse(current);

        return (data.isComponentType('image') && data.isComponentActive()) ? this.component.create('image', data.getComponent()) : false;
    },
    _insert: function(response, e)
    {
        this.app.api('module.modal.close');

        if (Array.isArray(response))
        {
            var obj = {};
            for (var i = 0; i < response.length; i++)
            {
                obj = $R.extend(obj, response[i]);
            }

            response = obj;
        }
        else if (typeof response === 'string')
        {
            response = { "file": { url: response }};
        }

        if (typeof response === 'object')
        {

            var multiple = 0;
            for (var key in response)
            {
                if (typeof response[key] === 'object') multiple++;
            }

            if (multiple > 1)
            {
                this._insertMultiple(response, e);
            }
            else
            {
                this._insertSingle(response, e);
            }
        }
    },
    _insertSingle: function(response, e)
    {
        for (var key in response)
        {
            if (typeof response[key] === 'object')
            {
                var $img = this._createImageAndStore(response[key]);
                var inserted = (e) ? this.insertion.insertToPoint(e, $img) : this.insertion.insertHtml($img);

                this._removeSpaceBeforeFigure(inserted[0]);

                // set is active
                this.component.setActive(inserted[0]);
                this.app.broadcast('image.uploaded', inserted[0], response);
            }
        }
    },
    _insertMultiple: function(response, e)
    {
        var z = 0;
        var inserted = [];
        var last;
        for (var key in response)
        {
            if (typeof response[key] === 'object')
            {
                z++;

                var $img = this._createImageAndStore(response[key]);

                if (z === 1)
                {
                    inserted = (e) ? this.insertion.insertToPoint(e, $img) : this.insertion.insertHtml($img);
                }
                else
                {
                    var $inserted = $R.dom(inserted[0]);
                    $inserted.after($img);
                    inserted = [$img.get()];

                    this.app.broadcast('image.inserted', $img);
                }

                last = inserted[0];

                this._removeSpaceBeforeFigure(inserted[0]);
                this.app.broadcast('image.uploaded', inserted[0], response);
            }
        }

        // set last is active
        this.component.setActive(last);
    },
    _createImageAndStore: function(item)
    {
        var $img = this.component.create('image');

        $img.addClass('redactor-uploaded-figure');
        $img.setData({
            src: item.url,
            id: (item.id) ? item.id : this.utils.getRandomId()
        });

        // add to storage
        this.storage.add('image', $img.getElement());

        return $img;
    },
    _removeSpaceBeforeFigure: function(img)
    {
        if (!img) return;

        var prev = img.previousSibling;
        if (prev)
        {
            this._removeInvisibleSpace(prev);
            this._removeInvisibleSpace(prev.previousSibling);
        }
    },
    _removeInvisibleSpace: function(el)
    {
        if (el && el.nodeType === 3 && this.utils.searchInvisibleChars(el.textContent) !== -1)
        {
            el.parentNode.removeChild(el);
        }
    },
    _save: function($modal, $form)
    {
        var data = $form.getData();
        var imageData = {
            title: data.title
        };

        if (this.opts.imageLink) imageData.link = { url: data.url, target: data.target };
        if (this.opts.imageCaption) imageData.caption = data.caption;
        if (this.opts.imagePosition) imageData.align = data.align;

        this.$image.setData(imageData);
        if (this.resizer) this.resizer.rebuild();

        this.app.broadcast('image.changed', this.$image);
        this.app.api('module.modal.close');
    },
    _change: function(response, modal)
    {
        if (typeof response === 'string')
        {
            response = { "file": { url: response }};
        }

        if (typeof response === 'object')
        {
            var $img;
            for (var key in response)
            {
                if (typeof response[key] === 'object')
                {
                    $img = $R.dom('<img>');
                    $img.attr('src', response[key].url);

                    this.$image.changeImage(response[key]);

                    this.app.broadcast('image.changed', this.$image, response);
                    this.app.broadcast('image.uploaded', this.$image, response);

                    this.app.broadcast('hardsync');

                    break;
                }
            }

            if (modal !== false)
            {
                $img.on('load', function() { this.$previewBox.html($img); }.bind(this));
            }
        }
    },
    _uploadError: function(response)
    {
        this.app.broadcast('image.uploadError', response);
    },
    _remove: function(node)
    {
        this.app.api('module.modal.close');
        this.component.remove(node);
    },
    _observeImages: function()
    {
        var $editor = this.editor.getElement();
        var self = this;
        $editor.find('img').each(function(node)
        {
            var $node = $R.dom(node);

            $node.off('.drop-to-replace');
            $node.on('dragover.drop-to-replace dragenter.drop-to-replace', function(e)
            {
                e.preventDefault();
                return;
            });

            $node.on('drop.drop-to-replace', function(e)
            {
                if (!self.app.isDragComponentInside())
                {
                    return self._setReplaceUpload(e, $node);
                }
            });
        });
    },
    _setFormData: function($modal, $form)
    {
        this._buildPreview();
        this._buildPreviewUpload();

        var imageData = this.$image.getData();
        var data = {
            title: imageData.title
        };

        // caption
        if (this.opts.imageCaption) data.caption = imageData.caption;
        else $modal.find('.form-item-caption').hide();

        // position
        if (this.opts.imagePosition) data.align = imageData.align;
        else $modal.find('.form-item-align').hide();

        // link
        if (this.opts.imageLink)
        {
            if (imageData.link)
            {
                data.url = imageData.link.url;
                if (imageData.link.target) data.target = true;
            }
        }
        else $modal.find('.form-item-link').hide();

        $form.setData(data);
    },
    _setFormFocus: function($form)
    {
        $form.getField('title').focus();
    },
    _setReplaceUpload: function(e, $node)
    {
        e = e.originalEvent || e;
        e.stopPropagation();
        e.preventDefault();

        if (!this.opts.imageUpload) return;

        this.$image = this.component.create('image', $node);

        var options = {
            url: this.opts.imageUpload,
            files: e.dataTransfer.files,
            name: 'imagereplace',
            data: this.opts.imageData,
            paramName: this.opts.imageUploadParam
        };

        this.app.api('module.upload.send', options);

        return;
    },
    _setUpload: function($form)
    {
        var options = {
            url: this.opts.imageUpload,
            element: $form.getField('file'),
            name: 'image',
            data: this.opts.imageData,
            paramName: this.opts.imageUploadParam
        };

        this.app.api('module.upload.build', options);
    },
    _buildPreview: function()
    {
        this.$preview = $R.dom('#redactor-modal-image-preview');

        var imageData = this.$image.getData();
        var $previewImg = $R.dom('<img>');
        $previewImg.attr('src', imageData.src);

        this.$previewBox = $R.dom('<div>');
        this.$previewBox.append($previewImg);

        this.$preview.html('');
        this.$preview.append(this.$previewBox);
    },
    _buildPreviewUpload: function()
    {
        if (!this.opts.imageUpload) return;

        var $desc = $R.dom('<div class="desc">');
        $desc.html(this.lang.get('upload-change-label'));

        this.$preview.append($desc);

        var options = {
            url: this.opts.imageUpload,
            element: this.$previewBox,
            name: 'imageedit',
            paramName: this.opts.imageUploadParam
        };

        this.app.api('module.upload.build', options);
    }
});
$R.add('class', 'image.component', {
    mixins: ['dom', 'component'],
    init: function(app, el)
    {
        this.app = app;
        this.opts = app.opts;
        this.selection = app.selection;

        // init
        return (el && el.cmnt !== undefined) ? el : this._init(el);
    },
    setData: function(data)
    {
        for (var name in data)
        {
            this._set(name, data[name]);
        }
    },
    getData: function()
    {
        var names = ['src', 'title', 'caption', 'align', 'link', 'id'];
        var data = {};

        for (var i = 0; i < names.length; i++)
        {
            data[names[i]] = this._get(names[i]);
        }

        return data;
    },
    getElement: function()
    {
        return this.$element;
    },
    changeImage: function(data)
    {
        this.$element.attr('src', data.url);
    },


    // private
    _init: function(el)
    {
        var $el = $R.dom(el);
        var $figure = $el.closest('figure');

        if (el === undefined)
        {
            this.$element = $R.dom('<img>');
            this.parse('<figure>');
            this.append(this.$element);
        }
        else if ($figure.length === 0)
        {
            this.parse('<figure>');
            this.$element = $el;
            this.$element.wrap(this);
        }
        else
        {
            this.parse($figure);
            this.$element = this.find('img');
        }

        this._initWrapper();
    },
    _set: function(name, value)
    {
        this['_set_' + name](value);
    },
    _get: function(name)
    {
        return this['_get_' + name]();
    },
    _set_src: function(src)
    {
       this.$element.attr('src', src);
    },
    _set_id: function(id)
    {
       this.$element.attr('data-image', id);
    },
    _set_title: function(title)
    {
        title = title.trim().replace(/(<([^>]+)>)/ig,"");

        if (title === '')
        {
            this.$element.removeAttr('alt');
        }
        else
        {
            this.$element.attr('alt', title);
        }

    },
    _set_caption: function(caption)
    {
        var $figcaption = this.find('figcaption');
        if ($figcaption.length === 0)
        {
            $figcaption = $R.dom('<figcaption>');
            $figcaption.attr('contenteditable', 'true');

            this.append($figcaption);
        }

        if (caption === '') $figcaption.remove();
        else $figcaption.html(caption);

        return $figcaption;
    },
    _set_align: function(align)
    {
        var imageFloat = '';
        var imageMargin = '';
        var textAlign = '';
        var $el = this;
        var $figcaption = this.find('figcaption');

        if (typeof this.opts.imagePosition === 'object')
        {
            var positions = this.opts.imagePosition;
            for (var key in positions)
            {
                $el.removeClass(positions[key]);
            }

            var alignClass = (typeof positions[align] !== 'undefined') ? positions[align] : false;
            if (alignClass)
            {
                $el.addClass(alignClass);
            }
        }
        else
        {
            switch (align)
            {
                case 'left':
                    imageFloat = 'left';
                    imageMargin = '0 ' + this.opts.imageFloatMargin + ' ' + this.opts.imageFloatMargin + ' 0';
                break;
                case 'right':
                    imageFloat = 'right';
                    imageMargin = '0 0 ' + this.opts.imageFloatMargin + ' ' + this.opts.imageFloatMargin;
                break;
                case 'center':
                    textAlign = 'center';
                break;
            }

            $el.css({ 'float': imageFloat, 'margin': imageMargin, 'text-align': textAlign });
            $el.attr('rel', $el.attr('style'));

            if (align === 'center')
            {
                $figcaption.css('text-align', 'center');
            }
            else
            {
                $figcaption.css('text-align', '');
            }
        }
    },
    _set_link: function(data)
    {
        var $link = this._findLink();
        if (data.url === '')
        {
            if ($link) $link.unwrap();

            return;
        }

        if (!$link)
        {
            $link = $R.dom('<a>');
            this.$element.wrap($link);
        }

        $link.attr('href', data.url);

        if (data.target) $link.attr('target', (data.target === true) ? '_blank' : data.target);
        else $link.removeAttr('target');

        return $link;
    },
    _get_src: function()
    {
        return this.$element.attr('src');
    },
    _get_id: function()
    {
        return this.$element.attr('data-image');
    },
    _get_title: function()
    {
        var alt = this.$element.attr('alt');

        return (alt) ? alt : '';
    },
    _get_caption: function()
    {
        var $figcaption = this.find('figcaption');

        if ($figcaption.length === 0)
        {
            return '';
        }
        else
        {
            return $figcaption.html();
        }
    },
    _get_align: function()
    {
        var align = '';
        if (typeof this.opts.imagePosition === 'object')
        {
            align = 'none';
            var positions = this.opts.imagePosition;
            for (var key in positions)
            {
                if (this.hasClass(positions[key]))
                {
                    align = key;
                    break;
                }
            }
        }
        else
        {
            align = (this.css('text-align') === 'center') ? 'center' : this.css('float');
        }

        return align;
    },
    _get_link: function()
    {
        var $link = this._findLink();
        if ($link)
        {
            var target = ($link.attr('target')) ? true : false;

            return {
                url: $link.attr('href'),
                target: target
            };
        }
    },
    _initWrapper: function()
    {
        this.addClass('redactor-component');
        this.attr({
            'data-redactor-type': 'image',
            'tabindex': '-1',
            'contenteditable': false
        });
    },
    _findLink: function()
    {
        var $link = this.find('a').filter(function(node)
        {
            return ($R.dom(node).closest('figcaption').length === 0);
        });

        if ($link.length !== 0)
        {
            return $link;
        }

        return false;
    }
});
$R.add('class', 'image.resize', {
    init: function(app)
    {
        this.app = app;
        this.$doc = app.$doc;
        this.$win = app.$win;
        this.$body = app.$body;
        this.editor = app.editor;
        this.toolbar = app.toolbar;
        this.inspector = app.inspector;

        // init
        this.$target = (this.toolbar.isTarget()) ? this.toolbar.getTargetElement() : this.$body;
        this._init();
    },
    // public
    rebuild: function()
    {
        this._setResizerPosition();
    },
    hide: function()
    {
        this.$target.find('#redactor-image-resizer').remove();
    },
    stop: function()
    {
        var $editor = this.editor.getElement();
        $editor.off('.redactor.image-resize');

        this.$doc.off('.redactor.image-resize');
        this.$win.off('resize.redactor.image-resize');
        this.hide();
    },

    // private
    _init: function()
    {
        var $editor = this.editor.getElement();
        $editor.on('click.redactor.image-resize', this._build.bind(this));

        this.$win.on('resize.redactor.image-resize', this._setResizerPosition.bind(this));
    },
    _build: function(e)
    {
        this.$target.find('#redactor-image-resizer').remove();

        var data = this.inspector.parse(e.target);
        var $editor = this.editor.getElement();

        if (data.isComponentType('image'))
        {
            this.$resizableBox = $editor;
            this.$resizableImage = $R.dom(data.getImageElement());

            this.$resizer = $R.dom('<span>');
            this.$resizer.attr('id', 'redactor-image-resizer');

            this.$target.append(this.$resizer);

            this._setResizerPosition();
            this.$resizer.on('mousedown touchstart', this._set.bind(this));
        }
    },
    _setResizerPosition: function()
    {
        if (this.$resizer)
        {
            var isTarget = this.toolbar.isTarget();
            var targetOffset = this.$target.offset();
            var offsetFix = 7;
            var topOffset = (isTarget) ? (offsetFix - targetOffset.top + this.$target.scrollTop()) : offsetFix;
            var leftOffset = (isTarget) ? (offsetFix - targetOffset.left) : offsetFix;
            var pos = this.$resizableImage.offset();
            var width = this.$resizableImage.width();
            var height = this.$resizableImage.height();
            var resizerWidth =  this.$resizer.width();
            var resizerHeight =  this.$resizer.height();

            this.$resizer.css({ top: (pos.top + height - resizerHeight + topOffset) + 'px', left: (pos.left + width - resizerWidth + leftOffset) + 'px' });
        }
    },
    _set: function(e)
    {
        e.preventDefault();

        this.resizeHandle = {
            x : e.pageX,
            y : e.pageY,
            el : this.$resizableImage,
            ratio: this.$resizableImage.width() / this.$resizableImage.height(),
            h: this.$resizableImage.height()
        };

        e = e.originalEvent || e;

        if (e.targetTouches)
        {
             this.resizeHandle.x = e.targetTouches[0].pageX;
             this.resizeHandle.y = e.targetTouches[0].pageY;
        }

        this.app.broadcast('contextbar.close');
        this.app.broadcast('image.resize', this.$resizableImage);
        this._start();
    },
    _start: function()
    {
        this.$doc.on('mousemove.redactor.image-resize touchmove.redactor.image-resize', this._move.bind(this));
        this.$doc.on('mouseup.redactor.image-resize touchend.redactor.image-resize', this._stop.bind(this));
    },
    _stop: function()
    {
        this.$doc.off('.redactor.image-resize');
        this.app.broadcast('image.resized', this.$resizableImage);
    },
    _move: function(e)
    {
        e.preventDefault();

        e = e.originalEvent || e;

        var height = this.resizeHandle.h;

        if (e.targetTouches) height += (e.targetTouches[0].pageY -  this.resizeHandle.y);
        else height += (e.pageY -  this.resizeHandle.y);

        var width = height * this.resizeHandle.ratio;

        if (height < 20 || width < 100) return;
        if (this._getResizableBoxWidth() <= width) return;

        this.resizeHandle.el.attr({width: width, height: height});
        this.resizeHandle.el.width(width);
        this.resizeHandle.el.height(height);
        this._setResizerPosition();
    },
    _getResizableBoxWidth: function()
    {
        var width = this.$resizableBox.width();
        return width - parseInt(this.$resizableBox.css('padding-left')) - parseInt(this.$resizableBox.css('padding-right'));
    }
});
$R.add('module', 'file', {
    modals: {
        'file':
            '<div class="redactor-modal-tab" data-title="## upload ##"><form action=""> \
                <div class="form-item form-item-title"> \
                    <label for="modal-file-title"> ## filename ## <span class="desc">(## optional ##)</span></label> \
                    <input type="text" id="modal-file-title" name="title" /> \
                </div> \
                <input type="file" name="file"> \
            </form></div>'
    },
    init: function(app)
    {
        this.app = app;
        this.opts = app.opts;
        this.lang = app.lang;
        this.caret = app.caret;
        this.utils = app.utils;
        this.storage = app.storage;
        this.component = app.component;
        this.inspector = app.inspector;
        this.insertion = app.insertion;
        this.selection = app.selection;
    },
    // messages
    onstarted: function()
    {
        // storage observe
        this.storage.observeFiles();
    },
    ondropfile: function(e, files, clipboard)
    {
        if (!this.opts.fileUpload) return;

        var options = {
            url: this.opts.fileUpload,
            event: (clipboard) ? false : e,
            files: files,
            name: 'filedrop',
            data: this.opts.fileData
        };

        this.app.api('module.upload.send', options);
    },
    onmodal: {
        file: {
            open: function($modal, $form)
            {
                this._setFormData($modal, $form);
                this._setUpload($form);
            },
            opened: function($modal, $form)
            {
                this._setFormFocus($form);

                this.$form = $form;
            }
        }
    },
    onupload: {
        file: {
            complete: function(response)
            {
                this._insert(response);
            },
            error: function(response)
            {
                this._uploadError(response);
            }
        },
        filedrop: {
            complete: function(response, e)
            {
                this._insert(response, e);
            },
            error: function(response)
            {
                this._uploadError(response);
            }
        }
    },
    oncontextbar: function(e, contextbar)
    {
        var current = this.selection.getCurrent();
        var data = this.inspector.parse(current);
        if (data.isFile())
        {
            var node = data.getFile();
            var buttons = {
                "remove": {
                    title: this.lang.get('delete'),
                    api: 'module.file.remove',
                    args: node
                }
            };

            contextbar.set(e, node, buttons, 'bottom');
        }

    },

    // public
    open: function()
    {
        this._open();
    },
    insert: function(data)
    {
        this._insert(data);
    },
    remove: function(node)
    {
        this._remove(node);
    },

    // private
    _open: function()
    {
        this.app.api('module.modal.build', this._getModalData());
    },
    _getModalData: function()
    {
        var modalData = {
            name: 'file',
            title: this.lang.get('file')
        };

        return modalData;
    },
    _insert: function(response, e)
    {
        this.app.api('module.modal.close');
        if (typeof response !== 'object') return;

        if (Array.isArray(response))
        {
            var obj = {};
            for (var i = 0; i < response.length; i++)
            {
                obj = $R.extend(obj, response[i]);
            }

            response = obj;
        }

        var multiple = (Object.keys(response).length  > 1);

        if (multiple)
        {
            this._insertMultiple(response, e);
        }
        else
        {
            this._insertSingle(response, e);
        }

        this.$form = false;
    },
    _insertSingle: function(response, e)
    {
        var inserted = [];
        for (var key in response)
        {
            var $file = this._createFileAndStore(response[key]);

            if (this.opts.fileAttachment)
            {
                inserted = this._insertAsAttachment($file);
            }
            else
            {
                inserted = (e) ? this.insertion.insertToPoint(e, $file) : this.insertion.insertRaw($file);
            }

            this.app.broadcast('file.uploaded', inserted[0], response);
        }
    },
    _insertMultiple: function(response, e)
    {
        var z = 0;
        var inserted = [];
        var $last;
        for (var key in response)
        {
            z++;

            var $file = this._createFileAndStore(response[key]);

            if (this.opts.fileAttachment)
            {
                inserted = this._insertAsAttachment($file, response);
            }
            else
            {
                if (z === 1)
                {
                    inserted = (e) ? this.insertion.insertToPoint(e, $file) : this.insertion.insertRaw($file);
                }
                else
                {
                    var $inserted = $R.dom(inserted[0]);
                    $inserted.after($file).after(' ');
                    inserted = [$file.get()];

                    this.app.broadcast('file.inserted', $file);
                }
            }

            $last = $file;
            this.app.broadcast('file.uploaded', inserted[0], response);
        }

        // set caret after last
        if (!this.opts.fileAttachment)
        {
            this.caret.setAfter($last);
        }
    },
    _insertAsAttachment: function($file, response)
    {
        var $box = $R.dom(this.opts.fileAttachment);
        var $wrapper = $file.wrapAttachment();
        $box.append($wrapper);

        var inserted = [$wrapper.get()];
        this.app.broadcast('file.appended', inserted[0], response);

        return inserted;
    },
    _createFileAndStore: function(item)
    {
        var modalFormData = (this.$form) ? this.$form.getData() : false;
        var name = (item.name) ? item.name : item.url;
        var title = (!this.opts.fileAttachment && modalFormData && modalFormData.title !== '') ? modalFormData.title : this._truncateUrl(name);

        var $file = this.component.create('file');
        $file.attr('href', item.url);
        $file.attr('data-file', (item.id) ? item.id : this.utils.getRandomId());
        $file.attr('data-name', item.name);
        $file.html(title);

        // add to storage
        this.storage.add('file', $file);

        return $file;
    },
    _remove: function(node)
    {
        this.selection.save();

        var $file = this.component.create('file', node);
        var stop = this.app.broadcast('file.delete', $file);
        if (stop !== false)
        {
            $file.unwrap();

            this.selection.restore();

            // callback
            this.app.broadcast('file.deleted', $file);
        }
        else
        {
            this.selection.restore();
        }
    },
    _truncateUrl: function(url)
    {
        return (url.search(/^http/) !== -1 && url.length > 20) ? url.substring(0, 20) + '...' : url;
    },
    _setUpload: function($form)
    {
        var options = {
            url: this.opts.fileUpload,
            element: $form.getField('file'),
            name: 'file',
            data: this.opts.fileData,
            paramName: this.opts.fileUploadParam
        };

        this.app.api('module.upload.build', options);
    },
    _setFormData: function($modal, $form)
    {
        if (this.opts.fileAttachment)
        {
            $modal.find('.form-item-title').hide();
        }
        else
        {
            $form.setData({ title: this.selection.getText() });
        }
    },
    _setFormFocus: function($form)
    {
        $form.getField('title').focus();
    },
    _uploadError: function(response)
    {
        this.app.broadcast('file.uploadError', response);
    }
});
$R.add('class', 'file.component', {
    mixins: ['dom', 'component'],
    init: function(app, el)
    {
        this.app = app;
        this.opts = app.opts;

        // init
        return (el && el.cmnt !== undefined) ? el : this._init(el);
    },
    wrapAttachment: function()
    {
        this.$wrapper = $R.dom('<span class="redactor-file-item">');
        this.$remover = $R.dom('<span class="redactor-file-remover">');
        this.$remover.html('&times;');
        this.$remover.on('click', this.removeAttachment.bind(this));

        this.$wrapper.append(this);
        this.$wrapper.append(this.$remover);

        return this.$wrapper;
    },
    removeAttachment: function(e)
    {
        e.preventDefault();

        var stop = this.app.broadcast('file.delete', this, this.$wrapper);
        if (stop !== false)
        {
            this.$wrapper.remove();
            this.app.broadcast('file.deleted', this);
            this.app.broadcast('file.removeAttachment', this);
        }
    },

    // private
    _init: function(el)
    {
        if (el === undefined)
        {
            this.parse('<a>');
        }
        else
        {
            var $a = $R.dom(el).closest('a');
            this.parse($a);
        }
    }
});
$R.add('module', 'buffer', {
    init: function(app)
    {
        this.app = app;
        this.opts = app.opts;
        this.editor = app.editor;
        this.offset = app.offset;
        this.keycodes = app.keycodes;
        this.selection = app.selection;

        // local
        this.state = false;
        this.passed = false;
        this.keyPressed = false;
        this.savedHtml = false;
        this.savedOffset = false;
        this.undoStorage = [];
        this.redoStorage = [];
    },
    // messages
    onkeydown: function(e)
    {
        this._listen(e);
    },
    onsyncing: function()
    {
        if (!this.keyPressed)
        {
            this.trigger();
        }

        this.keyPressed = false;
    },
    onbuffer: {
        trigger: function()
        {
            this.trigger();
        }
    },
    onstate: function(e, html, offset)
    {
        if ((e && (e.ctrlKey || e.metaKey)) || (e && (this._isUndo(e) || this._isRedo(e))))
        {
            return;
        }

        this.passed = false;
        this._saveState(html, offset);
    },
    onenable: function()
    {
        this.clear();
    },

    // public
    clear: function()
    {
        this.state = false;
        this.undoStorage = [];
        this.redoStorage = [];
    },
    undo: function()
    {
        this._getUndo();
    },
    redo: function()
    {
        this._getRedo();
    },
    trigger: function()
    {
        if (this.state && this.passed === false) this._setUndo();
    },

    // private
    _saveState: function(html, offset)
    {
        var $editor = this.editor.getElement();

        this.state = {
            html: html || $editor.html(),
            offset: offset || this.offset.get()
        };
    },
    _listen: function(e)
    {
        var key = e.which;
        var ctrl = e.ctrlKey || e.metaKey;
        var cmd = ctrl || e.shiftKey || e.altKey;
        var keys = [this.keycodes.SPACE, this.keycodes.ENTER, this.keycodes.BACKSPACE, this.keycodes.DELETE, this.keycodes.TAB,
                    this.keycodes.LEFT, this.keycodes.RIGHT, this.keycodes.UP, this.keycodes.DOWN];
        // undo
        if (this._isUndo(e)) // z key
        {
            e.preventDefault();
            this.undo();
            return;
        }
        // redo
        else if (this._isRedo(e))
        {
            e.preventDefault();
            this.redo();
            return;
        }
        // spec keys
        else if (!ctrl && keys.indexOf(key) !== -1)
        {
            cmd = true;
            this.trigger();
        }
        // cut & copy
        else if (ctrl && (key === 88 || key === 67))
        {
            cmd = true;
            this.trigger();
        }


        // empty buffer
        if (!cmd && !this._hasUndo())
        {
            this.trigger();
        }

        this.keyPressed = true;
    },
    _isUndo: function(e)
    {
        var key = e.which;
        var ctrl = e.ctrlKey || e.metaKey;

        return (ctrl && key === 90 && !e.shiftKey && !e.altKey);
    },
    _isRedo: function(e)
    {
        var key = e.which;
        var ctrl = e.ctrlKey || e.metaKey;

        return (ctrl && (key === 90 && e.shiftKey || key === 89 && !e.shiftKey) && !e.altKey);
    },
    _setUndo: function()
    {
        var last = this.undoStorage[this.undoStorage.length-1];
        if (typeof last === 'undefined' || last[0] !== this.state.html)
        {
            this.undoStorage.push([this.state.html, this.state.offset]);
            this._removeOverStorage();
        }
    },
    _setRedo: function()
    {
        var $editor = this.editor.getElement();
        var offset = this.offset.get();
        var html = $editor.html();

        this.redoStorage.push([html, offset]);
        this.redoStorage = this.redoStorage.slice(0, this.opts.bufferLimit);
    },
    _getUndo: function()
    {
        if (!this._hasUndo()) return;

        this.passed = true;

        var $editor = this.editor.getElement();
        var buffer = this.undoStorage.pop();

        this._setRedo();

        $editor.html(buffer[0]);
        this.offset.set(buffer[1]);
        this.selection.restore();

        this.app.broadcast('undo', buffer[0], buffer[1]);

    },
    _getRedo: function()
    {
        if (!this._hasRedo()) return;

        this.passed = true;

        var $editor = this.editor.getElement();
        var buffer = this.redoStorage.pop();

        this._setUndo();
        $editor.html(buffer[0]);
        this.offset.set(buffer[1]);

        this.app.broadcast('redo', buffer[0], buffer[1]);
    },
    _removeOverStorage: function()
    {
        if (this.undoStorage.length > this.opts.bufferLimit)
        {
            this.undoStorage = this.undoStorage.slice(0, (this.undoStorage.length - this.opts.bufferLimit));
        }
    },
    _hasUndo: function()
    {
        return (this.undoStorage.length !== 0);
    },
    _hasRedo: function()
    {
        return (this.redoStorage.length !== 0);
    }
});
$R.add('module', 'list', {
    init: function(app)
    {
        this.app = app;
        this.opts = app.opts;
        this.utils = app.utils;
        this.block = app.block;
        this.toolbar = app.toolbar;
        this.inspector = app.inspector;
        this.selection = app.selection;
    },
    // messages
    onbutton: {
        list: {
            observe: function(button)
            {
                this._observeButton(button);
            }
        }
    },
    ondropdown: {
        list: {
            observe: function(dropdown)
            {
                this._observeDropdown(dropdown);
            }
        }
    },

    // public
    toggle: function(type)
    {
        var nodes = this._getBlocks();
        var block = this.selection.getBlock();
        var $list = $R.dom(block).parents('ul, ol',  '.redactor-in').last();
        if (nodes.length === 0 && $list.length !== 0)
        {
            nodes = [$list.get()];
        }

        if (block && (block.tagName === 'TD' || block.tagName === 'TH'))
        {
            nodes = this.block.format('div');
        }

        this.selection.saveMarkers();

        nodes = (nodes.length !== 0 && this._isUnformat(type, nodes)) ? this._unformat(type, nodes) : this._format(type, nodes);

        this.selection.restoreMarkers();

        return nodes;
    },
    indent: function()
    {
        var isCollapsed = this.selection.isCollapsed();
        var current = this.selection.getCurrent();
        var data = this.inspector.parse(current);
        var item = (data.isList()) ? data.getListItem() : false;
        var $item = $R.dom(item);
        var $prev = $item.prevElement();
        var prev = $prev.get();
        var isIndent = (isCollapsed && item && prev && prev.tagName === 'LI');

        if (isIndent)
        {
            this.selection.saveMarkers();

            $prev = $R.dom(prev);
            var $prevChild = $prev.children('ul, ol');
            var $list = $item.closest('ul, ol');

            if ($prevChild.length !== 0)
            {
                $prevChild.append($item);
            }
            else
            {
                var listTag = $list.get().tagName.toLowerCase();
                var $newList = $R.dom('<' + listTag + '>');

                $newList.append($item);
                $prev.append($newList);
            }

            this.selection.restoreMarkers();
        }
    },
    outdent: function()
    {
        var isCollapsed = this.selection.isCollapsed();
        var current = this.selection.getCurrent();
        var data = this.inspector.parse(current);
        var item = (data.isList()) ? data.getListItem() : false;
        var $item = $R.dom(item);

        if (isCollapsed && item)
        {

            var $listItem = $item.parent();
            var $liItem = $listItem.closest('li', '.redactor-in');
            var $prev = $item.prevElement();
            var $next = $item.nextElement();
            var prev = $prev.get();
            var next = $next.get();
            var nextItems, nextList, $newList, $nextList;
            var isTop = (prev === false);
            var isMiddle = (prev !== false && next !== false);
            var isBottom = (!isTop && next === false);

            this.selection.saveMarkers();

            // out
            if ($liItem.length !== 0)
            {
                if (isMiddle)
                {
                    nextItems = this._getAllNext($item.get());
                    $newList = $R.dom('<' + $listItem.get().tagName.toLowerCase() + '>');

                    for (var i = 0; i < nextItems.length; i++)
                    {
                        $newList.append(nextItems[i]);
                    }

                    $liItem.after($item);
                    $item.append($newList);
                }
                else
                {
                    $liItem.after($item);

                    if ($listItem.children().length === 0)
                    {
                        $listItem.remove();
                    }
                    else
                    {
                        if (isTop) $item.append($listItem);
                    }
                }
            }
            // unformat
            else
            {
                var $container =  this._createUnformatContainer($item);
                var $childList = $container.find('ul, ol').first();

                if (isTop) $listItem.before($container);
                else if (isBottom) $listItem.after($container);
                else if (isMiddle)
                {
                    $newList = $R.dom('<' + $listItem.get().tagName.toLowerCase() + '>');
                    nextItems = this._getAllNext($item.get());

                    for (var i = 0; i < nextItems.length; i++)
                    {
                        $newList.append(nextItems[i]);
                    }

                    $listItem.after($container);
                    $container.after($newList);
                }

                if ($childList.length !== 0)
                {
                    $nextList = $container.nextElement();
                    nextList = $nextList.get();
                    if (nextList && nextList.tagName === $listItem.get().tagName)
                    {
                        $R.dom(nextList).prepend($childList);
                        $childList.unwrap();
                    }
                    else
                    {
                        $container.after($childList);
                    }
                }

                $item.remove();
            }

            this.selection.restoreMarkers();
        }
    },

    // private
    _getAllNext: function(next)
    {
        var nodes = [];

        while (next)
        {
            var $next = $R.dom(next).nextElement();
            next = $next.get();

            if (next) nodes.push(next);
            else return nodes;
        }

        return nodes;
    },
    _isUnformat: function(type, nodes)
    {
        var countLists = 0;
        for (var i = 0; i < nodes.length; i++)
        {
            if (nodes[i].nodeType !== 3)
            {
                var tag = nodes[i].tagName.toLowerCase();
                if (tag === type || tag === 'figure')
                {
                    countLists++;
                }
            }
        }

        return (countLists === nodes.length);
    },
    _format: function(type, nodes)
    {
        var tags = ['p', 'div', 'blockquote', 'pre', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'ul', 'ol'];
        var blocks = this._uniteBlocks(nodes, tags);
        var lists = [];

        for (var key in blocks)
        {
            var items = blocks[key];
            var $list = this._createList(type, blocks[key]);

            for (var i = 0; i < items.length; i++)
            {
                var $item;

                // lists
                if (items[i].nodeType !== 3 && (items[i].tagName === 'UL' || items[i].tagName === 'OL'))
                {
                    var $oldList = $R.dom(items[i]);

                    $item = $oldList.contents();
                    $list.append($item);

                    // old is empty
                    if (this.utils.isEmpty($oldList)) $oldList.remove();
                }
                // other blocks or texts
                else
                {
                    $item = this._createListItem(items[i]);
                    this.utils.normalizeTextNodes($item);
                    $list.append($item);
                }
            }

            lists.push($list.get());
        }

        return lists;
    },
    _uniteBlocks: function(nodes, tags)
    {
        var z = 0;
        var blocks = { 0: [] };
        var lastcell = false;
        for (var i = 0; i < nodes.length; i++)
        {
            var $node = $R.dom(nodes[i]);
            var $cell = $node.closest('th, td');

            if ($cell.length !== 0)
            {
                if ($cell.get() !== lastcell)
                {
                    // create block
                    z++;
                    blocks[z] = [];
                }

                if (this._isUniteBlock(nodes[i], tags))
                {
                    blocks[z].push(nodes[i]);
                }
            }
            else
            {
                if (this._isUniteBlock(nodes[i], tags))
                {
                    blocks[z].push(nodes[i]);
                }
                else
                {
                    // create block
                    z++;
                    blocks[z] = [];
                }
            }

            lastcell = $cell.get();
        }

        return blocks;
    },
    _isUniteBlock: function(node, tags)
    {
        return (node.nodeType === 3 || tags.indexOf(node.tagName.toLowerCase()) !== -1);
    },
    _createList: function(type, blocks)
    {
        var last = blocks[blocks.length-1];
        var $last = $R.dom(last);
        var $list = $R.dom('<' + type + '>');
        $last.after($list);

        return $list;
    },
    _createListItem: function(item)
    {
        var $item = $R.dom('<li>');
        if (item.nodeType === 3)
        {
            $item.append(item);
        }
        else
        {
            var $el = $R.dom(item);
            $item.append($el.contents());
            $el.remove();
        }

        return $item;
    },
    _unformat: function(type, nodes)
    {
        if (nodes.length === 1)
        {
            // one list
            var $list = $R.dom(nodes[0]);
            var $items = $list.find('li');

            var selectedItems = this.selection.getNodes({ tags: ['li'] });
            var block = this.selection.getBlock();
            var $li = $R.dom(block).closest('li');
            if (selectedItems.length === 0 && $li.length !== 0)
            {
                selectedItems = [$li.get()];
            }


            // 1) entire
            if (selectedItems.length === $items.length)
            {
                return this._unformatEntire(nodes[0]);
            }

            var pos = this._getItemsPosition($items, selectedItems);

            // 2) top
            if (pos === 'Top')
            {
                return this._unformatAtSide('before', selectedItems, $list);
            }

            // 3) bottom
            else if (pos === 'Bottom')
            {
                selectedItems.reverse();
                return this._unformatAtSide('after', selectedItems, $list);
            }

            // 4) middle
            else if (pos === 'Middle')
            {
                var $last = $R.dom(selectedItems[selectedItems.length-1]);

                var ci = false;

                var $parent = false;
                var $secondList = $R.dom('<' + $list.get().tagName.toLowerCase() + '>');
                $items.each(function(node)
                {
                    if (ci)
                    {
                        var $node = $R.dom(node);
                        if ($node.closest('.redactor-split-item').length === 0 && ($parent === false || $node.closest($parent).length === 0))
                        {
                            $node.addClass('redactor-split-item');
                        }

                        $parent = $node;
                    }

                    if (node === $last.get())
                    {
                        ci = true;
                    }
                });

                $items.filter('.redactor-split-item').each(function(node)
                {
                    var $node = $R.dom(node);
                    $node.removeClass('redactor-split-item');
                    $secondList.append(node);
                });

                $list.after($secondList);

                selectedItems.reverse();
                for (var i = 0; i < selectedItems.length; i++)
                {
                    var $item = $R.dom(selectedItems[i]);
                    var $container = this._createUnformatContainer($item);

                    $list.after($container);
                    $container.find('ul, ol').remove();
                    $item.remove();
                }


                return;
            }

        }
        else
        {
            // unformat all
            for (var i = 0; i < nodes.length; i++)
            {
                if (nodes[i].nodeType !== 3 && nodes[i].tagName.toLowerCase() === type)
                {
                    this._unformatEntire(nodes[i]);
                }
            }
        }
    },
    _unformatEntire: function(list)
    {
        var $list = $R.dom(list);
        var $items = $list.find('li');
        $items.each(function(node)
        {
            var $item = $R.dom(node);
            var $container = this._createUnformatContainer($item);

            $item.remove();
            $list.before($container);

        }.bind(this));

        $list.remove();
    },
    _unformatAtSide: function(type, selectedItems, $list)
    {
        for (var i = 0; i < selectedItems.length; i++)
        {
            var $item = $R.dom(selectedItems[i]);
            var $container = this._createUnformatContainer($item);

            $list[type]($container);

            var $innerLists = $container.find('ul, ol').first();
            $item.append($innerLists);

            $innerLists.each(function(node)
            {
                var $node = $R.dom(node);
                var $parent = $node.closest('li');

                if ($parent.get() === selectedItems[i])
                {
                    $node.unwrap();
                    $parent.addClass('r-unwrapped');
                }

            });

            if (this.utils.isEmptyHtml($item.html())) $item.remove();
        }

        // clear empty
        $list.find('.r-unwrapped').each(function(node)
        {
            var $node = $R.dom(node);
            if ($node.html().trim() === '') $node.remove();
            else $node.removeClass('r-unwrapped');
        });
    },
    _getItemsPosition: function($items, selectedItems)
    {
        var pos = 'Middle';

        var sFirst = selectedItems[0];
        var sLast = selectedItems[selectedItems.length-1];

        var first = $items.first().get();
        var last = $items.last().get();

        if (first === sFirst && last !== sLast)
        {
            pos = 'Top';
        }
        else if (first !== sFirst && last === sLast)
        {
            pos = 'Bottom';
        }

        return pos;
    },
    _createUnformatContainer: function($item)
    {
        var $container = $R.dom('<' + this.opts.markup + '>');
        if (this.opts.breakline) $container.attr('data-redactor-tag', 'br');

        $container.append($item.contents());

        return $container;
    },
    _getBlocks: function()
    {
        return this.selection.getBlocks({ first: true });
    },
    _observeButton: function()
    {
        var current = this.selection.getCurrent();
        var data = this.inspector.parse(current);
        var isDisabled = (data.isPre() || data.isCode() || data.isFigcaption());

        this._observeButtonsList(isDisabled, ['lists', 'ul', 'ol', 'outdent', 'indent']);

        var itemOutdent = this.toolbar.getButton('outdent');
        var itemIndent = this.toolbar.getButton('indent');

        this._observeIndent(itemIndent, itemOutdent);
    },
    _observeDropdown: function(dropdown)
    {
        var itemOutdent = dropdown.getItem('outdent');
        var itemIndent = dropdown.getItem('indent');

        this._observeIndent(itemIndent, itemOutdent);
    },
    _observeIndent: function(itemIndent, itemOutdent)
    {
        var isCollapsed = this.selection.isCollapsed();
        var current = this.selection.getCurrent();
        var data = this.inspector.parse(current);
        var item = (data.isList()) ? data.getListItem() : false;
        var $item = $R.dom(item);
        var $prev = $item.prevElement();
        var prev = $prev.get();
        var isIndent = (isCollapsed && item && prev && prev.tagName === 'LI');

        if (itemOutdent)
        {
            if (item && isCollapsed) itemOutdent.enable();
            else itemOutdent.disable();
        }

        if (itemIndent)
        {
            if (item && isIndent) itemIndent.enable();
            else itemIndent.disable();
        }
    },
    _observeButtonsList: function(param, buttons)
    {
        for (var i = 0; i < buttons.length; i++)
        {
            var button = this.toolbar.getButton(buttons[i]);
            if (button)
            {
                if (param) button.disable();
                else button.enable();
            }
        }
    }
});
$R.add('class', 'video.component', {
    mixins: ['dom', 'component'],
    init: function(app, el)
    {
        this.app = app;

        // init
        return (el && el.cmnt !== undefined) ? el : this._init(el);
    },

    // private
    _init: function(el)
    {
        if (typeof el !== 'undefined')
        {
            var $node = $R.dom(el);
            var $wrapper = $node.closest('figure');
            if ($wrapper.length !== 0)
            {
                this.parse($wrapper);
            }
            else
            {
                this.parse('<figure>');
                this.append(el);
            }
        }
        else
        {
            this.parse('<figure>');
        }


        this._initWrapper();
    },
    _initWrapper: function()
    {
        this.addClass('redactor-component');
        this.attr({
            'data-redactor-type': 'video',
            'tabindex': '-1',
            'contenteditable': false
        });
    }
});

$R.add('class', 'widget.component', {
    mixins: ['dom', 'component'],
    init: function(app, el)
    {
        this.app = app;

        // init
        return (el && el.cmnt !== undefined) ? el : this._init(el);
    },
    getData: function()
    {
        return {
            html: this._getHtml()
        };
    },

    // private
    _init: function(el)
    {
        if (typeof el !== 'undefined')
        {
            var $node = $R.dom(el);
            var $figure = $node.closest('figure');
            if ($figure.length !== 0)
            {
                this.parse($figure);
            }
            else
            {
                this.parse('<figure>');
                this.html(el);
            }
        }
        else
        {
            this.parse('<figure>');
        }


        this._initWrapper();
    },
    _getHtml: function()
    {
        var $wrapper = $R.dom('<div>');
        $wrapper.html(this.html());
        $wrapper.find('.redactor-component-caret').remove();

        return $wrapper.html();
    },
    _initWrapper: function()
    {
        this.addClass('redactor-component');
        this.attr({
            'data-redactor-type': 'widget',
            'tabindex': '-1',
            'contenteditable': false
        });
    }
});

    window.Redactor = window.$R = $R;

    // Data attribute load
    window.addEventListener('load', function()
    {
        $R('[data-redactor]');
    });

}());