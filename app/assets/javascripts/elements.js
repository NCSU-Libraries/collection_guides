$.fn.extend({
  removeHighlights: function() {
    $(this).find('.highlight').each( function() {
      $(this).removeClass('highlight');
    });
  }
});


var topLink = function() {
  var topLinkHtml = '<div id="top-link" class="hide">';
    topLinkHtml += '<a href="#"><i class="fa fa-chevron-up"></i> top</a>';
    topLinkHtml += '</div>';
  t = {};
  if ($('#top-link').length > 0) {
    t.el = $('#top-link').first();
  } else {
    t.el = $(topLinkHtml);
    $('main').append(t.el);
  }

  t.show = function() {
    t.el.fadeIn(200);
  }
  t.hide = function() {
    t.el.fadeOut(400);
  }

  t.el.on('click',function(event) {
    window.scrollTo(0,0);
    t.hide();
    event.preventDefault();
  });
  return t;
}


var stickable = function() {
  var s = {};

  if ($('.stickable').length > 0) {

    var t = topLink();

    s.el = $('.stickable').first();

    s.isStuck = function() {
      return s.el.is('.sticky');
    }

    s.stickyTop = $(s.el).offset().top;

    // console.log(s.stickyTop);

    var el_height = $(s.el).height();

    var mainDefaultPadding = $('main').css('padding-top');

    s.offset = el_height + parseInt(mainDefaultPadding);

    s.stick = function() {
      s.el.addClass('sticky');
      $('main').css('padding-top', s.offset + 'px');
      // setTabScroll(stickyTop);
      t.show();
    }

    s.unstick = function() {
      s.el.removeClass('sticky');
      $('main').css('padding-top', mainDefaultPadding);
      // setTabScroll(scrollTop);
      t.hide();
    }

    s.stickyNav = function() {
      var scrollTop = $(window).scrollTop();
      if (scrollTop > s.stickyTop) {
        s.stick();
      } else {
        s.unstick();
      }
    };

    s.stickyNav();

    $(window).scroll(function() {
      s.stickyNav();
    });
  }

  return s;
}



// Uses Foundation's tab CSS but replaces its Tabs JS to provide custom functionality
var tabs = function(stickable) {
  tb = {};
  tb.tabs = $('.data-tabs .tab');

  tb.tabsContent = $('.tabs-content').first();

  tb.deactivate = function() {
    tb.tabs.filter('.active').removeClass('active');
    tb.tabsContent.find('.active').removeClass('active');
  }

  $.fn.extend({
    activate: function() {
      return this.each(function() {
        $(this).addClass('active');
      });
    }
  });

  tb.updateUrl = function(id) {
    var url = window.location['origin'] + window.location['pathname']
    var base_url = url.replace(/\/[^\d]*$/,'')
    var newUrl = base_url + '/' + id
    var currentState = history.state;
    window.history.replaceState(currentState, null, newUrl);
  }

  tb.init = function() {

    tb.tabs.each(function() {

      var link = $(this).find('a').first();

      link.on('click', function(event) {
        var activeId = tb.tabsContent.find('.active').attr('id');
        var id = $(this).attr('href').replace('#','');
        if (id != activeId) {
          // console.log('activate!');

          // console.log(stickable.stickyTop);
          var top = stickable.isStuck() ? stickable.stickyTop : $(window).scrollTop();
          // console.log(top);
          window.scrollTo(0,top);

          if (history.pushState) {
            tb.updateUrl(id);
          }

          var content = $(tb.tabsContent).find('#' + id).first();
          var tab = $(this).parents('.tab').first();
          tb.deactivate();
          $(content).activate();
          $(tab).activate();

          // Remove highlighting added from deep link from search results
          $('.resource-tree').removeHighlights();

          // Show/hide load indicator
          var loadIndicator = $('#load-indicator').not('.complete');

          if (id == 'contents') {
            loadIndicator.show();
          } else {
            loadIndicator.hide();
          }

        }
        event.preventDefault();
      });
    });
  }

  tb.init();

  return tb;
}

s = stickable();
tabs(s);


