<?php

namespace Drupal\igbinary\Component\Serialization;

/**
 * Igbinary compressed serialization for serialized PHP.
 */
class IgbinaryCompressSerialize extends IgbinarySerialize {

  /**
   * {@inheritdoc}
   */
  public static function encode($data) {
    return gzcompress(igbinary_serialize($data), 1);
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
    return 'igbinary.gz';
  }

}
