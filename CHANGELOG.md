# Histórico de cambios
---
Todos los cambios notables de este proyecto se documentarán en este archivo.

* ## [Sin versión]
  > Ver [TODO.md](TODO.md)

---
* ## [v3.2.0] - 2023-09-17
  > Revisión.

  * #### Añadido:
    - Configuración para el [scanner de Lando](https://docs.lando.dev/core/v3/scanner.html).
    - Configuración inicial para Entity Print.
    - Mejora en la limpieza de caché a través del módulo igbinary y redis.
    - Comando Lando para ejecutar SASS en el custom theme.

  * #### Cambios:
    - Mejora de la documentación.
    - Reactivación del modo debug por defecto.
    - Upgrade a Drupal 10.1
    - Versión de PHP por defecto: 8.1.
    - Actualización del defatul.settings.php con los ajustes para Drupal 10.1.
    - En el script de instalación, los permisos por defecto del usuario manager,
      ahora se toman de las variables de los scripts.
    - Update de la versión de Node.js en el contenedor de Lando.
    - Actualización de versiones de los módulos instalados.
    - Carpeta para los test de API cambiada de nombre.
    - Update de la forma de instalar node.js y adaptación a la nueva
      documentación.

  * #### Eliminado:
    - Módulo Allowed Formats: ya no es necesario en Drupal 10.1.
    - Módulo Blazy: ya no es necesario en Drupal 10.1.

---
* ## [v3.1.1] - 2023-05-24
  > Revisión.

  * #### Añadido:
    - Configuración para el CKEditor 5.

  * #### Errores:
    - Corrección de errores en la documentación por falta de actualización de
      versiones anteriores.
    - Error al activar "cookies_recaptcha" por falta de dependencias, ya no se
      instala.
    - En la versión anterior se había eliminado por error la opción de aplicar
      parches en el composer.json.

  * #### Eliminado:
    - Módulo "default_content_deploy" y el script que hacía uso de este módulo
      por no ser de utilidad real.
    - Plugin de composer para aplicar parches, no tiene demasiado sentido en la
      estructura actual del proyecto.

---
* ## [v3.1.0] - 2023-05-20
  > Nuevas funcionalidades.

  * #### Añadido:
    - Módulo custom/sandbox para poder activar igbinary.

  * #### Errores:
    - Parche para Webform por error con PHP 8.2.

  * #### Eliminado:
    - Instalación de Bootstrap Barrio.
    - Módulo "ckeditor_accordion".
    - Módulo "views_ajax_history".
    - Módulo "recaptcha".

---
* ## [v3.0.0] - 2023-05-19
  > Nuevas funcionalidades.

  * #### Añadido:
    - Módulo para optimización de imágenes.
    - Módulo de desarrollo twig_vardumper.
    - Módulo coffee.
    - Módulo default_content_deploy; incluye modificaciones en script de deploy
      para que pregunte si se quieren importar las entidades y un nuevo script
      para realizar operaciones de pre-commit.
    - Módulo stage_file_proxy para descarga de files en entorno local desde
      producción.
    - Instalación de PV en el contenedor de la aplicación de Lando.
    - Instalación de la extensión para Redis/KeyDB en el contenedor de la
      aplicación de Lando.
    - Limpieza de CSS y JS al hacer un deploy.
    - Añadidos varios comandos a Lando para mejorar las funcionalidades.
    - Módulo de PHP PHPRedis en el contenedor principal.
    - Script para compartir el proyecto vía ngrok.
    - Configuración para excluir módulos de desarrollo de manera más óptima.
    - Uso de hooks en lando.
    - Requerimiento de extensiones PHP IgBinary y APCU para mejorar el
      rendimiento de Drupal.

  * #### Cambios:
    - Actualización a **Drupal 10**.
    - Ajuste del script `db.sh` para que trabaje con multi-sites.
    - Ajuste del script `deploy.sh` para que trabaje con multi-sites.
    - Ajuste del script `trans.sh` para que trabaje con multi-sites.
    - Por defecto se ha puesto a lando que use mariadb y php 8.2. La elección de
      mariadb se debe a que se producen algunos errores de despliegue en
      entornos Linux.
    - Reducción al mínimo posible de los módulos instalados en Drupal por
      defecto (siempre bajo mi propio punto de vista y necesidades).
    - Modificación del `default.settings.php` para dar soporte a las nuevas
      variables de entorno relacionadas con Redis/KeyDB.
    - Renombrado de la carpeta de las utilidades de Lando: utils => .lando.
    - Mejora de la documentación en el README.md.

  * #### Eliminado:
    - Se ha descartado el uso de `drupal-quality-checker` por incompatibilidades
      con PHP ^8.0

---
* ## [v2.0.1] - 2022-11-30
  > Nuevas funcionalidades.

  * #### Añadido:
    - Dependencia de desarrollo "phpspec/prophecy-phpunit".

  * #### Cambios:
    - Mejora de la documentación.
    - Actualización de versiones de los temas de administración.
    - Actualización de versiones de los módulos de desarrollo.
    - Actualización de versiones de los módulos de producción.

  * #### Errores:
    - Solución al error con GRUMP en PHP ^8.
    - Error con gulp al crear la plantilla custom.
    - Problemas de ejecución de gulp y npm en el directorio del theme.
    - Aplicar parche para Redirect After Login en PHP 8.1.

  * #### Eliminado:
    - Se elimina CKWordCount por incompatibilidades.

---
* ## [v2.0.0] - 2022-11-26
  > Nuevas funcionalidades y refactor completo de los scripts.

  * #### Añadido:
    - Módulo "view_password".
    - Módulo "antibot".
    - Módulo "webp".
    - Módulo "IMCE".
    - Módulo "Redirect".
    - Módulo "file_delete".
    - Módulo "Twig Xdebug" (entorno de desarrollo).
    - Configuración para usar LANDO.
    - Importación de traducciones opcional al realizar el deploy.
    - Pregunta en el script de inicialización por si se desea eliminar la
      plantilla custom que se haya generado.
    - Configuración para poder integrar Lullabot/drupal9ci.
    - Implementación del uso de PHPUnit.

  * #### Cambios:
    - Reducir cualquier pregunta al usuario del script de instalación, los
      posibles parámetros se han añadido al archivo `.env`.
    - Pequeños ajustes en el script de deploy.
    - Cambio en la ubicación de los parches de módulos o core.
    - Refactor completo del script de instalación inicial.
    - Actualización y mejora de la documentación en README.md.
    - Modificación del script de deploy para que se pueda ejecutar en cualquier
      rama del repositorio.

  * #### Errores:
    - No se estaban estableciendo los permisos adecuados para las carpetas
      *tmp* y *private_files*.
    - El *installer-paths* para las librerías de CKEditor estaba mal situado
      dentro del *composer.json*.
    - No se debe eliminar el archivo composer.lock al inicializar el proyecto.

  * #### Eliminado:
    - Al usar LANDO se han eliminado las configuraciones para Docker que eran
      más complejas de mantener.

---
* ## [v1.1.0] - 2022-03-26
  > Nuevas funcionalidades (no publicada).

  * #### Añadido:
    - GrumPHP para validar el código antes de cada commit.
    - Eliminación de archivos relacionados con Docker en el script
      *initialize.sh*.
    - Nuevo script para importar/exportar traducciones (***trans.sh***)

  * #### Cambios:
    - Se quita del composer.json la información de autor y soporte.
    - Se quita del README.md información del desarrollador.
    - Se elimina cualquier referencia al creador de los scripts.
    - Configuración inicial del módulo SMTP (Cambio de contraseña).
    - Ahora el script de deploy no importa la base de datos de forma
      predeterminada.
    - Mejora global de la documentación.

  * #### Eliminado:
    - Se quita el directorio ./docker/mysql de git.

---
* ## [v1.0.0] - 2022-03-05
  > Versión inicial (no publicada).