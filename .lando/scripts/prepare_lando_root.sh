#!/usr/bin/env bash

# ##############################################################################
#
# Realiza la configuración inicial del contenedor para el proyecto.
# (configuraciones que son necesarias realizar con el usuario root)
#
#  @version   v1.1.0
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

# Instalación de Node.js.
function install_node() {
  echo " "
  echo -e " Instalando ${YELLOW}Node.js y sus dependencias...${RESET}"
  linea

  apt-get update -y && apt-get install python3-software-properties gnupg curl wget gcc g++ make ca-certificates -y
  curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

  NODE_MAJOR=18
  echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list

  apt-get update
  apt-get install nodejs -y

  npm install -g npm@latest
}

# Instalación de GULP.
function install_gulp() {
  echo " "
  echo -e " Instalando ${YELLOW}Gulp...${RESET}"
  linea

  npm install -g gulp-cli
}

# Instalación de SASS.
function install_sass() {
  echo " "
  echo -e " Instalando ${YELLOW}SASS...${RESET}"
  linea

  npm install -g sass
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
# No se usa porque Lando ya incluye redis.
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

# Herramientas de desarrollo.
install_node
install_sass
install_gulp

# Herramientas de sistema.
install_jq
install_pv

# Herramientas de optimización y rendimiento.
install_igbinary

show_bye