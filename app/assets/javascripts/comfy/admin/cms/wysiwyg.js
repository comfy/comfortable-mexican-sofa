"use strict";

(function () {
  var Rails = window.Rails;

  var buildRedactorOptions = function buildRedactorOptions() {
    var fileUploadPath = document.querySelector('meta[name="cms-file-upload-path"]').content;
    var pagesPath = document.querySelector('meta[name="cms-pages-path"]').content;
    var csrfParam = Rails.csrfParam();
    var csrfToken = Rails.csrfToken();
    var imageUpload = new URL(fileUploadPath, document.location.href);
    imageUpload.searchParams.set('source', 'redactor');
    imageUpload.searchParams.set('type', 'image');
    imageUpload.searchParams.set(csrfParam, csrfToken);
    var imageManagerJson = new URL(fileUploadPath, document.location.href);
    imageManagerJson.searchParams.set('source', 'redactor');
    imageManagerJson.searchParams.set('type', 'image');
    var fileUpload = new URL(fileUploadPath, document.location.href);
    fileUpload.searchParams.set('source', 'redactor');
    fileUpload.searchParams.set('type', 'file');
    fileUpload.searchParams.set(csrfParam, csrfToken);
    var fileManagerJson = new URL(fileUploadPath, document.location.href);
    fileManagerJson.searchParams.set('source', 'redactor');
    fileManagerJson.searchParams.set('type', 'file');
    var definedLinks = new URL(pagesPath, document.location.href);
    definedLinks.searchParams.set('source', 'redactor');
    return {
      minHeight: 160,
      autoresize: true,
      buttonSource: true,
      formatting: ['p', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6'],
      plugins: ['imagemanager', 'filemanager', 'table', 'video', 'definedlinks'],
      lang: CMS.getLocale(),
      convertDivs: false,
      imageUpload: imageUpload,
      imageManagerJson: imageManagerJson,
      fileUpload: fileUpload,
      fileManagerJson: fileManagerJson,
      definedLinks: definedLinks
    };
  };

  var redactorInstances = [];
  window.CMS.wysiwyg = {
    init: function init() {
      var root = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : document;
      var textareas = root.querySelectorAll('textarea.rich-text-editor, textarea[data-cms-rich-text]');
      if (textareas.length === 0) return;
      var redactorOptions = buildRedactorOptions();
      var _iteratorNormalCompletion = true;
      var _didIteratorError = false;
      var _iteratorError = undefined;

      try {
        for (var _iterator = textareas[Symbol.iterator](), _step; !(_iteratorNormalCompletion = (_step = _iterator.next()).done); _iteratorNormalCompletion = true) {
          var textarea = _step.value;
          redactorInstances.push(new jQuery.Redactor(textarea, redactorOptions));
        }
      } catch (err) {
        _didIteratorError = true;
        _iteratorError = err;
      } finally {
        try {
          if (!_iteratorNormalCompletion && _iterator.return != null) {
            _iterator.return();
          }
        } finally {
          if (_didIteratorError) {
            throw _iteratorError;
          }
        }
      }
    },
    dispose: function dispose() {
      var _iteratorNormalCompletion2 = true;
      var _didIteratorError2 = false;
      var _iteratorError2 = undefined;

      try {
        for (var _iterator2 = redactorInstances[Symbol.iterator](), _step2; !(_iteratorNormalCompletion2 = (_step2 = _iterator2.next()).done); _iteratorNormalCompletion2 = true) {
          var redactor = _step2.value;
          redactor.core.destroy();
        }
      } catch (err) {
        _didIteratorError2 = true;
        _iteratorError2 = err;
      } finally {
        try {
          if (!_iteratorNormalCompletion2 && _iterator2.return != null) {
            _iterator2.return();
          }
        } finally {
          if (_didIteratorError2) {
            throw _iteratorError2;
          }
        }
      }

      redactorInstances.length = 0;
    }
  };
})();
