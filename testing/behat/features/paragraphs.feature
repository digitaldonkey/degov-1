@api @drupal @entities
Feature: deGov - Paragraphs

  Background:
    Given I am installing the "degov_paragraph_block_reference" module

  Scenario: Banner paragraph should contain expected fields
    Given I am logged in as a user with the "administrator" role
    And I am on "/admin/structure/paragraphs_type/image_header/fields"
    Then I should see the fields list with exactly 2 entries
    And I should see text matching "field_override_caption"
    And I should see text matching "field_header_media"

  Scenario: Paragraph block reference has correct blocks and can create an instance
    Given I have dismissed the cookie banner if necessary
    And I am logged in as a user with the "administrator" role
    And I am on "/node/add/normal_page#edit-group-righ"
    And I fill in "testblockreferenz" for "Titel"
    And I press the "edit-field-sidebar-right-paragraphs-add-more-add-modal-form-area-add-more" button
    And I press "field_sidebar_right_paragraphs_block_reference_sidebar_add_more"
    And I should see text matching "Block Referenz Seitenleiste" after a while
    Given Select "field_sidebar_right_paragraphs[0][subform][field_block_plugin][0][plugin_id]" has following options "views_block:press_latest_content-latest_press simplenews_subscription_block"
    And I select "simplenews_subscription_block" from "field_sidebar_right_paragraphs[0][subform][field_block_plugin][0][plugin_id]"
    And I should see text matching "Newsletter" after a while
    And I check checkbox by value "default" via JavaScript
    And I select "published" from "edit-moderation-state-0-state"
    And I press button with label "Save" via translated text
    And I should see HTML content matching "block-simplenews-subscription-block"

  Scenario: Blocks in sidebar block reference have reduced title options
    Given I am logged in as a user with the "administrator" role
    And I am on "/node/add/normal_page"
    And I click "Seitenleiste rechts"
    And I press the "edit-field-sidebar-right-paragraphs-add-more-add-modal-form-area-add-more" button
    And I press "field_sidebar_right_paragraphs_block_reference_sidebar_add_more"
    And I should see text matching "Block Referenz Seitenleiste" after a while
    Given Select "field_sidebar_right_paragraphs[0][subform][field_block_plugin][0][plugin_id]" has following options "views_block:press_latest_content-latest_press simplenews_subscription_block"
    And I select "views_block:press_latest_content-latest_press" from "field_sidebar_right_paragraphs[0][subform][field_block_plugin][0][plugin_id]"
    And I should not see text matching "Titel anzeigen" after a while
    And I should not see text matching "Titel übersteuern" after a while
    And I should not see HTML content matching "edit-field-sidebar-right-paragraphs-0-subform-field-block-plugin-0-settings-views-label-fieldset"

  Scenario: Paragraph Download type has its fields correctly translated
    Given I am logged in as a user with the "administrator" role
    Then I am installing the following Drupal modules:
      | degov_paragraph_downloads          |
    And I am on "/admin/structure/paragraphs_type/downloads/fields"
    Then I should see text matching "Dateien"
    And I should see text matching "Untertitel"
    And I should see text matching "Titel"
    And I should see text matching "Titellink"
    Then I am on "/admin/config/regional/language/add"
    And I select "en" in "edit-predefined-langcode"
    And I press button with label "Add language" via translated text
    Then I should see text matching "Add language" via translation after a while
    Then I set the privacy policy page for all languages
    And I clear the cache
    And I am on "/en/admin/structure/paragraphs_type/downloads/fields"
    And I should see text matching "Files"
    And I should see text matching "Subtitle"
    And I should see text matching "Title"
    And I should see text matching "Title Link"

  Scenario: Video upload can be added to the slide paragraph and it shows up on the page
    Given I have dismissed the cookie banner if necessary
    Given I am logged in as a user with the "administrator" role
    And I am on "/node/add/normal_page"
    And I fill in "title[0][value]" with "Video-upload-slide-paragraph-test"
    And I click by selector ".vertical-tabs__menu a[href=\'#edit-group-header\']" via JavaScript
    And I press the "edit-field-header-paragraphs-add-more-add-modal-form-area-add-more" button
    And I press "field-header-paragraphs-slide-add-more"
    Then I should see text matching "Slide" via translated text after a while
    And I click by selector ".field--name-field-slide-media > details > summary" via JavaScript
    And I click by selector ".field--name-field-slide-media input.form-submit" via JavaScript
    And I wait 2 seconds
    And I focus on the Iframe with ID "entity_browser_iframe_media_browser"
    And I set the value of element ".views-exposed-form .form-item-bundle select" to "video_upload" via JavaScript
    And I click by selector ".views-exposed-form .form-submit" via JavaScript
    And I wait for AJAX to finish
    And I click by selector ".view-content .row-1 > .col-1" via JavaScript
    And I click by selector ".is-entity-browser-submit" via JavaScript
    And I wait 2 seconds
    And I go back to the main window
    And I press button with label "Save" via translated text
    And I should see HTML content matching "</video>"

  Scenario: Responsive video can be added to the slide paragraph and it shows up on the page
    Given I have dismissed the cookie banner if necessary
    Given I am logged in as a user with the "administrator" role
    And I am on "/node/add/normal_page"
    And I fill in "title[0][value]" with "Responsive-video-slide-paragraph-test"
    And I click by selector ".vertical-tabs__menu a[href=\'#edit-group-header\']" via JavaScript
    And I press the "edit-field-header-paragraphs-add-more-add-modal-form-area-add-more" button
    And I press "field-header-paragraphs-slide-add-more"
    Then I should see text matching "Slide" via translated text after a while
    And I click by selector ".field--name-field-slide-media > details > summary" via JavaScript
    And I click by selector ".field--name-field-slide-media input.form-submit" via JavaScript
    And I wait 2 seconds
    And I focus on the Iframe with ID "entity_browser_iframe_media_browser"
    And I set the value of element ".views-exposed-form .form-item-bundle select" to "video_mobile" via JavaScript
    And I click by selector ".views-exposed-form .form-submit" via JavaScript
    And I wait for AJAX to finish
    And I click by selector ".view-content .row-1 > .col-1" via JavaScript
    And I click by selector ".is-entity-browser-submit" via JavaScript
    And I wait 2 seconds
    And I go back to the main window
    And I press button with label "Save" via translated text
    And I should see HTML content matching "</video>"
