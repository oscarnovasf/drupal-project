#!/usr/bin/env bash

# ##############################################################################
#
# Realiza la configuración inicial del contenedor para el proyecto.
# (configuraciones que son necesarias realizar con el usuario root)
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
RESET="\033[0m"
YELLOW="\033[0;33m"

# Control de tiempo de ejecución.
START=$(date +%s)


################################################################################
# FUNCIONES.
################################################################################


# Simplemente imprime una lína por pantalla.
function linea() {
  echo '--------------------------------------------------------------------------------'
}

# Muestra la cabecera de algunas respuestas del script.
function show_header() {
  linea
  echo -e " ${YELLOW}Preparando contenedor${RESET}"
  linea
}

# Mensaje de finalización del script.
function show_bye() {
  # Calculo el tiempo de ejecución y muestro mensaje de final del script.
  END=$(date +%s)
  RUNTIME=$((END-START))

  clear
  echo " "
  echo -e " Tiempo de ejecución: ${RUNTIME}s"
  linea
  exit 0
}

# Instalación de gulp y dependencias.
function install_gulp() {
  echo " "
  echo -e " Instalando ${YELLOW}Gulp y sus dependencias...${RESET}"
  linea

  apt-get update -y && apt-get install python3-software-properties gnupg2 curl wget -y
  curl -sL https://deb.nodesource.com/setup_14.x | bash -
  apt-get install nodejs -y

  npm install -g gulp-cli
}

# Instalación de JQ.
function install_jq() {
  echo " "
  echo -e " Instalando ${YELLOW}JQ...${RESET}"
  linea
  apt-get update -y && apt-get install -y jq
}

# Instalación de PV.
function install_pv() {
  echo " "
  echo -e " Instalando ${YELLOW}PV...${RESET}"
  linea
  apt-get update -y && apt-get install -y pv
}

# Instalación y activación de PhpRedis.
function install_redis() {
  echo " "
  echo -e " Instalando y activando ${YELLOW}PHPRedis...${RESET}"
  linea
  printf "\n" | pecl install -o -f redis
  rm -rf /tmp/pear
  echo "extension=redis.so" > /usr/local/etc/php/conf.d/redis.ini
}

# Instalación y activación de IgBinary.
function install_igbinary() {
  echo " "
  echo -e " Instalando y activando ${YELLOW}IgBinary...${RESET}"
  linea
  pecl install igbinary
  echo "extension=igbinary.so" > /usr/local/etc/php/conf.d/igbinary.ini
}


################################################################################
# CUERPO PRINCIPAL DEL SCRIPT.
################################################################################


show_header
install_gulp
install_jq
install_pv

# Lando ya incluye redis instalado, así que esto no es necesario pero se
# mantiene la funcionalidad por si en futuras versiones no le dan soporte.
# install_redis

install_igbinary

show_bye