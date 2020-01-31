@api @drupal @javascript
Feature: deGov - Media creation

  Background:
    Given I proof that the following Drupal modules are installed:
      | degov_media_video      |
      | degov_node_overrides   |
      | degov_node_normal_page |
      | degov_paragraph_text   |
      | degov_media_image      |
      | degov_media_gallery    |
    Given I am installing the "degov_paragraph_media_reference" module

  Scenario: I am creating a address media entity
    Given I have dismissed the cookie banner if necessary
    And I am logged in as a user with the "Administrator" role
    And I am on "/media/add/address"
    Then I fill in "Example address" for "Name"
    And I fill in "Example address public" for "Öffentlicher Titel"
    Then I fill in "DE" for "Land"
    And I wait 1 seconds
    And I should see HTML content matching "Straße" after a while
    And I select "DE" in "edit-field-address-address-0-address-country-code--2"
    And I wait 3 seconds
    And I fill in "Bilker Straße 29" for "Straße"
    And I fill in "40213" for "Postleitzahl"
    And I fill in "Düsseldorf" for "Stadt"
    And I scroll to top
    And I click "General" via translation
    And I check the box "Mediathek"
    And I scroll to element with id "edit-submit"
    And I press button with label "Save" via translated text

  Scenario: I proof that longitude and latitude has been generated automatically
    Given I have dismissed the cookie banner if necessary
    And I am logged in as a user with the "Administrator" role
    And I open address medias edit form from latest media with title "Example address public"
    And I should see HTML content matching "51.220793"
    And I should see HTML content matching "6.772623"

  Scenario: I am creating a quote media entity
    Given I have dismissed the cookie banner if necessary
    And I am logged in as a user with the "Administrator" role
    And I am on "media/add/citation"
    And I click "Beschreibung"
    Then I should see text matching "Öffentlicher Titel" after a while
    And I fill in the following:
      | Name               | Example quote              |
      | Öffentlicher Titel | Example quote public       |
      | Text               | Example text. Lorem ipsum. |
    Then I scroll to bottom
    And I press button with label "Save" via translated text
    And I am on "/admin/content/media"
    Then I should see text matching "Example quote" after a while

  Scenario: I am creating a person media entity
    Given I have dismissed the cookie banner if necessary
    And I am logged in as a user with the "Administrator" role
    And I am on "media/add/person"
    And I click "Beschreibung"
    Then I should see text matching "Öffentlicher Titel" after a while
    And I fill in the following:
      | Name               | Example person        |
      | Öffentlicher Titel | Example person public |
    Then I scroll to bottom
    And I press button with label "Save" via translated text
    And I am on "/admin/content/media"
    Then I should see text matching "Example person" after a while

  Scenario: I am creating a video upload media entity
    Given I have dismissed the cookie banner if necessary
    And I am logged in as an "Administrator"
    And I am on "/media/add/video_upload"
    And I fill in the following:
      | Name               | Video Example |
      | Öffentlicher Titel | Video Example |
    And I choose "Allgemein" from tab menu
    And I check the box "edit-field-include-search-value"
    And I choose "Medien" from tab menu
    And I attach the file "pexels-videos-1409899-standard.mp4" to "files[field_video_upload_mp4_0]"
    And I scroll to element with id "edit-submit"
    And I press button with label "Save" via translated text
    And I should see text matching "Video Upload Video Example wurde erstellt."

  Scenario: I create a rudimentary mobile video media entity
    Given I am logged in as an "Administrator"
    And I have dismissed the cookie banner if necessary
    And I am on "/media/add/video_mobile"
    And I fill in the following:
      | Name               | Mobile Video Example 1 |
      | Öffentlicher Titel | Mobile Video Example 1 |
    And I choose "Allgemein" from tab menu
    And I check the box "edit-field-include-search-value"
    And I choose "Medien" from tab menu
    And I attach the file "pexels-videos-1409899-mobile.mp4" to "files[field_mobile_video_mobile_mp4_0]"
    And I wait 3 seconds
    And I attach the file "pexels-videos-1409899-standard.mp4" to "files[field_video_mobile_mp4_0]"
    And I wait 3 seconds
    And I scroll to element with id "edit-submit"
    And I press button with label "Save" via translated text
    And I should see text matching "Responsives Video Mobile Video Example 1 wurde erstellt."

  Scenario: I create a mobile video media entity with HD videos
    Given I am logged in as an "Administrator"
    And I have dismissed the cookie banner if necessary
    And I am on "/media/add/video_mobile"
    And I fill in the following:
      | Name               | Mobile Video Example 2 |
      | Öffentlicher Titel | Mobile Video Example 2 |
    And I choose "Allgemein" from tab menu
    And I check the box "edit-field-include-search-value"
    And I choose "Medien" from tab menu
    And I attach the file "pexels-videos-1409899-standard.mp4" to "files[field_video_mobile_mp4_0]"
    And I wait 3 seconds
    And I attach the file "pexels-videos-1409899-mobile.mp4" to "files[field_mobile_video_mobile_mp4_0]"
    And I wait 3 seconds
    And I attach the file "pexels-videos-1409899-hd-ready.mp4" to "files[field_hdready_video_mobile_mp4_0]"
    And I wait 3 seconds
    And I attach the file "pexels-videos-1409899-full-hd.mp4" to "files[field_fullhd_video_mobile_mp4_0]"
    And I wait 3 seconds
    And I scroll to element with id "edit-submit"
    And I press button with label "Save" via translated text
    And I should see text matching "Responsives Video Mobile Video Example 2 wurde erstellt."

  Scenario: I test that the server-side video analysis works
    Given I am logged in as an "Administrator"
    And I have dismissed the cookie banner if necessary
    And I am on "/media/add/video_mobile"
    And I attach the file "portait-mode-mpeg4.mp4" to "files[field_video_mobile_mp4_0]"
    And I wait 3 seconds
    And I scroll to element with id "edit-submit"
    And I press button with label "Save" via translated text
    Then I should see HTML content matching 'Standard Video: Videomaße von 960 x 540 erwartet. Stattdessen vorgefunden: "480 x 720“.'
    Then I should see HTML content matching 'Standard Video: Seitenverhältnis von 16:9 erwartet. Stattdessen vorgefunden: "16:24".'
    Then I should see HTML content matching 'Standard Video: H.264 codiertes Video erwartet. Stattdessen vorgefunden: "mp4v".'

  Scenario: I test that messages from the video analysis don't repeat
    Given I have dismissed the cookie banner if necessary
    And I am logged in as an "Administrator"
    And I am on "/media/add/video_mobile"
    And I choose "Medien" from tab menu
    Then I attach the file "pexels-videos-1409899-standard.mp4" to "files[field_mobile_video_mobile_mp4_0]"
    And I wait 3 seconds
    And I should see 1 ".messages--warning" elements
    And I should see 0 ".messages--warning .messages__list" elements
    Then I attach the file "pexels-videos-1409899-hd-ready.mp4" to "files[field_video_mobile_mp4_0]"
    And I wait 3 seconds
    And I should see 2 ".messages--warning" elements
    And I should see 0 ".messages--warning .messages__list" elements

  Scenario: I verify that a mobile video entity has multiple download options
    Given I am logged in as an "Administrator"
    And I have dismissed the cookie banner if necessary
    And I am on "/media/add/video_mobile"
    And I fill in the following:
      | Name               | Video Example 2 |
      | Öffentlicher Titel | Video Example 2 |
    And I choose "Allgemein" from tab menu
    And I check the box "edit-field-include-search-value"
    And I choose "Medien" from tab menu
    And I attach the file "pexels-videos-1409899-mobile.mp4" to "files[field_mobile_video_mobile_mp4_0]"
    And I wait 3 seconds
    And I check checkbox with id "edit-field-allow-download-mobile-value"
    And I attach the file "pexels-videos-1409899-standard.mp4" to "files[field_video_mobile_mp4_0]"
    And I wait 3 seconds
    And I uncheck checkbox with id "edit-field-allow-download-value"
    And I attach the file "pexels-videos-1409899-full-hd.mp4" to "files[field_fullhd_video_mobile_mp4_0]"
    And I wait 3 seconds
    And I check checkbox with id "edit-field-allow-download-fullhd-value"
    And I scroll to element with id "edit-submit"
    And I press button with label "Save" via translated text
    And I should see text matching "Responsives Video Video Example 2 wurde erstellt."
    Then I am on "/video-example-2"
    And I should see 1 "video" elements
    And I should see 2 ".video-mobile__downloads .file--download" elements

  Scenario: I am creating a video media entity
    Given I have dismissed the cookie banner if necessary
    And I am logged in as an "Administrator"
    When I go to "/media/add/video"
    And I fill in the following:
      | Öffentlicher Titel     | Example video                               |
      | Name                   | Example video public                        |
      | Video-URL              | https://www.youtube.com/watch?v=qREKP9oijWI |
      | Quelle                 | youtube                                     |
    And I fill in "edit-field-media-publish-date-0-value-date" with "111118"
    And I fill in "edit-field-media-publish-date-0-value-time" with "000000AM"
    And I scroll to element with id "edit-submit"
    And I press button with label "Save" via translated text
    And I should not see text matching "Es konnte kein Video-Provider gefunden werden, der den angegeben URL verarbeiten kann."
    And I should see "Video Example video public wurde erstellt."

  Scenario: I am creating an Instagram media entity
    Given I have dismissed the cookie banner if necessary
    And I am logged in as an "Administrator"
    When I go to "media/add/instagram"
    Then I should see text matching "Öffentlicher Titel" after a while
    And I fill in the following:
      | Name               | Example Instagram                      |
      | Öffentlicher Titel | Example Instagram public               |
      | Instagram post     | https://www.instagram.com/p/JUvux9iFRY |
    And I scroll to element with id "edit-submit"
    And I press button with label "Save" via translated text
    Then I should not see "ist erforderlich."
    And I should see "Example Instagram wurde erstellt."

  Scenario: I am creating an media image entity with copyright
    Given I have dismissed the cookie banner if necessary
    And I am logged in as an "Administrator"
    And I am on "/media/add/image"
    And I fill in "Name" with "Test1234"
    And I fill in "edit-field-media-publish-date-0-value-date" with "111118"
    And I fill in "edit-field-media-publish-date-0-value-time" with "000000AM"
    And I fill in "Öffentlicher Titel" with "Test1234"
    And I should see text matching "320x320"
    And I attach the file "humberto-chavez-1058365-unsplash.jpg" to "edit-image-0-upload"
    And I should see text matching "Alternative text" via translation after a while
    And I fill in "Alternative text" via translated text with "Test1234"
    And I choose "Beschreibung" from tab menu
    And I fill in "Copyright" with "Test1234"
    And I scroll to element with id "edit-submit"
    And I press button with label "Save" via translated text
    Then I should not see "ist erforderlich."
    And I should see "wurde erstellt."

  Scenario: I try and fail to create a licensed image without copyright info
    Given I have dismissed the cookie banner if necessary
    And I am logged in as an "Administrator"
    And I am on "/media/add/image"
    And I fill in "Name" with "Test1234"
    And I fill in "edit-field-media-publish-date-0-value-date" with "111118"
    And I fill in "edit-field-media-publish-date-0-value-time" with "000000AM"
    And I fill in "Öffentlicher Titel" with "Test1234"
    And I should see text matching "320x320"
    And I attach the file "humberto-chavez-1058365-unsplash.jpg" to "edit-image-0-upload"
    And I should see text matching "Alternative text" via translation after a while
    And I fill in "Alternative text" via translated text with "Test1234"
    And I should see HTML content matching "Alternativer Text" after a while
    And I fill in "Alternativer Text" with "Test1234"
    And I scroll to element with id "edit-submit"
    And I press button with label "Save" via translated text
    Then I should see "ist erforderlich."

  Scenario: I try to create an image just to check if the copyright field is emptied when I set the image to be royalty free
    Given I have dismissed the cookie banner if necessary
    And I am logged in as an "Administrator"
    And I am on "/media/add/image"
    And I choose "Beschreibung" from tab menu
    And I fill in "Copyright" with "Test1234"
    And I scroll to element with id "edit-submit"
    And I press button with label "Save" via translated text
    Then I should see "ist erforderlich."
    And I choose "Beschreibung" from tab menu
    And I should see 1 form element with the label "Copyright" and the value "Test1234"
    And I check checkbox with id "edit-field-royalty-free-value"
    And I scroll to element with id "edit-submit"
    And I press button with label "Save" via translated text
    Then I should see "ist erforderlich."
    And I choose "Beschreibung" from tab menu
    And I should see 0 form element with the label "Copyright" and the value "Test1234"

  Scenario: I am creating an media image entity without copyright
    Given I have dismissed the cookie banner if necessary
    And I am logged in as an "Administrator"
    And I am on "/media/add/image"
    And I fill in "Name" with "Test1234"
    And I fill in "edit-field-media-publish-date-0-value-date" with "111118"
    And I fill in "edit-field-media-publish-date-0-value-time" with "000000AM"
    And I fill in "Öffentlicher Titel" with "Test1234"
    And I should see text matching "320x320"
    And I attach the file "humberto-chavez-1058365-unsplash.jpg" to "edit-image-0-upload"
    And I should see text matching "Alternative text" via translation after a while
    And I fill in "Alternative text" via translated text with "Test1234"
    And I choose "Beschreibung" from tab menu
    And I check checkbox with id "edit-field-royalty-free-value" by JavaScript
    And I scroll to element with id "edit-submit"
    And I press button with label "Save" via translated text
    Then I should not see "ist erforderlich."
    And I should see "wurde erstellt."

  Scenario: I try to create an image from the CKEditor entity embed dialog to check if the copyright field is present and can be emptied
    Given I have dismissed the cookie banner if necessary
    And I am logged in as an "Administrator"
    And I am on "/node/add/faq"
    And I click by CSS class "cke_button__media_browser"
    Then I should see HTML content matching "medien zum Einbetten auswählen" after a while
    And I switch to the "entity_browser_iframe_ckeditor_media_browser" frame
    And I click "Hochladen"
    Then I should see HTML content matching "Datei" after a while
    And I attach the file "humberto-chavez-1058365-unsplash.jpg" to "edit-input-file"
    Then I should see HTML content matching "Name" after a while
    And I fill in "Copyright" with "Test1234"
    And I scroll to element with id "edit-submit"
    And I press the "Place" button
    Then I should see text matching "ist erforderlich." after a while
    And I should see 1 form element with the label "Copyright" and the value "Test1234"
    And I click by selector "input[data-drupal-selector=edit-entity-field-royalty-free-value]" via JavaScript
    And I scroll to element with id "edit-submit"
    And I press the "Place" button
    Then I should see "ist erforderlich."
    And I verify that field "#edit-entity-field-copyright-0-target-id" has the value ""

  Scenario: I am creating an media gallery entity
    Given I have dismissed the cookie banner if necessary
    And I am logged in as an "Administrator"
    And I am on "/media/add/gallery"
    And I fill in "Name" with "Test1234"
    And I fill in "edit-field-media-publish-date-0-value-date" with "111118"
    And I fill in "edit-field-media-publish-date-0-value-time" with "000000AM"
    And I fill in "Öffentlicher Titel" with "Test1234"
    And I click by CSS id "edit-field-gallery-images-entity-browser-entity-browser-open-modal"
    And I switch to the "entity_browser_iframe_media_browser" frame
    And I should see HTML content matching "Hochladen" after a while
    And I click "Hochladen"
    And I attach the file "humberto-chavez-1058365-unsplash.jpg" to "edit-input-file"
    And I should see text matching "Alternative text" via translation after a while
    And I fill in "entity[field_title][0][value]" with "Test1234"
    And I fill in "entity[name][0][value]" with "Test1234"
    And I fill in "entity[image][0][alt]" with "Test1234"
    And I fill in "entity[field_copyright][0][target_id]" with "Test1234"
    And I press the "Auswählen" button
    And I press the "Use selected" button
    And I go back to the main window
    And I should see the details container titled "Current selections" with entries after a while
    And I scroll to element with id "edit-submit"
    And I press button with label "Save" via translated text
    Then I should not see "ist erforderlich."

  Scenario: I verify that the video upload dropzone plugin has been removed
    Given I am on "/"
    And I have dismissed the cookie banner if necessary
    And I am logged in as an "Administrator"
    And I am on "/node/add/normal_page"
    And I choose "Inhalt" from tab menu
    And I should see text matching "Inhaltsbereich"
    And I click by selector "#edit-field-content-paragraphs-wrapper .paragraph-type-add-modal-button" via JavaScript
    And I click by XPath "//input[@name='field_content_paragraphs_media_reference_add_more']"
    And I click by selector ".button.entity-browser-processed" via JavaScript
    And I switch to the "entity_browser_iframe_media_browser" frame
    Then I should not see text matching "Video Hochladen" after a while

  Scenario: Check if media full display is working if field_include_search is unchecked
    Given I am installing the "degov_demo_content" module
    Given I have dismissed the cookie banner if necessary
    And I am logged in as a user with the "administrator" role
    And I open media edit form by media name "demo image with a fixed title"
    And I choose "Allgemein" from tab menu
    And I uncheck the box "edit-field-include-search-value"
    And I scroll to element with id "edit-submit"
    And I press button with label "Save" via translated text
    And I am on "/demo-image-fixed-title"
    And I should not see "Mitglied seit"
    And I should see HTML content matching "media--view-mode-full"

  Scenario: I verify that a deleted Media's file is actually gone
    Given I am installing the "degov_demo_content" module
    And I have dismissed the cookie banner if necessary
    Given I am on "/"
    And I am logged in as a user with the "administrator" role
    Then I am on "/admin/content/media"
    Then I am on "/image-will-be-deleted"
    And I should see HTML content matching "/sites/default/files/degov_demo_content/taneli-lahtinen-1058552-unsplash.jpg"
    Then I am on "/sites/default/files/degov_demo_content/taneli-lahtinen-1058552-unsplash.jpg"
    Then I open medias delete url by title "This image will be deleted"
    And I click by CSS id "edit-submit"
    Then I am on "/sites/default/files/degov_demo_content/taneli-lahtinen-1058552-unsplash.jpg?1"
    And I should see HTML content matching "404 Not Found"

  Scenario: I proof that media browser does not provide video upload
    Given I am logged in as a user with the "administrator" role
    And I am on "/admin/config/content/entity_browser/media_browser/widgets"
    And I should not see HTML content matching "d6d67ff3-ab4f-482c-bf0f-aa21ef912d26"
