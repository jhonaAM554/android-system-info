#!/bin/bash

# ==========================================================
# ANDROID SYSTEM INFORMATION
# Identificacion automatica de Hardware y Software
# ==========================================================

clear

echo "=========================================================="
echo "              ANDROID SYSTEM INFORMATION"
echo "=========================================================="
echo "       IDENTIFICACION AUTOMATICA DEL SISTEMA"
echo "=========================================================="
echo ""

# ==========================================================
# FUNCIONES
# ==========================================================

seccion() {
    echo ""
    echo "----------------------------------------------------------"
    echo "[$1]"
    echo "----------------------------------------------------------"
}

# Convierte valores vacios o null en "No disponible"
limpiar() {
    valor="$1"

    if [ -z "$valor" ] || [ "$valor" = "null" ] || [ "$valor" = "NULL" ]; then
        echo "No disponible"
    else
        echo "$valor"
    fi
}

# ==========================================================
# INFORMACION GENERAL
# ==========================================================

modelo=$(getprop ro.product.model)
modelo_comercial=$(getprop ro.product.marketname)
fabricante=$(getprop ro.product.manufacturer)
marca=$(getprop ro.product.brand)
android=$(getprop ro.build.version.release)
api=$(getprop ro.build.version.sdk)
arquitectura=$(getprop ro.product.cpu.abi)
kernel=$(uname -r)
build=$(getprop ro.build.display.id)

if [ -z "$modelo_comercial" ] || [ "$modelo_comercial" = "null" ]; then
    modelo_comercial="$modelo"
fi

seccion "INFORMACION GENERAL"

echo "Fabricante          : $(limpiar "$fabricante")"
echo "Marca               : $(limpiar "$marca")"
echo "Modelo              : $(limpiar "$modelo")"
echo "Nombre comercial    : $(limpiar "$modelo_comercial")"
echo "Version Android     : $(limpiar "$android")"
echo "API Level           : $(limpiar "$api")"
echo "Arquitectura        : $(limpiar "$arquitectura")"
echo "Kernel              : $(limpiar "$kernel")"
echo "Build               : $(limpiar "$build")"

# ==========================================================
# SOFTWARE
# ==========================================================

seccion "SOFTWARE"

version_seguridad=$(getprop ro.build.version.security_patch)
build_id=$(getprop ro.build.id)
tipo_build=$(getprop ro.build.type)
tags_build=$(getprop ro.build.tags)
verified_boot=$(getprop ro.boot.verifiedbootstate)

shell_actual=$(basename "$SHELL")

echo "Sistema operativo   : Android"
echo "Version Android     : $(limpiar "$android")"
echo "API Level           : $(limpiar "$api")"
echo "Parche de seguridad : $(limpiar "$version_seguridad")"
echo "Build ID            : $(limpiar "$build_id")"
echo "Tipo de compilacion : $(limpiar "$tipo_build")"
echo "Tags de compilacion : $(limpiar "$tags_build")"
echo "Verified Boot       : $(limpiar "$verified_boot")"
echo "Shell                : $(limpiar "$shell_actual")"

# ==========================================================
# TERMUX
# ==========================================================

seccion "ENTORNO TERMUX"

if command -v termux-info >/dev/null 2>&1; then

    termux_version=$(termux-info 2>/dev/null |
        grep -i "TERMUX_VERSION" |
        head -n 1 |
        cut -d: -f2- |
        xargs)

    if [ -z "$termux_version" ]; then
        termux_version="Detectado"
    fi

else

    termux_version="No disponible"

fi

echo "Termux              : $(limpiar "$termux_version")"

# ==========================================================
# APLICACIONES INSTALADAS
# ==========================================================

seccion "APLICACIONES INSTALADAS"

# Intentar obtener aplicaciones mediante pm
if command -v pm >/dev/null 2>&1; then

    paquetes_usuario=$(pm list packages -3 2>/dev/null)
    paquetes_sistema=$(pm list packages -s 2>/dev/null)
    paquetes_total=$(pm list packages 2>/dev/null)

# Si pm no esta disponible, intentar mediante cmd
elif command -v cmd >/dev/null 2>&1; then

    paquetes_usuario=$(cmd package list packages -3 2>/dev/null)
    paquetes_sistema=$(cmd package list packages -s 2>/dev/null)
    paquetes_total=$(cmd package list packages 2>/dev/null)

else

    paquetes_usuario=""
    paquetes_sistema=""
    paquetes_total=""

fi

# Eliminar posibles lineas vacias
paquetes_usuario=$(echo "$paquetes_usuario" | sed '/^[[:space:]]*$/d')
paquetes_sistema=$(echo "$paquetes_sistema" | sed '/^[[:space:]]*$/d')
paquetes_total=$(echo "$paquetes_total" | sed '/^[[:space:]]*$/d')

cantidad_usuario=$(echo "$paquetes_usuario" | grep -c "^package:" 2>/dev/null)
cantidad_sistema=$(echo "$paquetes_sistema" | grep -c "^package:" 2>/dev/null)
cantidad_total=$(echo "$paquetes_total" | grep -c "^package:" 2>/dev/null)

# Si no se pudo contar mediante grep, usar wc
if [ "$cantidad_usuario" -eq 0 ] && [ -n "$paquetes_usuario" ]; then
    cantidad_usuario=$(echo "$paquetes_usuario" | wc -l)
fi

if [ "$cantidad_sistema" -eq 0 ] && [ -n "$paquetes_sistema" ]; then
    cantidad_sistema=$(echo "$paquetes_sistema" | wc -l)
fi

if [ "$cantidad_total" -eq 0 ] && [ -n "$paquetes_total" ]; then
    cantidad_total=$(echo "$paquetes_total" | wc -l)
fi

echo "Aplicaciones totales : $(limpiar "$cantidad_total")"
echo "Apps de usuario      : $(limpiar "$cantidad_usuario")"
echo "Apps del sistema     : $(limpiar "$cantidad_sistema")"

echo ""
echo "Aplicaciones de usuario instaladas:"
echo ""

if [ -n "$paquetes_usuario" ]; then

    echo "$paquetes_usuario" |
        sed 's/^package://g' |
        head -n 30 |
        while read -r paquete
        do
            echo "  - $paquete"
        done

else

    echo "  No disponible"

fi

# ==========================================================
# PROCESADOR
# ==========================================================

nucleos=$(nproc)
soc=$(getprop ro.soc.model)
plataforma=$(getprop ro.board.platform)

seccion "PROCESADOR"

echo "Nucleos disponibles : $(limpiar "$nucleos")"
echo "SoC                 : $(limpiar "$soc")"
echo "Plataforma          : $(limpiar "$plataforma")"

# ==========================================================
# MEMORIA RAM
# ==========================================================

ram_info=$(free -h)

ram_total=$(echo "$ram_info" | awk '/^Mem:/ {print $2}')
ram_usada=$(echo "$ram_info" | awk '/^Mem:/ {print $3}')
ram_libre=$(echo "$ram_info" | awk '/^Mem:/ {print $4}')
ram_disponible=$(echo "$ram_info" | awk '/^Mem:/ {print $7}')

seccion "MEMORIA RAM"

echo "RAM total           : $(limpiar "$ram_total")"
echo "RAM utilizada       : $(limpiar "$ram_usada")"
echo "RAM libre           : $(limpiar "$ram_libre")"
echo "RAM disponible      : $(limpiar "$ram_disponible")"

# ==========================================================
# ALMACENAMIENTO
# ==========================================================

seccion "ALMACENAMIENTO"

if [ -d "$HOME/storage/shared" ]; then

    echo "Almacenamiento compartido:"
    df -h "$HOME/storage/shared" 2>/dev/null | tail -n 1

else

    echo "Almacenamiento compartido : No disponible"
    echo ""
    echo "Particion /data:"
    df -h /data 2>/dev/null | tail -n 1

    echo ""
    echo "Para habilitar almacenamiento compartido:"
    echo "termux-setup-storage"

fi

# ==========================================================
# PANTALLA
# ==========================================================

seccion "PANTALLA"

resolucion=$(wm size 2>/dev/null |
    grep -oE '[0-9]+x[0-9]+' |
    tail -n 1)

densidad=$(wm density 2>/dev/null |
    grep -oE '[0-9]+' |
    tail -n 1)

echo "Resolucion          : $(limpiar "$resolucion")"

if [ -n "$densidad" ]; then
    echo "Densidad            : ${densidad} dpi"
else
    echo "Densidad            : No disponible"
fi

# ==========================================================
# GPU
# ==========================================================

seccion "GPU"

gpu_model=""

if [ -f /sys/class/kgsl/kgsl-3d0/gpu_model ]; then
    gpu_model=$(cat /sys/class/kgsl/kgsl-3d0/gpu_model 2>/dev/null)
fi

renderer=$(getprop debug.hwui.renderer)
egl=$(getprop ro.hardware.egl)
gralloc=$(getprop ro.hardware.gralloc)

echo "Modelo GPU          : $(limpiar "$gpu_model")"
echo "Renderer            : $(limpiar "$renderer")"
echo "EGL                 : $(limpiar "$egl")"
echo "Gralloc             : $(limpiar "$gralloc")"

# ==========================================================
# BATERIA
# ==========================================================

seccion "BATERIA"

if command -v termux-battery-status >/dev/null 2>&1; then

    bateria=$(termux-battery-status 2>/dev/null)

    # Eliminar valores null
    if echo "$bateria" | grep -q '"percentage":'; then

        nivel=$(echo "$bateria" |
            jq -r '.percentage // empty' 2>/dev/null)

        estado=$(echo "$bateria" |
            jq -r '.status // empty' 2>/dev/null)

        salud=$(echo "$bateria" |
            jq -r '.health // empty' 2>/dev/null)

        temperatura=$(echo "$bateria" |
            jq -r '.temperature // empty' 2>/dev/null)

        voltaje=$(echo "$bateria" |
            jq -r '.voltage // empty' 2>/dev/null)

        corriente=$(echo "$bateria" |
            jq -r '.current // empty' 2>/dev/null)

        conectado=$(echo "$bateria" |
            jq -r '.plugged // empty' 2>/dev/null)

        echo "Nivel               : $(limpiar "$nivel")%"
        echo "Estado              : $(limpiar "$estado")"
        echo "Salud               : $(limpiar "$salud")"
        echo "Temperatura         : $(limpiar "$temperatura") °C"
        echo "Voltaje             : $(limpiar "$voltaje") mV"
        echo "Corriente           : $(limpiar "$corriente") mA"
        echo "Fuente              : $(limpiar "$conectado")"

    else

        echo "Informacion de bateria no disponible."

    fi

else

    echo "Termux:API no instalado."
    echo "Ejecute: pkg install termux-api"

fi

# ==========================================================
# RED Y WIFI
# ==========================================================

seccion "RED Y WIFI"

if command -v termux-wifi-connectioninfo >/dev/null 2>&1; then

    wifi=$(termux-wifi-connectioninfo 2>/dev/null)

    ssid=$(echo "$wifi" |
        jq -r '.ssid // empty' 2>/dev/null)

    bssid=$(echo "$wifi" |
        jq -r '.bssid // empty' 2>/dev/null)

    ip_wifi=$(echo "$wifi" |
        jq -r '.ip // empty' 2>/dev/null)

    velocidad=$(echo "$wifi" |
        jq -r '.link_speed_mbps // empty' 2>/dev/null)

    frecuencia=$(echo "$wifi" |
        jq -r '.frequency_mhz // empty' 2>/dev/null)

    echo "SSID                : $(limpiar "$ssid")"
    echo "BSSID               : $(limpiar "$bssid")"
    echo "Direccion IP        : $(limpiar "$ip_wifi")"
    echo "Velocidad enlace    : $(limpiar "$velocidad") Mbps"
    echo "Frecuencia          : $(limpiar "$frecuencia") MHz"

else

    echo "Termux:API no instalado."

fi

echo ""
echo "Interfaces de red:"

if command -v ip >/dev/null 2>&1; then
    ip -brief addr 2>/dev/null | head -n 10
else
    echo "Informacion no disponible."
fi

# ==========================================================
# PROCESOS
# ==========================================================

seccion "PROCESOS"

echo "Procesos activos:"
echo ""

ps -A 2>/dev/null | head -n 16

# ==========================================================
# SENSORES
# ==========================================================

seccion "SENSORES"

if command -v termux-sensor >/dev/null 2>&1; then

    echo "Sensores disponibles:"
    echo ""

    termux-sensor -l 2>/dev/null

else

    echo "Termux:API no instalado."
    echo "Ejecute: pkg install termux-api"

fi

# ==========================================================
# KERNEL LINUX
# ==========================================================

seccion "KERNEL LINUX"

echo "Version kernel      : $(uname -r)"
echo "Arquitectura kernel : $(uname -m)"
echo "Sistema             : $(uname -o 2>/dev/null || echo Android)"

# ==========================================================
# PROPIEDADES IMPORTANTES DE ANDROID
# ==========================================================

seccion "PROPIEDADES ANDROID"

echo "Fabricante          : $(limpiar "$(getprop ro.product.manufacturer)")"
echo "Modelo              : $(limpiar "$(getprop ro.product.model)")"
echo "Android             : $(limpiar "$(getprop ro.build.version.release)")"
echo "API                 : $(limpiar "$(getprop ro.build.version.sdk)")"
echo "SoC                 : $(limpiar "$(getprop ro.soc.model)")"
echo "Plataforma          : $(limpiar "$(getprop ro.board.platform)")"
echo "ABI                 : $(limpiar "$(getprop ro.product.cpu.abi)")"

# ==========================================================
# RESUMEN
# ==========================================================

seccion "RESUMEN DEL SISTEMA"

echo "Dispositivo         : $(limpiar "$modelo")"
echo "Android             : $(limpiar "$android")"
echo "API                 : $(limpiar "$api")"
echo "CPU                 : $(limpiar "$nucleos") nucleos"
echo "RAM                 : $(limpiar "$ram_total")"
echo "Arquitectura        : $(limpiar "$arquitectura")"
echo "SoC                 : $(limpiar "$soc")"
echo "Kernel              : $(limpiar "$kernel")"
echo "Apps instaladas     : $(limpiar "$cantidad_total")"

# ==========================================================
# FINAL
# ==========================================================

echo ""
echo "=========================================================="
echo "             FIN DEL REPORTE DEL SISTEMA"
echo "=========================================================="
echo ""