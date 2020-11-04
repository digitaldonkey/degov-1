/**
 * @file
 * process.js
 *
 * Defines the behaviors of the degov_social_media_settings module.
 */

(function ($, Drupal, drupalSettings) {
  'use strict';

  // Polyfill Promise for ie9.
  window.Promise || document.write('<script src="https://unpkg.com/es6-promise@4.2.8/dist/es6-promise.auto.min.js"><\/script>');

  var
    modal = $('#social-media-settings'),
    cookieId = 'degov_social_media_settings',
    sources = {},
    settings = drupalSettings.degov_social_media_settings;

  Drupal.behaviors.degov_social_media_settings = {
    attach: function (context, drupalSettings) {

      settings = drupalSettings.degov_social_media_settings;
      modal.once('social-media-settings-init').each(function () {

      // Move the modal outside of the page wrappers, to prevent styling overwrites.
      modal.detach().appendTo('body');
      $(document).on('click', '[data-target="#social-media-settings"]', function () {
        modal
          .dialog({
            modal: true,
            width: 'auto',
            maxWidth: 600,
            fluid: true,
            dialogClass: 'no-title'
          })
          .attr('aria-hidden', false);
        openModal();
      });

      $(document).on('click', '[data-dismiss="modal"]', function () {
        modal
          .dialog('close')
          .attr('aria-hidden', false);
        openModal();
      });

      modal.on('click', '.show-more', function () {
        $(this).attr('aria-hidden', true);
        $('.social-media-read-more__overlay').hide();
        $('.collapse', modal).attr('aria-expanded', true);
      });

        // Bootstrap version.
        // Move the modal outside of the page wrappers, to prevent styling overwrites.
        //
        // modal.on({
        //   'hidden.bs.modal': function () {
        //     modal.attr('aria-hidden', true);
        //   },
        //   'shown.bs.modal': function () {
        //     openModal();
        //     modal.attr('aria-hidden', false).find('h2').focus();
        //   }
        // });

        // Initialize when cookies are accepted by eu_cookie_compliance module.
        $('.agree-button').on({
          click: function () {
            sources = settings.sources;
            initializeAllowedSocialMediaTypes();
          }
        });

        if (Drupal.eu_cookie_compliance !== undefined && Drupal.eu_cookie_compliance.hasAgreed()) {
          // Cookies allowed.
          sources = cookieExists() ? cookieGetSettings() : settings.sources;
          initializeAllowedSocialMediaTypes();
        }
        else {
          applySettings();
        }
      });


    }
  };

  // Opens the social media settings modal.
  function openModal() {

    // Update checkboxes with settings from cookie.
    $('.js-social-media-source', modal).each(function () {
      var elm = $(this),
          source = elm.val();
      if (sources.hasOwnProperty(source)) {
        elm.prop('checked', sources[source]);
      }
    });

    // Attach save modal settings.
    $('.js-social-media-settings-save', modal).click(function () {
      saveSettings();
    });

    // Attach 'all' checkbox.
    $('#checkbox-all-keys', modal).on({
      click: function (e) {
        var selectAll = $(e.currentTarget);
        selectAll
          .parents('.social-media-settings__settings-list')
          .find('.checkbox-switch')
          .prop('checked', selectAll.is(':checked'))
      }
    });
  }

  // Shows social media settings link and init option cookie.
  function initializeAllowedSocialMediaTypes() {
    $('.js-social-media-settings-open').removeClass('hidden');
    applySettings();
  }

  // Applies the social media settings to a social media wrapper.
  function applySettings() {
    var wrappers = document.querySelectorAll('.js-social-media-wrapper');
    Array.prototype.forEach.call(wrappers, function (el, i) {
      var elm = $(el),
        source = elm.attr('data-social-media-source'),
        entity = elm.attr('data-social-media-entity'),
        target = $('.js-social-media-code', elm);

      if (Drupal.eu_cookie_compliance !== undefined && Drupal.eu_cookie_compliance.hasAgreed()) {

        if (sources.hasOwnProperty(source) && sources[source] === true && settings.code.hasOwnProperty(entity)) {
          target.html(settings.code[entity]);
          if (source === 'twitter') {
            new Promise(function(resolve) {
              initTwitter(elm);
              initSoMeSlider('twitter');
              resolve();
            });
          }
          if (source === 'instagram') {
            new Promise(function(resolve) {
              initInstagram();
              initSoMeSlider('instagram');
              resolve();
            });
          }
          if (source === 'youtube') {
            new Promise(function(resolve) {
              setTimeout(function () {
                initSoMeSlider('youtube');
                resolve();
              }, 500);
            });
          }
        }
        else {
          target.html(Drupal.theme.prototype.socialMediaDisabledMessage(settings.mediaMessages[source], settings.link));
        }
      }
      else {
        //
        // TODO
        //  Shouldn't this  be default in html Template ??
        //
        target.html(Drupal.theme.prototype.socialMediaDisabledMessage(settings.mediaMessages[source], settings.cookie));
      }
    });
  }

  // Saves the social media settings in the cookie and applies the new
  // settings to all social media wrappers.
  function saveSettings() {
    // Update the sources variable.

    $('.js-social-media-source', modal).each(function () {
      var elm = $(this),
          source = $(this).val();
      if (sources.hasOwnProperty(source)) {
        sources[source] = elm.is(':checked');
      }
    });

    // Save settings in cookie.
    if (Drupal.eu_cookie_compliance.hasAgreed()) {
      cookieSaveSettings();
      settings.sources = sources;
    }

    // Apply new settings.
    initializeAllowedSocialMediaTypes();
  }

  // Initialize twitter media from media bundle tweet.
  function initTwitter(wrapper) {
    function _initTwitter() {
      // Twitter widgets.js is not supported in ie11.
      if (typeof twttr !== 'undefined') {
        twttr.widgets.load(wrapper);
        initSoMeSlider('twitter');
      }
    }

    if (typeof twttr === 'undefined') {
      $.ajax({
        url: '//platform.twitter.com/widgets.js',
        type: "GET",
        success: _initTwitter,
        dataType: "script",
        cache: true
      });
    }
    else {
      _initTwitter();
    }
  }

  // Initialize instagram media from media bundle instagram.
  function initInstagram() {
    function _initInstagram() {
      instgrm.Embeds.process();
    }

    if (typeof instgrm === 'undefined') {
      $.ajax({
        url: '//platform.instagram.com/en_US/embeds.js',
        type: "GET",
        success: _initInstagram,
        dataType: "script",
        cache: true
      });
    }
    else {
      _initInstagram();
    }
  }

  // Checks if the cookie exists.
  function cookieExists() {
    return typeof $.cookie(cookieId) !== 'undefined';
  }

  // Reads, parses and returns the settings from the cookie.
  function cookieGetSettings() {
    return JSON.parse($.cookie(cookieId));
  }

  // Saves the settings in the cookie.
  function cookieSaveSettings() {
    $.cookie(cookieId, JSON.stringify(sources), { path: '/'});
  }

  function initSoMeSlider(source) {
    var slider = (source === 'twitter') ? $('.tweets-slideshow .tweets') : $('.' + source + '-preview'),
        sliderWrap = slider.parent(),
        defaultSettings = {
          dots: true,
          infinite: true,
          speed: 300,
          slidesToShow: 1,
          slidesToScroll: 1,
          autoplay: true,
          arrows: true,
          appendArrows: $('.l-slick-navi', slider.parent()),
          appendDots: $('.l-slick-navi', slider.parent()),
          mobileFirst: true,
          adaptiveHeight: true,

          responsive: [
            {
              breakpoint: 720,
              settings: {
                slidesToShow: 2,
                slidesToScroll: 2
              }
            }
          ]
        };

    // Responsive override.
    if (source === 'youtube') {
      defaultSettings = mergeOptions(defaultSettings, {
        responsive: [
          {
            breakpoint: 420,
            settings: {
              slidesToShow: 2,
              slidesToScroll: 2
            }
          },
          {
            breakpoint: 840,
            settings: {
              slidesToShow: 3,
              slidesToScroll: 3
            }
          }
        ]
      })
    }

    if (slider.length && !slider.hasClass('slick-initialized')) {
      var slickControlls = sliderWrap.find('.slick-controls');

      slickControlls.show();
      slider.slick(defaultSettings);
      slickControlls.find('.slick__pause').click(function () {
        slider.slick('slickPause');
        $(this).hide().siblings('.slick__play').show();
      });
      var slickPlay = slickControlls.find('.slick__play');
      slickPlay.hide(); // Initial hide.
      slickPlay.on('click', function () {
        slider.slick('slickNext').slick('slickPlay');
        $(this).hide().siblings('.slick__pause').show();
      });
    }
  }

  Drupal.theme.prototype.socialMediaDisabledMessage = function (mediaMessages, link) {
    return '<div class="js-social-media-code__message">' + mediaMessages + ' ' + link + '</div>';
  }

  /**
   * Overwrites obj1's values with obj2's and adds obj2's if non existent in obj1
   * @param obj1
   * @param obj2
   * @returns obj3 a new object based on obj1 and obj2
   */
  function mergeOptions(obj1,obj2){
    var obj3 = {};
    for (var attrname in obj1) { obj3[attrname] = obj1[attrname]; }
    for (var attrname in obj2) { obj3[attrname] = obj2[attrname]; }
    return obj3;
  }

})(jQuery, Drupal, drupalSettings)
