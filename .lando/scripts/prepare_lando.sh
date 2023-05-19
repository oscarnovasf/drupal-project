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

# Instalación y configuración de Oh My Bash.
function install_ohmybash() {
  if [ -d ~/.oh-my-bash ]; then
    echo -e " ${YELLOW}Oh My Bash${RESET} ya está instalado."
    linea
  else
    echo -e " Instalando ${YELLOW}Oh My Bash...${RESET}"
    linea
    curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh | bash
    grep -l OSH_THEME=\"font\" ~/.bashrc|xargs sed -i -e "s/font/agnoster/g"
  fi
}


################################################################################
# CUERPO PRINCIPAL DEL SCRIPT.
################################################################################


show_header
install_ohmybash

show_bye