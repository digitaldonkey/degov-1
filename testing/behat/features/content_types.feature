@api @drupal @javascript
Feature: NRWGov content types
  Scenario: Content type normal_page has all required fields
    Given I am logged in as a user with the "administrator" role
    Then I am installing the "degov_node_overrides" module
    And I am installing the "degov_node_normal_page" module
    And I am on "/admin/structure/types/manage/normal_page/fields"
    And I should see text matching "field_header_paragraphs"
    And I should see text matching "field_tags"
    And I should see text matching "field_sidebar_right_paragraphs"
    And I should see text matching "field_social_media"
    And I should see text matching "field_teaser_image"
    And I should see text matching "field_teaser_text"
    And I should see text matching "field_teaser_title"
    And I should see text matching "field_teaser_sub_title"

  Scenario: Content type event has all required fields
    Given I am logged in as a user with the "administrator" role
    Then I am installing the "degov_node_event" module
    And I am on "/admin/structure/types/manage/event/fields"
    Then I should see text matching "field_event_date_end"
    And I should see text matching "field_content_paragraphs"
    And I should see text matching "field_internal_title"
    And I should see text matching "field_header_paragraphs"
    And I should see text matching "field_tags"
    And I should see text matching "field_sidebar_right_paragraphs"
    And I should see text matching "field_social_media"
    And I should see text matching "field_teaser_image"
    And I should see text matching "field_teaser_text"
    And I should see text matching "field_teaser_title"
    And I should see text matching "field_teaser_sub_title"
