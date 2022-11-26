Drupal Project - 9.x
===

<div style="margin: 35px 0 25px 0">
  <img alt="Drupal Logo" src="https://www.drupal.org/files/Wordmark_blue_RGB.png" height="60px">
</div>

>Plantilla para [Composer](https://getcomposer.org/) de instalación de
>Drupal 9.x.

[![version][version-badge]][changelog]
[![Licencia][license-badge]][license]
[![Código de conducta][conduct-badge]][conduct]
[![wakatime](https://wakatime.com/badge/user/236d57da-61e8-46f2-980b-7af630b18f42/project/e98b008a-b80c-421e-862a-b2c136d434b5.svg)](https://wakatime.com/badge/user/236d57da-61e8-46f2-980b-7af630b18f42/project/e98b008a-b80c-421e-862a-b2c136d434b5)

## Instalación

* ### Requerimientos
  * Es necesario tener instalada la `versión 2.0` de
    [Composer](https://getcomposer.org/doc/00-intro.md#installation-linux-unix-osx)
    o superior.
  * Es necesario tener instalada la herramienta `jq` para la línea de comandos.
    [JQ](https://stedolan.github.io/jq/).

* ### Proceso de instalación: Máquina local/servidor
  * Copiamos el contenido del proyecto en la carpeta raíz de nuestro servidor.
  * Creamos el archivo `.env` a partir de `.env.example` y establecemos los
    valores a las variables.
  * Establecemos el nombre del proyecto en nuestro `composer.custom.json`.
  * Ejecutamos (desde la raíz) el comando `bash ./scripts/shell/install.sh` y
    seguimos las instrucciones del instalador.

* ### Proceso de instalación: [LANDO](https://lando.dev/)
  * Copiamos el contenido del proyecto en una carpeta de nuestra máquina.
  * Establecemos los valores correctos en el archivo `.lando.yml` para la
    conexión con la base de datos y el nombre del proyecto.
  * Creamos el archivo `.env` a partir de `.env.example` y establecemos los
    valores a las variables.
  * Establecemos el nombre del proyecto en nuestro `composer.custom.json`.
  * Ejecutamos `lando start` para montar los contenedores del proyecto
    (cuando salga la pantalla de Oh-My-Bash escribimos exit).

    > Al usar lando, es recomendable que todos los scripts se ejecuten dentro
    > del contenedor, salvo que se use `lando drush` o `lando composer`.

## ¿Qué hace esta plantilla?

Al instalar con este `composer.json` se realizan las siguientes tareas:

* Se instala Drupal en el directorio `web`.
* Se sustituye el autoloader de Drupal (`web/vendor/autoload.php`) por el que se
  encuentra en `vendor/autoload.php`.
* Los módulos (tipo de paquete `drupal-module`) se instalan en
  `web/modules/contrib/`.
* Las plantillas (tipo de paquete `drupal-theme`) se instalan en
  `web/themes/contrib/`.
* Los perfiles (tipo de paquete `drupal-profile`) se instalan en
  `web/profiles/contrib/`.
* Genera las versiones de `settings.php` y `services.yml`.
* Genera los archivos `settings.develop.php` y `develop.services.yml` para usar
  en desarrollo.
* Crea la carpeta `web/sites/default/files`.
* Crea la carpeta `private_files`.
* Crea la carpeta temporal `tmp`.
* Crea y hace uso de las variables de entorno definidas en el archivo .env
  (ver [.env.example](.env.example)).
* Instala la última versión de [Drush](https://www.drush.org/latest/) para su
  uso local en `vendor/bin/drush`.
* Elimina cualquier carpeta `.git` dentro del directorio `web`.
* Elimina archivos innecesarios de la instalación de Drupal.
* Asigna el permiso de ejecución a los scripts del proyecto.

## Otros scripts adicionales

* ### Shell

  * #### db.sh
    > Script para importar/exportar el contenido de la base de datos.

    Admite cualquiera de estos parámetros (sólo uno y obligatorio):

    |Parámetro|Descripción|
    |---|---|
    |**im**|Realiza la importación de la base de datos.|
    |**ex**|Realiza la exportación de la base de datos.|

    > Si se usa lando este comando está disponible como `lando db`.

  * #### deploy.sh
    > Script para realizar el *deploy*.

    - Realiza un pull de la rama actual.
    - Importa las configuraciones.
    - Permite importar la base de datos si se desea (y si existe).
      (El volcado debe estar en ***./config/db/data.sql***)
    - Vacía la caché de Drupal.

    > Si se usa lando este comando está disponible como `lando deploy`.

  * #### dev_mode.sh
    > Script de activación / desactivación de opciones de desarrollo.

    Opcionalmente se le puede pasar uno de estos parámetros (sólo uno):

    |Parámetro|Descripción|
    |---|---|
    |**on**|Implica la activación de las opciones de desarrollo.|
    |**off**|Implica la desactivación de las opciones de desarrollo.|

    > En caso de no indicar parámetro se toma por defecto el valor según el
    > entorno indicado en `.env`.
    > Si se usa lando este comando está disponible como `lando dev`.

  * #### initialize.sh
    > Script para reiniciar el proyecto.

    - Elimina módulos, plantillas, profiles o comandos Drush (contrib).
    - Elimina el core y la carpeta vendor.
    - Elimina los archivos de configuración de Drupal.
    - Elimina composer.lock.

    > Si se usa lando este comando está disponible como `lando initialize`.

  * #### phpcs.sh
    > Script para comprobar el cumplimiento con el estándar de codificación de
    > Drupal.

    Admite cualquiera de estos parámetros (sólo uno):

    |Parámetro|Descripción|
    |---|---|
    |**install-coder**|Instala las reglas.|
    |**check-config**|Comprueba que las reglas estén instalados.|
    |**check-sandbox**|Comprueba la codificación de los módulos 'sandbox'.|
    |**check-modules**|Comprueba la codificación de los módulos 'custom'.|
    |**check-module name**|Comprueba la codificación de un módulo determinado.|
    |**check-themes**|Comprueba la codificación de las plantillas 'custom'.|
    |**check-theme name**|Comprueba la codificación de una plantilla determinada.|
    |**check-all**|Equivale a: *check-sandbox* + *check-modules* + *check-themes*.|

    > Si se usa lando este comando está disponible como `lando phpcs`.

  * #### trans.sh
    > Script para importar/exportar las traducciones (excepto el inglés).

    Admite cualquiera de estos parámetros (sólo uno y obligatorio):

    |Parámetro|Descripción|
    |---|---|
    |**im**|Realiza la importación de las traducciones.|
    |**ex**|Realiza la exportación de las traducciones.|

    > Si se usa lando este comando está disponible como `lando trans`.

## Módulos incluidos en las diferentes instalaciones

   * ### Entorno de Producción:
     * #### Módulos de Administración (Backend)
       * (drupal/admin_toolbar)[https://www.drupal.org/project/admin_toolbar]
       * (drupal/adminimal_admin_toolbar)[https://www.drupal.org/project/adminimal_admin_toolbar]
       * (drupal/allowed_formats)[https://www.drupal.org/project/allowed_formats]
       * (drupal/amswap)[https://www.drupal.org/project/amswap]
       * (drupal/config_pages)[https://www.drupal.org/project/config_pages]
       * (drupal/field_permissions)[https://www.drupal.org/project/field_permissions]
       * (drupal/module_filter)[https://www.drupal.org/project/module_filter]
       * (drupal/paragraphs)[https://www.drupal.org/project/paragraphs]
       * (drupal/redirect_after_login)[https://www.drupal.org/project/redirect_after_login]
       * (drupal/smtp)[https://www.drupal.org/project/smtp]
     * #### Módulos para Deploy/Optimización:
       * (drupal/db_maintenance)[https://www.drupal.org/project/db_maintenance]
       * (drupal/config_filter)[https://www.drupal.org/project/config_filter]
       * (drupal/config_ignore)[https://www.drupal.org/project/config_ignore]
       * (drupal/config_split)[https://www.drupal.org/project/config_split]
       * (drupal/entity_update)[https://www.drupal.org/project/entity_update]
       * (drupal/environment_indicator)[https://www.drupal.org/project/environment_indicator]
       * (drupal/file_delete)[https://www.drupal.org/project/file_delete]
       * (drupal/svg_image)[https://www.drupal.org/project/svg_image]
       * (drupal/webp)[https://www.drupal.org/project/webp]
     * #### Módulos de ayuda en el Desarrollo:
       * (drupal/context)[https://www.drupal.org/project/context]
     * #### Módulos de Formularios:
       * (drupal/antibot)[https://www.drupal.org/project/antibot]
       * (drupal/captcha)[https://www.drupal.org/project/captcha]
       * (drupal/recaptcha)[https://www.drupal.org/project/recaptcha]
       * (drupal/view_password)[https://www.drupal.org/project/view_password]
       * (drupal/webform)[https://www.drupal.org/project/webform]
       * (drupal/webform_views)[https://www.drupal.org/project/webform_views]
     * #### Módulos de ayuda en la Maquetación:
       * (drupal/block_class)[https://www.drupal.org/project/block_class]
       * (drupal/block_exclude_pages)[https://www.drupal.org/project/block_exclude_pages]
       * (drupal/body_roles_classes)[https://www.drupal.org/project/body_roles_classes]
       * (drupal/field_group)[https://www.drupal.org/project/field_group]
       * (drupal/page_specific_class)[https://www.drupal.org/project/page_specific_class]
       * (drupal/smart_trim)[https://www.drupal.org/project/smart_trim]
       * (drupal/token_filter)[https://www.drupal.org/project/token_filter]
       * (drupal/twig_field_value)[https://www.drupal.org/project/twig_field_value]
       * (drupal/twig_tools)[https://www.drupal.org/project/twig_tools]
       * (drupal/twig_tweak)[https://www.drupal.org/project/twig_tweak]
     * #### Módulos para SEO:
       * (drupal/easy_breadcrumb)[https://www.drupal.org/project/easy_breadcrumb]
       * (drupal/metatag)[https://www.drupal.org/project/metatag]
       * (drupal/pathauto)[https://www.drupal.org/project/pathauto]
       * (drupal/redirect)[https://www.drupal.org/project/redirect]
       * (drupal/simple_sitemap)[https://www.drupal.org/project/simple_sitemap]
     * #### Módulos para complementar Views:
       * (drupal/better_exposed_filters)[https://www.drupal.org/project/better_exposed_filters]
       * (drupal/verf)[https://www.drupal.org/project/verf]
       * (drupal/views_ajax_history)[https://www.drupal.org/project/views_ajax_history]
       * (drupal/views_bulk_operations)[https://www.drupal.org/project/views_bulk_operations]
       * (drupal/views_data_export)[https://www.drupal.org/project/views_data_export]
     * #### Módulos para complementar CKEditor:
       * (drupal/ckeditor_accordion)[https://www.drupal.org/project/ckeditor_accordion]
       * (drupal/ckwordcount)[https://www.drupal.org/project/ckwordcount]
       * (drupal/editor_advanced_link)[https://www.drupal.org/project/editor_advanced_link]
       * (drupal/imce)[https://www.drupal.org/project/imce]
     * #### Módulos con librerías:
       * (drupal/jquery_ui_accordion)[https://www.drupal.org/project/jquery_ui_accordion]
       * (drupal/jquery_ui_touch_punch)[https://www.drupal.org/project/jquery_ui_touch_punch]
     * #### Módulos para cumplimiento Legal:
       * (drupal/cookies)[https://www.drupal.org/project/cookies]
     * #### Módulos que son dependencias de otros:
       * (drupal/entity_reference_revisions)[https://www.drupal.org/project/entity_reference_revisions]
     * #### Otros módulos:
       * (drupal/entity_print)[https://www.drupal.org/project/entity_print]
       * (drupal/linkit)[https://www.drupal.org/project/linkit]

   * ### Desarrollo
     * (drupal/coder)[https://www.drupal.org/project/coder]
     * (drupal/config_delete)[https://www.drupal.org/project/config_delete]
     * (drupal/delete_all)[https://www.drupal.org/project/delete_all]
     * (drupal/devel)[https://www.drupal.org/project/devel]
     * (drupal/devel_kint_extras)[https://www.drupal.org/project/devel_kint_extras]
     * (drupal/devel_php)[https://www.drupal.org/project/devel_php]
     * (drupal/features)[https://www.drupal.org/project/features]
     * (drupal/module_missing_message_fixer)[https://www.drupal.org/project/module_missing_message_fixer]
     * (drupal/potx)[https://www.drupal.org/project/potx]
     * (drupal/twig_xdebug)[https://www.drupal.org/project/twig_xdebug]

## FAQs

* ### ¿Qué hace el script de instalación?

  El script de instalación realiza las siguientes tareas:

  * Ejecuta `composer install` con o sin los módulos de desarrollo.
  * Instala el sitio vía `Drush` y activa todos los módulos.
  * Crea una plantilla personalizada, la activa y la pone por defecto
    (opcional).
  * Activa (o no) las opciones de desarrollo en Drupal según el entorno
    seleccionado (archivo `.env`).
  * Cambia todos los permisos de los archivos y pone los que corresponderían.
  * Genera el rol y usuario *manager*, con sus permisos por defecto.
  * Desactiva algunos bloques, vistas y módulos que no se usan normalmente.
  * Permite elegir la plantilla de administración a instalar y la configura.

* ### ¿Cómo actualizar el Core de Drupal?

  Este proyecto intentará mantener actualizados todos tus archivos del núcleo de
  Drupal; el proyecto [drupal/core-composer-scaffold](https://github.com/drupal/core-composer-scaffold)
  se utiliza para garantizar que los archivos de *scaffold* se actualicen cada
  vez que se actualiza el núcleo. Si personalizas cualquiera de los archivos
  *"scaffolding"* (comúnmente .htaccess), es posible que debas fusionar los
  conflictos si alguno de tus archivos modificados se actualiza en una nueva
  versión del núcleo de Drupal.

  Para actualizar el núcleo de Drupal debes seguir estos pasos:

  1. Ejecuta `composer update "drupal/core-*" --with-dependencies` para
    actualizar el núcleo y sus dependencias.
  2. Ejecuta `git diff` para comprobar si alguno de los archivos *"scaffolding"*
    ha sufrido cambios.
    Revisa los archivos y restaura cualquier personalización de
    `.htaccess` o `robots.txt`.

* ### ¿Cómo especificar una versión concreta de PHP?

  En este proyecto se usa la versión de PHP 7.4 como mínimo
  (ver [Environment requirements of Drupal 9](https://www.drupal.org/docs/understanding-drupal/how-drupal-9-was-made-and-what-is-included/environment-requirements-of)),
  pero es posible que al usar `composer update` se actualicen algunos paquetes
  que un requerimiento superior a PHP 7.3+.

  Para evitar esto puedes indicar en la sección `config` del `composer.json` la
  versión que quieres usar:

  ```json
  "config": {
      "sort-packages": true,
      "platform": {
          "php": "7.3.19"
      }
  },
  ```

* ### ¿Cómo proteger archivos para no ser sobrescritos?

  En algún proyecto nos puede interesar no sobrescribir archivos como el
  *.htaccess* o el *robots.txt*. Para eso bastará con añadir lo siguiente al
  archivo `composer.json`:

  ```json
  "file-mapping": {
      ...
      "[web-root]/robots.txt": false,
      "[web-root]/.htaccess": false,
      "[web-root]/.ht.router.php": false
  },
  ```

* ### ¿Cómo aplicar un parche a mi proyecto?

  Para la aplicación de parches se ha instalado la dependencia
  [Composer Patches CLI](https://github.com/szeidler/composer-patches-cli), con
  la que podrás instalar un parche con el siguiente comando:

  ```bash
  composer patch-add <package> <description> <url>
  ```

  *Ejemplo*:
  ```bash
  composer patch-add drupal/core "SA-CORE-2018-002" "https://cgit.drupalcode.org/drupal/rawdiff/?h=8.5.x&id=5ac8738fa69df34a0635f0907d661b509ff9a28f"
  ```

  > Otra manera es hacer uso del archivo *composer.patches.json*.

* ### ¿Cómo mantener organizado mi composer.json?

  Para mantener el composer.json "normalizado", este proyecto hace uso del
  plugin [composer-normalize](https://github.com/ergebnis/composer-normalize).
  Para ejecutar este plugin sólo debes escribir en la consola:

  ```bash
  composer normalize
  ```

* ### ¿Cómo incluir mis composer.json de los módulos custom?

  Para incluir los composer.json de mis módulos custom y que las dependencias
  se añadan al directorio vendor del proyecto, se debe añadir la siguiente línea
  dentro del composer.json principal:

  ```json
    "merge-plugin": {
      ...
      "include": [
        "web/modules/custom/*/composer.json"
      ]
    }
  ```

* ### ¿Cómo saltarse la validación de los commits?

  Aunque no debería saltarse esta comprobación, es posible realizar un commit
  sin que ésta se realice, basta con añadir "-n":

  ```bash
    git commit -m "Random commit mesage" -n
  ```

  Si lo que queremos es desactivar esta validación ejecutamos:

  ```bash
    ./vendor/bin/grumphp git:deinit
  ```

  Para volver a activarla:

  ```bash
    ./vendor/bin/grumphp git:init
  ```

---

[version]: v2.0.0
[version-badge]: https://img.shields.io/badge/Versión-2.0.0-blue.svg

[license]: LICENSE.md
[license-badge]: https://img.shields.io/badge/Licencia-GPLv3+-green.svg "Leer la licencia"

[conduct]: CODE_OF_CONDUCT.md
[conduct-badge]: https://img.shields.io/badge/C%C3%B3digo%20de%20Conducta-2.0-4baaaa.svg "Código de conducta"

[changelog]: CHANGELOG.md "Histórico de cambios"