(() => {
  const isFirefox = /\bFirefox\//.test(navigator.userAgent);

  class FileLink {
    constructor(link) {
      this.link = link;
      this.isImage = !!link.dataset.cmsFileThumbUrl;

      link.addEventListener('dragstart', (evt) => {
        evt.dataTransfer.setData('text/plain', this.link.dataset.cmsFileLinkTag);
      });

      if (this.isImage) {
        new bootstrap.Popover(link, {
          container: link.parentElement,
          trigger: 'hover',
          placement: 'top',
          content: this.buildFileThumbnail(),
          html: true
        });

        link.addEventListener('dragstart', (evt) => {
          evt.dataTransfer.setDragImage(this.buildFileThumbnail(), 4, 2);
          this.getPopover().hide();
        });

        this.workAroundFirefoxPopoverGlitch();
      }
    }

    buildFileThumbnail() {
      const img = new Image();
      img.src = this.link.dataset.cmsFileThumbUrl;
      return img;
    }

    // To work around a Firefox bug causing the popover to re-appear after the drop:
    // https://github.com/comfy/comfortable-mexican-sofa/pull/799#issuecomment-369124161
    //
    // Possibly related to:
    // https://bugzilla.mozilla.org/show_bug.cgi?id=505521
    workAroundFirefoxPopoverGlitch() {
      if (!isFirefox) return;
      this.link.addEventListener('dragstart', () => {
        this.getPopover().disable();
      });
      this.link.addEventListener('dragend', () => {
        setTimeout(() => {
          const popover = this.getPopover();
          popover.enable();
          popover.hide();
        }, 300);
      });
    }

    // We can't keep a reference to the Popover object, because Bootstrap re-creates it internally.
    getPopover() {
      return jQuery(this.link).data(bootstrap.Popover.DATA_KEY);
    }
  }

  window.CMS.fileLinks = (root = document) => {
    for (const link of root.querySelectorAll('[data-cms-file-link-tag]')) {
      new FileLink(link);
    }
  };
})();
