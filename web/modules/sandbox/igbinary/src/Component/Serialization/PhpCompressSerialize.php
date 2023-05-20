<?php

namespace Drupal\igbinary\Component\Serialization;

use Drupal\Component\Serialization\PhpSerialize;

/**
 * PHP compressed serialization for serialized PHP.
 */
class PhpCompressSerialize extends PhpSerialize {

  /**
   * {@inheritdoc}
   */
  public static function encode($data) {
    return gzcompress(parent::encode($data), 1);
  }

  /**
   * {@inheritdoc}
   */
  public static function decode($raw) {
    if (strpos($raw, "\x78\x01") === 0) {
      $raw = gzuncompress($raw);
    }
    return parent::decode($raw);
  }

  /**
   * {@inheritdoc}
   */
  public static function getFileExtension() {
    return 'serialized.gz';
  }

}
