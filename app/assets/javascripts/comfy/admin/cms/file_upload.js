"use strict";

function _instanceof(left, right) { if (right != null && typeof Symbol !== "undefined" && right[Symbol.hasInstance]) { return !!right[Symbol.hasInstance](left); } else { return left instanceof right; } }

function _defineProperty(obj, key, value) { if (key in obj) { Object.defineProperty(obj, key, { value: value, enumerable: true, configurable: true, writable: true }); } else { obj[key] = value; } return obj; }

function _classCallCheck(instance, Constructor) { if (!_instanceof(instance, Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function _createClass(Constructor, protoProps, staticProps) { if (protoProps) _defineProperties(Constructor.prototype, protoProps); if (staticProps) _defineProperties(Constructor, staticProps); return Constructor; }

//= require comfy/vendor/moxie.min
//= require comfy/vendor/plupload.dev
(function () {
  var DROP_TARGET_ACTIVE_CLASS = 'cms-uploader-drag-drop-target-active';

  var FileUpload =
  /*#__PURE__*/
  function () {
    function FileUpload(container, settings) {
      var _this = this;

      _classCallCheck(this, FileUpload);

      if (!container.id) container.id = plupload.guid();
      settings = Object.assign(FileUpload.defaultUploaderSettings(container.id), settings);
      this.ui = {
        container: container,
        list: container.querySelector('.cms-uploader-filelist'),
        dropElement: container.querySelector("#".concat(settings.drop_element))
      };
      this.cleanupFns = [];
      this.uploader = new plupload.Uploader(settings);
      this.uploader.bind('PostInit', function () {
        return _this.onUploaderPostInit();
      });
      this.uploader.bind('Error', function (_uploader, error) {
        return _this.onUploaderError(error);
      });
      this.uploader.bind('FilesAdded', function (_uploader, files) {
        return _this.onUploaderFilesAdded(files);
      });
      this.uploader.bind('UploadProgress', function (_uploader, file) {
        return _this.onUploaderUploadProgress(file);
      });
      this.uploader.bind('FileUploaded', function (_uploader, file, info) {
        return _this.onUploaderFileUploaded(file, info);
      });
      this.uploader.bind('FilesRemoved', function (_uploader, files) {
        return _this.onUploaderFilesRemoved(files);
      });
      this.uploader.init();

      if (settings.setup) {
        settings.setup(this.uploader);
      }
    }

    _createClass(FileUpload, [{
      key: "destroy",
      value: function destroy() {
        this.uploader.destroy();
        var _iteratorNormalCompletion = true;
        var _didIteratorError = false;
        var _iteratorError = undefined;

        try {
          for (var _iterator = this.cleanupFns[Symbol.iterator](), _step; !(_iteratorNormalCompletion = (_step = _iterator.next()).done); _iteratorNormalCompletion = true) {
            var cleanupFn = _step.value;
            cleanupFn();
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
      }
    }, {
      key: "addCleanup",
      value: function addCleanup(cleanupFn) {
        this.cleanupFns.push(cleanupFn);
      }
    }, {
      key: "onUploaderPostInit",
      value: function onUploaderPostInit() {
        var _this2 = this;

        // Show drag and drop info and attach events only if drag and drop is enabled and supported.
        if (!this.uploader.settings.dragdrop || !this.uploader.features.dragdrop) {
          this.ui.container.querySelector('.cms-uploader-drag-drop-info').style.display = 'none';
          return;
        } // When dragging over the document add a class to the drop target that puts it on top of every element and remove
        // that class when dropping or leaving the drop target. Otherwise the dragleave event would fire whenever we drag
        // over a child element inside the drop target such as text nodes.


        var onDragEnter = function onDragEnter(e) {
          // Only react to drag'n'drops that contain a file. See:
          // https://developer.mozilla.org/en-US/docs/Web/API/DataTransfer/types
          if (e.dataTransfer.types.includes('Files')) {
            _this2.ui.dropElement.classList.add(DROP_TARGET_ACTIVE_CLASS);
          }
        };

        document.addEventListener('dragenter', onDragEnter);
        this.addCleanup(function () {
          document.removeEventListener('dragenter', onDragEnter);
        });

        for (var _i = 0, _arr = ['drop', 'dragleave']; _i < _arr.length; _i++) {
          var eventName = _arr[_i];
          this.ui.dropElement.addEventListener(eventName, function () {
            _this2.ui.dropElement.classList.remove(DROP_TARGET_ACTIVE_CLASS);
          });
        }
      }
    }, {
      key: "onUploaderError",
      value: function onUploaderError(error) {
        if (error.code === plupload.INIT_ERROR) {
          window.alert('Error: Initialisation error. Reload to try again.');
          return;
        }

        var file = error.file;
        if (!file) return; // Get error message from the server response. Not all runtimes support this.

        var message = error.response; // If no error message is in the server response get standard plupload error messages.
        // This will have descriptive error message for something like file size or file format errors but for
        // server errors it will only display a general error message.

        if (!message) {
          message = error.message;
          if (error.details) message += " (".concat(error.details, ")");
        }

        file.status = plupload.FAILED;
        file.error_message = message;
        this.updateFileStatus(file);
      }
    }, {
      key: "onUploaderFilesAdded",
      value: function onUploaderFilesAdded(files) {
        var _iteratorNormalCompletion2 = true;
        var _didIteratorError2 = false;
        var _iteratorError2 = undefined;

        try {
          for (var _iterator2 = files[Symbol.iterator](), _step2; !(_iteratorNormalCompletion2 = (_step2 = _iterator2.next()).done); _iteratorNormalCompletion2 = true) {
            var file = _step2.value;
            this.addFile(file);
          } // Auto start upload when files are added.

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

        this.uploader.start();
      }
    }, {
      key: "onUploaderUploadProgress",
      value: function onUploaderUploadProgress(file) {
        this.updateFileStatus(file);
      }
    }, {
      key: "onUploaderFileUploaded",
      value: function onUploaderFileUploaded(file, info) {
        // Replace the dummy file entry in the file list with the the entry from the server response.
        var template = document.createElement('template');
        template.innerHTML = info.response;
        var newListItem = template.content.firstElementChild;
        this.ui.list.replaceChild(newListItem, this.fileListItem(file));
        window.CMS.fileLinks(newListItem);
      }
    }, {
      key: "onUploaderFilesRemoved",
      value: function onUploaderFilesRemoved(files) {
        var _iteratorNormalCompletion3 = true;
        var _didIteratorError3 = false;
        var _iteratorError3 = undefined;

        try {
          for (var _iterator3 = files[Symbol.iterator](), _step3; !(_iteratorNormalCompletion3 = (_step3 = _iterator3.next()).done); _iteratorNormalCompletion3 = true) {
            var file = _step3.value;
            this.removeFile(file);
          }
        } catch (err) {
          _didIteratorError3 = true;
          _iteratorError3 = err;
        } finally {
          try {
            if (!_iteratorNormalCompletion3 && _iterator3.return != null) {
              _iterator3.return();
            }
          } finally {
            if (_didIteratorError3) {
              throw _iteratorError3;
            }
          }
        }
      }
    }, {
      key: "addFile",
      value: function addFile(file) {
        var _this3 = this;

        this.ui.list.insertAdjacentHTML('afterbegin', FileUpload.buildListItemHTML(file));
        this.fileListItem(file).querySelector('.cms-uploader-file-delete').addEventListener('click', function (evt) {
          evt.preventDefault();

          _this3.uploader.removeFile(file);
        });
        this.updateFileStatus(file);
      }
    }, {
      key: "removeFile",
      value: function removeFile(file) {
        this.fileListItem(file).remove();
      }
    }, {
      key: "updateFileStatus",
      value: function updateFileStatus(file) {
        var progressBar = this.fileListItem(file).querySelector('.progress-bar');

        switch (file.status) {
          case plupload.UPLOADING:
            progressBar.style.width = "".concat(file.percent, "%");
            break;

          case plupload.FAILED:
            progressBar.style.width = '100%';
            progressBar.classList.add('progress-bar-danger');
            progressBar.querySelector('span').innerHTML = file.error_message;
            break;
        }
      }
    }, {
      key: "fileListItem",
      value: function fileListItem(_ref) {
        var id = _ref.id;
        return this.ui.container.querySelector("#".concat(id));
      }
    }], [{
      key: "buildListItemHTML",
      value: function buildListItemHTML(_ref2) {
        var id = _ref2.id,
            name = _ref2.name;
        return "<li id='".concat(id, "' class='row temp'>\n        <div class='col-md-9 d-flex align-items-center'>\n          <div class='progress'>\n            <div class='progress-bar progress-bar-striped progress-bar-animated'>\n              <span>").concat(name, "</span>\n            </div>\n          </div>\n        </div>\n        <div class='col-md-3 d-flex align-items-center justify-content-md-end'>\n          <a class='btn btn-sm btn-danger float-right cms-uploader-file-delete' href='#'>Delete</a>\n        </div>\n      </li>");
      }
    }, {
      key: "defaultUploaderSettings",
      value: function defaultUploaderSettings(id) {
        return {
          runtimes: 'html5,browserplus,silverlight,flash,gears',
          dragdrop: true,
          drop_element: "".concat(id, "-drag-drop-target"),
          browse_button: "".concat(id, "-browse"),
          container: id,
          file_data_name: 'file[file]'
        };
      }
    }]);

    return FileUpload;
  }();

  var uploaders = [];
  window.CMS.fileUpload = {
    init: function init() {
      var _multipart_params;

      var root = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : document;
      var el = root.querySelector('#cms-uploader');
      if (el === null) return;
      uploaders.push(new FileUpload(el, {
        url: el.dataset.cmsUploaderUrl,
        multipart_params: (_multipart_params = {}, _defineProperty(_multipart_params, el.dataset.cmsUploaderTokenName, el.dataset.cmsUploaderTokenValue), _defineProperty(_multipart_params, el.dataset.cmsUploaderSessionName, el.dataset.cmsUploaderSessionValue), _multipart_params)
      }));
    },
    dispose: function dispose() {
      var _iteratorNormalCompletion4 = true;
      var _didIteratorError4 = false;
      var _iteratorError4 = undefined;

      try {
        for (var _iterator4 = uploader[Symbol.iterator](), _step4; !(_iteratorNormalCompletion4 = (_step4 = _iterator4.next()).done); _iteratorNormalCompletion4 = true) {
          var _uploader2 = _step4.value;

          _uploader2.dispose();
        }
      } catch (err) {
        _didIteratorError4 = true;
        _iteratorError4 = err;
      } finally {
        try {
          if (!_iteratorNormalCompletion4 && _iterator4.return != null) {
            _iterator4.return();
          }
        } finally {
          if (_didIteratorError4) {
            throw _iteratorError4;
          }
        }
      }

      uploaders.length = 0;
    }
  };
})();
