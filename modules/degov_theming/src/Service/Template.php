<?php

declare(strict_types=1);

namespace Drupal\degov_theming\Service;

use Drupal\Core\Template\TwigEnvironment;
use Drupal\Core\Theme\ActiveTheme;
use Drupal\Core\Theme\ThemeInitializationInterface;
use Drupal\Core\Theme\ThemeManagerInterface;
use Drupal\degov_theming\Facade\ComponentLocation;

/**
 * Class Template.
 */
class Template {

  /**
   * Theme manager.
   *
   * @var \Drupal\Core\Theme\ThemeManagerInterface
   */
  private $themeManager;

  /**
   * Library discovery.
   *
   * @var \Drupal\Core\Asset\LibraryDiscovery
   */
  private $libraryDiscovery;

  /**
   * Drupal path.
   *
   * @var DrupalPath
   */
  private $drupalPath;

  /**
   * File system.
   *
   * @var \Symfony\Component\Filesystem\Filesystem
   */
  private $filesystem;

  /**
   * Twig.
   *
   * @var \Drupal\Core\Template\TwigEnvironment
   */
  private $twig;

  /**
   * @var \Drupal\Core\Theme\ThemeInitializationInterface
   */
  private $themeInitialization;

  /**
   * Template constructor.
   */
  public function __construct(
    ThemeManagerInterface $themeManager,
  ComponentLocation $componentLocation,
  TwigEnvironment $twig,
    ThemeInitializationInterface $theme_initialization
  ) {
    $this->themeManager = $themeManager;
    $this->libraryDiscovery = $componentLocation->getLibraryDiscovery();
    $this->filesystem = $componentLocation->getFilesystem();
    $this->drupalPath = $componentLocation->getDrupalPath();
    $this->twig = $twig;
    $this->themeInitialization = $theme_initialization;
  }

  /**
   * Get inherited theme.
   */
  private function getInheritedTheme(): ActiveTheme {
    $activeTheme = $this->themeManager->getActiveTheme();
    $baseThemes = $activeTheme->getBaseThemeExtensions();
    $base_theme = reset($baseThemes);
    return $this->themeInitialization->getActiveThemeByName($base_theme->getName());
  }

  /**
   * Build path.
   */
  private function buildPath(string $base, string $directory): string {
    if (!preg_match("/\/$/", $base)) {
      $base .= '/';
    }
    return $base . $directory;
  }

  /**
   * Add template to array if file is found.
   */
  private function addTemplateToArrayIfFileIsFound(array &$original_array, string $theme_path, string $template_filename, string $directory_name): bool {
    $template_filename_with_suffix = $template_filename . '.html.twig';
    if ($directory_iterator = $this->getFileSystemIteratorForDirectory($directory_name)) {
      foreach ($directory_iterator as $file_in_directory) {
        if ($file_in_directory->getFilename() === $template_filename_with_suffix) {
          $original_array = array_merge($original_array, [
            'template'   => $template_filename,
            'theme path' => $theme_path,
            'path'       => $this->getDirnameWithoutVfsProtocol($file_in_directory->getPathName()),
          ]);
          return TRUE;
        }
      }
    }
    return FALSE;
  }

  /**
   * Get directory name without vfs protocol.
   */
  private function getDirnameWithoutVfsProtocol(string $path): string {
    $path = dirname($path);
    if (preg_match('/^vfs:\/\/\//', $path)) {
      $path = str_replace('vfs:///', '', $path);
    }
    return $path;
  }

  /**
   * Get filesystem interator for directory.
   */
  private function getFileSystemIteratorForDirectory(string $directory_name) {
    $directory_path = $directory_name;
    if (preg_match('/vfsStreamDirectory$/', get_class($this->filesystem))) {
      $directory_path = $this->filesystem->url() . '/' . $directory_name;
    }
    if (file_exists($directory_path) && is_dir($directory_path)) {
      return new \RecursiveIteratorIterator(new \RecursiveDirectoryIterator($directory_path));
    }
    return NULL;
  }

  /**
   * Compute template filename.
   */
  private function computeTemplateFilename(array &$variables, $entity_view_modes, $entity_type, $entity_bundle): array {

    /*
     * A second call of \Drupal\degov_common\Common::addThemeSuggestions in hook_preprocess could override a working template
     * therefore we store here which non default template was processed.
     */
    static $processed;

    if (isset($variables['elements']['#view_mode']) && in_array($variables['elements']['#view_mode'],
        $entity_view_modes)) {
      $template_filename = $entity_type . '--' . $entity_bundle . '--' . $variables['elements']['#view_mode'];
      $processed[$template_filename] = TRUE;
    }
    else {
      if (isset($variables['elements']['#view_mode']) && $entity_bundle !== NULL) {
        $template_filename = $entity_type . '--' . $entity_bundle . '--' . $variables['elements']['#view_mode'];
        if (isset($processed[$template_filename])) {
          return [
            $variables,
            $template_filename,
          ];
        }
      }

      if (isset($entity_bundle)) {
        $template_filename = $entity_type . '--' . $entity_bundle;
      }
      else {
        $template_filename = $entity_type;
      }
    }
    return [
      $variables,
      $template_filename,
    ];
  }

  /**
   * Render.
   */
  public function render(string $module, string $templatePath, array $variables = []) {
    $path = $this->drupalPath->getPath('module', $module) . '/' . $templatePath;
    $twigTemplate = $this->twig->load($path);

    return $twigTemplate->render($variables);
  }

}
