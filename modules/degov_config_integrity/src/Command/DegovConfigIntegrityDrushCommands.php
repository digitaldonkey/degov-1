<?php

namespace Drupal\degov_config_integrity\Command;

use Drupal\Core\StringTranslation\StringTranslationTrait;
use Drupal\degov_config_integrity\DegovModuleIntegrityChecker;
use Drush\Commands\DrushCommands;

/**
 * Class DegovConfigIntegrityDrushCommands.
 *
 * @package Drupal\degov_config_integrity\Command
 */
class DegovConfigIntegrityDrushCommands extends DrushCommands {

  use StringTranslationTrait;

  /**
   * The ModuleIntegrityChecker.
   *
   * @var \Drupal\degov_config_integrity\DegovModuleIntegrityChecker
   */
  private $moduleIntegrityChecker;

  /**
   * DegovConfigIntegrityDrushCommands constructor.
   *
   * @param \Drupal\degov_config_integrity\DegovModuleIntegrityChecker $moduleIntegrityChecker
   *   The ModuleIntegrityChecker.
   */
  public function __construct(DegovModuleIntegrityChecker $moduleIntegrityChecker) {
    parent::__construct();
    $this->moduleIntegrityChecker = $moduleIntegrityChecker;
  }

  /**
   * Checks for missing configuration.
   *
   * @command config:diff:installed-modules
   */
  public function checkConfigOfInstalledModules() {
    drush_print($this->t('deGov Configuration Integrity Check running…'));
    $configurationIntegrityIntact = TRUE;
    foreach ($this->moduleIntegrityChecker->checkIntegrity() as $module) {
      foreach ($module as $moduleName => $missingConfigs) {
        drush_print($this->t('Module @module', ['@module' => $moduleName]), 2);
        drush_print($this->t('Configuration is missing'), 4);
        foreach ($missingConfigs as $missingConfig) {
          drush_print($missingConfig, 6);
        }
        $configurationIntegrityIntact = FALSE;
      }
    }
    if ($configurationIntegrityIntact) {
      drush_print($this->t('All expected configuration seems to be in place.'));
    }
  }

}
