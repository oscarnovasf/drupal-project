<?php

namespace DrupalProject\composer;

use Composer\Script\Event;
use Composer\Semver\Comparator;
use DrupalFinder\DrupalFinder;
use Symfony\Component\Filesystem\Filesystem;

/**
 * Scripts para ser lanzados en composer install y update.
 */
class ScriptHandler {

  /**
   * Genera archivos necesarios para la instalación de Drupal.
   *
   * @param Composer\Script\Event $event
   *   Eventos de Composer.
   */
  public static function createRequiredFiles(Event $event): void {
    $fs = new Filesystem();
    $drupalFinder = new DrupalFinder();
    $drupalFinder->locateRoot(getcwd());
    $drupalRoot = $drupalFinder->getDrupalRoot();

    // Crea los directorios necesarios.
    $dirs = [
      'config/db',
      'config/sync',
      'config/sync/global',
      'config/sync/dev',
      'config/sync/loc',
      'config/sync/pro',
      'config/sync/stg',
      'config/translations',
      'docs/simpletest/browser_output',
      'private_files',
      'tmp',
      'web/libraries',
      'web/profiles',
      'web/sites/default/files',
    ];

    // Ajusto algunos permisos para que no falle el script.
    $fs->chmod('web/sites', 0777);
    $fs->chmod('web/sites/default', 0777);

    foreach ($dirs as $dir) {
      if (!$fs->exists($dir)) {
        if ($dir == 'web/sites/default/files' ||
            $dir == 'private_files' ||
            $dir == 'tmp' ||
            $dir == 'docs/simpletest/browser_output') {
          $fs->mkdir($dir, 0777);
          $event->getIO()->write('Creado el directorio "' . $dir . ' (chmod 0777)');
        }
        else {
          $fs->mkdir($dir);
          $event->getIO()->write('Creado el directorio "' . $dir);
        }
      }
    }

    // Prepara el archivo settings para la instalación.
    if (!$fs->exists($drupalRoot . '/sites/default/settings.php') && $fs->exists($drupalRoot . '/sites/default/default.settings.php')) {
      $fs->copy($drupalRoot . '/sites/default/default.settings.php', $drupalRoot . '/sites/default/settings.php');

      /* Asigno permisos a la configuración */
      $fs->chmod($drupalRoot . '/sites/default/settings.php', 0666);

      $event->getIO()->write("Creado el archivo sites/default/settings.php con chmod 0666");
    }

  }

  /**
   * Verifica la versión de Composer instalada.
   *
   * @param Composer\Script\Event $event
   *   Eventos de Composer.
   *
   * @SuppressWarnings(PHPMD)
   * @see https://github.com/composer/composer/pull/5035
   */
  public static function checkComposerVersion(Event $event): void {
    $composer = $event->getComposer();
    $io = $event->getIO();

    $version = $composer::VERSION;

    // The dev-channel of composer uses the git revision as version number,
    // try to the branch alias instead.
    if (preg_match('/^[0-9a-f]{40}$/i', $version)) {
      $version = $composer::BRANCH_ALIAS_VERSION;
    }

    // If Composer is installed through git we have no easy way to determine if
    // it is new enough, just display a warning.
    if ($version === '@package_version@' || $version === '@package_branch_alias_version@') {
      $io->writeError('<warning>Estas usando una versión "development" de Composer. Si tienes problemas actualiza a una versión estable.</warning>');
    }
    elseif (Comparator::lessThan($version, '2.0.0')) {
      $io->writeError('<error>Drupal Project 9.x necesita una versión de Composer superior a la 2.0. Por favor, actualiza antes de continuar</error>.');
      exit(1);
    }
  }

  /**
   * Elimina cualquier directorio .git dentro de la web.
   *
   * @param Composer\Script\Event $event
   *   Eventos de Composer.
   */
  public static function removeGitDirectories(Event $event): void {
    $drupalFinder = new DrupalFinder();
    $drupalFinder->locateRoot(getcwd());
    $drupalRoot = $drupalFinder->getDrupalRoot();
    $vendorRoot = $drupalFinder->getVendorDir();

    exec('find ' . $drupalRoot . ' -name \'.git\' | xargs rm -rf');
    exec('find ' . $vendorRoot . ' -name \'.git\' | xargs rm -rf');

    $event->getIO()->write("Eliminar directorios .git internos.");
  }

  /**
   * Remove unnecessary files.
   */
  public static function removeUnnecesaryFiles(Event $event): void {
    $fs = new Filesystem();
    $drupalFinder = new DrupalFinder();
    $drupalFinder->locateRoot(getcwd());
    $drupalRoot = $drupalFinder->getDrupalRoot();

    $files = [
      $drupalRoot . '/web.config',
      $drupalRoot . '/INSTALL.txt',
      $drupalRoot . '/README.txt',
      $drupalRoot . '/README.md',
      $drupalRoot . '/example.gitignore',
      $drupalRoot . '/modules/README.txt',
      $drupalRoot . '/profiles/README.txt',
      $drupalRoot . '/sites/example.sites.php',
      $drupalRoot . '/sites/example.settings.local.php',
      $drupalRoot . '/sites/development.services.yml',
      $drupalRoot . '/sites/README.txt',
      $drupalRoot . '/themes/README.txt',
      $drupalRoot . '/robots.txt',
    ];
    foreach ($files as $file) {
      if ($fs->exists($file)) {
        $fs->remove($file);
        $event->getIO()->write('Eliminado el archivo: "' . $file);
      }
    }
  }

  /**
   * Actualiza el permiso de ejecución para todos los scripts del proyecto.
   *
   * @param Composer\Script\Event $event
   *   Eventos de Composer.
   */
  public static function setScriptsPermissions(Event $event): void {
    $fs = new Filesystem();

    $files_755 = [
      'scripts/shell/db.sh',
      'scripts/shell/deploy.sh',
      'scripts/shell/dev_mode.sh',
      'scripts/shell/initialize.sh',
      'scripts/shell/install.sh',
      'scripts/shell/phpcs.sh',
      'scripts/shell/share.sh',
      'scripts/shell/trans.sh',
    ];

    foreach ($files_755 as $file) {
      if ($fs->exists($file)) {
        $fs->chmod($file, 0755);
        $event->getIO()->write("Permiso de ejecución al script: $file");
      }
    }
  }

  /**
   * Establece los permisos de ficheros y directorios de Drupal.
   *
   * @param Composer\Script\Event $event
   *   Eventos de Composer.
   */
  public static function setDrupalPermissions(Event $event): void {
    $fs = new Filesystem();
    $drupalFinder = new DrupalFinder();
    $drupalFinder->locateRoot(getcwd());
    $drupalRoot = $drupalFinder->getDrupalRoot();

    if ($fs->exists($drupalRoot . '/sites/default/settings.php')) {
      $fs->chmod($drupalRoot . '/sites/default', 0555);
      $fs->chmod($drupalRoot . '/sites/default/files', 0755);
      $fs->chmod($drupalRoot . '/sites/default/settings.php', 0555);

      if ($fs->exists($drupalRoot . '/sites/default/settings.develop.php')) {
        $fs->chmod($drupalRoot . '/sites/default/settings.develop.php', 0555);
      }
      if ($fs->exists($drupalRoot . '/sites/default/settings.local.php')) {
        $fs->chmod($drupalRoot . '/sites/default/settings.local.php', 0555);
      }
      if ($fs->exists($drupalRoot . '/sites/default/settings.custom.php')) {
        $fs->chmod($drupalRoot . '/sites/default/settings.custom.php', 0555);
      }

      $event->getIO()->write("Establecidos permisos por defecto.");
    }
  }

  /**
   * Pre Drupal scaffold actions.
   */
  public static function preDrupalScaffold(): void {
    $fs = new Filesystem();
    $drupalFinder = new DrupalFinder();
    $drupalFinder->locateRoot(getcwd());
    $drupalRoot = $drupalFinder->getDrupalRoot();

    if ($fs->exists($drupalRoot . '/sites/default/settings.php')) {
      $fs->chmod($drupalRoot . '/sites/default', 0777);
      $fs->chmod($drupalRoot . '/sites/default/settings.php', 0777);
    }
  }

  /**
   * Check prohibited modules.
   */
  public static function checkProhibitedModules(Event $event): void {
    $fs = new Filesystem();
    $drupalFinder = new DrupalFinder();
    $drupalFinder->locateRoot(getcwd());
    $drupalRoot = $drupalFinder->getDrupalRoot();

    if (empty($_SERVER['COMPOSER_DEV_MODE'])) {
      $files = [
        $drupalRoot . '/modules/contrib/backup_migrate',
        $drupalRoot . '/modules/contrib/devel',
        $drupalRoot . '/modules/contrib/potx',
      ];
      foreach ($files as $file) {
        if ($fs->exists($file)) {
          $event
            ->getIO()
            ->writeError('<error>ERROR: El módulo "' . $file . '" no puede instalarse en producción.</error>');
          exit(1);
        }
      }
    }
  }

}
