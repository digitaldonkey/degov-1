<?php

namespace Drupal\node_action\Plugin\Action;

use Drupal\Core\Access\AccessResultForbidden;
use Drupal\Core\Action\Plugin\Action\EntityActionBase;
use Drupal\Core\Entity\EntityTypeManagerInterface;
use Drupal\Core\Session\AccountInterface;
use Drupal\node\Entity\Node;
use Drupal\node_action\AccessChecker\PublishAction as PublishActionChecker;
use Symfony\Component\DependencyInjection\ContainerInterface;

/**
 * Publishes an node.
 *
 * @Action(
 *   id = "node_action:entity:publish_action:node",
 *   action_label = @Translation("Publish"),
 * )
 */
class PublishAction extends EntityActionBase {

  private $publishActionChecker;

  public function __construct(array $configuration, string $plugin_id, array $plugin_definition, EntityTypeManagerInterface $entity_type_manager, PublishActionChecker $publishActionChecker) {
    parent::__construct($configuration, $plugin_id, $plugin_definition, $entity_type_manager);
    $this->publishActionChecker = $publishActionChecker;
  }

  /**
   * {@inheritdoc}
   */
  public static function create(ContainerInterface $container, array $configuration, $plugin_id, $plugin_definition) {
    return new static(
      $configuration,
      $plugin_id,
      $plugin_definition,
      $container->get('entity_type.manager'),
      $container->get('node_action.access_checker.publish_action')
    );
  }

  /**
   * {@inheritdoc}
   */
  public function execute($entity = NULL): void {
    /**
     * @var Node $entity
     */
    $entity->set('moderation_state', 'published')->save();
  }

  /**
   * {@inheritdoc}
   */
  public function access($object, AccountInterface $account = NULL, $return_as_object = FALSE) {
    if (!$this->publishActionChecker->canAccess($object) instanceof AccessResultForbidden) {
      return TRUE;
    }

    return FALSE;
  }

}
