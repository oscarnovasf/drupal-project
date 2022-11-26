#!/usr/bin/env bash

# ##############################################################################
#
# Realiza la configuración inicial del contenedor para el proyecto.
#
#  @version   v1.0.0
#  @license   GNU/GPL v3+
# ##############################################################################


################################################################################
# CONFIGURACIÓN DEL SCRIPT.
################################################################################


# Cierro el script en caso de error.
set -e

# Colores.
R="\e[0m"  # reset
Y="\e[33m" # amarillo

# Control de tiempo de ejecución.
START=$(date +%s)


################################################################################
# FUNCIONES.
################################################################################


# Muestra la cabecera de algunas respuestas del script.
function show_header() {
  echo -e "
 +-----------------------------------------------------------------------------+
 | ${Y}Preparando contenedor${R}                                                       |
 +-----------------------------------------------------------------------------+
  "
}

# Mensaje de finalización del script.
function show_bye() {
  # Calculo el tiempo de ejecución y muestro mensaje de final del script.
  END=$(date +%s)
  RUNTIME=$((END-START))

  clear
  echo "
 Tiempo de ejecución: ${RUNTIME}s
-------------------------------------------------------------------------------
  "
  exit 0
}

# Instalación de gulp y dependencias.
function install_gulp() {
  echo -e "
  Instalando ${Y}Gulp y sus dependencias...${R}
 -------------------------------------------------------------------------------
  "
  apt-get update -y && apt-get install python3-software-properties gnupg2 curl wget -y
  curl -sL https://deb.nodesource.com/setup_14.x | bash -
  apt-get install nodejs -y

  npm install -g gulp-cli
}

# Instalación de JQ.
function install_jq() {
  echo -e "
  Instalando ${Y}JQ...${R}
 -------------------------------------------------------------------------------
  "
  apt-get update -y && apt-get install -y jq
}


################################################################################
# CUERPO PRINCIPAL DEL SCRIPT.
################################################################################


show_header
install_gulp
install_jq

show_bye