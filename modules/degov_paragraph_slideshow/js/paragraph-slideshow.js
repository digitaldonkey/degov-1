/**
 * @file
 * slideshow.js
 */

/**
 * Youtube player state change callback.
 * Pause Sliding if Video is about to start playing.
 */
function onYouTubePlayerStateChange(event) {
  // Stop automatic progression when a video starts playing.
  if (event.data === YT.PlayerState.CUED || event.data === YT.PlayerState.PLAYING) {
    // sliderWrap => .slideshow-type-1 wrapper
    jQuery(event.target.f)
      .closest('[class^=slideshow-type-]')
      .trigger('pauseSlider');
  }
}

/**
 * Defines the behavior of the Slideshow paragraph.
 */
(function ($, Drupal, drupalSettings) {
  'use strict';

  /**
   * Type-1 Slider.
   *
   * Slick slider with Autoplay option.
   */
  Drupal.behaviors.slideShowType1 = {
    attach: function (context, settings) {
      $('.slideshow-type-1', context).once('createSlider1').each(function () {
        const sliderWrap = $(this),
              slider = $('.slideshow__slides', sliderWrap);

        if (slider.children().length > 1) {
          // Start Slick player
          // @see https://kenwheeler.github.io/slick/
           slider.slick({
             dots: true,
             autoplay: false,
             speed: 500,
             appendArrows: $('.l-slick-navi', sliderWrap),
             appendDots: $('.l-slick-navi', sliderWrap),
             adaptiveHeight: true,
           });

          // Provide single point of interaction.
          sliderWrap.on({
            pauseSlider: function () {
              // halt auto slide play.
              slider.slick('slickPause');
              $(this).find('.slick__pause').hide().siblings('.slick__play').show().focus();
            },
            playSlider: function () {
              // Start auto slide play.
              slider.slick('slickNext').slick('slickPlay');
              $(this).find('.slick__play').hide().siblings('.slick__pause').show().focus();
            }
          });

          // Center the dots in case the active dot scrolled out of visible dots.
          slider.on('afterChange', function (event, slick, currentSlide, nextSlide) {
            const
              dotsWrapper = $(slick.$dots[0]),
              activeDot = dotsWrapper.find('.slick-active'),
              dotsWrapperWidth = dotsWrapper.width(),
              trashHold = 10,
              inView = activeDot.offset().left > dotsWrapper.offset().left
                && activeDot.offset().left < (dotsWrapper.offset().left + dotsWrapperWidth - trashHold);
            if (!inView) {
              // All dots have same outerWidth.
              dotsWrapper[0].scrollLeft = activeDot.prevAll().length * activeDot.outerWidth(true) - dotsWrapperWidth / 2;
            }
          });

          // Pause videos when changing slides.
          slider.on('beforeChange', function (event, slick, currentSlide, nextSlide) {
            slickCommon.stopAllVideosOnSlide($(slick.$slides.get(currentSlide)), sliderWrap)
          });

          // Init play and pause buttons.
          $('.slick__pause', sliderWrap).hide()
            .on('click', function () {
              sliderWrap.trigger('pauseSlider');
            });
          $('.slick__play', sliderWrap).show()
            .on('click', function () {
              sliderWrap.trigger('playSlider');
            });

          // Initialize iframe players when ready.
          slickCommon.iframeReady(sliderWrap, [
            slickCommon.initYoutube,
            slickCommon.initVimeo
          ]);

          // Init pause slide on native video play.
          slider.find('video').once('initVideo').each(function () {
            $(this).on('play', function () {
              sliderWrap.trigger('pauseSlider');
            });
          });
        }
        else {
          // No need for interaction handlers.
          slider.find('.paragraph-slideshow').addClass('single-slide');
        }
      });

    }
  };

  /**
   * Type-2 Slider.
   *
   * Slick slider with prev/next thumbnail images.
  */
  Drupal.behaviors.slideshowType2 = {
    attach: function (context, settings) {
      const behavior = this;
      $('.slideshow-type-2', context).once('createSlider2').each(function () {
        const sliderWrap = $(this),
              slider = $('.slides_prev_next', sliderWrap);
        slider.on({
          init: function (event, slick) {
            // Add a Element for thumbs so we can handle responsiveness in css.
            sliderWrap.find('.slick-arrow').once('navThumbWrap').each(function () {
              const arrow = $(this),
                className = arrow.hasClass('slick-next') ? 'slick-next-thumb' : 'slick-prev-thumb';
              arrow.prepend('<div class="slick-nav-thumb"><div class="slick-nav-thumb-image ' + className + '"></div></div>');
            });
            behavior.addThumbnails(slider.find('.slick-current'), sliderWrap);
          },
          beforeChange: function (event, slick, currentSlide, nextSlide) {
            const thisSlide = $(slick.$slides.get(currentSlide));
            slickCommon.stopAllVideosOnSlide(thisSlide, sliderWrap);
            // Hide image while sliding
            sliderWrap.find('.slick-nav-thumb-image').css({opacity: 0})
          },
          afterChange: function (event, slick, currentSlide, nextSlide) {
            behavior.addThumbnails($(slick.$slides.get(currentSlide)), sliderWrap);
            sliderWrap.find('.slick-nav-thumb-image').css({opacity: 1})
          }
        });
        slider.slick({
          dots: false,
          slidesToShow: 1,
          autoplay: false,
          appendArrows: $('.l-slick-navi', sliderWrap),
          adaptiveHeight: true,
        });
        slickCommon.iframeReady(sliderWrap, [
          slickCommon.initYoutube,
          slickCommon.initVimeo
        ]);
      });
    },
    addThumbnails: function (currentSlide, sliderWrap) {
      let prevUri, nextUri;
      if (!currentSlide.data('navThumbs')) {
        prevUri = currentSlide.prev('.slick-slide').find('.slide__media img').attr('src');
        prevUri = prevUri ? prevUri : '';
        nextUri = currentSlide.next('.slick-slide').find('.slide__media img').attr('src');
        nextUri = nextUri ? nextUri : '';
        // Cache in data object.
        currentSlide.data('navThumbs', {
          next: nextUri,
          prev: prevUri,
        })
      }
      else {
        prevUri = currentSlide.data('navThumbs').prev;
        nextUri = currentSlide.data('navThumbs').next;
      }
      sliderWrap.find('.slick-next-thumb').css({
        backgroundImage: 'url(' + nextUri + ')',
      });
      sliderWrap.find('.slick-prev-thumb').css({
        backgroundImage: 'url(' + prevUri + ')',
      });
    },
  };

  const slickCommon = {

    /**
     * Stop all kind of videos on current slide.
     * @param slide jQuery Object
     * @param sliderWrap jQuery Object
     */
    stopAllVideosOnSlide: function(slide, sliderWrap) {
      slide.find('video, .video-embed-field-provider-youtube, .video-embed-field-provider-vimeo')
        .each(function () {
          const elm = $(this);
          if (elm.is('video')) {
            const video = elm.get(0);
            // console.log('FOUND upload', video);
            if (video && !video.paused) {
              video.pause();
            }
          }
          else if (elm.is('.video-embed-field-provider-youtube')) {
            const video = elm.find('iframe');
            // console.log('FOUND youtube', video);
            if(video) {
              video.get(0).contentWindow.postMessage('{"event":"command","func":"pauseVideo","args":""}', '*');
            }
          }
          else if (elm.is('.video-embed-field-provider-vimeo') && elm.find('iframe').attr('id')) {
            const vimeoPlayer = sliderWrap.data('vimeo-player')[elm.find('iframe').attr('id')];
            // console.log('FOUND vimeo', vimeoPlayer);
            if(typeof vimeoPlayer !== 'undefined') {
              vimeoPlayer.pause();
            }
          }
        })
    },

    /**
     * Wait for Embed iframe and execute init functions
     * @param sliderWrap jQuery Object
     * @param functions Array of functions to call when ready.
     */
    iframeReady: function (sliderWrap, functions) {
      sliderWrap.find('.video__video').each(function () {
        const target = this,
          observer = new MutationObserver(function (mutations, observer) {
            functions.forEach(function (f) {
              f(sliderWrap)
            });
          });
        observer.observe(target, {childList: true, subtree: true});
      });

    },

    /**
     * Events for Vimeo players.
     *
     * @param sliderWrap jQuery Object
     */
    initVimeo: function (sliderWrap) {
      const vimeoPlayer = sliderWrap.data('vimeo-player') ? sliderWrap.data('vimeo-player') : [];

      $('.video-embed-field-provider-vimeo iframe', sliderWrap)
        .once('initVimeo').each(function (index) {
        const iframe = $(this);
        if (!iframe.attr('id')) {
          const id = 'slider-vimeo-video-' + index;
          iframe.attr('id', id);
          vimeoPlayer[id] = new Vimeo.Player(id);
          vimeoPlayer[id].on('play', function () {
            sliderWrap.trigger('pauseSlider');
          });
        }
      });
      sliderWrap.data('vimeo-player', vimeoPlayer);
    },

    /**
     * Attach Youtube embed players.
     * @param sliderWrap jQuery Object
     */
    initYoutube: function (sliderWrap) {
      sliderWrap.once('initYoutube').each(function () {
        $(this).find ('.slideshow__slides .video-embed-field-provider-youtube iframe')
          .each(function (index) {
            $(this).on('load', function () {
              if (!$(this).attr('id')) {
                const id = 'slider-youtube-video-' + index;
                $(this).attr('id', id);
                new YT.Player(id, {
                  events: {
                    'onStateChange': onYouTubePlayerStateChange
                  }
                });
              }
            });
          });
      });
    }
  };

  /**
   * Hide/show below slideshow copyright.
   *
   * @type {{attach(*=): void}}
   */
  Drupal.behaviors.paragraphSlideChangeCopyright = {
    attach: function(context) {
      $('.paragraph-slideshow-wrapper.has-copyright', context)
        .once('initSubSliderCopyright')
        .each(function(i, elm) {
          const wrapper = $(elm);
          const paragraphSelector = wrapper.find('.paragraph-slideshow');

          if (wrapper.length && paragraphSelector.length > 0) {
            paragraphSelector.on({
              beforeChange: function(event, slick, currentSlide) {
                const thisSlide = wrapper.find('.copyright-slide-' + currentSlide);
                thisSlide.delay(200).toggleClass('is-visible');
              },
              afterChange: function(event, slick, currentSlide) {
                const thisSlide = wrapper.find('.copyright-slide-' + currentSlide);
                thisSlide.delay(600).toggleClass('is-visible');
              }
            });
          }
        });
    }
  };

})(jQuery, Drupal, drupalSettings);
