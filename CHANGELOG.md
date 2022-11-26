# Histórico de cambios
---
Todos los cambios notables de este proyecto se documentarán en este archivo.

* ## [Sin versión]
  > Ver [TODO.md](TODO.md)

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