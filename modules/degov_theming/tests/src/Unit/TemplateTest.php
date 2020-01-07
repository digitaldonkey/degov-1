<?php

namespace Drupal\Tests\degov_theming\Unit;

use Drupal\Core\Asset\LibraryDiscovery;
use Drupal\Core\Entity\Entity;
use Drupal\Core\Theme\ActiveTheme;
use Drupal\Core\Theme\ThemeManager;
use Drupal\degov_theming\Facade\ComponentLocation;
use Drupal\degov_theming\Service\DrupalPath;
use Drupal\degov_theming\Service\Template;
use Drupal\Tests\UnitTestCase;
use org\bovigo\vfs\vfsStream;
use Prophecy\Argument;
use Drupal\Core\Template\TwigEnvironment;

/**
 * Class TemplateTest.
 */
class TemplateTest extends UnitTestCase {

  /**
   * Template.
   *
   * @var \Drupal\degov_theming\Service\Template
   */
  private $template;

  /**
   * {@inheritdoc}
   */
  protected function setUp() {
    parent::setUp();

    $this->mockThemeManager();
  }

  /**
   * Mock drupal path.
   *
   * @return \Drupal\degov_theming\Service\DrupalPath
   *   Drupal path.
   */
  private function mockDrupalPath($bundle) {
    $drupalPath = $this->prophesize(DrupalPath::class);
    switch ($bundle) {
      case 'normal_page':
        $drupalPath->getPath(Argument::type('string'), Argument::type('string'))
          ->willReturn('profiles/contrib/degov/modules/degov_node_normal_page');
        break;

      case 'blog':
        $drupalPath->getPath(Argument::type('string'), Argument::type('string'))
          ->willReturn('profiles/contrib/degov/modules/degov_node_blog');
        break;
    }

    return $drupalPath->reveal();
  }

  /**
   * Mock component location.
   */
  private function mockComponentLocation($bundle = 'normal_page') {
    /**
     * @var \Drupal\degov_theming\Facade\ComponentLocation $componentLocation
     */
    $componentLocation = $this->prophesize(ComponentLocation::class);
    $componentLocation->getDrupalPath()->willReturn($this->mockDrupalPath($bundle));
    $componentLocation->getFilesystem()->willReturn($this->mockFilesystem());
    $componentLocation->getLibraryDiscovery()->willReturn($this->mockLibraryDiscovery());

    return $componentLocation->reveal();
  }

  /**
   * Mock theme manager.
   *
   * @return \Drupal\Core\Theme\ThemeManager
   *   Theme manager.
   */
  private function mockThemeManager() {
    $themeManager = $this->prophesize(ThemeManager::class);

    $activeThemeStub = $this->prophesize(ActiveTheme::class);

    $baseTheme = $this->prophesize(ActiveTheme::class);
    $baseTheme->getPath()->willReturn('themes/custom/base_theme/');

    $projectTheme = $this->prophesize(ActiveTheme::class);
    $projectTheme->getBaseThemes()->willReturn([
      $baseTheme->reveal(),
      $activeThemeStub->reveal(),
    ]);
    $projectTheme->getPath()->willReturn('themes/custom/project_theme/');
    $projectTheme->reveal();

    $themeManager->getActiveTheme()->willReturn($projectTheme);

    return $themeManager->reveal();
  }

  /**
   * Mock library discovery.
   *
   * @return \Drupal\Core\Asset\LibraryDiscovery
   *   Library discovery.
   */
  private function mockLibraryDiscovery() {
    $libraryDiscovery = $this->prophesize(LibraryDiscovery::class);
    $libraryDiscovery->getLibraryByName(Argument::type('string'), Argument::type('string'))
      ->willReturn('any.library');

    return $libraryDiscovery->reveal();
  }

  /**
   * Mock filesystem.
   *
   * @return \Drupal\degov_theming\Factory\FilesystemFactory
   *   Filesystem factory.
   */
  private function mockFilesystem() {
    return vfsStream::setup(NULL, NULL, [
      'profiles' => [
        'contrib' => [
          'degov' => [
            'modules' => [
              'degov_node_blog' => [],
              'degov_node_normal_page' => [
                'templates' => [
                  'node--normal_page--small_image.html.twig' => 'Foo',
                  'node--normal_page--preview.html.twig'     => 'Foo',
                  'node--normal_page--default.html.twig'     => 'Foo',
                  'node--normal_page--full.html.twig'        => 'Foo',
                ],
              ],
            ],
          ],
        ],
      ],
      'themes'   => [
        'custom' => [
          'project_theme' => [
            'templates' => [
              'nodes' => [
                'node--normal_page--preview.html.twig' => 'Foo',
                'node--normal_page--default.html.twig' => 'Foo',
              ],
            ],
          ],
          'base_theme'    => [
            'templates' => [
              'node--normal_page--preview.html.twig' => 'Foo',
              'node--normal_page--full.html.twig'    => 'Foo',
            ],
          ],
        ],
      ],
    ]);
  }

  /**
   * Mock twig.
   *
   * @return \Drupal\Core\Template\TwigEnvironment
   *   Twig environment.
   */
  private function mockTwig() {
    $twig = $this->prophesize(TwigEnvironment::class);

    return $twig->reveal();
  }

  /**
   * Get preprocess.
   */
  public function getPreprocess() {
    $out = [];

    $out[] = [
      'hook'    => 'node',
      'info'    => [
        'render element' => 'elements',
        'type'           => 'base_theme',
        'theme path'     => 'themes',
        'template'       => 'node--normal_page--default',
        'path'           => 'themes/base-theme/templates',
      ],
      'options' => [
        'module_name'       => 'degov_node_normal_page',
        'entity_type'       => 'node',
        'entity_bundles'    =>
          [
            0 => 'normal_page',
          ],
        'entity_view_modes' =>
          [
            0 => 'full',
            1 => 'long_text',
            2 => 'preview',
            3 => 'slim',
            4 => 'small_image',
          ],
      ],
    ];

    return $out;
  }

  /**
   * Get client  theme preprocess.
   */
  public function getClientThemePreprocess() {
    $out = [];

    $out[] = [
      'hook'    => 'node',
      'info'    => [
        'render element' => 'elements',
        'type'           => 'base_theme',
        'theme path'     => 'themes',
        'template'       => 'node--normal_page--default',
        'path'           => 'themes/client-theme/templates',
      ],
      'options' => [
        'module_name'       => 'degov_node_normal_page',
        'entity_type'       => 'node',
        'entity_bundles'    =>
          [
            0 => 'normal_page',
          ],
        'entity_view_modes' =>
          [
            0 => 'full',
            1 => 'long_text',
            2 => 'preview',
            3 => 'slim',
            4 => 'small_image',
          ],
      ],
    ];

    return $out;
  }

  /**
   * Get no template preprocess.
   */
  public function getNoTemplatePreprocess() {
    $out = [];

    $out[] = [
      'hook'    => 'node',
      'info'    => [
        'render element' => 'elements',
        'type'           => 'base_theme',
        'theme path'     => 'themes',
        'template'       => 'node--blog--default',
        'path'           => 'themes/client-theme/templates',
      ],
      'options' => [
        'module_name'       => 'degov_node_blog',
        'entity_type'       => 'node',
        'entity_bundles'    =>
          [
            0 => 'blog',
          ],
        'entity_view_modes' =>
          [
            0 => 'full',
            1 => 'long_text',
            2 => 'preview',
            3 => 'slim',
            4 => 'small_image',
          ],
      ],
    ];

    return $out;
  }

  /**
   * Test suggest template from module.
   *
   * @dataProvider getPreprocess()
   */
  public function testSuggestTemplateFromModule($hook, $info, $options) {
    $this->template = new Template($this->mockThemeManager(), $this->mockComponentLocation(), $this->mockTwig());

    $node = $this->prophesize(Entity::class);
    $node->bundle()->willReturn('normal_page');

    $variables = [
      'elements' => [
        '#view_mode' => 'small_image',
      ],
      'node'     => $node->reveal(),
    ];

    $this->template->suggest($variables, $hook, $info, $options);

    $this->assertArrayEquals(
      [
        'render element' => 'elements',
        'type'           => 'base_theme',
        'theme path'     => 'modules',
        'template'       => 'node--normal_page--small_image',
        'path'           => 'profiles/contrib/degov/modules/degov_node_normal_page/templates',
      ],
      $info
    );
  }

  /**
   * Test suggest template from base theme.
   *
   * @dataProvider getPreprocess()
   */
  public function testSuggestTemplateFromBaseTheme($hook, $info, $options) {
    $this->template = new Template($this->mockThemeManager(), $this->mockComponentLocation(), $this->mockTwig());

    $node = $this->prophesize(Entity::class);
    $node->bundle()->willReturn('normal_page');

    $variables = [
      'elements' => [
        '#view_mode' => 'full',
      ],
      'node'     => $node->reveal(),
    ];

    $this->template->suggest($variables, $hook, $info, $options);

    $this->assertArrayEquals(
      [
        'render element' => 'elements',
        'type'           => 'base_theme',
        'theme path'     => 'themes',
        'template'       => 'node--normal_page--full',
        'path'           => 'themes/custom/base_theme/templates',
      ],
      $info
    );
  }

  /**
   * Test suggest template from project theme in preview viewmode.
   *
   * @dataProvider getClientThemePreprocess()
   */
  public function testSuggestTemplateFromProjectThemeInPreviewViewMode($hook, $info, $options) {
    $this->template = new Template($this->mockThemeManager(), $this->mockComponentLocation(), $this->mockTwig());

    $node = $this->prophesize(Entity::class);
    $node->bundle()->willReturn('normal_page');

    $variables = [
      'elements' => [
        '#view_mode' => 'preview',
      ],
      'node'     => $node->reveal(),
    ];

    $this->template->suggest($variables, $hook, $info, $options);

    $this->assertArrayEquals(
      [
        'render element' => 'elements',
        'type'           => 'base_theme',
        'theme path'     => 'themes',
        'template'       => 'node--normal_page--preview',
        'path'           => 'themes/custom/project_theme/templates/nodes',
      ],
      $info
    );
  }

  /**
   * Test suggest template from project  theme in default viewmode.
   *
   * @dataProvider getClientThemePreprocess()
   */
  public function testSuggestTemplateFromProjectThemeInDefaultViewMode($hook, $info, $options) {
    $this->template = new Template($this->mockThemeManager(), $this->mockComponentLocation(), $this->mockTwig());

    $node = $this->prophesize(Entity::class);
    $node->bundle()->willReturn('normal_page');

    $variables = [
      'elements' => [
        '#view_mode' => 'default',
      ],
      'node'     => $node->reveal(),
    ];

    $this->template->suggest($variables, $hook, $info, $options);

    $this->assertArrayEquals(
      [
        'render element' => 'elements',
        'type'           => 'base_theme',
        'theme path'     => 'themes',
        'template'       => 'node--normal_page--default',
        'path'           => 'themes/custom/project_theme/templates/nodes',
      ],
      $info
    );
  }

  /**
   * Test do not add suggestion if no template is found.
   *
   * @dataProvider getNoTemplatePreprocess()
   */
  public function testDoNotAddSuggestionIfNoTemplateIsFound($hook, $info, $options) {
    $this->template = new Template($this->mockThemeManager(), $this->mockComponentLocation('blog'), $this->mockTwig());

    $node = $this->prophesize(Entity::class);
    $node->bundle()->willReturn('blog');

    $variables = [
      'elements' => [
        '#view_mode' => 'long_text',
      ],
      'node' => $node->reveal(),
    ];

    $this->template->suggest($variables, $hook, $info, $options);

    $this->assertArrayEquals(
      [
        'render element' => 'elements',
        'type'           => 'base_theme',
        'theme path'     => 'themes',
        'template'       => 'node--blog--default',
        'path'           => 'themes/client-theme/templates',
      ],
      $info
    );
  }

}
