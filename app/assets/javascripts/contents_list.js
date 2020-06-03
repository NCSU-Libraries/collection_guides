function ContentsList() {
  this.resourceTree = document.querySelector('.resource-tree');
  if (this.resourceTree) {
    var params = queryParamsFromUrl();
    this.skeletonTreeMode = document.querySelectorAll('.resource-tree.skeleton-tree').length > 0;
    this.targetArchivalObjectId = params.archival_object_id ? ('archival-object-' + params.archival_object_id) : null;

    if (this.targetArchivalObjectId) {
      this.targetArchivalObjectId = this.targetArchivalObjectId.replace(/[^\d]*/,'');
    }

    this.disableSeriesNavLinks();

    if (this.skeletonTreeMode) {
      this.generateList();
    }
    else {
      this.postLoad();
    }
  }
}


ContentsList.prototype.postLoad = function() {
  var _this = this;
  this.stickySeriesTitle();
  this.enableFilesystemBrowseLinks();
  this.thumbnailViewers(function() { _this.stickySeriesTitle(); });
  this.seriesNav();
  this.calculateDeepLinkOffset();
  this.deepLinkToTarget();
}


ContentsList.prototype.calculateDeepLinkOffset = function() {
  var stickable = document.querySelector('.stickable');
  var offset = stickable.offsetHeight;
  this.deepLinkOffset = offset;
  return offset;
}


ContentsList.prototype.deepLinkToTarget = function() {
  console.log('*');
  this.calculateDeepLinkOffset();
  if (this.targetArchivalObjectId) {
    var id = 'archival-object-' + this.targetArchivalObjectId;
    var target = document.querySelector('#' + id);
    return this.deepLink(target, { highlight: true });
  }
}


ContentsList.prototype.deepLink = function(element, options) {
  var _this = this;

  this.calculateDeepLinkOffset();

  function deepLinkToPrevious() {
    var prevSibling = element.previousElementSibling;
    if (prevSibling) {
      var prevSiblingTargetPos = prevSibling.getBoundingClientRect().top + window.scrollY;
      prevSiblingTargetPos = prevSiblingTargetPos - _this.deepLinkOffset;
      window.scrollTo(0, prevSiblingTargetPos);
    }
  }

  function delayedDeepLink() {
    // recalculate offset
    _this.calculateDeepLinkOffset();
    options = options || {};
    var targetPos = element.getBoundingClientRect().top + window.scrollY;
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


ContentsList.prototype.generateList = function() {
  var _this = this;
  this.totalLoaded = 0;
  this.treeSize = document.querySelectorAll('.resource-tree .tree-item').length;

  if (this.treeSize > 3000) {
    this.generateLoadIndicator();
    this.loadResourceTree(null, 1);
    this.resourceTree.querySelectorAll('.tree-item-1').forEach(function(item) {
      _this.loadResourceTree(item);
    });
  }
  else {
    this.loadResourceTree();
  }
}


ContentsList.prototype.updateTotalLoaded = function(added) {
  this.totalLoaded = this.totalLoaded + added;

  if (this.loadIndicator) {
    this.loadIndicator.update();
  }
}


ContentsList.prototype.loadResourceTree = function(element, level) {
  var _this = this;
  element = element || this.resourceTree;
  var itemsSelector = level ? ('.skeleton-tree-item.tree-item-' + level) : '.skeleton-tree-item';
  var items = element.querySelectorAll(itemsSelector);
  var deepLinkTarget;
  var deepLinkTargetIndex;

  if (this.targetArchivalObjectId) {
    deepLinkTarget = document.querySelector('[data-archival-object-id="' + this.targetArchivalObjectId + '"]');
    deepLinkTargetIndex = Array.from(items).indexOf(deepLinkTarget);
  }

  function notLoaded(el) {
    return !el.classList.contains('loaded');
  }

  function priorElementsLoaded() {
    if (deepLinkTargetIndex) {
      var priorElements = Array.from(items).slice(0, deepLinkTargetIndex);
      var pendingElements = priorElements.filter(notLoaded)
      return pendingElements.length == 0;
    }
    else {
      return true;
    }
  }

  function executeDeepLink(element, options) {
    if (priorElementsLoaded()) {
      _this.deepLink(element, options);
      _this.loadIndicator.waitOff();
    }
    else {
      setTimeout(function() { executeDeepLink(element); }, 500);
    }
  }

  function loadTreeItem(id, data) {
    var el = document.querySelector('.skeleton-tree-item#archival-object-' + id);
    var firstChild = el.firstChild;
    var item = htmlToElement(data);
    el.insertBefore(item, firstChild);
    el.classList.add('loaded');

    if (el.getAttribute('id') == _this.targetArchivalObjectId) {
      executeDeepLink(el, { highlight: true });
    }
  }

  var batchSize = 50;
  var i = 0;
  var batch = [];
  var retrieved = 0;

  items.forEach(function(item) {
    var archivalObjectId = item.getAttribute('data-archival-object-id');
    batch.push(archivalObjectId);
    i++;

    // Process batch and reset
    if ( (batch.length == batchSize) || (i == items.length) ) {
      var url = rootUrl() + 'archival_objects/batch?ids=' + batch.join(',');

      getUrl(url, function(data) {
        var data = JSON.parse(data);
        var first = Object.keys(data)[0];

        for (var key in data) {
          retrieved++;

          if (data.hasOwnProperty(key)) {
            loadTreeItem(key, data[key]);
          }
        }

        _this.updateTotalLoaded(retrieved);
        retrieved = 0;

        if (_this.totalLoaded == _this.treeSize) {
          _this.postLoad();
        }
      });

      batch = [];
    }
  });
}


ContentsList.prototype.generateLoadIndicator = function() {
  var _this = this;
  this.loadIndicator = { 'loaded': 0 };
  var mode;

  if (this.targetArchivalObjectId) {
    mode = 'wait';
  }
  else if (currentTab() != 'contents') {
    mode = 'hide';
  }

  // create elements
  var indicatorElement = document.createElement('div');
  indicatorElement.setAttribute('id', 'load-indicator');
  var indicatorText = document.createElement('div');
  indicatorText.setAttribute('id', 'loading-text');
  indicatorText.append('Loading');
  var indicatorBar = document.createElement('div');
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
    var total = _this.treeSize;
    var scale = 2;
    var loaded = _this.totalLoaded;
    var percent = (loaded / total) * 100;
    var scaledPercent = Math.floor(percent/scale) * scale;
    var percentClass = 'percent-' + scaledPercent;
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
    loadIndicator.indicator.classList.remove('wait');
  }
}


ContentsList.prototype.stickySeriesTitle = function() {
  var _this = this;
  var series = document.querySelectorAll('.resource-tree .series-level');

  function seriesIndex(s) {
    return Array.from(series).indexOf(s);
  }

  series.forEach(function(el) {
    var stickable = document.querySelector('.stickable');
    var stickableOffset = stickable.offsetHeight;
    var titleWrapper = stickable.querySelector('.series-title');

    if (!titleWrapper) {
      titleWrapper = htmlToElement('<div class="series-title hidden"></div>')
      stickable.append(titleWrapper);
    }

    var treeTop = _this.resourceTree.offsetTop;
    var id = el.getAttribute('data-archival-object-id');
    var title = el.querySelector('.component-title').innerHTML;

    var updateStickyTitle = function() {
      show(titleWrapper);
      titleWrapper.setAttribute('data-archival-object-id', id);
      titleWrapper.innerHTML = title;
      _this.calculateDeepLinkOffset();
    };

    var resetStickyTitle = function() {
      hide(titleWrapper);
      titleWrapper.setAttribute('data-archival-object-id', 'bob');
      titleWrapper.innerHTML = '';
      _this.calculateDeepLinkOffset();
    };

    window.addEventListener('scroll', function() {
      // top of series div
      var triggerTop = el.getBoundingClientRect().top + window.scrollY - stickableOffset;
      // bottom of series div
      var triggerBottom = el.offsetHeight + triggerTop;

      var scrollTop = window.scrollY;
      var condition1 = scrollTop > triggerTop;
      var condition2 = scrollTop < triggerBottom;
      var condition3 = titleWrapper.getAttribute('data-archival-object-id') != id;

      var condition4 = scrollTop < triggerTop;
      var condition5 = titleWrapper.getAttribute('data-archival-object-id') == id;
      var condition6 = seriesIndex(el) == 0;

      if (condition1 && condition2 && condition3) {
        updateStickyTitle();
        console.log('*');
        _this.calculateDeepLinkOffset();
      }
      else if (condition4 && condition5 && condition6) {
        console.log('should unset the sticky series title');
        resetStickyTitle();
      }

      if (scrollTop < (treeTop - stickableOffset)) {
        titleWrapper.innerHTML = '';
        hide(titleWrapper);
      }
    });
  });
}


ContentsList.prototype.disableSeriesNavLinks = function() {
  var element = document.querySelector('.series-nav');
  if (element) {
    var links = element.querySelectorAll('ul li a');
    links.forEach(function(link) {
      link.classList.add('disabled');
      link.addEventListener('click', function(event) {
        event.preventDefault();
      });
    });
  }
}


ContentsList.prototype.seriesNav = function() {
  var element = document.querySelector('.series-nav');

  if (element) {
    var links = element.querySelectorAll('ul li a');

    links.forEach(function(link) {
      var deepLinkTargetId = link.getAttribute('href').replace(/#/,'');
      link.classList.remove('disabled');
      link.addEventListener('click', function(event) {
        deepLinkToId(deepLinkTargetId, { 'highlight': false });
        event.preventDefault();
      });
    });
    return element;
  }
}
