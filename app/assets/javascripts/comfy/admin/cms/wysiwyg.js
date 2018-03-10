(() => {
  const Rails = window.Rails;
  const buildRedactorOptions = () => {
    const fileUploadPath = document.querySelector('meta[name="cms-file-upload-path"]').content;
    const pagesPath = document.querySelector('meta[name="cms-pages-path"]').content;
    const csrfParam = Rails.csrfParam();
    const csrfToken = Rails.csrfToken();

    const imageUpload = new URL(fileUploadPath, document.location.href);
    imageUpload.searchParams.set('source', 'redactor');
    imageUpload.searchParams.set('type', 'image');
    imageUpload.searchParams.set(csrfParam, csrfToken);

    const imageManagerJson = new URL(fileUploadPath, document.location.href);
    imageManagerJson.searchParams.set('source', 'redactor');
    imageManagerJson.searchParams.set('type', 'image');

    const fileUpload = new URL(fileUploadPath, document.location.href);
    fileUpload.searchParams.set('source', 'redactor');
    fileUpload.searchParams.set('type', 'file');
    fileUpload.searchParams.set(csrfParam, csrfToken);

    const fileManagerJson = new URL(fileUploadPath, document.location.href);
    fileManagerJson.searchParams.set('source', 'redactor');
    fileManagerJson.searchParams.set('type', 'file');

    const definedLinks = new URL(pagesPath, document.location.href);
    definedLinks.searchParams.set('source', 'redactor');

    return {
      minHeight: 160,
      autoresize: true,
      buttonSource: true,
      formatting: ['p', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6'],
      plugins: ['imagemanager', 'filemanager', 'table', 'video', 'definedlinks'],
      lang: CMS.getLocale(),
      convertDivs: false,
      imageUpload,
      imageManagerJson,
      fileUpload,
      fileManagerJson,
      definedLinks
    };
  };

  const redactorInstances = [];
  window.CMS.wysiwyg = {
    init(root = document) {
      const textareas = root.querySelectorAll('textarea.rich-text-editor, textarea[data-cms-rich-text]');
      if (textareas.length === 0) return;
      const redactorOptions = buildRedactorOptions();
      for (const textarea of textareas) {
        redactorInstances.push(new jQuery.Redactor(textarea, redactorOptions));
      }
    },
    dispose() {
      for (const redactor of redactorInstances) {
        redactor.core.destroy();
      }
      redactorInstances.length = 0;
    }
  }
})();


