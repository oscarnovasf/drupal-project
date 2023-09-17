#!/usr/bin/env bash

# ##############################################################################
#
# Activa o desactiva XDEBUG en el contenedor de la aplicación.
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
GREEN="\033[0;32m"

# Script actual.
SELF=$(basename "${0}")

# Variable para almacenar la acción realizada.
ACTION=''

# Control de tiempo de ejecución.
START=$(date +%s)


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
  echo -e " ${GREEN}Script de activación desactivación de XDEBUG.${RESET}"
  linea
  echo " "
  echo " Uso: ${SELF} [on|off]"
  echo " "
  echo " [on]  Realiza la activación de XDEBUG."
  echo " [off] Realiza la desactivación de XDEBUG."
  echo " "
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


# ##############################################################################
# INICIO DEL SCRIPT.
# ##############################################################################

clear

if [ "$1" == "on" ]; then
  ACTION='Activación'
  docker-php-ext-enable xdebug && /etc/init.d/apache2 reload
elif [ "$1" == "off" ]; then
  ACTION='Desactivación'
  rm /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && /etc/init.d/apache2 reload
else
  clear
  usage
fi


# ##############################################################################
# FIN DEL SCRIPT.
# ##############################################################################

# Calculo el tiempo de ejecución y muestro mensaje de final del script.
END=$(date +%s)
runtime=$((END-START))

clear
linea
echo -e " ${GREEN}${ACTION}${RESET} de XDEBUG realizada correctamente."
linea
echo " "
echo " Tiempo de ejecución: ${runtime}s"
echo " "