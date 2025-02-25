class ContentsList {

  constructor() {
    this.resourceTree = document.querySelector('.resource-tree');
    if (this.resourceTree) {
      this.initialize();
    }
  }

  #disableSeriesNavLinks() {
    const element = document.querySelector('.series-nav');

    if (element) {
      const links = element.querySelectorAll('ul li a');

      for (let link of links) {
        link.classList.add('disabled');

        link.addEventListener('click', function(event) {
          event.preventDefault();
        });
      }
    }
  }

  #enableSeriesNav() {
    const element = document.querySelector('.series-nav');
  
    if (element) {
      const links = element.querySelectorAll('ul li a');
  
      for (let link of links) {
        let deepLinkTargetId = link.getAttribute('href').replace(/#/,'');
        link.classList.remove('disabled');

        link.addEventListener('click', function(event) {
          deepLinkToId(deepLinkTargetId, { 'highlight': false });
          event.preventDefault();
        });
      }
      return element;
    }
  }

  #generateLoadIndicator() {
    const _this = this;
    this.loadIndicator = { 'loaded': 0 };
    let mode = null; // Changed from const to let
    // create elements
    const indicatorElement = document.createElement('div');
    const indicatorText = document.createElement('div');
    const indicatorBar = document.createElement('div');
  
    if (this.targetArchivalObjectId) {
      mode = 'wait';
    }
    else if (currentTab() != 'contents') {
      mode = 'hide';
    }
    
    indicatorElement.setAttribute('id', 'load-indicator');
    indicatorText.setAttribute('id', 'loading-text');
    indicatorText.append('Loading');
    indicatorBar.setAttribute('id', 'indicator-bar');
    indicatorBar.classList.add('percent-0');
    indicatorElement.append(indicatorText, indicatorBar);
    this.loadIndicator.element = indicatorElement;
    this.loadIndicator.textElement = indicatorText;
    this.loadIndicator.bar = indicatorBar;
  
    if (mode == 'wait') {
      this.loadIndicator.element.classList.add('wait');
    }
    else if (mode == 'hide') {
      this.loadIndicator.element.classList.add('hidden');
    }
  
    this.loadIndicator.textElement.innerHTML = 'Loading (0/' + this.treeSize + ')';
  
    document.querySelector('main').append(this.loadIndicator.element);
  
    this.loadIndicator.update = function() {
      const total = _this.treeSize;
      const scale = 2;
      let loaded = _this.totalLoaded;
      let percent = (loaded / total) * 100;
      let scaledPercent = Math.floor(percent/scale) * scale;
      let percentClass = 'percent-' + scaledPercent;
      _this.loadIndicator.loaded = loaded;
      _this.loadIndicator.textElement.innerHTML= 'Loading (' + loaded + '/' + total + ')';
  
      if (!_this.loadIndicator.bar.classList.contains(percentClass)) {
        _this.loadIndicator.bar.removeAttribute('class');
        _this.loadIndicator.bar.classList.add(percentClass);
      }
  
      if (percent >= 100) {
        _this.loadIndicator.element.classList.add('complete');
        hide(_this.loadIndicator.element);
      }
    }
  
    this.loadIndicator.waitOff = function() {
      _this.loadIndicator.indicator.classList.remove('wait');
    }
  }

  #calculateDeepLinkOffset() {
    const stickable = document.querySelector('.stickable');
    const offset = stickable.offsetHeight;
    this.deepLinkOffset = offset;
    return offset;
  }

  #deepLink(element, options) {
    const _this = this;
    this.#calculateDeepLinkOffset();
  
    function deepLinkToPrevious() {
      const prevSibling = element.previousElementSibling;
      if (prevSibling) {
        let prevSiblingTargetPos = prevSibling.getBoundingClientRect().top + window.scrollY;
        prevSiblingTargetPos = prevSiblingTargetPos - _this.deepLinkOffset;
        window.scrollTo(0, prevSiblingTargetPos);
      }
    }
  
    function delayedDeepLink() {
      // recalculate offset
      _this.#calculateDeepLinkOffset();
      options = options || {};
      let targetPos = element.getBoundingClientRect().top + window.scrollY;
      targetPos = targetPos - _this.deepLinkOffset;
      window.scrollTo(0, targetPos);
  
      if (options['highlight']) {
        element.classList.add('highlight');
      }
    }
  
    // Link to previous sibling to trigger sticky series title first
    deepLinkToPrevious();
    // Wait for stickyseries title to execute then scroll to position
    setTimeout(delayedDeepLink, 10);
  
    return element;
  }

  #loadResourceTree(element, level) {
    const _this = this;
    element = element || this.resourceTree;
    const itemsSelector = level ? ('.skeleton-tree-item.tree-item-' + level) : '.skeleton-tree-item';
    const items = element.querySelectorAll(itemsSelector);
    let deepLinkTarget;
    let deepLinkTargetIndex;
    let batchSize = 50;
    let i = 0;
    let batch = [];
    let retrieved = 0;
  
    if (this.targetArchivalObjectId) {
      deepLinkTarget = document.querySelector('[data-archival-object-id="' + this.targetArchivalObjectId + '"]');
      deepLinkTargetIndex = Array.from(items).indexOf(deepLinkTarget);
    }
  
    function priorElementsLoaded() {
      if (deepLinkTargetIndex) {
        let priorElements = Array.from(items).slice(0, deepLinkTargetIndex);
        let pendingElements = priorElements.filter(function(el) { return !el.classList.contains('loaded'); })
        return pendingElements.length == 0;
      }
      else {
        return true;
      }
    }
  
    function executeDeepLink(element, options) {
      if (element) {
        if (priorElementsLoaded()) {
          _this.#deepLink(element, options);
          _this.loadIndicator.waitOff();
        }
        else {
          setTimeout(function() { executeDeepLink(element); }, 500);
        }
      }
    }
  
    function loadTreeItem(id, data) {
      const el = document.querySelector('.skeleton-tree-item#archival-object-' + id);
      const firstChild = el.firstChild;
      const item = htmlToElement(data);
      el.insertBefore(item, firstChild);
      el.classList.add('loaded');
  
      if (el.getAttribute('id') == _this.targetArchivalObjectId) {
        executeDeepLink(el, { highlight: true });
      }
    }

    for (let item of items) {
      const archivalObjectId = item.getAttribute('data-archival-object-id');
      batch.push(archivalObjectId);
      i++;
  
      // Process batch and reset
      if ( (batch.length == batchSize) || (i == items.length) ) {
        let url = rootUrl() + 'archival_objects/batch?ids=' + batch.join(',');
  
        getUrl(url, function(data) {
          data = JSON.parse(data);
          let first = Object.keys(data)[0];
  
          for (var key in data) {
            retrieved++;
  
            if (data.hasOwnProperty(key)) {
              loadTreeItem(key, data[key]);
            }
          }
  
          _this.#updateTotalLoaded(retrieved);
          retrieved = 0;
  
          if (_this.totalLoaded == _this.treeSize) {
            _this.#postLoad();
          }
        });
  
        batch = [];
      }
    }
  }

  initialize() {
    let params = queryParamsFromUrl();
    this.skeletonTreeMode = document.querySelectorAll('.resource-tree.skeleton-tree').length > 0;
    this.targetArchivalObjectId = params.archival_object_id ? ('archival-object-' + params.archival_object_id) : null;

    if (this.targetArchivalObjectId) {
      this.targetArchivalObjectId = this.targetArchivalObjectId.replace(/[^\d]*/,'');
    }

    this.#disableSeriesNavLinks();

    if (this.skeletonTreeMode) {
      this.totalLoaded = 0;
      this.treeSize = document.querySelectorAll('.resource-tree .tree-item').length;
      this.#generateList();
    }
    else {
      this.#postLoad();
    }
  }

  #postLoad() {
    this.#stickySeriesTitle();
    new ThumbnailGallery();
    this.#enableSeriesNav();
    this.#calculateDeepLinkOffset();
    this.#deepLinkToTarget();
  }

  #deepLinkToTarget() {
    this.#calculateDeepLinkOffset();
    if (this.targetArchivalObjectId) {
      let id = 'archival-object-' + this.targetArchivalObjectId;
      let target = document.querySelector('#' + id);
      if (target) {
        return this.#deepLink(target, { highlight: true });
      }
    }
  }

  #generateList() {
      if (this.treeSize > 3000) {
      this.#generateLoadIndicator();
      this.#loadResourceTree(null, 1);
      const items = this.resourceTree.querySelectorAll('.tree-item-1');

      for (let item of items) {
        this.#loadResourceTree(item);
      }
    }
    else {
      this.#loadResourceTree();
    }
  }

  #updateTotalLoaded = function(added) {
    this.totalLoaded = this.totalLoaded + added;
  
    if (this.loadIndicator) {
      this.loadIndicator.update();  
    }
  }

  #stickySeriesTitle() {
    const _this = this;
    const series = document.querySelectorAll('.resource-tree .series-level');
  
    function seriesIndex(s) {
      return Array.from(series).indexOf(s);
    }
  
    for (let el of series) {
      let stickable = document.querySelector('.stickable');
      let stickableOffset = stickable.offsetHeight;
      let titleWrapper = stickable.querySelector('.series-title');
      let treeTop = _this.resourceTree.offsetTop;
      let id = el.getAttribute('data-archival-object-id');
      let title = el.querySelector('.component-title').innerHTML;
  
      if (!titleWrapper) {
        titleWrapper = htmlToElement('<div class="series-title hidden"></div>')
        stickable.append(titleWrapper);
      }
  
      function updateStickyTitle() {
        show(titleWrapper);
        titleWrapper.setAttribute('data-archival-object-id', id);
        titleWrapper.innerHTML = title;
        _this.#calculateDeepLinkOffset();
      };
  
      function resetStickyTitle() {
        hide(titleWrapper);
        titleWrapper.setAttribute('data-archival-object-id', 'bob');
        titleWrapper.innerHTML = '';
        _this.#calculateDeepLinkOffset();
      };
  
      window.addEventListener('scroll', function() {
        // top of series div
        let triggerTop = el.getBoundingClientRect().top + window.scrollY - stickableOffset;
        // bottom of series div
        let triggerBottom = el.offsetHeight + triggerTop;
        let scrollTop = window.scrollY;
        let condition1 = scrollTop > triggerTop;
        let condition2 = scrollTop < triggerBottom;
        let condition3 = titleWrapper.getAttribute('data-archival-object-id') != id;
        let condition4 = scrollTop < triggerTop;
        let condition5 = titleWrapper.getAttribute('data-archival-object-id') == id;
        let condition6 = seriesIndex(el) == 0;
  
        if (condition1 && condition2 && condition3) {
          updateStickyTitle();
          _this.#calculateDeepLinkOffset();
        }
        else if (condition4 && condition5 && condition6) {
          resetStickyTitle();
        }
  
        if (scrollTop < (treeTop - stickableOffset)) {
          titleWrapper.innerHTML = '';
          hide(titleWrapper);
        }
      });
    }
  }
}