// Site files modal.
(() => {
  const HIDE_FILES_MODAL_MESSAGE = 'hideFilesModal';

  // The files modal embeds an iframe that runs all of Comfy JavaScript, including this code.
  if (window.parent !== window) {
    const onIframeDragStart = (evt) => {
      if (evt.target.nodeType === Node.ELEMENT_NODE &&
          evt.target.matches('.cms-uploader-filelist .item-title a')) {
        window.parent.postMessage(HIDE_FILES_MODAL_MESSAGE, document.origin)
      }
    };
    window.CMS.files = {
      init() {
        document.addEventListener('dragstart', onIframeDragStart);
      },
      dispose() {
        document.removeEventListener('dragstart', onIframeDragStart);
      }
    };
  } else {
    let modal = null;
    const onParentWindowMessage = (evt) => {
      if (evt.origin !== document.origin || evt.data !== HIDE_FILES_MODAL_MESSAGE || modal === null) return;
      modal.hide();
    };
    window.CMS.files = {
      init() {
        const modalContainer = document.querySelector('.cms-files-modal');
        const modalToggle = document.querySelector('.cms-files-open-modal');
        if (modalToggle === null) return;
        modalToggle.addEventListener('click', (evt) => {
          evt.preventDefault();
          const iframe = modalContainer.querySelector('iframe');
          if (iframe.getAttribute('src') !== modalContainer.dataset.iframeSrc) {
            iframe.setAttribute('src', modalContainer.dataset.iframeSrc)
          }
          modal = modal || new bootstrap.Modal(modalContainer);
          modal.show();
        });
        window.addEventListener('message', onParentWindowMessage);
      },
      dispose() {
        if (modal !== null) {
          modal.hide();
          modal.dispose();
          modal = null;
        }
        window.removeEventListener('message', onParentWindowMessage);
      }
    };
  }
})();
