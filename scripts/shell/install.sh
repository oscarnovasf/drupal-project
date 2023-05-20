#!/usr/bin/env bash

# ##############################################################################
#
# Script de instalación de Drupal vía Composer/Drush.
#
# - El script lee el entorno que se va a usar desde el archivo .env y activa o
#   no los módulos según el entorno.
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

# Rutas a los diferentes componentes / directorios.
DRUSH="php -d memory_limit=-1 ./vendor/bin/drush"

# Cargo archivo con las variables de dependencias.
source "$(dirname $0)"/.variables

# Almacena la existencia de BBDD para realizar la instalación.
HAS_DB="n"

# Exportación de configuraciones para composer.
export COMPOSER_ALLOW_SUPERUSER=1;
export COMPOSER_MEMORY_LIMIT=-1;
export COMPOSER_PROCESS_TIMEOUT=600


# ##############################################################################
# FUNCIONES AUXILIARES.
# ##############################################################################

# Simplemente imprime una lína por pantalla.
function linea() {
  echo '--------------------------------------------------------------------------------'
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

# Verifica si existe una instalación previa.
function check_installed() {
  DIR_VENDOR=./vendor
  if [ -d "$DIR_VENDOR" ]; then
    clear
    linea
    echo -e " ${RED}El sistema ya está instalado, no se puede ejecutar este script.${RESET}"
    linea
    exit 0
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

# Verifica que las herramientas necesarias están instaladas en el servidor.
function check_requirements() {
  if ! [ -x "$(command -v jq)" ]; then
    clear
    linea
    echo -e " ${RED}No se ha encontrado la herramienta JQ.${RESET}"
    echo -e " ${RED}Visita https://stedolan.github.io/jq/download e instala la versión necesaria.${RESET}"
    linea
    exit 4
  fi

  if ! [ -x "$(command -v pv)" ]; then
    clear
    linea
    echo -e " ${RED}No se ha encontrado la herramienta PV.${RESET}"
    linea
    exit 4
  fi
}

# Cambia los permisos de los archivos.
function asign_perms() {
  clear
  linea
  echo -e " ${YELLOW}Asignando permisos a ficheros...${RESET}"
  linea

  # Asigno grupo y propietario a todos los ficheros.
  find . \
    -path ./.git -prune \
    -o -exec chown "$USER_OWNER":"$USER_GROUP" {} + | pv -pte

  # Me aseguro que puedo ejecutar todos los scripts.
  find ./scripts/shell/ -type f -iname "*.sh" -exec chmod +x {} \;
}

# Función que finaliza la ejecución de la instalación.
function finalize() {
  # CAMBIO DE PERMISOS.
  asign_perms

  # OPCIONES DE DESARROLLO.
  if [ "$SET_PRODUCTION" == "y" ]; then
    # Renombro el archivo settings.develop.php
    chmod 777 "${FILE}"
    chmod 777 "$(pwd)"/web/sites/default
    mv "$(pwd)"/web/sites/default/settings.develop.php "$(pwd)"/web/sites/default/_settings.develop.php
    chmod 555 "$(pwd)"/web/sites/default/_settings.develop.php
    chmod 555 "$(pwd)"/web/sites/default
  fi

  # FIN DEL SCRIPT.
  clear
  linea
  echo -e " ${YELLOW}Finalizando la instalación...${RESET}"
  linea

  # Ejecuto actualización de la base de datos.
  ${DRUSH} updatedb -y

  # Vuelvo a comprobar traducciones disponibles.
  ${DRUSH} locale-update

  # Limpio la caché.
  ${DRUSH} cache-rebuild

  # Calculo el tiempo de ejecución y muestro mensaje de final del script.
  end=$(date +%s)
  runtime=$((end-start))

  clear
  linea
  echo -e " ${YELLOW}Drupal instalado correctamente.${RESET}"
  if [ "$HAS_DB" == "y" ]; then
    echo -e " ${YELLOW}Es recomendable ejecutar un deploy tras esta instalación.${RESET}"
  fi
  echo " "
  echo -e " ${YELLOW}Tiempo de ejecución: ${runtime}s${RESET}"
  linea
  echo " "

  read -n 1 -s -r -p "Pulsa cualquier tecla para continuar..."
  exit 0
}

# Comprobaciones relativas a la base de datos.
function check_database() {
  if [ "$DRUPAL_DB_HOSTNAME" == "localhost" ]; then

    linea
    echo -e " ${YELLOW}Verificando base de datos...${RESET}"
    linea

    DB_CHECK="$(mysql -u ${SCRIPT_DB_ROOT_USER} -e "show databases like '$DRUPAL_DB_DATABASE'" --batch --skip-column-names)"
    if [ ! "${DB_CHECK}" ]; then
      if [ "$SCRIPT_DB_DATABASE_CREATE_IF_NOT_EXISTS" == "y" ]; then
        if [ "$SCRIPT_SERVER_HAS_PLESK" == "y" ]; then
          # Creo la base de datos con PLESK.
          plesk bin database --create "${DRUPAL_DB_DATABASE}" -domain "${SCRIPT_PLESK_SUBSCRIPTION}" -type mysql
          plesk bin database --create-dbuser "${DRUPAL_DB_USER}" -passwd "${DRUPAL_DB_PASSWORD}" -domain "${SCRIPT_PLESK_SUBSCRIPTION}" -server localhost:3306 -database "${DRUPAL_DB_DATABASE}"
        else
          # Creo la base de datos con MySql.
          mysql -u ${SCRIPT_DB_ROOT_USER} -p${SCRIPT_DB_ROOT_PASS} -e "CREATE DATABASE $DRUPAL_DB_DATABASE CHARACTER SET utf8 COLLATE utf8_general_ci";
          mysql -u ${SCRIPT_DB_ROOT_USER} -p${SCRIPT_DB_ROOT_PASS} -e "CREATE USER $DRUPAL_DB_USER@localhost IDENTIFIED BY '$DRUPAL_DB_PASSWORD'";
          mysql -u ${SCRIPT_DB_ROOT_USER} -p${SCRIPT_DB_ROOT_PASS} -e "GRANT ALL PRIVILEGES ON $DRUPAL_DB_DATABASE.* TO '$DRUPAL_DB_USER'@localhost";
          mysql -u ${SCRIPT_DB_ROOT_USER} -p${SCRIPT_DB_ROOT_PASS} -e "FLUSH PRIVILEGES";
        fi
      else
        clear
        linea
        echo -e " ${RED}No es posible continuar sin crear la base de datos previamente.${RESET}"
        linea
        exit 0
      fi
    fi
  fi
}

# Verifica si existe un volcado de la BBDD.
function check_db_dump() {
  if [ -f ./config/db/data.sql ]; then
    HAS_DB="y"
  fi
}

# Instala las dependencias del proyecto.
function run_composer() {
  echo " "
  linea
  echo -e " ${YELLOW}Instalando dependencias...${RESET}"
  linea

  if [ "$SET_PRODUCTION" == "n" ]; then
    # Añado las dependencias de desarrollo.
    for i in "${DEV_COMPOSER[@]}"; do
      IFS=': ' read -r -a array <<< "${i}"
      DATA1="${array[0]}"
      DATA2="${array[1]}"
      cat composer.custom.json | jq --arg e "require-dev" --arg data1 "$DATA1" --arg data2 "$DATA2" '.[$e] += { ($data1) : ($data2) }' > composer.custom.json2
      mv -f composer.custom.json{2,}
    done
  fi

  # Realizo la instalación.
  composer install

  # Realizo update por culpa de las dependencias de merge-plugin
  composer update
}

# Activa/desactiva las opciones de desarrollo.
function set_development() {
  echo " "
  linea
  echo -e " ${YELLOW}Estableciendo opciones de desarrollo...${RESET}"
  linea

  chmod 777 ${WEB_ROOT}/sites/default

  if [ "$SET_PRODUCTION" == "y" ]; then
    FILE=$(pwd)/${WEB_ROOT}/sites/default/settings.develop.php
    if [ -f "$FILE" ]; then
      chmod 777 ${FILE}
      mv "${FILE}" "$(pwd)"/${WEB_ROOT}/sites/default/_settings.develop.php
    fi
  else
    FILE=$(pwd)/${WEB_ROOT}/sites/default/_settings.develop.php
    if [ -f "$FILE" ]; then
      chmod 777 ${FILE}
      mv "${FILE}" "$(pwd)"/${WEB_ROOT}/sites/default/settings.develop.php
    fi
  fi
}

# Realiza la instalación de Drupal.
function install_drupal() {
  clear
  linea
  echo -e " ${YELLOW}Instalando Drupal...${RESET}"
  linea

  # Ejecuto la instalación del sitio
  ${DRUSH} si -y
}

# Activa los módulos instalados.
function activate_modules() {
  clear
  linea
  echo -e " ${YELLOW}Activando módulos...${RESET}"
  linea

  # Módulos generales.
  for i in "${PROD_DRUSH_NAMES[@]}"; do
    echo " "
    echo -e " ${GREEN}Activando ${i}...${RESET}"
    linea
    echo " "
    ${DRUSH} -y en "${i}"
  done
}

# Activa los módulos de desarrollo si procede.
function activate_devel_modules() {
  if [ "$SET_PRODUCTION" == "n" ]; then
    clear
    linea
    echo -e " ${YELLOW}Activando módulos de desarrollo...${RESET}"
    linea

    for i in "${DEV_DRUSH_NAMES[@]}"; do
      echo " "
      echo -e " ${GREEN}Activando ${i}...${RESET}"
      linea
      echo " "
      ${DRUSH} -y en "${i}"
    done

    clear
    linea
    echo -e " ${YELLOW}Importando configuraciones iniciales...${RESET}"
    linea

    echo ' '
    ${DRUSH} config-import --partial --source="$(pwd)"/config/base/config_files/develop/ -y
  fi
}

# Crea el usuario manager y le asigna sus permisos.
function create_manager() {
  clear
  linea
  echo -e " ${YELLOW}Creando usuario Manager y asignando permisos...${RESET}"
  linea

  # Creo el usuario manager, el rol manager y lo asigno al usuario.
  ${DRUSH} user-create "${DRUPAL_MANAGER_NAME}" --mail="${DRUPAL_MANAGER_MAIL}" --password="${DRUPAL_MANAGER_PASS}"
  ${DRUSH} role:create "manager" "Manager"
  ${DRUSH} user-add-role "manager" "${DRUPAL_MANAGER_NAME}"

  # Asigno permisos por defecto al usuario manager.
  ${DRUSH} role-add-perm "manager" "\
    access site in maintenance mode, \
    access site reports, \
    access taxonomy overview, \
    access toolbar, \
    access user profiles, \
    administer users, \
    create page content, \
    delete all revisions, \
    delete any webform submission, \
    edit any page content, \
    edit any webform submission, \
    edit config_pages entity, \
    revert all revisions, \
    use text format full_html, \
    view all revisions, \
    view any webform submission, \
    view config_pages entity, \
    view own unpublished content, \
    view the administration theme, \
    view user email addresses \
  "
}

# Desactiva módulos y vistas que no uso.
function clear_drupal() {
  clear
  linea
  echo -e " ${YELLOW}Desactivando módulos y vistas innecesarias...${RESET}"
  linea

  # Desactivo vistas que no se usan normalmente.
  ${DRUSH} views:disable comments_recent
  ${DRUSH} views:disable content_recent
  ${DRUSH} views:disable who_s_new
  ${DRUSH} views:disable who_s_online

  # Elimino contenidos para poder desactivar el módulo.
  ${DRUSH} entity:delete shortcut -y

  # Desactivo módulos que no se usan normalmente.
  for i in "${CORE_MODULES_DISABLED[@]}"; do
    echo " "
    echo -e " ${GREEN}Desactivando ${i}...${RESET}"
    linea
    echo " "
    ${DRUSH} -y pm:uninstall "${i}"
  done
}

# Importa las configuraciones base.
function import_config() {
  clear
  linea
  echo -e " ${YELLOW}Importando configuraciones iniciales...${RESET}"
  linea

  # Realizo importaciones de configuraciones (Drupal).
  echo ' '
  ${DRUSH} config-import --partial --source="$(pwd)"/config/base/config_files/drupal/ -y

  # Realizo importaciones de configuraciones (Módulos).
  echo ' '
  ${DRUSH} config-import --partial --source="$(pwd)"/config/base/config_files/modulos/ -y

  # Realizo importaciones de configuraciones (Vistas).
  echo ' '
  ${DRUSH} config-import --partial --source="$(pwd)"/config/base/config_files/vistas/ -y
}

# Realiza un volcado de la base de datos.
function dump_bbdd() {
  clear
  linea
  echo -e " ${YELLOW}Realizando copia de seguridad de la BBDD...${RESET}"
  linea

  # Vacio logs y caché de la base de datos.
  echo " "
  echo -e " - ${YELLOW}Vaciando watchdog y caché de Drupal...${RESET}"
  linea

  echo " "
  ${DRUSH} watchdog:delete all -y
  echo " "
  ${DRUSH} cr

  # Genero dump de la base de datos.
  echo " "
  echo -e " - ${YELLOW}Realizando volcado...${RESET}"
  linea

  echo " "
  ${DRUSH} sql-dump --result-file=../config/db/data.sql --skip-tables-key=common
}


# ##############################################################################
# COMPROBACIONES PREVIAS.
# ##############################################################################

clear

# Muestro cabecera del script.
linea
echo -e " ${GREEN}Script que permite la instalación de Drupal de una manera rápida.${RESET}"
echo -e " ${GREEN}(instala los módulos que solemos usar de manera habitual)${RESET}"
linea

echo " "
linea
echo -e " ${YELLOW}Ejecutando comprobaciones previas...${RESET}"
linea

# Compruebo que exista el archivo de variables de entorno.
load_env

# Compruebo que el sistema no esté ya instalado.
check_installed

# Verifico que Drupal se encuentra en una de las rutas válidas.
check_drupal

# Verifico existencia de herramientas necesarias.
check_requirements

# Si el entorno es "pro" o "stg" no se activarán los módulos de desarrollo.
SET_PRODUCTION="n"
if [ "$DRUPAL_ENV" == "pro" ]; then
  SET_PRODUCTION="y"
fi
if [ "$DRUPAL_ENV" == "stg" ]; then
  SET_PRODUCTION="y"
fi

# Ajustes para Plesk en caso de ser necesario.
if [ "$SCRIPT_SERVER_HAS_PLESK" == "y" ]; then
  export PATH=/opt/plesk/php/${SCRIPT_SERVER_PLESK_PHP_VERSION}/bin:$PATH;
fi

# Compruebo si existe la base de datos.
check_database

# Verifico si existe un volcado de la BBDD.
check_db_dump


# ##############################################################################
# INICIO DE LA INSTALACIÓN.
# ##############################################################################

clear


if [ "$HAS_DB" == "y" ]; then
  # Ejecuto instalación de composer.
  echo " "
  linea
  echo -e " ${YELLOW}Instalando dependencias...${RESET}"
  linea
  composer install

  # Realizo la importación de la base de datos.
  clear
  linea
  echo -e " ${YELLOW}Realizando volcado de la base de datos...${RESET}"
  linea
  pv ./config/db/data.sql | ${DRUSH} sql-cli
else
  # Instalo las dependencias según el tipo de entorno.
  run_composer

  # Activo/desactivo opciones de desarrollo.
  set_development

  # Realizo la instalación de Drupal.
  install_drupal

  # Activo módulos.
  activate_modules

  # Creo usuario manager.
  create_manager

  # Elimino cosas innecesarias de Drupal.
  clear_drupal

  # Importo las configuraciones base.
  import_config

  # Realizo backup de la BBDD antes de activar los módulos de desarrollo.
  dump_bbdd

  # Activo módulos de desarrollo.
  activate_devel_modules
fi


# ##############################################################################
# FIN DE LA INSTALACIÓN.
# ##############################################################################

# Finalizo el script.
finalize
