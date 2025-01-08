# DNS Pentesting Script

Este script realiza pruebas de penetración en servidores DNS para identificar posibles vulnerabilidades, incluyendo la transferencia de zonas, consultas recursivas, subdominios mal configurados y más.

## Funcionalidades

1. Prueba de transferencia de zonas (AXFR): Verifica si el servidor DNS permite la transferencia de zonas.
2. Detección de consultas recursivas: Comprueba si el servidor está configurado para permitir consultas recursivas.
3. Escaneo de subdominios: Busca subdominios relacionados con el dominio objetivo utilizando un archivo de lista.
4. Pruebas de vulnerabilidades DNSSEC: Verifica si el servidor admite configuraciones inseguras de DNSSEC.
5. Pruebas de cache poisoning: Identifica configuraciones que puedan exponer al servidor a ataques de envenenamiento de caché.

## Requisitos

- **Sistema operativo:** Basado en Unix/Linux
- **Herramientas necesarias:** 
  - `dig`
  - `nc`
- **Permisos:** Acceso a la línea de comandos y permisos para ejecutar scripts bash.

## Uso


Instalación repositorio
```bash
git clone https://github.com/nikagod25/BDD
```

Transferencia de zonas y consultas básicas
```bash
./BDD.sh -i <IP> -d <dominio>
```

Incluyendo escaneo de subdominios
```bash 
./BDD.sh -i <IP> -d <dominio> -p <puerto> -s <archivo_subdominios>
```

Especificando un puerto DNS personalizado
```bash
./BDD.sh -i <IP> -d <dominio> -p <puerto>
```

## Notas

Uso ético: Este script debe usarse solo en entornos bajo autorización explícita. El mal uso puede ser ilegal y está sujeto a sanciones legales.
Contribuciones: Se aceptan sugerencias y mejoras a través de pull requests o issues en este repositorio.

