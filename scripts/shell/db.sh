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
RESET="\033[0m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
GREEN="\033[0;32m"

# Script actual.
SELF=$(basename "${0}")

# Rutas a los diferentes componentes / directorios.
DRUSH_DIR="vendor/bin/drush"
DRUSH="php -d memory_limit=-1 ./vendor/bin/drush"

# Variable para almacenar la acción realizada.
ACTION=''

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

  if ! [ -x "$(command -v pv)" ]; then
    clear
    linea
    echo -e " ${RED}No se ha encontrado la herramienta PV.${RESET}"
    linea
    exit 2
  fi
}

# Comprueba si es un multi-site.
function check_multisite() {
  SITES=$(find ./web/sites -mindepth 1 -maxdepth 1 -type d | sort)
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

# Exportación de BBDD de un solo sitio.
function exportacion_simple() {
  # Vacio logs y caché de la base de datos.
  echo " "
  echo -e " ${YELLOW}Vaciando watchdog y caché de Drupal...${RESET}"
  linea
  ${DRUSH} watchdog:delete all -y
  ${DRUSH} cr

  # Genero dump de la base de datos.
  echo " "
  echo -e " ${YELLOW}Realizando volcado de la base de datos...${RESET}"
  linea

  # Ruta destino relativa desde la carpeta web (../).
  ${DRUSH} sql-dump --result-file=../config/db/data.sql --skip-tables-key=common
}

# Exportación de BBDD de multi-site.
function exportacion_multisite() {
  for i in $(seq 0 $SITES_COUNT); do
    SITE_ID="${SITES[$i]}"
    SITE_PATH="./config/db/${SITE_ID}"

    mkdir -p "${SITE_PATH}"

    clear
    linea
    echo -e "${GREEN} Procesando ${SITE_ID}...${RESET}"
    linea

    # Vacio logs y caché de la base de datos.
    echo " "
    echo -e " ${YELLOW}Vaciando watchdog y caché de Drupal...${RESET}"
    linea
    ${DRUSH} -l "${SITE_ID}" watchdog:delete all -y
    ${DRUSH} -l "${SITE_ID}" cr

    # Genero dump de la base de datos.
    echo " "
    echo -e " ${YELLOW}Realizando volcado de la base de datos...${RESET}"
    linea

    # Ruta destino relativa desde la carpeta web (../).
    ${DRUSH} -l "${SITE_ID}" sql-dump --result-file=."${SITE_PATH}"/data.sql --skip-tables-key=common
  done
}

# Importación de BBDD de un solo sitio.
function importacion_simple() {
  # Compruebo que exista un volcado para importar.
  if [ -f ./config/db/data.sql ]; then
    echo " "
    echo -e " ${YELLOW}Eliminando datos previos de la base de datos...${RESET}"
    linea
    ${DRUSH} sql-drop -y

    echo " "
    echo -e " ${YELLOW}Realizando volcado de la base de datos...${RESET}"
    linea
    pv ./config/db/data.sql | ${DRUSH} sql-cli

    # Realizo actualización posterior a la importación de configuraciones.
    echo " "
    echo -e " ${YELLOW}Actualizando la base de datos...${RESET}"
    linea
    ${DRUSH} updatedb -y
  else
    linea
    echo -e " ${RED}No existe una exportación previa que se pueda importar!!${RESET}"
    linea
  fi
}

# Importación de BBDD de multi-site.
function importacion_multisite() {
  for i in $(seq 0 $SITES_COUNT); do
    SITE_ID="${SITES[$i]}"
    SITE_PATH="./config/db/${SITE_ID}"

    clear
    linea
    echo -e "${GREEN} Procesando ${SITE_ID}...${RESET}"
    linea

    # Compruebo que exista un volcado para importar.
    if [ -f "${SITE_PATH}"/data.sql ]; then
      echo " "
      echo -e " ${YELLOW}Eliminando datos previos de la base de datos...${RESET}"
      linea
      ${DRUSH} -l "${SITE_ID}" sql-drop -y

      echo " "
      echo -e " ${YELLOW}Realizando volcado de la base de datos...${RESET}"
      linea
      pv ."${SITE_PATH}"/data.sql | ${DRUSH} -l "${SITE_ID}" sql-cli

      # Realizo actualización posterior a la importación de configuraciones.
      echo " "
      echo -e " ${YELLOW}Actualizando la base de datos...${RESET}"
      linea
      ${DRUSH} -l "${SITE_ID}" updatedb -y
    else
      echo " "
      echo -e " ${RED}No existe una exportación previa que se pueda importar!!${RESET}"
      linea
    fi
  done
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

# Comprueba si es un multisite.
check_multisite


# ##############################################################################
# INICIO DEL SCRIPT.
# ##############################################################################

clear

if [ "$1" == "ex" ]; then
  ACTION='Exportación'

  # Ejecuto exportación simple o de multi-site según corresponda.
  if [ $MULTI_SITE -gt 0 ]; then
    exportacion_multisite
  else
    exportacion_simple
  fi

elif [ "$1" == "im" ]; then
  ACTION='Importación'

  # Ejecuto importación simple o de multi-site según corresponda.
  if [ $MULTI_SITE -gt 0 ]; then
    importacion_multisite
  else
    importacion_simple
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
if [ $MULTI_SITE -gt 0 ]; then
  echo -e " ${GREEN}${ACTION}${RESET} de las bases de datos realizada correctamente."
else
  echo -e " ${GREEN}${ACTION}${RESET} de la base de datos realizada correctamente."
fi
linea
echo " "
echo " Tiempo de ejecución: ${runtime}s"
echo " "