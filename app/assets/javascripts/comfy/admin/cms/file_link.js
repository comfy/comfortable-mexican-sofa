"use strict";

function _instanceof(left, right) { if (right != null && typeof Symbol !== "undefined" && right[Symbol.hasInstance]) { return !!right[Symbol.hasInstance](left); } else { return left instanceof right; } }

function _classCallCheck(instance, Constructor) { if (!_instanceof(instance, Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function _createClass(Constructor, protoProps, staticProps) { if (protoProps) _defineProperties(Constructor.prototype, protoProps); if (staticProps) _defineProperties(Constructor, staticProps); return Constructor; }

(function () {
  var isFirefox = /\bFirefox\//.test(navigator.userAgent);

  var FileLink =
  /*#__PURE__*/
  function () {
    function FileLink(link) {
      var _this = this;

      _classCallCheck(this, FileLink);

      this.link = link;
      this.isImage = !!link.dataset.cmsFileThumbUrl;
      link.addEventListener('dragstart', function (evt) {
        evt.dataTransfer.setData('text/plain', _this.link.dataset.cmsFileLinkTag);
      });

      if (this.isImage) {
        new bootstrap.Popover(link, {
          container: link.parentElement,
          trigger: 'hover',
          placement: 'top',
          content: this.buildFileThumbnail(),
          html: true
        });
        link.addEventListener('dragstart', function (evt) {
          evt.dataTransfer.setDragImage(_this.buildFileThumbnail(), 4, 2);

          _this.getPopover().hide();
        });
        this.workAroundFirefoxPopoverGlitch();
      }
    }

    _createClass(FileLink, [{
      key: "buildFileThumbnail",
      value: function buildFileThumbnail() {
        var img = new Image();
        img.src = this.link.dataset.cmsFileThumbUrl;
        return img;
      } // To work around a Firefox bug causing the popover to re-appear after the drop:
      // https://github.com/comfy/comfortable-mexican-sofa/pull/799#issuecomment-369124161
      //
      // Possibly related to:
      // https://bugzilla.mozilla.org/show_bug.cgi?id=505521

    }, {
      key: "workAroundFirefoxPopoverGlitch",
      value: function workAroundFirefoxPopoverGlitch() {
        var _this2 = this;

        if (!isFirefox) return;
        this.link.addEventListener('dragstart', function () {
          _this2.getPopover().disable();
        });
        this.link.addEventListener('dragend', function () {
          setTimeout(function () {
            var popover = _this2.getPopover();

            popover.enable();
            popover.hide();
          }, 300);
        });
      } // We can't keep a reference to the Popover object, because Bootstrap re-creates it internally.

    }, {
      key: "getPopover",
      value: function getPopover() {
        return jQuery(this.link).data(bootstrap.Popover.DATA_KEY);
      }
    }]);

    return FileLink;
  }();

  window.CMS.fileLinks = function () {
    var root = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : document;
    var _iteratorNormalCompletion = true;
    var _didIteratorError = false;
    var _iteratorError = undefined;

    try {
      for (var _iterator = root.querySelectorAll('[data-cms-file-link-tag]')[Symbol.iterator](), _step; !(_iteratorNormalCompletion = (_step = _iterator.next()).done); _iteratorNormalCompletion = true) {
        var link = _step.value;
        new FileLink(link);
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
  };
})();
