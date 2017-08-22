function queryParamsFromUrl() {
  var paramsRaw = window.location.search.substring(1).split('&');
  var params = {};
  for (var i = 0; i < paramsRaw.length; i++) {
    var param = paramsRaw[i].split('=');
    params[param[0]] = param[1];
  }
  return params;
}

function initializeLoadIndicator(mode,total,scale) {
  var loadIndicator = { 'loaded': 0 };
  var loadIndicatorHtml = '<div id="load-indicator">';
  loadIndicatorHtml += '<div id="loading-text">Loading</div>';
  loadIndicatorHtml += '<div id="indicator-bar" class="percent-0"></div>';
  loadIndicatorHtml += '</div>';
  var indicator = $(loadIndicatorHtml);
  loadIndicator.indicator = indicator;

  var updateLoaded = function(added) {
    newLoaded = loadIndicator.loaded + added;
    loadIndicator.loaded = newLoaded;
    return loadIndicator.loaded;
  }

  if (mode == 'wait') {
    loadIndicator.indicator.addClass('wait');
  } else if (mode == 'hide') {
    loadIndicator.indicator.addClass('hide');
  }

  if (typeof total !== 'undefined') {
    indicator.find('#loading-text').first().html('Loading (0/' + total + ')')
  }

  $('main').append(loadIndicator.indicator);

  loadIndicator.total = function() {
    return total;
  }

  loadIndicator.scale = function() {
    scale = typeof scale !== 'undefined' ? scale : 2;
    return scale;
  }

  // loadIndicator.update = function(loaded,total,scale) {
  loadIndicator.update = function(added) {
    var loaded = updateLoaded(added);
    var indicatorBar = $(this.indicator).find('#indicator-bar').first();
    var loadingText = $(this.indicator).find('#loading-text').first();
    var total = loadIndicator.total();
    var scale = loadIndicator.scale();

    $(loadingText).html('Loading (' + loaded + '/' + total + ')');

    var percent = (loaded / total) * 100;
    var scaledPercent = Math.floor(percent/scale) * scale;
    var percentClass = 'percent-' + scaledPercent;

    if (!$(indicatorBar).hasClass(percentClass)) {
      $(indicatorBar).removeClass();
      $(indicatorBar).addClass(percentClass);
    }

    if (percent >= 100) {
      // console.log('load done');
      $(this.indicator).addClass('complete');
      if ($(this.indicator).is(':visible')) {
        $(this.indicator).fadeOut(600, function() {
          $(this.indicator).remove();
        });
      } else {
        $(this.indicator).remove();
      }
    }
    return loadIndicator;
  }

  loadIndicator.waitOff = function() {
    this.indicator.removeClass('wait');
  }

  return loadIndicator;

}


$(document).ready(function() {

  $.fn.extend({


    showMore: function(options) {
      return this.each(function() {

        var el = $(this);
        var trigger = el.find('.trigger');
        var textShort = el.find('.text-short').first();
        var textLong = el.find('.text-long').first();

        // it's all responsive
        // enquire.register("screen and (max-width:40em)", {
        //   match : function() {
        //     textLong.show();
        //     textShort.hide();
        //     trigger.hide();
        //   },
        //   unmatch : function() {
        //     trigger.show();
        //     textLong.hide();
        //     textShort.show();

        //   },
        // });

        trigger.on('click', function() {
          if (el.is('.open')) {
            textLong.hide();
            textShort.show();
            el.removeClass('open');
          } else {
            textLong.show();
            textShort.hide();
            el.addClass('open');
          }
        });

      });
    }

  });


  $('.show-more').showMore();

});
