(() => {
  const DATA_ID_ATTRIBUTE = 'data-id';

  const sortableStore = {
    get(sortable) {
      return Array.from(sortable.el.children, (el) => el.getAttribute(DATA_ID_ATTRIBUTE));
    },
    set(sortable) {
      jQuery.ajax({
        url: `${CMS.current_path}/reorder`,
        type: 'POST',
        dataType: 'json',
        data: {
          order: sortable.toArray(),
          _method: 'PUT',
        }
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
