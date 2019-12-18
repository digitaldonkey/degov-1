<?php

namespace Drupal\degov_common;

use Drupal\language\Config\LanguageConfigFactoryOverride;
use Drupal\language\Config\LanguageConfigOverride;
use Symfony\Component\Yaml\Yaml;

/**
 * Class TranslationImport
 *
 * @package Drupal\degov_common
 */
class TranslationImport {

  /**
   * @var \Drupal\language\Config\LanguageConfigFactoryOverride
   */
  private $languageConfigFactoryOverride;

  public function __construct(LanguageConfigFactoryOverride $languageConfigFactoryOverride) {
    $this->languageConfigFactoryOverride = $languageConfigFactoryOverride;
  }

  /**
   * Imports the german translations from the directory translations of the
   * component.
   *
   * @param $name
   *   The name of the item for which the path is requested. Ignored for
   *   $type 'core'.
   * @param $type
   *   The type of the item; one of 'core', 'profile', 'module', 'theme', or
   *   'theme_engine'.
   *
   * @return void
   */
  public function import(string $name, string $type = 'module'): void {
    $filepath = drupal_get_path($type, $name) . '/translations/de-de.po';
    $langcode = 'de';
    if (!file_exists($filepath)) {
      return;
    }
    \Drupal::moduleHandler()->loadInclude('locale', 'bulk.inc');
    \Drupal::moduleHandler()->loadInclude('locale', 'translation.inc');
    $file = locale_translate_file_create($filepath);
    $file->langcode = $langcode;
    $options = array_merge(_locale_translation_default_update_options(), [
      'overwrite_options' => [
        'not_customized' => TRUE,
        'customized'     => TRUE,
      ],
      'customized'        => LOCALE_CUSTOMIZED,
    ]);
    $file = locale_translate_file_attach_properties($file, $options);
    $file->langcode = $langcode;
    $batch = locale_translate_batch_build([$file->uri => $file], $options);
    batch_set($batch);
  }

  /**
   * Imports translations for a given configuration.
   *
   * @param string $langcode
   *   The target language code.
   * @param string $configName
   *   The name of the config we are translating.
   * @param string $pathToFile
   *   The path to the translation file.
   */
  public function importConfigTranslation(string $langcode, string $configName, string $pathToFile): void {
    $configOverride = $this->languageConfigFactoryOverride->getOverride($langcode, $configName);
    $fileContents = Yaml::parseFile($pathToFile);
    $this->processConfigTranslationFileContents($fileContents, $configOverride);
    $configOverride->save();
  }

  /**
   * Processes an array of config data.
   *
   * @param array $configArray
   *   The config array to process.
   * @param \Drupal\language\Config\LanguageConfigOverride $languageConfigOverride
   *   The LanguageConfigOverride storing our translations.
   * @param array $currentConfigKeyPath
   *   An array containing the config path, for recursion.
   */
  private function processConfigTranslationFileContents(array $configArray, LanguageConfigOverride $languageConfigOverride, array $currentConfigKeyPath = []) {
    foreach ($configArray as $key => $value) {
      $nextConfigKeyPath = array_merge($currentConfigKeyPath, [$key]);
      if (\is_array($value)) {
        $this->processConfigTranslationFileContents($value, $languageConfigOverride, $nextConfigKeyPath);
      }
      else {
        $languageConfigOverride->set(implode('.', $nextConfigKeyPath), $value);
      }
    }
  }
}
