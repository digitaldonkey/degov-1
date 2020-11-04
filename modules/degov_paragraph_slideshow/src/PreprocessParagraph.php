<?php

namespace Drupal\degov_paragraph_slideshow;

use Drupal\Component\Utility\Html;
use Drupal\Core\DependencyInjection\ContainerInjectionInterface;
use Drupal\Core\Entity\EntityTypeManagerInterface;
use Drupal\Core\Extension\ModuleHandlerInterface;
use Drupal\Core\Url;
use Symfony\Component\DependencyInjection\ContainerInterface;

/**
 * Class PreprocessParagraph.
 */
final class PreprocessParagraph implements ContainerInjectionInterface {

  /**
   * The entity type manager.
   *
   * @var \Drupal\Core\Entity\EntityTypeManagerInterface
   */
  protected $entityTypeManager;

  /**
   * Module handler.
   *
   * @var \Drupal\Core\Extension\ModuleHandlerInterface
   */
  protected $moduleHandler;

  /**
   * PreprocessParagraph constructor.
   *
   * @param \Drupal\Core\Entity\EntityTypeManagerInterface $entityTypeManager
   *   The entity type manager service.
   * @param \Drupal\Core\Extension\ModuleHandlerInterface $module_handler
   *   Module handler.
   */
  public function __construct(EntityTypeManagerInterface $entityTypeManager, ModuleHandlerInterface $module_handler) {
    $this->entityTypeManager = $entityTypeManager;
    $this->moduleHandler = $module_handler;
  }

  /**
   * {@inheritdoc}
   */
  public static function create(ContainerInterface $container) {
    return new static(
      $container->get('entity_type.manager'),
      $container->get('module_handler')
    );
  }

  /**
   * Preprocess the paragraphs type "slide".
   *
   *  See degov_paragraph_slideshow_preprocess_paragraph.
   *
   * @param array &$variables
   *   The theme preprocess function argument.
   */
  public function slide(array &$variables): void {
    /** @var \Drupal\paragraphs\Entity\Paragraph $paragraph */
    $paragraph = $variables['paragraph'];
    // Add the variable slide_link.
    $variables['slide_link'] = FALSE;
    if ($paragraph->field_slide_link->uri) {
      $url = Url::fromUri($paragraph->field_slide_link->uri);
      $variables['slide_link'] = $url;
    }
  }

  /**
   * Preprocess the paragraphs type "slide".
   *
   * See degov_paragraph_slideshow_preprocess_paragraph.
   *
   * @param array &$variables
   *   The theme preprocess function argument.
   */
  public function slider(array &$variables): void {
    /** @var \Drupal\paragraphs\Entity\Paragraph $paragraph */
    $paragraph = $variables['paragraph'];

    // Add the variable slideshow_type.
    $variables['slideshow_type'] = $paragraph->field_slideshow_type->value;

    // Loop each paragraph in the slideshow field to propagate
    // referenced slides.
    if ($this->moduleHandler->moduleExists('degov_paragraph_node_reference')
      || $this->moduleHandler->moduleExists('degov_paragraph_view_reference')) {
      $propagated_slides = [];

      $paragraph_slides = $paragraph->field_slideshow_slides->referencedEntities();

      foreach ($paragraph_slides as $i => $paragraph_slide) {
        if ($paragraph_slide->hasField('field_node_reference_nodes')) {
          // Every node reference should be included as a single slide.
          foreach ($paragraph_slide->field_node_reference_nodes->referencedEntities() as $node) {
            $view_builder = $this->entityTypeManager->getViewBuilder('node');
            $propagated_slides[] = $view_builder->view($node, 'slideshow');
          }
        }
        elseif ($paragraph_slide->hasField('field_view_reference_view')) {
          // Every node in a view reference should be included as
          // a single slide.
          $result = views_get_view_result($paragraph_slide->field_view_reference_view->target_id, $paragraph_slide->field_view_reference_view->display_id);
          foreach ($result as $row) {
            $view_builder = $this->entityTypeManager->getViewBuilder('node');
            $propagated_slides[] = $view_builder->view($row->_entity, 'slideshow');
          }
        }
        else {
          // Normal paragraph slides will be included back in the slideshow.
          $propagated_slides[] = $variables['content']['field_slideshow_slides'][$i];
        }
        // Unset each slide, as last step will propagate all slides again.
        unset($variables['content']['field_slideshow_slides'][$i]);
      }

      // Media copyright field.
      if ($this->moduleHandler->moduleExists('degov_media_copyright')) {
        foreach ($propagated_slides as $k => $slide) {
          $media = NULL;
          $mediaCopyright = NULL;
          $slideParagraph = NULL;

          // Get media from paragraph.
          if (isset($slide['#paragraph'])) {
            $slideParagraph = $slide['#paragraph'];
            if (is_object($slideParagraph) && isset($slideParagraph->field_slide_media->referencedEntities()[0])) {
              $media = $slideParagraph->field_slide_media->referencedEntities()[0];
            }
          }
          // Get media from node field.
          elseif (isset($slide['#node'])) {
            $node = $slide['#node'];
            if ($node->hasField('field_teaser_image') && isset($node->get('field_teaser_image')->referencedEntities()[0])) {
              $media = $node->get('field_teaser_image')->referencedEntities()[0];
            }
          }

          // Attach media_copyright.
          if ($media) {
            $mediaCopyright = $media->get('field_media_copyright')->first()->view();
            $mediaCopyright['#attributes'] = [
              'class' => ['copyright-slide-' . $k],
            ];
            if ($k === 0) {
              $mediaCopyright['#attributes']['class'][] = 'is-visible';
            }

            // Override caption from paragraphs.
            $hasCaptionOverride = $slideParagraph
              && $slideParagraph->hasField('field_override_caption')
              && !$slideParagraph->get('field_override_caption')->isEmpty();
            if ($hasCaptionOverride) {
              $mediaCopyright['#caption'] = $slideParagraph->get('field_override_caption')->first()->value;
            }

            // Attach to slider.
            if ($mediaCopyright) {
              $propagated_slides[$k]['field_media_copyright'] = $mediaCopyright;
            }
          }
        }
      }
      $variables['content']['field_slideshow_slides'] += $propagated_slides;
      // Add a counter variable.
      $variables['content']['field_slideshow_slides']['#number_of_slides'] = count($propagated_slides);
    }
    $variables['slider_id'] = Html::getUniqueId('degov-slider');
    $variables['#attached']['library'][] = 'degov_paragraph_slideshow/slideshow';
  }

}
