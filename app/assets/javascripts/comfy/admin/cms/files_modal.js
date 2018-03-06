// Site files modal.
(() => {
  let modal = null;

  const initModalContent = (modalContent) => {
    window.CMS.fileUpload.init(modalContent);
    window.CMS.fileLinks(modalContent);
    modalContent.addEventListener('dragstart', (evt) => {
      if (evt.target.nodeType === Node.ELEMENT_NODE &&
          evt.target.matches('.cms-uploader-filelist .item-title a') && modal != null) {
        modal.hide();
      }
    });
  };

  window.CMS.files = {
    init() {
      const modalToggle = document.querySelector('.cms-files-open-modal');
      const modalContainer = document.querySelector('.cms-files-modal');
      if (modalToggle === null || modalContainer === null) return;
      const modalContent = modalContainer.querySelector('.modal-content');
      modalToggle.addEventListener('click', (evt) => {
        evt.preventDefault();
        fetch(modalContainer.dataset.url, {credentials: 'same-origin'}).then((resp) => resp.text()).then((html) => {
          modalContent.innerHTML = `<div class="modal-body">${html}</div>`;
          initModalContent(modalContent);
        });
        modal = modal || new bootstrap.Modal(modalContainer);
        modal.show();
      });
    },
    dispose() {
      if (modal !== null) {
        modal.hide();
        modal.dispose();
        modal = null;
      }
    }
  };
})();
