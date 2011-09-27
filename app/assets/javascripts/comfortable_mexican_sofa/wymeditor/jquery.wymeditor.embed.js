/**
 * WYMeditor : what you see is What You Mean web-based editor
 * Copyright (c) 2005 - 2009 Jean-Francois Hovinne, http://www.wymeditor.org/
 * Dual licensed under the MIT (MIT-license.txt)
 * and GPL (GPL-license.txt) licenses.
 *
 * For further information visit:
 *        http://www.wymeditor.org/
 *
 * File Name:
 *        jquery.wymeditor.embed.js
 *        Experimental embed plugin
 *
 * File Authors:
 *        Jonatan Lundin (jonatan.lundin a-t gmail dotcom)
 *        Roger Hu (roger.hu a-t gmail dotcom)
 *        Scott Nixon (citadelgrad a-t gmail dotcom)
 */
(function(){function a(a,b){for(var c=b.length;c--;){if(b[c]===a){b.splice(c,1)}}return b}if(WYMeditor&&WYMeditor.XhtmlValidator._tags.param.attributes){WYMeditor.XhtmlValidator._tags.embed={attributes:["allowscriptaccess","allowfullscreen","height","src","type","width"]};WYMeditor.XhtmlValidator._tags.param.attributes={0:"name",1:"type",valuetype:/^(data|ref|object)$/,2:"valuetype",3:"value"};WYMeditor.XhtmlValidator._tags.iframe={attributes:["allowfullscreen","width","height","src","title","frameborder"]};var b=WYMeditor.XhtmlSaxListener;WYMeditor.XhtmlSaxListener=function(){var c=b.call(this);a("param",c.block_tags);c.inline_tags.push("param");c.inline_tags.push("embed");c.inline_tags.push("iframe");return c};WYMeditor.XhtmlSaxListener.prototype=b.prototype}})()