/**
 * @file
 * Video_upload.js.
 *
 * Defines the behavior of the media bundle video.
 */

(function ($, Drupal, drupalSettings) {

  'use strict';

  /**
   * Behavior for Video Transcript acordion.
   */
  Drupal.behaviors.audio = {
    attach: function (context, settings) {
      $('.audio__transcription', context).once('audio-js').each(function () {
        var transcriptionContent = $('.audio__transcription__body', context);
        $('.audio__transcription__header', context).click(function () {
          $(this).parent().toggleClass('is-open');
          transcriptionContent.slideToggle();
          $('i', this).toggleClass('fa-caret-right fa-caret-down');
        });
        transcriptionContent.slideToggle();
      });
    }
  }
})(jQuery, Drupal, drupalSettings);
