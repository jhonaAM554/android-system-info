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