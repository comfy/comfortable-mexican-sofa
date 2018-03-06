//= require comfy/vendor/moxie.min
//= require comfy/vendor/plupload.dev

(() => {
  const DROP_TARGET_ACTIVE_CLASS = 'cms-uploader-drag-drop-target-active';

  class FileUpload {
    constructor(container, settings) {
      if (!container.id) container.id = plupload.guid();
      settings = Object.assign(FileUpload.defaultUploaderSettings(container.id), settings);
      this.ui = {
        container,
        list: container.querySelector('.cms-uploader-filelist'),
        dropElement: container.querySelector(`#${settings.drop_element}`),
      };
      this.cleanupFns = [];
      this.uploader = new plupload.Uploader(settings);
      this.uploader.bind('PostInit', () => this.onUploaderPostInit());
      this.uploader.bind('Error', (_uploader, error) => this.onUploaderError(error));
      this.uploader.bind('FilesAdded', (_uploader, files) => this.onUploaderFilesAdded(files));
      this.uploader.bind('UploadProgress', (_uploader, file) => this.onUploaderUploadProgress(file));
      this.uploader.bind('FileUploaded', (_uploader, file, info) => this.onUploaderFileUploaded(file, info));
      this.uploader.bind('FilesRemoved', (_uploader, files) => this.onUploaderFilesRemoved(files));
      this.uploader.init();
      if (settings.setup) {
        settings.setup(this.uploader);
      }
    }

    destroy() {
      this.uploader.destroy();
      for (const cleanupFn of this.cleanupFns) {
        cleanupFn();
      }
    }

    addCleanup(cleanupFn) {
      this.cleanupFns.push(cleanupFn);
    }

    onUploaderPostInit() {
      // Show drag and drop info and attach events only if drag and drop is enabled and supported.
      if (!this.uploader.settings.dragdrop || !this.uploader.features.dragdrop) {
        this.ui.container.querySelector('.cms-uploader-drag-drop-info').style.display = 'none';
        return;
      }
      // When dragging over the document add a class to the drop target that puts it on top of every element and remove
      // that class when dropping or leaving the drop target. Otherwise the dragleave event would fire whenever we drag
      // over a child element inside the drop target such as text nodes.
      const onDragEnter = (e) => {
        // Only react to drag'n'drops that contain a file. See:
        // https://developer.mozilla.org/en-US/docs/Web/API/DataTransfer/types
        if (e.dataTransfer.types.includes('Files')) {
          this.ui.dropElement.classList.add(DROP_TARGET_ACTIVE_CLASS);
        }
      };
      document.addEventListener('dragenter', onDragEnter);
      this.addCleanup(() => {
        document.removeEventListener('dragenter', onDragEnter);
      });
      for (const eventName of ['drop', 'dragleave']) {
        this.ui.dropElement.addEventListener(eventName, () => {
          this.ui.dropElement.classList.remove(DROP_TARGET_ACTIVE_CLASS);
        });
      }
    }

    onUploaderError(error) {
      if (error.code === plupload.INIT_ERROR) {
        window.alert('Error: Initialisation error. Reload to try again.');
        return;
      }
      const file = error.file;
      if (!file) return;
      // Get error message from the server response. Not all runtimes support this.
      let message = error.response;
      // If no error message is in the server response get standard plupload error messages.
      // This will have descriptive error message for something like file size or file format errors but for
      // server errors it will only display a general error message.
      if (!message) {
        message = error.message;
        if (error.details) message += ` (${error.details})`;
      }
      file.status = plupload.FAILED;
      file.error_message = message;
      this.updateFileStatus(file);
    }

    onUploaderFilesAdded(files) {
      for (const file of files) {
        this.addFile(file);
      }
      // Auto start upload when files are added.
      this.uploader.start();
    }

    onUploaderUploadProgress(file) {
      this.updateFileStatus(file);
    }

    onUploaderFileUploaded(file, info) {
      // Replace the dummy file entry in the file list with the the entry from the server response.
      const template = document.createElement('template');
      template.innerHTML = info.response;
      const newListItem = template.content.firstElementChild;
      this.ui.list.replaceChild(newListItem, this.fileListItem(file));
      window.CMS.fileLinks(newListItem);
    }

    onUploaderFilesRemoved(files) {
      for (const file of files) {
        this.removeFile(file);
      }
    }

    addFile(file) {
      this.ui.list.insertAdjacentHTML('afterbegin', FileUpload.buildListItemHTML(file));
      this.fileListItem(file).querySelector('.cms-uploader-file-delete').addEventListener('click', (evt) => {
        evt.preventDefault();
        this.uploader.removeFile(file);
      });
      this.updateFileStatus(file);
    }

    removeFile(file) {
      this.fileListItem(file).remove();
    }

    updateFileStatus(file) {
      const progressBar = this.fileListItem(file).querySelector('.progress-bar');
      switch (file.status) {
        case plupload.UPLOADING:
          progressBar.style.width = `${file.percent}%`;
          break;
        case plupload.FAILED:
          progressBar.style.width = '100%';
          progressBar.classList.add('progress-bar-danger');
          progressBar.querySelector('span').innerHTML = file.error_message;
          break;
      }
    }

    fileListItem({id}) {
      return this.ui.container.querySelector(`#${id}`);
    }

    static buildListItemHTML({id, name}) {
      return `<li id='${id}' class='row temp'>
        <div class='col-md-9 d-flex align-items-center'>
          <div class='progress'>
            <div class='progress-bar progress-bar-striped progress-bar-animated'>
              <span>${name}</span>
            </div>
          </div>
        </div>
        <div class='col-md-3 d-flex align-items-center justify-content-md-end'>
          <a class='btn btn-sm btn-danger float-right cms-uploader-file-delete' href='#'>Delete</a>
        </div>
      </li>`;
    }

    static defaultUploaderSettings(id) {
      return {
        runtimes: 'html5,browserplus,silverlight,flash,gears',
        dragdrop: true,
        drop_element: `${id}-drag-drop-target`,
        browse_button: `${id}-browse`,
        container: id,
        file_data_name: 'file[file]',
      };
    }
  }

  const uploaders = [];
  window.CMS.fileUpload = {
    init(root = document) {
      const el = root.querySelector('#cms-uploader');
      if (el === null) return;
      uploaders.push(new FileUpload(el, {
        url: el.dataset.cmsUploaderUrl,
        multipart_params: {
          [el.dataset.cmsUploaderTokenName]: el.dataset.cmsUploaderTokenValue,
          [el.dataset.cmsUploaderSessionName]: el.dataset.cmsUploaderSessionValue
        }
      }));
    },
    dispose() {
      for (const uploader of uploader) {
        uploader.dispose();
      }
      uploaders.length = 0;
    }
  };
})();
