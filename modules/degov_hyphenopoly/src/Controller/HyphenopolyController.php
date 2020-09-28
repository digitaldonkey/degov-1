<?php

namespace Drupal\degov_hyphenopoly\Controller;

use Drupal\Core\Controller\ControllerBase;
use Drupal\Core\Render\RendererInterface;
use Symfony\Component\DependencyInjection\ContainerInterface;
use Symfony\Component\HttpFoundation\Response;
use Drupal\Core\Config\ConfigFactoryInterface;

/**
 * Provides a config based stylesheet.
 */
class HyphenopolyController extends ControllerBase {

  /**
   * The renderer.
   *
   * @var \Drupal\Core\Render\RendererInterface
   */
  protected $renderer;

  /**
   * The config.
   *
   * @var \Drupal\Core\Config\ConfigFactoryInterface
   */
  protected $config;

  /**
   * HyphenopolyController constructor.
   */
  public function __construct(RendererInterface $renderer, ConfigFactoryInterface $config_factory) {
    $this->renderer = $renderer;
    $this->config = $config_factory->get('degov_hyphenopoly.settings');
  }

  /**
   * {@inheritdoc}
   */
  public static function create(ContainerInterface $container) {
    return new self(
      $container->get('renderer'),
      $container->get('config.factory')
    );
  }

  /**
   * Provides a config based css file.
   *
   * @return \Symfony\Component\HttpFoundation\Response
   *   Returns a CSS file as response
   */
  public function cssContent() {
    $selectors = $this->config->get('hyphenopoly_selectors');
    $response = new Response();

    if (count($selectors)) {
      $css_selectors = '';
      foreach ($selectors as $s) {
        $css_selectors .= $s . ",\n";
      }
      $css_selectors = substr($css_selectors, 0, -2) . ' ';

      $build = [
        '#theme' => 'degov_hyphenopoly_css',
        '#css_selectors' => $css_selectors,
        '#cache' => [
          'tags' => $this->config->getCacheTags(),
        ],
      ];
      $rendered = $this->renderer->renderPlain($build);
      // Removes debug output.
      $clean_css = trim(strip_tags($rendered));
      $response->headers->set('Content-Type', 'text/css');
      $response->setContent($clean_css);
      return $response;
    }
    throw $response->createNotFoundException('Module not configured');
  }

}
