(() => {
  const Rails = window.Rails;
  const DATA_ID_ATTRIBUTE = 'data-id';

  const sortableStore = {
    get(sortable) {
      return Array.from(sortable.el.children, (el) => el.getAttribute(DATA_ID_ATTRIBUTE));
    },
    set(sortable) {
      fetch(`${CMS.current_path}/reorder`, {
        body: JSON.stringify({order: sortable.toArray()}),
        headers: {'Content-Type': 'application/json', 'X-CSRF-Token': Rails.csrfToken()},
        credentials: 'same-origin',
        method: 'PUT',
      });
    }
  };

  const sortableInstances = [];
  window.CMS.sortableList = {
    init(root = document) {
      for (const sortableRoot of root.querySelectorAll('.sortable')) {
        sortableInstances.push(Sortable.create(sortableRoot, {
          handle: '.dragger',
          draggable: 'li',
          dataIdAttr: DATA_ID_ATTRIBUTE,
          store: sortableStore,
          onStart: (evt) => evt.from.classList.add('sortable-active'),
          onEnd: (evt) => evt.from.classList.remove('sortable-active')
        }));
      }
    },
    dispose() {
      for (const sortable of sortableInstances) {
        sortable.destroy();
      }
      sortableInstances.length = 0;
    }
  }
})();
