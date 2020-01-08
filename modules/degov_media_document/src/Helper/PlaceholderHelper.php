<?php

namespace Drupal\degov_media_document\Helper;

use Drupal\file\FileInterface;

/**
 * Class PlaceholderHelper.
 *
 * @package Drupal\degov_media_document\Helper
 */
class PlaceholderHelper {

  /**
   * Map file to font  awesome icon.
   *
   * @param \Drupal\file\FileInterface $file
   *   File.
   *
   * @return string
   *   Icon class.
   */
  public static function mapFileToFaIcon(FileInterface $file): string {
    $extension = pathinfo($file->getFilename(), PATHINFO_EXTENSION);
    switch ($extension) {
      case 'doc':
      case 'docx':
      case 'odt':
        return 'fa fa-file-word-o';

      case 'xls':
      case 'xlsx':
      case 'csv':
      case 'ods':
        return 'fa fa-file-excel-o';

      case 'ppt':
      case 'pptx':
      case 'odp':
        return 'fa fa-file-powerpoint-o';

      case 'pdf':
        return 'fa fa-file-pdf-o';

      default:
        return 'fa fa-file';
    }
  }

}
