(() => {
  const codeMirrorInstances = [];
  window.CMS.codemirror = {
    init(root = document) {
      for (const textarea of root.querySelectorAll('textarea[data-cms-cm-mode]')) {
        const codemirror = CodeMirror.fromTextArea(textarea, {
          mode: textarea.dataset.cmsCmMode,
          tabSize: 2,
          lineWrapping: true,
          autoCloseTags: true,
          lineNumbers: true,
          viewportMargin: Infinity
        });
        codeMirrorInstances.push(codemirror);
      }

      const tabsRoot = root.id === 'form-fragments' ? root : root.querySelector('#form-fragments');
      jQuery(tabsRoot).find('a[data-toggle="tab"]').on('shown.bs.tab', () => {
        for (const codemirror of codeMirrorInstances) {
          codemirror.refresh();
        }
      });
    },
    dispose() {
      for (const codemirror of codeMirrorInstances) {
        codemirror.toTextArea();
      }
      codeMirrorInstances.length = 0;
    }
}
})();
