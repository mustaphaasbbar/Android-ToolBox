#!/bin/bash
# Script para obtener la ruta de esta carpeta
CambiaDir=`readlink -f "$0"`
NombreDir="`dirname "$CambiaDir"`"
echo $NombreDir

