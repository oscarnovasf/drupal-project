Drupal Project
===

<div style="margin: 35px 0 25px 0">
  <img alt="Drupal Logo" src="https://www.drupal.org/files/Wordmark_blue_RGB.png" height="60px">
</div>

>Plantilla para [Composer](https://getcomposer.org/) de instalación de Drupal.

[![version][version-badge]][changelog]
[![Licencia][license-badge]][license]
[![Código de conducta][conduct-badge]][conduct]
[![wakatime](https://wakatime.com/badge/user/236d57da-61e8-46f2-980b-7af630b18f42/project/e98b008a-b80c-421e-862a-b2c136d434b5.svg)](https://wakatime.com/badge/user/236d57da-61e8-46f2-980b-7af630b18f42/project/e98b008a-b80c-421e-862a-b2c136d434b5)

## Requerimientos

* ### Herramientas
  * Es necesario tener instalada la `versión ^2.0` de
    [Composer](https://getcomposer.org/doc/00-intro.md#installation-linux-unix-osx)
    o superior.
  * Es necesario tener instalada la herramienta `jq` para la línea de comandos.
    [JQ](https://stedolan.github.io/jq/).
  * Es necesario tener instalada la herramienta `pv` para la línea de comandos.
    [PV](http://www.ivarch.com/programs/pv.shtml).

* ### Otros Requerimientos
  * El proyecto está pensado para hacer uso de *Redis* / *KeyDB*, por lo que
    será necesario tener acceso a una de estas herramientas.  
    Si no se desea usar, se puede desactivar en el archivo de variables de
    entorno.
  * El proyecto también hace uso de *IgBinary*, si no se desea utilizar es
    preciso cambiar el nombre al archivo `igbinary.services.yml` situado en la
    carpeta `web\sites`.
  * Si se quiere poder enviar una url de nuestro proyecto en local con Lando, es
    necesario instalar y configurar `ngrok` [NGROK](https://ngrok.com/).

## Instalación

* ### Proceso de instalación: Máquina local/servidor
  * Copiamos el contenido del proyecto en la carpeta raíz de nuestro servidor.
  * Creamos el archivo `.env` a partir de `.env.example` y establecemos los
    valores a las variables.
  * Establecemos el nombre del proyecto en nuestro `composer.custom.json`.
  * Ejecutamos (desde la raíz) el comando `bash ./scripts/shell/install.sh` y
    seguimos las instrucciones del instalador.

  > De forma opcional podemos usar el script [iniciar-proyecto](https://github.com/oscarnovasf/iniciar-proyecto)
  > para descargar e iniciar un proyecto nuevo.

* ### Proceso de instalación: [LANDO](https://lando.dev/)
  * Copiamos el contenido del proyecto en una carpeta de nuestra máquina.
  * Establecemos los valores correctos en el archivo `.lando.yml` para la
    conexión con la base de datos y el nombre del proyecto.
  * Creamos el archivo `.env` a partir de `.env.example` y establecemos los
    valores a las variables.
  * Establecemos el nombre del proyecto en nuestro `composer.custom.json`.
  * Ejecutamos `lando start` para montar los contenedores del proyecto.

    > Al usar lando, es recomendable que todos los scripts se ejecuten dentro
    > del contenedor, salvo que se use `lando drush` o `lando composer`.

* ### Notas sobre LANDO:
  * Es posible crear un `launch` a través de un alias que nos permita ejecutar
    lando start y, al mismo tiempo, abrir nuestro proyecto en el explorador web.
    El alias a crear sería (con drush launch instalado en nuestra máquina):

    ```bash
      alias launch="lando start && sleep 5 && open $(drush uli -l $(lando info --format json | jq '.[0].urls' | jq -r '.[1]'))"
    ```

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

  * #### share.sh
    > Script para generar un túnel y poder compartir nuestro proyecto local
    > fuera de nuestra red.

    Este script hace uso de [ngrok](https://ngrok.com/) por lo que será necesario
    crearse una cuenta y configurar el API Key en nuestro entorno local.
    Al ejecutarse se genera una url que podemos utilizar desde una máquina
    externa para conectarnos a nuestro sistema.

    > El script usa lando para obtener la url pero no se puede ejecutar dentro
    > de lando, por lo que no está disponible ningún atajo al comando.

  * #### trans.sh
    > Script para importar/exportar las traducciones (excepto el inglés).

    Admite cualquiera de estos parámetros (sólo uno y obligatorio):

    |Parámetro|Descripción|
    |---|---|
    |**im**|Realiza la importación de las traducciones.|
    |**ex**|Realiza la exportación de las traducciones.|

    > Si se usa lando este comando está disponible como `lando trans`.

## Módulos incluidos en las diferentes instalaciones

   El listado completo de módulos se puede ver en el archivo
   `scripts/shell/.variables`

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

  En este proyecto se usa la versión de PHP 8.1 como mínimo
  (ver [System Requirements](https://www.drupal.org/docs/getting-started/system-requirements/overview)),
  pero es posible que al usar `composer update` se actualicen algunos paquetes
  con un requerimiento superior.

  Para evitar esto puedes indicar en la sección `config` del `composer.json` la
  versión que quieres usar:

  ```json
  "config": {
      "platform": {
          "php": "8.1.6"
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

* ### ¿Cómo aplicar un parche al proyecto?

  La gestión de parches para el sistema está alojada en la carpeta:
  `./config/patches/` en el archivo *composer.patches.json*.

  Se recomienda que, siempre que sea posible, se descarguen los parches que
  serán aplicados dentro de su propia carpeta.

  Por ejemplo, para un parche del core de drupal se generará la siguiente
  estructura:

  ```
  - config
    - patches
      - core
        - archivo.patch
  ```

* ### ¿Cómo mantener organizado el composer.json?

  Para mantener el composer.json "normalizado", este proyecto hace uso del
  plugin [composer-normalize](https://github.com/ergebnis/composer-normalize).
  Para ejecutar este plugin sólo debes escribir en la consola:

  ```bash
  composer normalize
  ```

* ### ¿Cómo incluir los composer.json de los módulos custom?

  Para incluir los composer.json de tus módulos custom y que las dependencias
  se añadan al directorio vendor del proyecto, se hace uso de la siguiente línea
  dentro del composer.json principal:

  ```json
    "merge-plugin": {
      ...
      "include": [
        "web/modules/custom/*/composer.json"
      ]
    }
  ```

---

[version]: v3.2.0
[version-badge]: https://img.shields.io/badge/Versión-3.2.0-blue.svg

[license]: LICENSE.md
[license-badge]: https://img.shields.io/badge/Licencia-GPLv3+-green.svg "Leer la licencia"

[conduct]: CODE_OF_CONDUCT.md
[conduct-badge]: https://img.shields.io/badge/C%C3%B3digo%20de%20Conducta-2.0-4baaaa.svg "Código de conducta"

[changelog]: CHANGELOG.md "Histórico de cambios"