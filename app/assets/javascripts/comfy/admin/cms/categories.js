(() => {
  window.CMS.categories = (root = document) => {
    const widget = root.querySelector('.categories-widget');
    if (widget === null) return;
    const readSection = widget.querySelector('.read');
    const editSection = widget.querySelector('.editable');
    widget.querySelector('.read button.toggle-cat-edit').addEventListener('click', () => {
      readSection.style.display = 'none';
      editSection.style.display = 'block';
    });
    widget.querySelector('.editable button.toggle-cat-edit').addEventListener('click', () => {
      editSection.style.display = 'none';
      readSection.style.display = 'block';
    });
  };
})();

