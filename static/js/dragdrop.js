jsProtect(function() {
  window.addEventListener("load", function(event) {
    jsProtect(function() {
      var originalElement;
      var draggedElement;
      var mouseX;
      var mouseY;
      var mouseOffsetX;
      var mouseOffsetY;
      var elementOffsetX;
      var elementOffsetY;
      var dropFunc;
      var dragElement = function(element, func) {
        //if (typeof(element) == "string") element = document.getElementById(element);
        originalElement = element;
        draggedElement = originalElement.cloneNode(true);
        originalElement.style.visibility = "hidden";
        draggedElement.style.margin = 0;
        draggedElement.style.position = "absolute";
        draggedElement.style.left = elementOffsetX = originalElement.offsetLeft;
        draggedElement.style.top  = elementOffsetY = originalElement.offsetTop;
        draggedElement.style.width  = originalElement.clientWidth;
        draggedElement.style.height = originalElement.clientHeight;
        draggedElement.style.backgroundColor = "#eee";
        draggedElement.style.opacity = 0.8;
        originalElement.offsetParent.appendChild(draggedElement);
        draggedElement.style.width = originalElement.clientWidth + "px";
        draggedElement.style.height = originalElement.clientHeight + "px";
        draggedElement.style.left = originalElement.offsetLeft + "px";
        draggedElement.style.top = originalElement.offsetTop + "px";
        mouseOffsetX = mouseX;
        mouseOffsetY = mouseY;
        dropFunc = func;
      };
      window.addEventListener("mousemove", function(event) {
        jsProtect(function() {
          mouseX = event.pageX;
          mouseY = event.pageY;
          if (draggedElement) {
            draggedElement.style.left = elementOffsetX + mouseX - mouseOffsetX + "px";
            draggedElement.style.top  = elementOffsetY + mouseY - mouseOffsetY + "px";
          }
        });
      }, true);
      var mouseDrop = function(event) {
        jsProtect(function() {
          if (draggedElement) {
            dropFunc(
              originalElement,
              elementOffsetX + mouseX - mouseOffsetX,
              elementOffsetY + mouseY - mouseOffsetY
            );
            originalElement.style.visibility = '';
            draggedElement.parentNode.removeChild(draggedElement);
            originalElement = null;
            draggedElement = null;
          }
        });
      };
      window.addEventListener("mouseup",   mouseDrop, true);
      window.addEventListener("mousedown", mouseDrop, true);
      var elements = document.getElementsByTagName("*");
      for (var i=0; i<elements.length; i++) {
        var element = elements[i];
        if (element.className == "movable") {
          element.addEventListener("mousedown", function(event) {
            jsProtect(function() {
              event.target.style.cursor = "move";
              dragElement(event.currentTarget, function(element, dropX, dropY) {
                event.target.style.cursor = '';
                elementDropped(element, dropX, dropY);
              });
              event.preventDefault();
            });
          }, false);
        } else if (element.classList.contains("clickable")) {
          element.addEventListener("mousedown", function(event) {
            jsProtect(function() {
              event.stopPropagation();
            });
          }, false);
        }
      }
    });
  }, false);
});
