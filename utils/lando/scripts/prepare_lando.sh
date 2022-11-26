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

# Actualización de composer (por si acaso).
function update_composer() {
  echo -e "
  Actualizando ${Y}composer...${R}
 -------------------------------------------------------------------------------
  "
  composer self-update
}

# Instalación y configuración de Oh My Bash.
function install_ohmybash() {
  if [ -d ~/.oh-my-bash ]; then
    echo -e "
  ${Y}Oh My Bash${R} ya está instalado.
 -------------------------------------------------------------------------------
    "
  else
    echo -e "
  Instalando ${Y}Oh My Bash...${R}
 -------------------------------------------------------------------------------
    "
    curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh | bash
    grep -l OSH_THEME=\"font\" ~/.bashrc|xargs sed -i -e "s/font/agnoster/g"
  fi
}


################################################################################
# CUERPO PRINCIPAL DEL SCRIPT.
################################################################################


show_header
update_composer
install_ohmybash

show_bye