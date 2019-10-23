"use strict";

// Site files modal.
(function () {
  var modal = null;

  var initModalContent = function initModalContent(modalContent) {
    window.CMS.fileUpload.init(modalContent);
    window.CMS.fileLinks(modalContent);
    modalContent.addEventListener('dragstart', function (evt) {
      if (evt.target.nodeType === Node.ELEMENT_NODE && evt.target.matches('.cms-uploader-filelist .item-title a') && modal != null) {
        modal.hide();
      }
    });
  };

  window.CMS.files = {
    init: function init() {
      var modalToggle = document.querySelector('.cms-files-open-modal');
      var modalContainer = document.querySelector('.cms-files-modal');
      if (modalToggle === null || modalContainer === null) return;
      var modalContent = modalContainer.querySelector('.modal-content');
      modalToggle.addEventListener('click', function (evt) {
        evt.preventDefault();
        fetch(modalContainer.dataset.url, {
          credentials: 'same-origin'
        }).then(function (resp) {
          return resp.text();
        }).then(function (html) {
          modalContent.innerHTML = "<div class=\"modal-body\">".concat(html, "</div>");
          initModalContent(modalContent);
        });
        modal = modal || new bootstrap.Modal(modalContainer);
        modal.show();
      });
    },
    dispose: function dispose() {
      if (modal !== null) {
        modal.hide();
        modal.dispose();
        modal = null;
      }
    }
  };
})();
