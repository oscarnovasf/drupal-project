#!/usr/bin/env bash

# ##############################################################################
#
# Script para importar o exportar la base de datos.
#
# - Recibe como parámetro la palabra im|ex:
#   * im implica la importación de la base de datos.
#   * ex implica la exportación de la base de datos.
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

# Script actual.
SELF=$(basename "${0}")

# Rutas a los diferentes componentes / directorios.
DRUSH_DIR="vendor/bin/drush"
DRUSH="php -d memory_limit=-1 ./vendor/bin/drush"

# Variable para almacenar la acción realizada.
ACTION=''


# ##############################################################################
# FUNCIONES AUXILIARES.
# ##############################################################################

# Simplemente imprime una lína por pantalla.
function linea() {
  echo '--------------------------------------------------------------------------------'
}

# Función que imprime las instrucciones de uso.
usage() {
  echo " "
  linea
  echo -e " ${GREEN}Script de importación / exportación de la base de datos.${RESET}"
  linea
  echo " "
  echo " Uso: ${SELF} [ex|im]"
  echo " "
  echo " [ex] Realiza la exportación de la base de datos."
  echo " [im] Realiza la importación de la base de datos."
  echo " "
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


# ##############################################################################
# COMPROBACIONES PREVIAS.
# ##############################################################################

# Número de parámetros
if [ ! "$#" -eq 1 ]; then
  clear
  usage
  exit 1
fi

# Verifico que Drupal se encuentra en una de las rutas válidas.
check_drupal

# Verifico instalación de Drush.
check_requirements

# Compruebo que exista el archivo de variables de entorno.
load_env


# ##############################################################################
# INICIO DEL SCRIPT.
# ##############################################################################

clear

if [ "$1" == "ex" ]; then
  ACTION='Exportación'

  # Vacio logs y caché de la base de datos.
  linea
  echo -e " ${YELLOW}Vaciando watchdog y caché de Drupal...${RESET}"
  linea
  ${DRUSH} watchdog:delete all -y
  ${DRUSH} cr

  # Genero dump de la base de datos.
  clear
  echo " "
  echo -e " ${YELLOW}Realizando volcado de la base de datos...${RESET}"
  linea
  # Ruta destino relativa desde la carpeta web (../).
  ${DRUSH} sql-dump --result-file=../config/db/data.sql --skip-tables-key=common

elif [ "$1" == "im" ]; then
  ACTION='Importación'

  # Compruebo que exista un volcado para importar.
  if [ -f ./config/db/data.sql ]; then
    echo " "
    echo -e " ${YELLOW}Eliminando datos previos de la base de datos...${RESET}"
    linea
    ${DRUSH} sql-drop -y

    clear
    echo " "
    echo -e " ${YELLOW}Realizando volcado de la base de datos...${RESET}"
    linea
    ${DRUSH} sql-cli < ./config/db/data.sql

    # Realizo actualización posterior a la importación de configuraciones.
    echo " "
    echo -e " ${YELLOW}Actualizando la base de datos...${RESET}"
    linea
    ${DRUSH} updatedb
  else
    linea
    echo -e " ${RED}No existe una exportación previa que se pueda importar!!${RESET}"
    linea
  fi
else
  clear
  usage
fi


# ##############################################################################
# FIN DEL SCRIPT.
# ##############################################################################

# Calculo el tiempo de ejecución y muestro mensaje de final del script.
end=$(date +%s)
runtime=$((end-start))

clear
linea
echo -e " ${GREEN}${ACTION}${RESET} de la base de datos realizada correctamente."
linea
echo " "
echo " Tiempo de ejecución: ${runtime}s"
echo " "