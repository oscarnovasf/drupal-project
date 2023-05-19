#!/usr/bin/env bash

# ##############################################################################
#
# Script de comprobación de la hoja de estilos de Drupal.
#
# - Se encarga de verificar que se cumple el standard de codificación.
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
PHPCS="vendor/bin/phpcs"
DRUPAL_CODER_PATH="vendor/drupal/coder/coder_sniffer"
CUSTOM_MODULES_PATH="modules/custom"
CUSTOM_THEMES_PATH="themes/custom"
SANDBOX_MODULES_PATH="modules/sandbox"


# ##############################################################################
# FUNCIONES AUXILIARES.
# ##############################################################################

# Simplemente imprime una lína por pantalla.
function linea() {
  echo '--------------------------------------------------------------------------------'
}

# Función que imprime las instrucciones de uso.
usage() {
  clear
  echo " "
  linea
  echo -e " ${YELLOW}Script que permite verificar el cumplimiento de los estándares de codificación"
  echo -e " de Drupal${RESET}"
  linea
  echo " "
  echo " Uso: ${SELF} [option]"
  echo " "
  echo "[option] puede tomar los siguientes valores:"
  echo "   check-config       Comprueba que las reglas esten instalados."
  echo "   install-coder      Instala las reglas."
  echo "   check-sandbox      Comprueba la codificación de los módulos 'sandbox'."
  echo "   check-modules      Comprueba la codificación de los módulos 'custom'."
  echo "   check-module name  Comprueba la codificación de un módulo determinado."
  echo "   check-themes       Comprueba la codificación de las plantillas 'custom'."
  echo "   check-theme name   Comprueba la codificación de una plantilla determinada."
  echo "   check-all          Equivale a: check-sandbox + check-modules + check-themes."
  echo " "
}

# Verifica que las herramientas necesarias están instaladas en el servidor.
function check_requirements() {
  # Verifico instalación de phpcs.
  if [ ! -f "${PHPCS}" ]; then
    clear
    linea
    echo -e " ${RED}No se encuentra ${PHPCS}${RESET}."
    echo " Verifica que tienes instalado los módulos necesarios:"
    echo " - squizlabs/php_codesniffer"
    linea
    echo " "
    exit 1
  fi

  # Verifico instalación de las reglas.
  if [ ! -d "${DRUPAL_CODER_PATH}" ]; then
    clear
    linea
    echo -e " ${RED}No se encuentra ${DRUPAL_CODER_PATH}${RESET}."
    echo " Verifica que tienes instalado los módulos necesarios:"
    echo " - drupal/coder"
    linea
    echo " "
    exit 1
  fi

  # Verifico que exista el archivo phpcs.xml.
  if [ ! -f "phpcs.xml" ]; then
    clear
    linea
    echo -e " ${RED}No se encuentra phpcs.xml${RESET}."
    echo " Este archivo de configuración es necesario para verificar el standard."
    linea
    echo " "
    exit 1
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


# ##############################################################################
# COMPROBACIONES PREVIAS.
# ##############################################################################

# Verifico requerimientos.
check_requirements

# Verifico que Drupal se encuentra en una de las rutas válidas.
check_drupal


# ##############################################################################
# INICIO DEL SCRIPT.
# ##############################################################################

clear

if [ "${1}" == "check-config" ]; then
  ${PHPCS} -i
elif [ "${1}" == "install-coder" ]; then
  ${PHPCS} --config-set installed_paths "${DRUPAL_CODER_PATH}"
elif [[ "${1}" =~ ^check\-(all|modules|module|themes|theme|sandbox)$ ]]; then

  if [[ "${1}" =~ ^check\-(all|modules)$ ]]; then
    if [ -d "${WEB_ROOT}/${CUSTOM_MODULES_PATH}" ]; then
      for FILE in $(find "${WEB_ROOT}/${CUSTOM_MODULES_PATH}" -mindepth 1 -maxdepth 1 -type d | sort); do
        echo -e " Comprobando módulo. Archivo: ${GREEN}${FILE}${RESET}..."
        linea
        ${PHPCS} -s "${FILE}"
        echo " "
      done
    fi
  fi

  if [[ "${1}" =~ ^check\-(module|theme)$ ]]; then
    if [[ "${2}" == "" ]]; then
      echo -e " ${RED}ERROR: Faltan parámetros.${RESET}"
      usage
      exit 1
    fi
    if [[ "${1}" == "check-module" ]]; then
      FILE="${WEB_ROOT}/${CUSTOM_MODULES_PATH}/${2}"
      if [ ! -d "${FILE}" ]; then
        echo -e " ${RED}ERROR: No se encuentra el módulo especificado (${2})${RESET}."
        exit 1
      fi
      echo -e " Comprobando módulo ${YELLOW}${2}${RESET}. Archivo: ${GREEN}${FILE}${RESET}..."
      linea
      ${PHPCS} -s "${FILE}"
      echo " "
    elif [[ "${1}" == "check-theme" ]]; then
      FILE="${WEB_ROOT}/${CUSTOM_THEMES_PATH}/${2}"
      if [ ! -d "${FILE}" ]; then
        echo -e " ${RED}ERROR: No se encuentra la plantilla especificada (${2})${RESET}."
        exit 1
      fi
      echo -e " Comprobando plantilla ${YELLOW}${2}${RESET}. Archivo: ${GREEN}${FILE}${RESET}..."
      linea
      ${PHPCS} -s "${FILE}"
      echo " "
    fi
  fi

  if [[ "${1}" =~ ^check\-(all|sandbox)$ ]]; then
    if [ -d "${WEB_ROOT}/${SANDBOX_MODULES_PATH}" ]; then
      for FILE in $(find "${WEB_ROOT}/${SANDBOX_MODULES_PATH}" -mindepth 1 -maxdepth 1 -type d | sort); do
        echo -e " Comprobando módulo sandbox. Archivo: ${GREEN}${FILE}${RESET}..."
        linea
        ${PHPCS} -s "${FILE}"
        echo " "
      done
    fi
  fi

  if [[ "${1}" =~ ^check\-(all|themes)$ ]]; then
    if [ -d "${WEB_ROOT}/${CUSTOM_THEMES_PATH}" ]; then
      for FILE in $(find "${WEB_ROOT}/${CUSTOM_THEMES_PATH}" -mindepth 1 -maxdepth 1 -type d | sort); do
        echo -e " Comprobando plantilla. Archivo: ${GREEN}${FILE}${RESET}..."
        linea
        ${PHPCS} -s "${FILE}"
        echo " "
      done
    fi
  fi

  # Calculo el tiempo de ejecución y muestro mensaje de final del script.
  end=$(date +%s)
  runtime=$((end-start))

  clear
  linea
  echo -e " ${GREEN}Comprobación finalizada.${RESET}"
  linea
  echo " "
  echo " Tiempo de ejecución: ${runtime}s"
  echo " "
else
  echo -e " ${RED}ERROR: Parámetros incorrectos.${RESET}"
  usage
  exit 1
fi

exit 0