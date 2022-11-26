#!/usr/bin/env bash

# ##############################################################################
#
# Script para realizar el deploy sobre la rama de desarrollo principal.
#
# @see https://chromatichq.com/insights/drupal-8-deployment-scripts
#
#  @version   v2.0.0
#  @license   GNU/GPL v3+
# ##############################################################################


# Control de tiempo de ejecución.
start=$(date +%s)

# Cierro el script en caso de error.
set -e


# ##############################################################################
# VARIABLES AUXILIARES.
# ##############################################################################

# Colores.
RESET="\e[0m"
YELLOW="\e[33m"
RED="\e[31m"
GREEN="\e[32m"

# Rutas a los diferentes componentes / directorios.
DRUSH_DIR="vendor/bin/drush"
DRUSH="php -d memory_limit=-1 ./vendor/bin/drush"


# ##############################################################################
# FUNCIONES AUXILIARES.
# ##############################################################################

# Simplemente imprime una lína por pantalla.
function linea() {
  echo '--------------------------------------------------------------------------------'
}

# Lee archivo de configuración.
function load_env() {
  ENV_FILE=.env
  if [ ! -f "${ENV_FILE}" ]; then
    clear
    linea
    echo -e " ${RED}No existe el archivo de variables de entorno (.env).${RESET}"
    linea
    exit 1
  else
    source "$(echo ${ENV_FILE})"
  fi
}

# Verifica que existe realmente una configuración de Drupal.
function check_drupal() {
  WEB_ROOT="$(pwd)"
  if [ -f web/sites/default/default.settings.php ]; then
    WEB_ROOT="web"
  elif [ -f sites/default/default.settings.php ]; then
    WEB_ROOT="."
  else
    clear
    linea
    echo -e " ${RED}Este script debe ser ejecutado en la raíz del proyecto.${RESET}"
    echo "($WEB_ROOT)"
    linea
    exit 3
  fi
}

# Verifica que las herramientas necesarias están instaladas en el servidor.
function check_requirements() {
  # Verifico instalación de Drush.
  if [ ! -f "${DRUSH_DIR}" ]; then
    clear
    linea
    echo -e " ${RED}No se encuentra $DRUSH_DIR.${RESET}"
    echo -e " ${RED}Ejecuta: composer require drush/drush${RESET}"
    linea
    exit 2
  fi
}


# ##############################################################################
# COMPROBACIONES PREVIAS.
# ##############################################################################

# Verifico que Drupal se encuentra en una de las rutas válidas.
check_drupal

# Compruebo que exista el archivo de variables de entorno.
load_env

# Verifico instalación de Drush.
check_requirements

# Exportación de configuraciones para composer.
export COMPOSER_ALLOW_SUPERUSER=1;
export COMPOSER_MEMORY_LIMIT=-1;
export COMPOSER_PROCESS_TIMEOUT=600

# Ajustes para Plesk en caso de ser necesario.
if [ "$SCRIPT_SERVER_HAS_PLESK" == "y" ]; then
  export PATH=/opt/plesk/php/${SCRIPT_SERVER_PLESK_PHP_VERSION}/bin:$PATH;
fi


# ##############################################################################
# INICIO DEL SCRIPT.
# ##############################################################################

clear

# Obtengo la información de la rama.
RAMA_ACTUAL=$(git branch --show-current)

# Pregunto si se quiere importar la base de datos.
echo ''
read -r -p "¿Deseas realizar el deploy sobre la rama ${RAMA_ACTUAL}? [y]: " CONTINUAR
CONTINUAR=${CONTINUAR:-y}

if [ "$CONTINUAR" == "y" ] || [ "$CONTINUAR" == "Y" ]; then
  # Pongo el drupal en modo mantenimiento.
  ${DRUSH} sset system.maintenance_mode TRUE

  # Descargo última versión.clear
  linea
  echo -e " ${YELLOW}Descargando proyecto...${RESET}"
  linea
  git pull

  # Ejecuto composer install.
  clear
  linea
  echo -e " ${YELLOW}Instalando dependencias...${RESET}"
  linea
  composer install

  # Actualizo los permisos de los ficheros.
  clear
  linea
  echo -e " ${YELLOW}Asignando permisos a ficheros...${RESET}"
  linea
  find . \
    -path ./.git -prune \
    -o -exec chown "$USER_OWNER":"$USER_GROUP" {} +

  # Compruebo que exista un volcado para importar.
  if [ -f ./config/db/data.sql ]; then
    # Pregunto si se quiere importar la base de datos.
    echo ''
    read -r -p "¿Deseas realizar la importación de la base de datos? [n]: " IMPORTAR_BD
    IMPORTAR_BD=${IMPORTAR_BD:-n}

    if [ "$IMPORTAR_BD" == "y" ]; then
      # Borro datos previos.
      echo ''
      echo -e " ${YELLOW}Borrando datos previos...${RESET}"
      linea
      ${DRUSH} sql-drop

      # Realizo la importación.
      echo ''
      echo -e " ${YELLOW}Importando datos...${RESET}"
      linea
      ${DRUSH} sql-cli < ./config/db/data.sql

      # Pongo el drupal en modo mantenimiento.
      ${DRUSH} sset system.maintenance_mode TRUE

      # Realizo actualización por si acaso..
      clear
      linea
      echo -e " ${YELLOW}Operaciones adicionales...${RESET}"
      linea
      ${DRUSH} updatedb -y

      # Borro la caché de la base de datos.
      echo ''
      ${DRUSH} cache:rebuild
    else
      # Realizo actualización previa a la importación de configuraciones.
      clear
      linea
      echo -e " ${YELLOW}Operaciones adicionales...${RESET}"
      linea
      ${DRUSH} updatedb --no-cache-clear

      # Borro la caché de la base de datos.
      echo ''
      ${DRUSH} cache:rebuild

      # Realizo importación de configuraciones.
      echo ''
      ${DRUSH} config:import -y

      # Borro la caché de la base de datos.
      echo ''
      ${DRUSH} cache:rebuild

      # Realizo actualización posterior a la importación de configuraciones.
      echo ''
      ${DRUSH} updatedb -y

      # Ejecuto el Cron
      echo ''
      ${DRUSH} cron

      # Borro la caché de la base de datos.
      echo ''
      ${DRUSH} cache:rebuild

      # Al no importar la base de datos importo las traducciones.
      echo ''
      ${DRUSH} locale-check

      echo ''
      ${DRUSH} locale-update

      # Borro la caché de la base de datos.
      echo ''
      ${DRUSH} cache:rebuild
    fi
  fi

  # Pregunto si se quieren importar las traducciones.
  clear
  echo ''
  read -r -p "¿Deseas realizar la importación de las traducciones? [n]: " IMPORTAR_TRANS
  IMPORTAR_TRANS=${IMPORTAR_TRANS:-n}

  if [ "$IMPORTAR_TRANS" == "y" ]; then
    linea
    echo -e " ${YELLOW}Realizando importación de traducciones...${RESET}"
    linea
    echo " "

    # Obtengo los idiomas instalados.
    CURRENT_LANGCODES="$(./vendor/bin/drush language-info --field=language | cut -d'(' -f2 | cut -d')' -f1)"

    for lc in $CURRENT_LANGCODES
    do
      case $lc in
        'en')
          ;;

        *)
          echo ' '
          echo -e " - IMPORTANDO: ${GREEN}${lc}${RESET}..."
          linea
          ${DRUSH} locale:import --override=all --type=customized,not-customized "${lc}" ../config/translations/all_site-"${lc}".po
          ;;
      esac
    done

    # Limpio caché y activo de nuevo el sitio.
    ${DRUSH} cache:rebuild
  fi

  # Desactivo modo de mantenimiento.
  ${DRUSH} sset system.maintenance_mode FALSE
fi


# ##############################################################################
# FIN DEL SCRIPT.
# ##############################################################################

# Calculo el tiempo de ejecución y muestro mensaje de final del script.
end=$(date +%s)
runtime=$((end-start))

clear
linea
echo -e " ${GREEN}Deploy realizado correctamente.${RESET}"
linea
echo " "
echo " Tiempo de ejecución: ${runtime}s"
echo " "