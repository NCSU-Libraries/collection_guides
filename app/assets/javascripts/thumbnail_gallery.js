class ThumbnailGallery {

  constructor(config) {
    this.#initialize(config);
  }

  #initialize(config) {
    this.viewerElements = document.getElementsByClassName('thumbnail-viewer');

    if (this.viewerElements.length > 0) {
      this.#activateThumbnailViewers();

      if (this.thumbnailViewers.length > 0) {
        this.#enableThumbnailVisibilityToggle();
      }
      else {
        this.#hideVisibilityToggleIfNoViewers();
      }
    }
  }

  #activateThumbnailViewers() {
    this.thumbnailViewers = [];
    this.totalThumbnailViewers = 0;

    let viewerConfig = {
      thumbnailMaxWidth: 90
    }

    for (let i = 0; i < this.viewerElements.length; i++) {
      let viewerContainer = this.viewerElements[i];
      
      if (viewerContainer) {
        viewerConfig['selector'] = "#" + viewerContainer.id;
        let viewer = new ThumbnailViewer(viewerConfig)
        this.thumbnailViewers.push(viewer);
      }
    }
  }

  #hideAllViewers() {
    for (let i = 0; i < this.thumbnailViewers.length; i++) {
      let viewer = this.thumbnailViewers[i];
      viewer.hide();
    }
  }

  #showAllViewers() {
    for (let i = 0; i < this.thumbnailViewers.length; i++) {
      let viewer = this.thumbnailViewers[i];
      viewer.show();
    }
  }

  anyVisible() {
    for (let i = 0; i < this.thumbnailViewers.length; i++) {
      let viewer = this.thumbnailViewers[i];
      if (viewer.visible()) {
        return true;
      }
    }
    return false;
  }

  #getTopVisibleTreeItemId() {
    const stuckHeader = document.querySelectorAll('.stickable.persistent-header.sticky')[0];

    if (!stuckHeader) {
      return null;
    }
    else {
      const headerOffset = stuckHeader.offsetHeight;
      const main = document.querySelectorAll('main')[0];
      const mainOffset = main.offsetTop;
      const scrollPos = window.scrollY;
      const testPos = scrollPos + headerOffset;
      const treeItems = document.querySelectorAll('.tree-item');

      for (let i = 0; i < treeItems.length; i++) {
        const treeItem = treeItems[i];
        const treeItemPos = treeItem.offsetTop + mainOffset;
        const treeItemId = treeItem.id;

        if (treeItemPos >= testPos) {
          return treeItemId || null;
        }
      }
    }
  }

  #scrollToElement(elementId) {
    let scrollPos = 0;

    if (elementId) {
      const main = document.querySelectorAll('main')[0];
      const mainOffset = main.offsetTop;
      const el = document.getElementById(elementId);
      const stuckHeader = document.querySelectorAll('.stickable.persistent-header.sticky')[0];
      const headerOffset = stuckHeader.offsetHeight;
      scrollPos = (el.offsetTop + mainOffset) - headerOffset;
    }

    window.scroll(0, scrollPos);
  }

  #enableThumbnailVisibilityToggle() {
    const _this = this;
    const toggleWrapper = document.getElementsByClassName('thumbnail-visibility-toggle')[0];

    if (toggleWrapper) {
      const toggle = document.createElement("span");
      const toggleShowText = '<i class="far fa-images" aria-hidden="true"></i>Show all digitized content';
      const toggleHideText = '<i class="fas fa-eye-slash" aria-hidden="true"></i>Hide all digitized content';
      toggle.classList.add('link', 'visibility-toggle');
      
      if (this.anyVisible()) {
        toggle.setAttribute('data-toggle-mode', 'hide');
        toggle.innerHTML = toggleHideText;
      }
      else {
        toggle.setAttribute('data-toggle-mode', 'show');
        toggle.innerHTML = toggleShowText;
      }

      toggle.addEventListener('click', function() {
        const topVisibleElementId = _this.#getTopVisibleTreeItemId();
        const mode = this.getAttribute('data-toggle-mode');

        if (mode == 'hide') {
          _this.#hideAllViewers();
          toggle.innerHTML = toggleShowText;
          toggle.setAttribute('data-toggle-mode', 'show');
        }
        else if (mode == 'show') {
          _this.#showAllViewers();
          toggle.innerHTML = toggleHideText;
          toggle.setAttribute('data-toggle-mode', 'hide');
        }
        
        _this.#scrollToElement(topVisibleElementId);
      });

      toggleWrapper.appendChild(toggle);
    }
  }

  // Remove visibility toggle if all viewres were deleted because there were no images in manifests
  // This function will be passed as callback to ThumbnailViewer on last iteration
  #hideVisibilityToggleIfNoViewers() {
    if (this.thumbnailViewers.length == 0) {
      const toggleWrapper = document.getElementsByClassName('thumbnail-visibility-toggle')[0];
      if (toggleWrapper) {
        hide(toggleWrapper);
      }
    }
  }
}
