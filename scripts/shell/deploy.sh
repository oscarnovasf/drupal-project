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
RESET="\033[0m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
GREEN="\033[0;32m"

# Rutas a los diferentes componentes / directorios.
DRUSH_DIR="vendor/bin/drush"
DRUSH="php -d memory_limit=-1 ./vendor/bin/drush"
WEB_ROOT="$(pwd)"

# Variables para controlar multi-site.
SITES_COUNT=0
MULTI_SITE=0

# Para verificar si se ha realizado el deploy.
RUN_DEPLOY=0


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
  if [ -f web/sites/default/default.settings.php ]; then
    WEB_ROOT="./web"
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

# Comprueba si es un multi-site.
function check_multisite() {
  SITES=$(find ${WEB_ROOT}/sites -mindepth 1 -maxdepth 1 -type d | sort)
  i=0
  for SITE_ID in $SITES; do
    SITE_ID=$(basename "${SITE_ID}")
    if [ "${SITE_ID}" != "default" ] && [ -f "${SITES_PATH}/${SITE_ID}/settings.php" ]; then
      SITES[i]="${SITE_ID}";
      i=$((i+1))
    fi
  done
  SITES_COUNT=$((i-1))

  if [ $SITES_COUNT -gt 0 ]; then
    MULTI_SITE=1
  fi
}

# Limpieza de archivos CSS y JS.
function limpiar_css_js {
  clear
  linea
  echo -e " ${YELLOW}Limpiando CSS y JS...${RESET}"
  linea
  echo " "

  if [ $MULTI_SITE -gt 0 ]; then
    # Limpieza multisite.
    for i in $(seq 0 $SITES_COUNT); do
      SITE_ID="${SITES[$i]}"

      echo " "
      linea
      echo -e "${GREEN} Procesando ${SITE_ID}...${RESET}"
      linea

      rm -rf ${WEB_ROOT}/sites/${SITE_ID}/files/css/*
      rm -rf ${WEB_ROOT}/sites/${SITE_ID}/files/js/*
    done
  else
    # Limpieza simple.
    rm -rf ${WEB_ROOT}/sites/default/files/css/*
    rm -rf ${WEB_ROOT}/sites/default/files/js/*
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

# Comprueba si es un multisite.
check_multisite

# Exportación de configuraciones para composer.
export COMPOSER_ALLOW_SUPERUSER=1;
export COMPOSER_MEMORY_LIMIT=-1;
export COMPOSER_PROCESS_TIMEOUT=600

# Ajustes para Plesk en caso de ser necesario.
if [ "$SCRIPT_SERVER_HAS_PLESK" == "y" ]; then
  export PATH=/opt/plesk/php/${SCRIPT_SERVER_PLESK_PHP_VERSION}/bin:$PATH;
fi


################################################################################
# FUNCIONES.
################################################################################

# Cambia los permisos de los archivos.
function asign_perms() {
  clear
  linea
  echo -e " ${YELLOW}Asignando permisos a ficheros...${RESET}"
  linea

  # Asigno grupo y propietario a todos los ficheros.
  find . \
    -path ./.git -prune \
    -o -exec chown "$USER_OWNER":"$USER_GROUP" {} +

  # Me aseguro que puedo ejecutar todos los scripts.
  find ./scripts/shell/ -type f -iname "*.sh" -exec chmod +x {} \;
}

# Importa el contenido bajo demanda.
function import_content() {
  clear
  echo ''
  files=(./config/sync/content/**/*.json)
  if [ ${#files[@]} -gt 0 ]; then
    read -r -p "¿Deseas realizar la importación de entidades? [n]: " IMPORTAR_CONTENIDO
    IMPORTAR_CONTENIDO=${IMPORTAR_CONTENIDO:-n}

    if [ "$IMPORTAR_CONTENIDO" == "y" ]; then
      linea
      echo -e " ${YELLOW}Realizando importación de entidades...${RESET}"
      linea
      echo " "

      # Ejecuto importación simple o de multi-site según corresponda.
      if [ $MULTI_SITE -gt 0 ]; then
        # Importación multisite.
        for i in $(seq 0 $SITES_COUNT); do
          SITE_ID="${SITES[$i]}"

          echo " "
          linea
          echo -e "${GREEN} Procesando ${SITE_ID}...${RESET}"
          linea

          ${DRUSH} -l "${SITE_ID}" dcdi --force-override -y
        done
      else
        # Importación simple.
        ${DRUSH} dcdi --force-override -y
      fi
    fi
  fi
}

# Importa la base de datos.
function import_ddbb {
  echo ''
  read -r -p "¿Deseas realizar la importación de la base de datos? [n]: " IMPORTAR_BD
  IMPORTAR_BD=${IMPORTAR_BD:-n}

  if [ "$IMPORTAR_BD" == "y" ]; then
    bash ./scripts/shell/db.sh im

    # Pongo el sitio en modo mantenimiento otra vez.
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
}

# Importa las traducciones bajo demanda.
function import_translations() {
  clear
  echo ''
  read -r -p "¿Deseas realizar la importación de las traducciones? [n]: " IMPORTAR_TRANS
  IMPORTAR_TRANS=${IMPORTAR_TRANS:-n}

  if [ "$IMPORTAR_TRANS" == "y" ]; then
    bash ./scripts/shell/trans.sh im

    # Pongo el sitio en modo mantenimiento otra vez.
    ${DRUSH} sset system.maintenance_mode TRUE
  fi
}


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
  # Indico que voy a hacer el deploy.
  RUN_DEPLOY=1

  # Pongo el drupal en modo mantenimiento.
  ${DRUSH} sset system.maintenance_mode TRUE

  # Descargo última versión.
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
  asign_perms

  # Limpieza de archivos CSS y JS.
  limpiar_css_js

  # Pregunto si se quiere importar la base de datos.
  import_ddbb

  # Pregunto si se quiere importar el contenido.
  import_content

  # Pregunto si se quieren importar las traducciones.
  import_translations

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
if [ $RUN_DEPLOY -gt 0 ]; then
  linea
  echo -e " ${GREEN}Deploy realizado correctamente.${RESET}"
  linea
  echo " "
  echo " Tiempo de ejecución: ${runtime}s"
  echo " "
fi