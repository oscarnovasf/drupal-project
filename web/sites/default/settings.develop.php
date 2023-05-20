<?php

// @codingStandardsIgnoreFile

use Drupal\Component\Assertion\Handle;

assert_options(ASSERT_ACTIVE, TRUE);
Handle::register();

$settings['container_yamls'][] = DRUPAL_ROOT . '/sites/develop.services.yml';
$settings['cache']['bins']['render'] = 'cache.backend.null';
$settings['cache']['bins']['discovery_migration'] = 'cache.backend.memory';
$settings['cache']['bins']['dynamic_page_cache'] = 'cache.backend.null';
$settings['extension_discovery_scan_tests'] = TRUE;
$settings['rebuild_access'] = TRUE;
$settings['skip_permissions_hardening'] = TRUE;
$settings['update_free_access'] = TRUE;

$config['system.logging']['error_level'] = 'verbose';
$config['system.performance']['css']['preprocess'] = FALSE;
$config['system.performance']['js']['preprocess'] = FALSE;
