#!/bin/bash


## Creado por Omar Prego aka "nika"
## Ayuda con IA para el script de bash

#Colours by s4vitar

greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"



ctrl_c(){
    echo -e "${redcolour}\n\n [!] Saliendo...\n${endColour}"
    exit 1
}

#Ctrl+C
trap ctrl_c SIGINT

 
# Función para mostrar ayuda
uso() {
    echo "Uso: $0 -i <IP> [-d <dominio>] [-p <puerto>] [-s <archivo_subdominios>]"
    echo "Opciones:"
    echo "  ${purpleColour}-i${endColour} <IP>                  Dirección IP del servidor DNS objetivo."
    echo "  ${purpleColour}-d${endColour} <dominio>             Dominio principal para análisis."
    echo "  ${purplecolour}-p${endColour} <puerto>              Puerto del servicio DNS (por defecto: 53)."
    echo "  ${purpleColour}-s${endColour} <archivo_subdominios> Archivo con una lista de subdominios para analizar."
    echo "  ${purpleColour}-h${endColour}                 Mostrar esta ayuda."
    exit 1
}

# Variables
IP=""
DOMINIO=""
PUERTO=53
SUBDOMINIOS_FILE=""

# Procesar opciones
while getopts "i:d:p:s:h" opt; do
    case "$opt" in
        i) IP="$OPTARG" ;;
        d) DOMINIO="$OPTARG" ;;
        p) PUERTO="$OPTARG" ;;
        s) SUBDOMINIOS_FILE="$OPTARG" ;;
        h) uso ;;
        *) uso ;;
    esac
done

# Validar parámetros
if [ -z "$IP" ] || [ -z "$DOMINIO" ]; then
    echo "[-] Error: Debes especificar una dirección IP y un dominio principal."
    uso
fi

echo -e "\n${blueColour}========== Iniciando pruebas de DNS ==========${endColour}"
echo -e "${yellowColour}[+] IP objetivo:${endColour} $IP"
echo -e "${yellowColour}[+] Dominio:${endColour} $DOMINIO"
if [ -n "$SUBDOMINIOS_FILE" ]; then
echo -e "${yellowColour}[+] Archivo de subdominios:${endColour} $SUBDOMINIOS_FILE"
fi
echo -e "${yellowColour}[+] Puerto:${endColour} $PUERTO"

# 1. Comprobar consultas recursivas
echo -e "\n${yellowColour}[+] Verificando consultas recursivas...${endColour}"
dig @$IP -p $PUERTO google.com A +short > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${turquoiseColour}[+] El servidor permite consultas recursivas. Esto podría ser explotado para ataques de amplificación.${endColour}"
else
    echo -e "\n${redColour}[-] El servidor no permite consultas recursivas.${endColour}"
fi

# 2. Transferencia de zonas (AXFR)
echo -e "\n${yellowColour}[+] Intentando transferencia de zona en${endColour}${grayColour} $DOMINIO${endColour}"
AXFR_RESULT=$(dig @$IP -p $PUERTO $DOMINIO AXFR)
if echo "$AXFR_RESULT" | grep -q "Transfer failed"; then
    echo -e "${redColour}[-] La transferencia de zona falló. El servidor no permite AXFR.${endColour}"
else
    echo -e "${turquoiseColour}[+] Transferencia de zona exitosa. Información expuesta:${endColour}"
    echo "$AXFR_RESULT"
fi

# 3. Escaneo de subdominios
if [ -n "$SUBDOMINIOS_FILE" ]; then
    echo -e "\n${yellowColour}[+] Escaneando subdominios listados en${endColour}${grayColour} $SUBDOMINIOS_FILE${endColour}"
    while IFS= read -r subdomain; do
        full_domain="${subdomain}.${DOMINIO}"
        echo -e "\n ${turquoiseColour}[+] Probando subdominio:${endColour} $full_domain"
        dig @$IP -p $PUERTO $full_domain A +short
        dig @$IP -p $PUERTO $full_domain CNAME +short
    done < "$SUBDOMINIOS_FILE"
else
    echo -e "\n${redColour}[-] Se omitió el escaneo de subdominios. Proporcione un archivo con -s.\n${endColour}"
fi

# 4. Verificar soporte para DNSSEC
    echo -e "\n${yellowColour}[+] Verificando soporte para DNSSEC...${endColour}"
DNSSEC_SUPPORT=$(dig @$IP -p $PUERTO dnssec-failed.org A +dnssec 2>/dev/null)
if [[ "$DNSSEC_SUPPORT" == *"SERVFAIL"* ]]; then
    echo -e "\n${redColour}   [-] El servidor no soporta DNSSEC.${endColour}"
else
    echo -e "\n ${turquoiseColour}[+] El servidor soporta DNSSEC.${endColour}"
fi

# 5. Prueba de Cache Poisoning
    echo -e "\n${yellowColour}[+] Probando vulnerabilidad de caché DNS (Cache Poisoning)...${endColour}"
dig @$IP -p $PUERTO random.test A +short > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "\n ${turquoiseColour} [+] El servidor parece almacenar en caché dominios inexistentes. Esto podría indicar una vulnerabilidad.${endColour}"
else
    echo -e "\n ${redColour}[-] No se detectaron problemas de caché evidentes.${endColour}"
fi

    echo -e "\n\n${blueColour} ========== Pruebas de DNS completadas ==========${endColour}"

