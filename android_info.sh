#!/bin/bash

# ==========================================================
# ANDROID SYSTEM INFORMATION
# Script de identificación y diagnóstico de Android
# ==========================================================

clear

echo "=========================================================="
echo "              ANDROID SYSTEM INFORMATION"
echo "=========================================================="
echo ""

# ----------------------------------------------------------
# FUNCION PARA MOSTRAR SECCIONES
# ----------------------------------------------------------

seccion() {
    echo ""
    echo "----------------------------------------------------------"
    echo "[$1]"
    echo "----------------------------------------------------------"
}

# ----------------------------------------------------------
# INFORMACION GENERAL
# ----------------------------------------------------------

modelo=$(getprop ro.product.model)
fabricante=$(getprop ro.product.manufacturer)
marca=$(getprop ro.product.brand)
android=$(getprop ro.build.version.release)
api=$(getprop ro.build.version.sdk)
arquitectura=$(getprop ro.product.cpu.abi)
kernel=$(uname -r)
build=$(getprop ro.build.display.id)
uptime=$(uptime)

seccion "INFORMACION GENERAL"

echo "Fabricante          : $fabricante"
echo "Marca               : $marca"
echo "Modelo              : $modelo"
echo "Android             : $android"
echo "API Level           : $api"
echo "Arquitectura        : $arquitectura"
echo "Kernel              : $kernel"
echo "Build               : $build"
echo "Tiempo activo       : $uptime"

# ----------------------------------------------------------
# CPU
# ----------------------------------------------------------

nucleos=$(nproc)
soc=$(getprop ro.soc.model)
plataforma=$(getprop ro.board.platform)

seccion "PROCESADOR"

echo "Nucleos disponibles : $nucleos"
echo "SoC                 : ${soc:-No disponible}"
echo "Plataforma          : ${plataforma:-No disponible}"

# ----------------------------------------------------------
# MEMORIA RAM
# ----------------------------------------------------------

ram_total=$(free -h | awk '/^Mem:/ {print $2}')
ram_usada=$(free -h | awk '/^Mem:/ {print $3}')
ram_libre=$(free -h | awk '/^Mem:/ {print $4}')
ram_disponible=$(free -h | awk '/^Mem:/ {print $7}')

seccion "MEMORIA RAM"

echo "RAM total           : $ram_total"
echo "RAM utilizada       : $ram_usada"
echo "RAM libre           : $ram_libre"
echo "RAM disponible      : $ram_disponible"

# ----------------------------------------------------------
# ALMACENAMIENTO
# ----------------------------------------------------------

seccion "ALMACENAMIENTO"

if [ -d "$HOME/storage/shared" ]; then

    almacenamiento=$(df -h "$HOME/storage/shared" | tail -n 1)

    echo "$almacenamiento"

else

    echo "Almacenamiento de usuario no disponible."
    echo "Se muestra la particion principal del sistema:"
    df -h /data

fi

# ----------------------------------------------------------
# PANTALLA
# ----------------------------------------------------------

resolucion=$(wm size 2>/dev/null | tail -n 1)
densidad=$(wm density 2>/dev/null | tail -n 1)

seccion "PANTALLA"

echo "Resolucion          : $resolucion"
echo "Densidad            : $densidad"

# ----------------------------------------------------------
# GPU
# ----------------------------------------------------------

renderer=$(getprop debug.hwui.renderer)
gpu=$(getprop ro.hardware.egl)

seccion "GPU"

echo "Renderer            : ${renderer:-No disponible}"
echo "Hardware EGL        : ${gpu:-No disponible}"

# ----------------------------------------------------------
# BATERIA
# ----------------------------------------------------------

bateria=$(dumpsys battery 2>/dev/null)

nivel=$(echo "$bateria" | awk -F': ' '/level:/ {print $2}')
estado=$(echo "$bateria" | awk -F': ' '/status:/ {print $2}')
temperatura=$(echo "$bateria" | awk -F': ' '/temperature:/ {print $2}')
voltaje=$(echo "$bateria" | awk -F': ' '/voltage:/ {print $2}')
tecnologia=$(echo "$bateria" | awk -F': ' '/technology:/ {print $2}')

case "$estado" in
    1) estado_texto="Desconocido" ;;
    2) estado_texto="Cargando" ;;
    3) estado_texto="Descargando" ;;
    4) estado_texto="No cargando" ;;
    5) estado_texto="Completa" ;;
    *) estado_texto="No disponible" ;;
esac

if [ -n "$temperatura" ]; then
    temperatura_c=$(awk "BEGIN {printf \"%.1f\", $temperatura/10}")
else
    temperatura_c="No disponible"
fi

if [ -n "$voltaje" ]; then
    voltaje_v=$(awk "BEGIN {printf \"%.2f\", $voltaje/1000}")
else
    voltaje_v="No disponible"
fi

seccion "BATERIA"

echo "Nivel               : ${nivel:-No disponible}%"
echo "Estado              : $estado_texto"
echo "Temperatura         : ${temperatura_c} °C"
echo "Voltaje             : ${voltaje_v} V"
echo "Tecnologia          : ${tecnologia:-No disponible}"

# ----------------------------------------------------------
# RED
# ----------------------------------------------------------

seccion "RED"

interfaz=$(ip route 2>/dev/null | awk '/default/ {print $5; exit}')

if [ -n "$interfaz" ]; then

    ip_local=$(ip -4 addr show "$interfaz" 2>/dev/null |
        awk '/inet / {print $2; exit}')

    echo "Interfaz            : $interfaz"
    echo "Direccion IPv4      : ${ip_local:-No disponible}"

else

    echo "Interfaz            : No disponible"
    echo "Direccion IPv4      : No disponible"

fi

echo ""
echo "Rutas principales:"
ip route 2>/dev/null | head -n 5

# ----------------------------------------------------------
# PROCESOS
# ----------------------------------------------------------

seccion "PROCESOS"

echo "Procesos activos:"
echo ""

ps -A 2>/dev/null | head -n 11

# ----------------------------------------------------------
# SENSORES
# ----------------------------------------------------------

seccion "SENSORES"

sensores=$(dumpsys sensorservice 2>/dev/null |
    grep -i "Sensor List" | head -n 1)

if [ -n "$sensores" ]; then
    echo "$sensores"
else
    echo "Informacion de sensores no disponible mediante este comando."
fi

# ----------------------------------------------------------
# INFORMACION DEL KERNEL
# ----------------------------------------------------------

seccion "KERNEL LINUX"

echo "Kernel              : $(uname -r)"
echo "Arquitectura        : $(uname -m)"
echo "Sistema             : $(uname -o 2>/dev/null || echo Android)"


# ==========================================================
# SOFTWARE
# ==========================================================

version_seguridad=$(getprop ro.build.version.security_patch)
build_id=$(getprop ro.build.id)
tipo_build=$(getprop ro.build.type)
tags_build=$(getprop ro.build.tags)
verified_boot=$(getprop ro.boot.verifiedbootstate)

shell_actual=$(basename "$SHELL")

# Version de Termux
if command -v termux-info >/dev/null 2>&1; then
    termux_version=$(termux-info 2>/dev/null |
        grep -i "TERMUX_VERSION" |
        head -n 1 |
        cut -d: -f2- |
        xargs)
else
    termux_version="No disponible"
fi

# Cantidad de aplicaciones Android de usuario
apps_usuario=$(pm list packages -3 2>/dev/null | wc -l)

# Cantidad de aplicaciones Android del sistema
apps_sistema=$(pm list packages -s 2>/dev/null | wc -l)

# Cantidad total de aplicaciones
apps_total=$(pm list packages 2>/dev/null | wc -l)

seccion "SOFTWARE"

echo "Sistema operativo   : Android"
echo "Version Android     : ${android:-No disponible}"
echo "API Level           : ${api:-No disponible}"
echo "Parche seguridad    : ${version_seguridad:-No disponible}"
echo "Build ID            : ${build_id:-No disponible}"
echo "Tipo de build       : ${tipo_build:-No disponible}"
echo "Tags de build       : ${tags_build:-No disponible}"
echo "Verified Boot       : ${verified_boot:-No disponible}"
echo "Shell               : ${shell_actual:-No disponible}"
echo "Version Termux      : ${termux_version:-No disponible}"
echo "Aplicaciones total  : ${apps_total:-No disponible}"
echo "Apps de usuario     : ${apps_usuario:-No disponible}"
echo "Apps del sistema    : ${apps_sistema:-No disponible}"

echo ""
echo "Primeras aplicaciones de usuario:"

if [ "$apps_usuario" -gt 0 ] 2>/dev/null; then
    pm list packages -3 2>/dev/null |
        head -n 15 |
        sed 's/^package:/  - /'
else
    echo "  No disponible"
fi

echo ""
echo "Paquetes instalados en Termux:"

if command -v pkg >/dev/null 2>&1; then
    pkg list-installed 2>/dev/null |
        grep -E '^[a-zA-Z0-9._+-]+/' |
        head -n 15
else
    echo "  No disponible"
fi
# ----------------------------------------------------------
# FINAL
# ----------------------------------------------------------

echo ""
echo "=========================================================="
echo "                FIN DEL REPORTE"
echo "=========================================================="
echo ""