function Stickable() {
  var _this = this;
  this.element = document.querySelector('.stickable');

  if (this.element) {
    this.main = document.querySelector('main');

    this.mainDefaultPaddingTop = getProperty(this.main, 'padding-top');
    this.generateTopLink();
    this.stickyTop = this.element.getBoundingClientRect().top + window.scrollY;

    let notice = document.querySelector('.sitewide-notice');
    if (notice) {
      this.stickyTop -= notice.offsetHeight;
    }

    const el_height = this.element.offsetHeight;
    this.offset = el_height + parseInt(this.mainDefaultPaddingTop);

    this.stickyNav();

    window.addEventListener('scroll', function() {
      _this.stickyNav();
    });
  }
}


Stickable.prototype.isStuck = function() {
  return this.element.classList.contains('sticky');
}


Stickable.prototype.stick = function() {
  if ( !this.isStuck() ) {
    this.element.classList.add('sticky');
    this.main.style.paddingTop = this.offset + 'px';
    show(this.topLink);
  }
}


Stickable.prototype.unstick = function() {
  if (this.isStuck()) {
    this.element.classList.remove('sticky');
    this.main.style.paddingTop = this.mainDefaultPaddingTop;
    hide(this.topLink);
    var seriesTitle = this.element.querySelector('.series-title');
    if (seriesTitle) {
      hide(seriesTitle);
    }
  }
}


Stickable.prototype.generateTopLink = function() {
  var _this = this;
  var topLinkHtml = '<div id="top-link" class="hidden"><a href="#"><i class="fa fa-chevron-up"></i> Top</a></div>';
  var topLinkEl = htmlToElement(topLinkHtml);
  var el = document.querySelector('#top-link');

  if (el) {
    this.topLink = el;
  }
  else {
    this.main.append(topLinkEl);
    this.topLink = topLinkEl;
  }

  this.topLink.addEventListener('click', function(event) {
    window.scrollTo(0,0);
    _this.unstick();
    hide(_this.topLink);
    event.preventDefault();
  });
}


Stickable.prototype.stickyNav = function() {
  let scrollTop = window.scrollY;
  console.log(scrollTop);

  if (scrollTop > this.stickyTop) {
    this.stick();
  } else {
    this.unstick();
  }
};
