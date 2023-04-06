// Uses Foundation's tab CSS but replaces its Tabs JS to provide custom functionality
function Tabs(stickable) {
  var tabs = document.querySelectorAll('.tabs .tabs-title');
  var tabsContent = document.querySelector('.tabs-content');

  if (tabs.length > 0 && tabsContent) {
    this.tabs = tabs;
    this.tabsContent = tabsContent;
    this.tabsPanels = tabsContent.querySelectorAll('.tabs-panel');
    this.stickable = stickable;
    this.initializeTabs();
  }
}


Tabs.prototype.getActiveTabId = function() {
  var id;
  for (var i = 0; i < this.tabs.length; i++) {
    var tab = this.tabs[i];
    if (tab.classList.contains('is-active')) {
      id = tab.getAttribute('data-tab-id');
      break;
    }
  }
  return id;
}


Tabs.prototype.addIsActiveClass = function(element) {
  if (!element.classList.contains('is-active')) {
    element.classList.add('is-active');
  }
}


Tabs.prototype.initializeTabs = function() {
  var _this = this;

  this.tabs.forEach(function(tab) {
    var link = tab.querySelector('a');

    link.addEventListener('click', function(event) {
      var activeId = _this.getActiveTabId();
      var id = link.getAttribute('href').replace('#','');

      if (id != activeId) {
        var top = _this.stickable.isStuck() ? _this.stickable.stickyTop : window.scrollY;
        window.scrollTo(0,top);

        if (history.pushState) {
          _this.updateUrl(id);
        }

        var contentPanel = _this.tabsContent.querySelector('#' + id);
        _this.deactivate();
        _this.addIsActiveClass(contentPanel);
        _this.addIsActiveClass(tab);

        document.querySelectorAll('.highlight').forEach(function(el) {
          el.classList.remove('highlight');
        });

        // Show/hide load indicator
        var loadIndicator = document.querySelector('#load-indicator');

        if (loadIndicator && !loadIndicator.classList.contains('complete')) {
          if (id == 'contents') {
            show(loadIndicator);
          }
          else {
            hide(loadIndicator);
          }
        }
      }

      _this.showHideThumbnailVisibilityToggle();

      event.preventDefault();
    }, false);

  });
}


Tabs.prototype.deactivate = function() {
  function removeIsActiveClass(element) {
    element.classList.remove('is-active');
  }
  this.tabs.forEach(removeIsActiveClass);
  this.tabsPanels.forEach(removeIsActiveClass);
}


Tabs.prototype.updateUrl = function(id) {
  var url = window.location['origin'] + window.location['pathname']
  var base_url = url.replace(/\/[^\d]*$/,'')
  var newUrl = base_url + '/' + id
  var currentState = history.state;
  window.history.replaceState(currentState, null, newUrl);
}


Tabs.prototype.showHideThumbnailVisibilityToggle = function() {
  var toggle = document.querySelector('.thumbnail-visibility-toggle');
  if (toggle) {
    var activeTabId = this.getActiveTabId();

    console.log(activeTabId);

    if (activeTabId == 'contents') {
      show(toggle);
    }
    else {
      hide(toggle);
    }
  }
}
