var stickySeriesTitle = function() {
  var series = $('.resource-tree .series-level');
  series.each(function() {
    var stickable = $('.stickable').first();
    var stickableOffset = $(stickable).height();
    var titleWrapper = $(stickable).find('.series-title').first();
    if (titleWrapper.length == 0) {
      titleWrapper = $('<div class="row series-title hidden"></div>');
      $(stickable).append(titleWrapper);
    }
    var treeTop = $('.resource-tree').first().offset().top;
    var id = $(this).attr('data-archival-object-id');
    var title = $(this).find('.component-title').first().html();
    var triggerTop = $(this).offset().top - stickableOffset;
    var triggerBottom = $(this).height() + triggerTop;

    var updateStickyTitle = function() {
      $(titleWrapper).show();
      $(titleWrapper).attr('data-archival-object-id',id);
      $(titleWrapper).html(title);
    };

    $(window).scroll(function() {
      var scrollTop = $(window).scrollTop();
      if ((scrollTop > triggerTop) && (scrollTop < triggerBottom) && (titleWrapper.not('[data-archival-object-id=' + id + ']'))) {
        updateStickyTitle();
      }
      if (scrollTop < (treeTop - stickableOffset)) {
        $(titleWrapper).html('');
        $(titleWrapper).hide();
      }
    });
  });
}


document.addEventListener('DOMContentLoaded', function () {

  function rootUrl() {
    if (window.location.pathname.match(/^\/findingaids/)) {
      root = '/findingaids/';
    } else {
      root = '/';
    }
    return root;
  }

  function hasResourceTree() {
    var resourceTree = document.querySelectorAll('.resource-tree');
    return (resourceTree.length > 0) ? true : false;
  }

  function skeletonTreeMode() {
    var skeletonTree = document.querySelectorAll('.resource-tree.skeleton-tree');
    return (skeletonTree.length > 0) ? true : false;
  }


  function resourceTreeSize() {
    var treeItems = document.querySelectorAll('.resource-tree .tree-item');
    return treeItems.length;
  }

  function getTargetArchivalObjectId() {
    var params = queryParamsFromUrl();
    if (typeof params.archival_object_id != 'undefined') {
      return 'archival-object-' + params.archival_object_id;
    }
  }

  function currentTab() {
    var tabOptions = ['summary','contents','terms','access'];

    function isInArray(value, array) {
      return array.indexOf(value) > -1;
    }

    var path = window.location['pathname'].replace(/^\//,'');
    var path_parts = path.split('/');
    var last_path_segment = path_parts[path_parts.length - 1];

    if (tabOptions.indexOf(last_path_segment) > -1) {
      return last_path_segment;
    }
    else {
      return 'summary';
    }
  }

  function resourceTreeLoadIndicator(totalItems) {
    if (typeof getTargetArchivalObjectId() != 'undefined') {
      var indicatorMode = 'wait';
    } else if (currentTab() != 'contents') {
      var indicatorMode = 'hide';
    } else {
      var indicatorMode = null;
    }
    var loadIndicator = initializeLoadIndicator(indicatorMode, totalItems);
    return loadIndicator;
  }


  $.fn.extend({

    loadResourceTree: function(deepLinkTargetId,loadIndicator,level) {

      var batchSize = 50;

      if (typeof level == 'undefined') {
        var items = $(this).find('.skeleton-tree-item');
      }
      else {
        var items = $(this).find('.skeleton-tree-item.tree-item-' + level);
        // console.log('loading level ' + level);
      }

      if (typeof loadIndicator == 'undefined') {
        var loadIndicator = resourceTreeLoadIndicator(items.length);
      }

      if (typeof deepLinkTargetId != 'undefined') {
        var targetArchivalObjectId = deepLinkTargetId.replace(/[^\d]*/,'');
        var deepLinkTarget = $(items).find('[data-archival-object-id=' + targetArchivalObjectId + ']')
        var deepLinkTargetIndex = $(items).index(deepLinkTarget);
        // console.log('deepLinkTargetIndex = ' + deepLinkTargetIndex);
      }

      var priorElementsLoaded = function() {
        if (typeof deepLinkTargetIndex != 'undefined') {
          var priorElements = $(items).slice(0,deepLinkTargetIndex);
          var notLoaded = $(priorElements).not('.loaded');
          if (notLoaded.length == 0) {
            return true;
          }
          else {
            return false;
          }
        }
        else {
          return true;
        }
      }

      var executeDeepLink = function(item) {
        if (priorElementsLoaded()) {
          $(item).deepLink();
          loadIndicator.waitOff();
        }
        else {
          setTimeout(function(){ executeDeepLink(item); }, 500);
        }
      }

      var loadTreeItem = function(id,data) {
        var item = $('.skeleton-tree-item#archival-object-' + id).first();
        $(item).prepend( data ).addClass('loaded');
        if ($(item).attr('id') == deepLinkTargetId) {
          executeDeepLink(item);
        }
      };

      var i = 0;
      var batch = [];
      var retrieved = 0;

      var updateTotal = function(additional) {
        totalLoaded = totalLoaded + additional;
      }

      $(items).each(function() {
        var archivalObjectId = $(this).attr('data-archival-object-id');
        batch.push(archivalObjectId);
        i++;
        // Process batch and reset
        if ( (batch.length == batchSize) || (i == $(items).length) ) {
          var getUrl = rootUrl() + 'archival_objects/batch?ids=' + batch.join(',');
          function targetLoaded() {
            var loaded = $('#' + deepLinkTargetId + '.loaded');
            return (loaded.length > 0) ? true : false;
          }
          $.get( getUrl, function( data ) {
            var first = Object.keys(data)[0];
            for (var key in data) {
              retrieved++;
              if (data.hasOwnProperty(key)) {
                loadTreeItem(key,data[key]);
              }
            }

          }).done( function() {
            loadIndicator.update(retrieved);
            updateTotal(retrieved);
            retrieved = 0;
            if (totalLoaded == treeSize) {
              console.log(totalLoaded + " / " + treeSize);
              stickySeriesTitle();
              thumbnailViewers(stickySeriesTitle);
              enableFilesystemBrowseLinks();
            }
          });
          batch = [];
        }
      });
      return retrieved;
    },

    scrollToPosition: function() {
      // var offset = $('.stickable').first().height() + 50;
      var offset = $('.stickable').first().height();
      var targetPos = $(this).offset().top;
      targetPos = targetPos - offset;

      window.scrollTo(0,targetPos);

      if (window.pageYOffset == 0 && targetPos != 0) {
      }
      return this;
    },

    highlight: function() {
      var row = $(this).find('.row').first();
      $(row).addClass('highlight');
      return this;
    },

    deepLink: function(options) {
      options = typeof options !== 'undefined' ? options : {};
      options['highlight'] = typeof options['highlight'] === 'undefined' ? true : options['highlight'];
      $(this).scrollToPosition();
      if (options['highlight']) {
        $(this).highlight();
      }
      return this;
    },

    containerListDeepLink: function(deepLinkTargetId, options) {
      options = typeof options !== 'undefined' ? options : {}
      if (typeof deepLinkTargetId != 'undefined') {
        var target = $('#' + deepLinkTargetId).first();
        $(target).deepLink(options);
      }
      return this;
    },

    seriesNav: function() {
      var links = $(this).find('ul li a');

      $(links).each(function() {
        var deepLinkTargetId = $(this).attr('href').replace(/#/,'');
        $(this).on('click', function(event) {
          $(this).containerListDeepLink(deepLinkTargetId, { 'highlight': false });
          event.preventDefault();
        });
      });
      return this;
    }

  });

  enableFilesystemBrowseLinks();

  if (hasResourceTree()) {
    var targetArchivalObjectId = getTargetArchivalObjectId();

    if (skeletonTreeMode()) {
      var totalLoaded = 0;
      // console.log('skeleton tree mode');
      var treeSize = resourceTreeSize();
      if (treeSize > 3000) {
        var loadIndicator = resourceTreeLoadIndicator(treeSize);
        $('.resource-tree').loadResourceTree(targetArchivalObjectId, loadIndicator, 1);
        $('.resource-tree .tree-item-1').each(function() {
          $(this).loadResourceTree(targetArchivalObjectId, loadIndicator);
        });
      }
      else {
        $('.resource-tree').loadResourceTree(targetArchivalObjectId);
      }
    }
    else {
      // console.log('not skeleton tree');
      thumbnailViewers(stickySeriesTitle);
      stickySeriesTitle();
      $('.resource-tree').containerListDeepLink(targetArchivalObjectId);
    }

    $('.series-nav').seriesNav();
  }


});
