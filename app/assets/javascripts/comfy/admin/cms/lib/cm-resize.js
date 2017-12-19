// https://github.com/Sphinxxxx/cm-resize/blob/v0.1/src/cm-resize.js
// License: MIT
function cmResize(cm, config) {
  config = config || {};

  const minW = config.minWidth  || 200,
      minH = config.minHeight || 100,
      resizeW = (config.resizableWidth  !== false),
      resizeH = (config.resizableHeight !== false);

  const cmElement = cm.display.wrapper,
      cmHandle = config.handle || (function() {
        const h = cmElement.appendChild(document.createElement('div'));
        h.className = 'cm-drag-handle';
        h.style = ''
            + 'position: absolute;'
            + 'bottom:0; right:0;'
            + 'z-index: 999;'
            + 'width:15px; height:15px;'
            + 'cursor: pointer;'
            + 'color: gray;'
            + 'background: repeating-linear-gradient(135deg, transparent, transparent 2px, currentColor 0, currentColor 4px);'
        ;
        return h;
      })();

  let startX, startY,
      startW, startH;

  function isLeftButton(e) {
    //https://developer.mozilla.org/en-US/docs/Web/API/MouseEvent/buttons
    return (e.buttons !== undefined)
        ? (e.buttons === 1)
        : (e.which === 1) /* Safari (not tested) */;
  }

  function onDrag(e) {
    if(!isLeftButton(e)) {
      //Mouseup outside of window:
      onRelease(e);
      return;
    }
    e.preventDefault();

    const w = resizeW ? Math.max(minW, (startW + e.clientX - startX)) : null,
        h = resizeH ? Math.max(minH, (startH + e.clientY - startY)) : null;
    cm.setSize(w, h);

    //Leave room for our default drag handle when only one scrollbar is visible:
    if(!config.handle) {
      cmElement.querySelector('.CodeMirror-vscrollbar').style.bottom = '15px';
      cmElement.querySelector('.CodeMirror-hscrollbar').style.right = '15px';
    }
  }

  function onRelease(e) {
    e.preventDefault();

    window.removeEventListener("mousemove", onDrag);
    window.removeEventListener("mouseup", onRelease);
  }

  cmHandle.addEventListener("mousedown", function (e) {
    if(!isLeftButton(e)) { return; }
    e.preventDefault();

    startX = e.clientX;
    startY = e.clientY;
    startH = cmElement.offsetHeight;
    startW = cmElement.offsetWidth;

    window.addEventListener("mousemove", onDrag);
    window.addEventListener("mouseup", onRelease);
  });
}
