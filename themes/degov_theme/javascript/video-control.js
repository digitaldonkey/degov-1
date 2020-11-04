/**
 * @file
 * Embedded video controller plugin for jQuery.
 *
 * Implements easy controls for embedded vimeo and youtube videos.
 *
 * @author antroxim@gmail.com
 */

(function ($) {
  'use strict';

  if ($('[class*=video-embed-field-provider] > iframe[src*=youtube]').length) {
    $.getScript('https://www.youtube.com/iframe_api');
  }
  if ($("[class*=video-embed-field-provider] > iframe[src*=vimeo]").length) {
    $.getScript('https://player.vimeo.com/api/player.js', function () {
      onVimeoPlayerAPIReady();
    });
  }

  // Vimeo API ready callback.
  function onVimeoPlayerAPIReady() {
    $('[class*=video-embed-field-provider] > iframe[src*=vimeo]').each(function (i) {
      /* global Vimeo */
      var id = $(this).attr('id') + '-' + i;
      $(this).attr('id', id);
      $(this).data('player', {type: 'vimeo', player: new Vimeo.Player(this)});
      assignControlls($(this));
    });
  }

  // Youtube API ready callback.
  window.onYouTubePlayerAPIReady = function () {
    $("[class*=video-embed-field-provider] > iframe[src*=youtube]").each(function (i) {
      /* global YT */
      var id = $(this).attr('id') + '-' + i;
      $(this).attr('id', id);

      $(this).data('player', {
        type: 'youtube', player: new YT.Player(id, {
          events: {
            onReady: youtubePlayerReady,
            onStateChange: youtubePlayerStateChange
          }
        })
      });
    });
  };

  // Youtube player ready callback.
  function youtubePlayerReady(event) {
    var iframe = $(event.target.a);
    assignControlls(iframe);
  }

  // Passing events to iframe object.
  function youtubePlayerStateChange(event) {
    var iframe = $(event.target.a);
    switch (event.data) {
      case 0:
        iframe.trigger('onStop');
        break;

      case 1:
        iframe.trigger('onPlay');
        break;

      case 2:
        iframe.trigger('onPause');
        break;

      default:
        break;
    }
  }

  // Assigning controlls to player to use them.
  function assignControlls(iframe) {
    var player = iframe.data('player');
    switch (player.type) {
      case 'vimeo':
        // Assigning player controls.
        player.controls = {
          play: function () {
            player.player.play();
          },
          pause: function () {
            player.player.pause();
          },
          stop: function () {
            player.player.unload();
          }
        };

        // Assigning Vimeo player events.
        player.player.on('play', function () {
          iframe.trigger('onPlay');
        });
        player.player.on('pause', function () {
          iframe.trigger('onPause');
        });
        player.player.on('ended', function () {
          iframe.trigger('onStop');
        });

        break;

      case 'youtube':
        player.controls = {
          play: function () {
            player.player.playVideo();
          },
          pause: function () {
            player.player.pauseVideo();
          },
          stop: function () {
            player.player.stopVideo();
          }
        };
        break;

      default:
        break;
    }
  }

  /**
   * Drupal js behaviour callback.
   *
   * @type {{init: Drupal.behaviors.initVideoPlayer.init, attach: Drupal.behaviors.initVideoPlayer.attach}}
   */
  Drupal.behaviors.initVideoPlayer = {
    init: function ($element) {
      var player = $element.find('iframe'),
        playerThumbnail = $('.video-preview-image', $element),
        playerWrapper = $('.video-iframe-wrapper', $element);
      if (player.length) {
        var $videoButton = $element.parents('.paragraph__content').find('.video-play-btn');
        $videoButton.on('click', function () {
          player.data('player').controls.play();
          playerWrapper.css({visibility: "visible"});
          playerThumbnail.fadeOut(500);
        });

      }
    },
    attach: function (context) {
      $(context).find('.video-preview:not(.no-image)').once('video-formatter').each(function () {
        Drupal.behaviors.initVideoPlayer.init($(this), context);
      });
    }
  };
}(jQuery));
