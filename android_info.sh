#!/bin/bash

echo "=========================================="
echo "       ANDROID SYSTEM INFORMATION"
echo "=========================================="

echo ""
echo "[INFORMACION GENERAL DEL SISTEMA]"
echo ""

modelo=$(getprop ro.product.model)
version_android=$(getprop ro.build.version.release)
arquitectura=$(getprop ro.product.cpu.abi)
kernel=$(uname -r)

echo "Modelo              : $modelo"
echo "Android             : $version_android"
echo "Arquitectura        : $arquitectura"
echo "Kernel              : $kernel"

echo ""
echo "[ HARDWARE ]"
echo ""

nucleos=$(nproc)

echo "Nucleos de CPU      : $nucleos"

ram=$(free -h | awk '/^Mem:/ {print $2}')
ram_usada=$(free -h | awk '/^Mem:/ {print $3}')
ram_disponible=$(free -h | awk '/^Mem:/ {print $7}')

echo "RAM total           : $ram"
echo "RAM utilizada       : $ram_usada"
echo "RAM disponible      : $ram_disponible"