#!/usr/bin/env bash

# ##############################################################################
#
# Script de activación / desactivación de opciones de desarrollo.
#
# - Recibe como parámetro la palabra on|off:
#   * on implica la activación de las opciones de desarrollo.
#   * off implica la desactivación de las opciones de desarrollo.
# - En caso de no indicar parámetro se toma el valor establecido en .env.
#
#  @version   v2.0.0
#  @license   GNU/GPL v3+
# ##############################################################################


# Control de tiempo de ejecución.
start=$(date +%s)

# Cierro el script en caso de error.
# set -e


# ##############################################################################
# VARIABLES AUXILIARES.
# ##############################################################################

# Colores.
RESET="\033[0m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
GREEN="\033[0;32m"

# Cargo archivo con las variables de dependencias.
source "$(dirname $0)"/.variables

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

  # Verifico instalación de JQ.
  if ! [ -x "$(command -v jq)" ]; then
    clear
    linea
    echo -e " ${RED}No se ha encontrado la herramienta JQ.${RESET}"
    echo -e " ${RED}Visita https://stedolan.github.io/jq/download e instala la versión necesaria.${RESET}"
    linea
    exit 2
  fi
}

# Cambia los permisos de los archivos.
function asign_perms() {
  clear
  linea
  echo -e " ${YELLOW}Asignando permisos a ficheros...${RESET}"
  linea

  # Asigno los permisos de manera recurrente.
  find . \
    -path ./.git -prune \
    -o -exec chown "$USER_OWNER":"$USER_GROUP" {} +
}


# ##############################################################################
# COMPROBACIONES PREVIAS.
# ##############################################################################

clear

# Muestro cabecera del script.
linea
echo -e " ${GREEN}Script que permite activar/desactivar las opciones de desarrollo.${RESET}"
linea

# Compruebo que exista el archivo de variables de entorno.
load_env

# Verifico que Drupal se encuentra en una de las rutas válidas.
check_drupal

# Verifico existencia de herramientas necesarias.
check_requirements

# Establezco el entorno que se va a usar.
DEV_MODE="ON"
if [ "$DRUPAL_ENV" == "pro" ] || [ "$DRUPAL_ENV" == "stg" ]; then
  DEV_MODE="OFF"
fi

# Cambio entorno según parámetro.
if [ "$1" == "off" ]; then
  DEV_MODE="OFF"
fi
if [ "$1" == "on" ]; then
  DEV_MODE="ON"
fi

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

# Pongo el drupal en modo mantenimiento.
${DRUSH} sset system.maintenance_mode TRUE

if [ "$DEV_MODE" == "ON" ]; then
  # Añado las dependencias de desarrollo.
  linea
  echo -e " ${YELLOW}Actualizando dependencias de desarrollo...${RESET}"
  linea
  for i in "${DEV_COMPOSER[@]}"; do
    IFS=': ' read -r -a array <<< "${i}"
    DATA1="${array[0]}"
    DATA2="${array[1]}"
    cat composer.custom.json | jq --arg e "require-dev" --arg data1 "$DATA1" --arg data2 "$DATA2" '.[$e] += { ($data1) : ($data2) }' > composer.custom.json2
    mv -f composer.custom.json{2,}
  done

  # Realizo la instalación.
  composer update

  clear
  linea
  echo -e " ${YELLOW}Activando módulos de desarrollo...${RESET}"
  linea

  for i in "${DEV_DRUSH_NAMES[@]}"; do
    echo " "
    echo -e " Activando ${GREEN}${i}${RESET}..."
    linea
    ${DRUSH} -y en "${i}"
    echo " "
  done

  # Importación de configuraciones para los módulos de desarrollo.
  clear
  linea
  echo -e " ${YELLOW}Importando configuraciones de desarrollo...${RESET}"
  linea

  echo ' '
  ${DRUSH} config-import --partial --source=$(pwd)/config/base/config_files/develop/ -y

  # Renombro el archivo _settings.develop.php
  FILE=$(pwd)/web/sites/default/_settings.develop.php
  if [ -f "$FILE" ]; then
    chmod 777 "${FILE}"
    chmod 777 web/sites/default
    mv "${FILE}" $(pwd)/web/sites/default/settings.develop.php
    chmod 555 ./web/sites/default/settings.develop.php
    chmod 555 web/sites/default
  fi

  # Actualizo los permisos.
  asign_perms

else
  # Desactivo los módulo en Drupal.
  clear
  linea
  echo -e " ${YELLOW}Desactivando módulos...${RESET}"
  linea

  for i in "${DEV_DRUSH_NAMES_UNINSTALL[@]}"; do
    echo " "
    echo -e " Desinstalando ${GREEN}${i}${RESET}..."
    linea
    ${DRUSH} -y pm:uninstall "${i}"
    ${DRUSH} cache-rebuild
    echo " "
  done

  # Elimino los ficheros de los módulos.
  clear
  linea
  echo -e " ${YELLOW}Eliminando módulos...${RESET}"
  linea

  cat composer.custom.json | jq --arg e "require-dev" '.[$e] = { }' > composer.custom.json2
  mv -f composer.custom.json{2,}

  # Actualizo composer para eliminar las dependencias.
  composer update

  # Renombro el archivo settings.develop.php
  FILE=$(pwd)/web/sites/default/settings.develop.php
  if [ -f "$FILE" ]; then
    chmod 777 "${FILE}"
    chmod 777 web/sites/default
    mv "${FILE}" web/sites/default/_settings.develop.php
    chmod 555 web/sites/default/_settings.develop.php
    chmod 555 web/sites/default
  fi
fi

# Desactivo modo de mantenimiento.
${DRUSH} sset system.maintenance_mode FALSE


# ##############################################################################
# FIN DEL SCRIPT.
# ##############################################################################


clear
linea
echo -e " ${YELLOW}Finalizando la instalación...${RESET}"
linea
echo " "

# Ejecuto de nuevo composer para prevenir posibles fallos anterirores.
composer update
echo " "

# Limpio la caché.
${DRUSH} cache-rebuild

# Ejecuto actualización de la base de datos.
${DRUSH} updatedb -y

# Calculo el tiempo de ejecución y muestro mensaje de final del script.
end=$(date +%s)
runtime=$((end-start))

clear
linea
if [ "$DEV_MODE" == "ON" ]; then
  echo -e " ${GREEN}Activación de modo desarrollo finalizada correctamente.${RESET}"
else
  echo -e " ${GREEN}Desactivación de modo desarrollo finalizada correctamente.${RESET}"
fi
echo " "
echo " - Recuerda que debes actualizar manualmente tu archivo .env"
echo "   y modificar el tipo de entorno que estás usando."
echo " - Es recomendable que ejecutes composer update tras el cambio de entorno"
linea
echo " "
echo " Estado actual: DEV_MODE=${DEV_MODE}"
echo " Tiempo de ejecución: ${runtime}s"
echo " "
