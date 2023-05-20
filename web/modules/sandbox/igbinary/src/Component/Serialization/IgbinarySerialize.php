<?php

namespace Drupal\igbinary\Component\Serialization;

use Drupal\Component\Serialization\PhpSerialize;

/**
 * Igbinary serialization for serialized PHP.
 */
class IgbinarySerialize extends PhpSerialize {

  /**
   * {@inheritdoc}
   */
  public static function encode($data) {
    return igbinary_serialize($data);
  }

  /**
   * {@inheritdoc}
   */
  public static function decode($raw) {
    if (strpos($raw, "\x00") === 0) {
      return igbinary_unserialize($raw);
    }
    elseif (strpos($raw, ':') === 1) {
      // Fallback for existing values previously serialized with phpserialize.
      return parent::decode($raw);
    }
  }

  /**
   * {@inheritdoc}
   */
  public static function getFileExtension() {
    return 'igbinary';
  }

}
