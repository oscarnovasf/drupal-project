#!/usr/bin/env bash

# ##############################################################################
#
# Script para realizar tareas previas al commit.
#
# Aquí se deben añadir todas las exportaciones de contenido con drush.
#
# @see https://www.drupal.org/project/default_content_deploy
#
#  @version   v1.0.0
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

# Variables para controlar multi-site.
SITES_COUNT=0
MULTI_SITE=0


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

# Ajustes para Plesk en caso de ser necesario.
if [ "$SCRIPT_SERVER_HAS_PLESK" == "y" ]; then
  export PATH=/opt/plesk/php/${SCRIPT_SERVER_PLESK_PHP_VERSION}/bin:$PATH;
fi


# ##############################################################################
# INICIO DEL SCRIPT.
# ##############################################################################

# Realizo exportación de alias.
clear
linea
echo -e " ${YELLOW}Exportando...${RESET}"
linea

# Realizo exportación de alias.
${DRUSH} dcde path_alias

# Realizo exportación de enlaces de menú.
${DRUSH} dcde menu_link_content

# Realizo exportación de contenidos.
# TODO: Añadir todos los contenidos que se deseen.
# ${DRUSH} dcde node --bundle=page

# Realizo exportación de taxonomías.
# TODO: Añadir todos los taxonomías que se deseen.
# ${DRUSH} dcde taxonomy_term --bundle=tags

# Realizo exportación de otros contenidos.
# TODO: Añadir todos los otros contenidos que se deseen.
# ${DRUSH} dcde config_pages --bundle=site_config

# Realizo exportación de configuraciones.
${DRUSH} cex -y


# ##############################################################################
# FIN DEL SCRIPT.
# ##############################################################################

# Calculo el tiempo de ejecución y muestro mensaje de final del script.
end=$(date +%s)
runtime=$((end-start))

clear
linea
echo -e " ${GREEN}El proyecto está preparado para el commit.${RESET}"
echo -e " ${RED}(Recuerda que no se ha realizado exportación de la BBDD)${RESET}"
linea
echo " "
echo " Tiempo de ejecución: ${runtime}s"
echo " "