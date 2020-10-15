@api @drupal @content
Feature: deGov - Demo Content

  Background:
    Given I am installing the following Drupal modules:
      | degov_demo_content |

  Scenario: Check if all teasers will be displayed
    Given I am logged in as a user with the "administrator" role
    And I delete all content
    And I reset the demo content
    And I am on "/degov-demo-content/page-all-teasers"
    And I should see HTML content matching "Page with text paragraph in sidebar" after a while
    And I should see HTML content matching "Page with download paragraph" after a while
    And I should see HTML content matching "Page with iframe paragraph" after a while
    And I should see HTML content matching "Page with map paragraph" after a while
    And I should see HTML content matching "Page with FAQ-List paragraph" after a while
    And I should see HTML content matching "Page with video header" after a while
    And I should see HTML content matching "Page with type 1 slideshow" after a while
    And I should see HTML content matching "Page with banner" after a while
    And I should see HTML content matching "Teaser - Small Image" after a while
    And I should see HTML content matching "Teaser - Long Text" after a while
    And I should see HTML content matching "Teaser - Slim" after a while
    And I should see HTML content matching "Teaser - Preview" after a while
    And I should see 149 ".paragraph__content article .image" elements
    And I should see 152 ".paragraph__content article .teaser-title" elements
    And I should see 114 ".paragraph__content article [class*=__teaser-text]" elements

  Scenario: Check for missing fields
    Given I am logged in as a user with the "administrator" role
    And I am on "/degov-demo-content/page-banner"
    And I should see HTML content matching "Page with banner" after a while
    And I should see HTML content matching "A page with an image header" after a while
    And I should see HTML content matching "degov_demo_content" after a while

  Scenario: Check page with video mobile
    Given I am logged in as a user with the "administrator" role
    And I am on "/degov-demo-content/page-responsive-video"
    Then I should see text matching "Page with responsive video" after a while
    And I should see text matching "Choose quality:" via translated text
    And I should see text matching "Download" via translated text

  Scenario: Check that the transcription toggle is working correctly.
    Given I am on "/video-upload/video-upload-sound"
    Then I should see HTML content matching "fa-caret-right"
    And I should not see the element with css selector ".video-upload__transcription__body"
    When I click by selector ".video-upload__transcription__header" via JavaScript
    Then I should see HTML content matching "fa-caret-down"
    And I should see the element with css selector ".video-upload__transcription__body"

  Scenario: Check that generated video upload without sound does not have subtitles file attached
    Given I have dismissed the cookie banner if necessary
    And I am logged in as a user with the "administrator" role
    And I open media edit form by media name "The latest video upload"
    And I choose "Beschreibung" from tab menu
    Then I should see 0 "#field-video-upload-subtitle-values .paragraph-type-title" elements

  Scenario: Check that generated video upload has a subtitles file attached
    Given I have dismissed the cookie banner if necessary
    And I am logged in as a user with the "administrator" role
    And I open media edit form by media name "A video upload with sound"
    And I choose "Beschreibung" from tab menu
    Then I should see 1 "#field-video-upload-subtitle-values .paragraph-type-title" elements

  Scenario: I verify that long paragraph title links are not cut off
    Given I have dismissed the cookie banner if necessary
    And I am on "/degov-demo-content/page-text-paragraph"
    Then I should see HTML content matching "https://www.example.com/this-is-a-very-long-link-over-eighty-characters-that-should-not-be-cut-off"
