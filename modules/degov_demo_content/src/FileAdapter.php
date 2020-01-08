<?php

namespace Drupal\degov_demo_content;

use Drupal\file\Entity\File;

/**
 * Class FileAdapter.
 */
class FileAdapter {

  /**
   * Save file data.
   *
   * @param mixed $fileData
   *   File data.
   * @param string $filepath
   *   File path.
   *
   * @return \Drupal\file\FileInterface|null
   *   Saved file.
   */
  public function fileSaveData($fileData, string $filepath): ?File {

    $fileSaveData = file_save_data($fileData, $filepath, FILE_EXISTS_REPLACE);
    return ($fileSaveData === FALSE ? NULL : $fileSaveData);
  }

  /**
   * Get file contents.
   *
   * @param string $filepath
   *   File path.
   *
   * @return string
   *   File content.
   */
  public function fileGetContents(string $filepath): string {
    return file_get_contents($filepath);
  }

}
