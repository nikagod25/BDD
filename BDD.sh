#!/bin/bash


## Creado por Omar Prego aka "nika"
## Ayuda con IA para el script de bash

#Ctrl+C
trap ctrl_c SIGINT

uso ctrl_c(){
    echo -e "\n\n [!] Saliendo...\n"
}
 
# Función para mostrar ayuda
uso() {
    echo "Uso: $0 -i <IP> [-d <dominio>] [-p <puerto>] [-s <archivo_subdominios>]"
    echo "Opciones:"
    echo "  -i <IP>                  Dirección IP del servidor DNS objetivo."
    echo "  -d <dominio>             Dominio principal para análisis."
    echo "  -p <puerto>              Puerto del servicio DNS (por defecto: 53)."
    echo "  -s <archivo_subdominios> Archivo con una lista de subdominios para analizar."
    echo "  -h                       Mostrar esta ayuda."
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

echo "========== Iniciando pruebas de DNS =========="
echo -e "\n[+] IP objetivo: $IP"
echo -e "\n[+] Dominio: $DOMINIO"
if [ -n "$SUBDOMINIOS_FILE" ]; then
    echo "[+] Archivo de subdominios: $SUBDOMINIOS_FILE"
fi
echo "[+] Puerto: $PUERTO"

# 1. Comprobar consultas recursivas
echo -e "\n[+] Verificando consultas recursivas..."
dig @$IP -p $PUERTO google.com A +short > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "[+] El servidor permite consultas recursivas. Esto podría ser explotado para ataques de amplificación."
else
    echo -e \n"[-] El servidor no permite consultas recursivas."
fi

# 2. Transferencia de zonas (AXFR)
echo -e "\n[+] Intentando transferencia de zona en $DOMINIO..."
AXFR_RESULT=$(dig @$IP -p $PUERTO $DOMINIO AXFR)
if echo "$AXFR_RESULT" | grep -q "Transfer failed"; then
    echo "[-] La transferencia de zona falló. El servidor no permite AXFR."
else
    echo "[+] Transferencia de zona exitosa. Información expuesta:"
    echo "$AXFR_RESULT"
fi

# 3. Escaneo de subdominios
if [ -n "$SUBDOMINIOS_FILE" ]; then
    echo -e "\n[+] Escaneando subdominios listados en $SUBDOMINIOS_FILE..."
    while IFS= read -r subdomain; do
        full_domain="${subdomain}.${DOMINIO}"
        echo "[+] Probando subdominio: $full_domain"
        dig @$IP -p $PUERTO $full_domain A +short
        dig @$IP -p $PUERTO $full_domain CNAME +short
    done < "$SUBDOMINIOS_FILE"
else
    echo "[-] Se omitió el escaneo de subdominios. Proporcione un archivo con -s."
fi

# 4. Verificar soporte para DNSSEC
echo -e "\n[+] Verificando soporte para DNSSEC..."
DNSSEC_SUPPORT=$(dig @$IP -p $PUERTO dnssec-failed.org A +dnssec 2>/dev/null)
if [[ "$DNSSEC_SUPPORT" == *"SERVFAIL"* ]]; then
    echo "\n[-] El servidor no soporta DNSSEC."
else
    echo "\n[+] El servidor soporta DNSSEC."
fi

# 5. Prueba de Cache Poisoning
echo "\n[+] Probando vulnerabilidad de caché DNS (Cache Poisoning)..."
dig @$IP -p $PUERTO random.test A +short > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "\n[+] El servidor parece almacenar en caché dominios inexistentes. Esto podría indicar una vulnerabilidad."
else
    echo "\n[-] No se detectaron problemas de caché evidentes."
fi

echo "\n\n========== Pruebas de DNS completadas =========="

