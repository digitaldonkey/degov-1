<?php

namespace Drupal\degov_common;

/**
 * Class Common.
 *
 * Contains all common function implementations.
 *
 * @package Drupal\degov_common
 */
class Common {

  /**
   * Remove content.
   *
   * @param array $options
   *   Options.
   */
  public static function removeContent(array $options): void {
    $entity_type = $options['entity_type'];
    $entity_bundles = $options['entity_bundles'];

    if (\in_array($entity_type, ['paragraph', 'node'])) {
      foreach ($entity_bundles as $entity_bundle) {
        self::removeEntities($entity_type, $entity_bundle, 'type');
      }
    }

    if ($entity_type === 'taxonomy_term') {
      foreach ($entity_bundles as $entity_bundle) {
        self::removeEntities($entity_type, $entity_bundle, 'vid');
      }
    }

    if ($entity_type === 'media') {
      foreach ($entity_bundles as $entity_bundle) {
        self::removeEntities($entity_type, $entity_bundle, 'bundle');
      }
    }
  }

  /**
   * Remove entities.
   *
   * @param int $entity_id
   *   Entity ID.
   * @param string $entity_bundle
   *   Entity bundle.
   * @param string $condition_field
   *   Condition field.
   */
  public static function removeEntities($entity_id, $entity_bundle, $condition_field): void {
    \Drupal::logger($entity_id)
      ->notice('Removing all content of type @type', ['@type' => $entity_bundle]);
    $entity_ids = \Drupal::entityQuery($entity_id)
      ->condition($condition_field, $entity_bundle)
      ->accessCheck(FALSE)
      ->execute();
    $controller = \Drupal::entityTypeManager()->getStorage($entity_id);
    $entities = $controller->loadMultiple($entity_ids);
    $controller->delete($entities);
  }

}
