# BDD
Back Door Detection - Script in Bash
Hecho para Parrot OS - Basado en Debian

Creado por Omar Prego aka "nika".



# Ejecuta distintas consultas de DNS para probar vulnerabilidades para crear puertas traseras:
Ejecuta estas consultas:

- Consultas recursivas
- Transferencia de zonas (AXFR)
- Escaneo de subdominios | Necesitarás tener --dig--  instalado
- Verifica soporte para DNSSEC
- Pruebas de Cache Poisoning

# REQUISITOS: 

Herramientas necesarias : dig y nc (netcat)
Wordlist con subdominios.

# Instalación: 
- git clone https://github.com/nikagod25/BDD

Guia de usos: 

Ejecutar con wordlist con subdominios:
- ./BDD.sh -i <IP> -d <DOMINIO> -s <WORDLISTSUBDOMAINS.txt>

Ejecutar con IP y Dominio:
- ./BDD.sh -i <IP> -d <DOMINIO>

Ejecutar Especificando puerto a escanear:
- ./BDD.sh -i <IP> -d <DOMINIO> -p <PUERTO>

Mostrar ayuda : -h
- ./BDD.sh -h

 


