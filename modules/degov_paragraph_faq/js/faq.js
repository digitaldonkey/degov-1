/**
 * @file
 * faq.js
 *
 * Defines the behavior of the FAQ paragraph.
 */

(function ($, Drupal, drupalSettings) {

  'use strict';

  /**
   * Hide/shows a FAQ paragraph text by clicking on the title.
   */
  Drupal.behaviors.faq = {
    attach: function (context, settings) {

      if ($('.faq', context).length == 0) {
        return;
      }

      $('.faq', context).once('faq-is-opened').each(function () {
        var wrapper = $(this);
        $('.faq-question', wrapper).click(function () {
          if (wrapper.hasClass('is-openend')) {
            $('.faq-answer', wrapper).slideUp();
            wrapper.removeClass('is-openend');
          }
          else {
            $('.faq-answer', wrapper).slideDown();
            wrapper.addClass('is-openend');
          }
        });
        $('.faq-question', wrapper).keyup(function (e) {
          if (e.key === "Enter") {
            e.preventDefault();
            $('.faq-question', wrapper).click();
          }
        });
      });
    }
  }

})(jQuery, Drupal, drupalSettings);
