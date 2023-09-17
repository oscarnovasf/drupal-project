<?php

// phpcs:ignoreFile

/**
 * @file
 * Drupal site-specific configuration file.
 */

/**
 * Conjunto de configuraciones específicas para cada entorno.
 */
switch ($_ENV['DRUPAL_ENV']) {
  case 'prod':
  case 'stg':
    break;

  case 'loc':
  case 'dev':
  default:
    break;
}
