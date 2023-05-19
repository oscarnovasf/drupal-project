#!/usr/bin/env bash

# ##############################################################################
#
# Script que crea un tunel para poder compartir online nuestro proyecto.
#
#  @version   v1.0.0
#  @license   GNU/GPL v3+
# ##############################################################################

set -eo pipefail

# ##############################################################################
# VARIABLES AUXILIARES.
# ##############################################################################

# Colores.
RESET="\033[0m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
GREEN="\033[0;32m"


# ##############################################################################
# FUNCIONES AUXILIARES.
# ##############################################################################

# Simplemente imprime una lína por pantalla.
function linea() {
  echo '--------------------------------------------------------------------------------'
}

# Verifica que las herramientas necesarias están instaladas en el servidor.
function check_requirements() {
  # Verifico instalación de ngrok.
  if ! [ -x "$(command -v ngrok)" ]; then
    clear
    linea
    echo -e " ${RED}No se encuentra ngrok.${RESET}"
    echo -e " ${YELLOW}Visita https://ngrok.com/download e instala la versión necesaria.${RESET}"
    linea
    exit 1
  fi

  # Verifico instalación de JQ.
  if ! [ -x "$(command -v jq)" ]; then
    clear
    linea
    echo -e " ${RED}No se ha encontrado la herramienta JQ.${RESET}"
    echo -e " ${YELLOW}Visita https://stedolan.github.io/jq/download e instala la versión necesaria.${RESET}"
    linea
    exit 2
  fi
}


# ##############################################################################
# COMPROBACIONES PREVIAS.
# ##############################################################################

clear

# Muestro cabecera del script.
linea
echo -e " ${GREEN}Script que crea un tunel para poder compartir online el proyecto.${RESET}"
linea

check_requirements


# ##############################################################################
# INICIO DEL SCRIPT.
# ##############################################################################

# Obtengo la ruta https de Lando y elimino la barra final de la url.
FULL_SITE_NAME=$(lando info --format json | jq '.[0].urls[-1]' | tr '"' ' ')
FULL_SITE_NAME=$(echo $FULL_SITE_NAME | rev | cut -c 2- | rev)

# Elimino el protocolo de la url.
SITE_NAME=$(echo "$FULL_SITE_NAME" | awk -F '//' {'print $2'})

# Ejecuto ngrok.
ngrok http --host-header="$SITE_NAME" "$FULL_SITE_NAME"