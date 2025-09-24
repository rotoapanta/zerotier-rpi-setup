[![Python](https://img.shields.io/badge/Python-3.11-brightgreen)](https://www.python.org/) 
![GitHub issues](https://img.shields.io/github/issues/rotoapanta/zerotier-rpi-setup) 
![GitHub repo size](https://img.shields.io/github/repo-size/rotoapanta/zerotier-rpi-setup) 
![GitHub last commit](https://img.shields.io/github/last-commit/rotoapanta/zerotier-rpi-setup)
[![Discord Invite](https://img.shields.io/badge/discord-join%20now-green)](https://discord.gg/bf6rWDbJ) 
[![Docker](https://img.shields.io/badge/Docker-No-brightgreen)](https://www.docker.com/) 
[![Linux](https://img.shields.io/badge/Linux-Supported-brightgreen)](https://www.linux.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Author](https://img.shields.io/badge/Roberto%20-Toapanta-brightgreen)](https://www.linkedin.com/in/roberto-carlos-toapanta-g/) 
[![Version](https://img.shields.io/badge/Version-1.0.0-brightgreen)](#registro-de-cambios) 
![GitHub forks](https://img.shields.io/github/forks/rotoapanta/zerotier-rpi-setup?style=social) 

# <p align="center">Zerotier rpi setup</p>

Script Bash para instalar, unir, verificar y desinstalar ZeroTier One en Raspberry Pi (y sistemas basados en Debian/Ubuntu en general). Automatiza la instalación del servicio, la unión a una red, la espera de autorización en ZeroTier Central y una prueba de conectividad opcional con ping. También permite abandonar una red o desinstalar ZeroTier.

---

## Características

- Detecta si el equipo es una Raspberry Pi e informa el modelo (Raspberry Pi 3/5 y otros). También muestra el sistema operativo y la arquitectura detectada.
- Instala ZeroTier si no está presente (y dependencias mínimas). 
- Habilita y reinicia el servicio `zerotier-one`.
- Se une a la red indicada y espera hasta 180 segundos a que autorices el equipo en ZeroTier Central.
- Muestra un resumen: estado del cliente (`zerotier-cli status`), redes a las que pertenece (`listnetworks`), interfaces `zt*` y la IP ZeroTier asignada (IPv4).
- Si se indicó `-p`, realiza una prueba de ping al peer configurado.

## Requisitos del Sistema

- Sistemas soportados:
  - Debian 11/12, Ubuntu 20.04/22.04/24.04 (Server/Desktop)
  - Raspberry Pi OS Bullseye/Bookworm (arm64/armhf)
  - Otros derivados de Debian pueden funcionar, pero no están probados
- Permisos: cuenta con privilegios de administrador (sudo) para instalar paquetes y gestionar servicios.
- Red y puertos:
  - Salida a Internet vía HTTPS (TCP 443) para descargar el instalador.
  - Tráfico UDP 9993 abierto hacia/desde Internet (requerido por ZeroTier).
  - Si usas UFW: `sudo ufw allow 9993/udp`
- Arquitecturas compatibles: `amd64/x86_64`, `arm64/aarch64`, `armhf`.
- Recursos mínimos: ~50 MB libres en disco y ~50 MB de RAM para el servicio.
- Cuenta y red ZeroTier:
  - Una cuenta en https://my.zerotier.com y el Network ID de tu red.
  - Opcional: IP ZeroTier de un peer para pruebas de ping (`-p`) y cantidad de paquetes (`-t`).

Nota: si ya tienes ZeroTier instalado, el script lo detecta y no lo reinstala.

## Estructura del proyecto

```
zerotier-rpi-setup/
├── zerotier-rpi-setup.sh   # Script principal: instala, une, espera autorización y prueba conectividad
└── README.md               # Documentación, guía de uso, solución de problemas y registro de cambios
```

## 🚀 Implementación y despliegue

1) 📦 Preparación
   - Clona o copia este repositorio en el equipo objetivo (Raspberry Pi o Ubuntu).

      ```bash
   git clone git@github.com:rotoapanta/zerotier-rpi-setup.git
   ```

2) 🛠️ Despliegue con el script (recomendado)
   ```bash
   chmod +x zerotier-rpi-setup.sh
   sudo ./zerotier-rpi-setup.sh -n <NETWORK_ID>
   # Para tu red actual: sudo ./zerotier-rpi-setup.sh -n d5e5fb65374a3986
   ```
   - El script instala dependencias si faltan, instala ZeroTier, habilita y reinicia el servicio `zerotier-one`, se une a la red y espera autorización.

3) 🔐 Autorizar en ZeroTier Central
   - https://my.zerotier.com → Networks → tu_red → Members → marcar "Auth" al nuevo miembro.

4) 🔍 Verificar estado e IP
   ```bash
   sudo zerotier-cli status
   sudo zerotier-cli listnetworks
   ip -o -4 addr show | awk '/zt/{print $4}'
   ```

5) 🧰 (Opcional) Registrar el script como comando del sistema
   ```bash
   sudo install -m 0755 zerotier-rpi-setup.sh /usr/local/bin/zerotier-rpi-setup
   # Uso posterior:
   sudo zerotier-rpi-setup -n <NETWORK_ID>
   ```

6) 🧱 Firewall (si usas UFW)
   ```bash
   sudo ufw allow 9993/udp
   ```

7) 📜 Servicio y logs
   ```bash
   sudo systemctl enable zerotier-one
   sudo systemctl status zerotier-one
   sudo journalctl -u zerotier-one -n 200 --no-pager
   ```

8) 🧪 Alternativa manual (sin el script)
   ```bash
   curl -s https://install.zerotier.com | sudo bash
   sudo zerotier-cli join <NETWORK_ID>
   ```

9) 🧹 Reversión / limpieza
   ```bash
   # Salir de la red
   sudo zerotier-cli leave <NETWORK_ID>
   # o con el script
   sudo ./zerotier-rpi-setup.sh -n <NETWORK_ID> --leave

   # Desinstalar ZeroTier
   sudo apt purge zerotier-one -y && sudo apt autoremove -y
   # o con el script
   sudo ./zerotier-rpi-setup.sh --uninstall
   ```

## �� Uso rápido

1) Dar permisos de ejecución al script:
```bash
chmod +x zerotier-rpi-setup.sh
```

2) Unirte a una red (reemplaza `NETWORK_ID` por el ID de tu red):
```bash
sudo ./zerotier-rpi-setup.sh -n <NETWORK_ID>
```

3) Autorizar el nuevo miembro en ZeroTier Central si aparece en estado "PENDING". El script espera hasta 180s por la autorización y luego muestra un resumen del estado de la red e IP asignada.

## 🆘 Ayuda y flags

```text
Uso: sudo ./zerotier-rpi-setup.sh -n <NETWORK_ID> [-p <PEER_IP>] [-t <PING_COUNT>] [--leave] [--uninstall]
  -n   ID de red de ZeroTier (obligatorio, ej. 8056c2e21c000001)
  -p   IP virtual ZeroTier de un peer para probar ping (opcional)
  -t   Número de pings al probar (por defecto: 4)
  --leave     Abandona la red especificada (-n requerido)
  --uninstall Desinstala ZeroTier (purge)
Ejemplos:
  sudo ./zerotier-rpi-setup.sh -n 8056c2e21c000001
  sudo ./zerotier-rpi-setup.sh -n 8056c2e21c000001 -p 10.147.20.12 -t 5
```

- -n: ID de red de ZeroTier (obligatorio).
- -p: IP ZeroTier (IPv4) de un peer para probar conectividad mediante ping.
- -t: Cantidad de paquetes a enviar en la prueba de ping.
- --leave: Abandona la red especificada (no se desinstala el servicio).
- --uninstall: Desinstala completamente ZeroTier.
- -h | --help: Muestra la ayuda.

## 🐧 Conectar desde Ubuntu

1) Usando este script (recomendado en Debian/Ubuntu):
```bash
chmod +x zerotier-rpi-setup.sh
sudo ./zerotier-rpi-setup.sh -n <NETWORK_ID>
# Para tu red actual: sudo ./zerotier-rpi-setup.sh -n d5e5fb65374a3986
```

2) Instalación manual (sin el script):
```bash
curl -s https://install.zerotier.com | sudo bash
sudo zerotier-cli join <NETWORK_ID>
# Autoriza el miembro en Central y verifica con:
sudo zerotier-cli listnetworks
```

## 🔗 Conectar un nuevo dispositivo desde cero (paso a paso)

Prerequisitos:
- Tener el `NETWORK_ID` de tu red (en https://my.zerotier.com → Networks).
- Acceso para autorizar miembros en ZeroTier Central.

1) Linux / Raspberry Pi (Debian/Ubuntu)
   - Instala y une usando este script (recomendado):
     ```bash
     chmod +x zerotier-rpi-setup.sh
     sudo ./zerotier-rpi-setup.sh -n <NETWORK_ID>
     ```
   - Alternativa manual:
     ```bash
     curl -s https://install.zerotier.com | sudo bash
     sudo zerotier-cli join <NETWORK_ID>
     ```

2) Windows
   - Instala ZeroTier One desde https://www.zerotier.com/download/.
   - Join Network con `<NETWORK_ID>`, autoriza en Central, verifica IP.

3) iPhone (iOS)
   - App Store: https://apps.apple.com/app/zerotier-one/id1085978097
   - Únete con `<NETWORK_ID>`, permite el perfil VPN, activa ZeroTier en Ajustes si es necesario, autoriza en Central.

## ↩️ Salir de la red / Desinstalar

- Salir de la red (script):
  ```bash
  sudo ./zerotier-rpi-setup.sh -n <NETWORK_ID> --leave
  ```
- Desinstalar ZeroTier (script):
  ```bash
  sudo ./zerotier-rpi-setup.sh --uninstall
  ```
- Manual (Linux):
  ```bash
  sudo zerotier-cli leave <NETWORK_ID>
  sudo apt purge zerotier-one && sudo apt autoremove
  ```

## 🧩 Solución de problemas

- ⚠️ Miembro en PENDING y sin IP
  - Autoriza en https://my.zerotier.com → Networks → tu_red → Members (checkbox Auth).
  - Revisa que el pool de direcciones (Auto-Assign) esté configurado.
- 🛡️ Sin IP ZeroTier
  - Verifica pools/reglas, reinicia el servicio: `sudo systemctl restart zerotier-one`.
- 🔌 Sin conectividad con el peer
  - Ambos miembros en la misma red, autorizados, con IP; revisa firewall (ICMP), rutas y que el peer esté online.
- 📜 Logs/estado del servicio
  ```bash
  sudo systemctl status zerotier-one
  sudo journalctl -u zerotier-one -n 200 --no-pager
  ```

## 💬 Comentarios

Si tienes comentarios o sugerencias, contáctanos en robertocarlos.toapanta@gmail.com

## 🛟 Soporte

Para soporte, escribe a robertocarlos.toapanta@gmail.com o únete a nuestro canal de Discord.

## Licencia

[MIT](https://opensource.org/licenses/MIT)

## Autores

- [@rotoapanta](https://github.com/rotoapanta)

## Registro de cambios

Este proyecto sigue el formato Keep a Changelog y Semantic Versioning.

[Unreleased]
- 

- 1.0.0 – 2025-09-23
  - Añadido:
    - Numeración de progreso “Paso X/Y” en el flujo principal del script.
    - Guía de conexión desde cero por plataforma (Linux/Raspberry Pi, Windows, macOS, Android, iPhone iOS).
  - Cambiado:
    - Sugerencias finales simplificadas para evitar expansiones complejas de shell.
  - Corregido:
    - Expansión accidental de `$1` bajo `set -u` en una sugerencia impresa.
  - Documentación:
    - README reorganizado con secciones nuevas: iPhone (iOS), Change log y “Más información (de acuerdo a este proyecto)”.

- 0.3.1 – 2025-09-23
  - Corregido:
    - Comillas/codificación extraña en el README.
  - Cambiado:
    - Sugerencias finales del script simplificadas para evitar expansión de variables con `set -u`.

- 0.3.0 – 2025-09-23
  - Añadido:
    - Guía “Conectar un nuevo dispositivo desde cero” por plataforma (Linux/Raspberry Pi, Windows, macOS, Android, iPhone iOS).
    - Sección específica para iPhone (iOS) con pasos y notas.
  - Cambiado:
    - Salida del script con “Paso X/Y” para visualizar el progreso.
  - Corregido:
    - Evitada la expansión de `$1` bajo `set -u` en las sugerencias impresas.

- 0.2.0 – 2025-09-23
  - Añadido:
    - Flags `--leave` y `--uninstall` para abandonar red y desinstalar ZeroTier.
  - Cambiado:
    - Detección de Raspberry Pi y reporte de SO/arquitectura.

- 0.1.0 – 2025-09-23
  - Inicial:
    - Versión inicial del script para instalación, unión a red, espera de autorización y resumen; prueba de peer opcional.

## ℹ️ Más información

Enlaces útiles:
- ZeroTier Central: https://my.zerotier.com
- Descargas ZeroTier: https://www.zerotier.com/download/
- Documentación CLI: https://docs.zerotier.com/zerotier/cli

## 🧭 Comandos rápidos
- Unir este equipo:
  ```bash
  sudo ./zerotier-rpi-setup.sh -n d5e5fb65374a3986
  ```
- Probar ping a otro miembro:
  ```bash
  sudo ./zerotier-rpi-setup.sh -n d5e5fb65374a3986 -p <IP_ZeroTier_del_peer> -t 5
  ```
- Abandonar la red:
  ```bash
  sudo ./zerotier-rpi-setup.sh -n d5e5fb65374a3986 --leave
  ```
- Desinstalar ZeroTier:
  ```bash
  sudo ./zerotier-rpi-setup.sh --uninstall
  ```
- Autorizar miembros en ZeroTier Central:
  https://my.zerotier.com → Networks → rotoapanta_vpn → Members → marcar "Auth".

## 🔗 Enlaces

[![linkedin](https://img.shields.io/badge/linkedin-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/roberto-carlos-toapanta-g/)

[![twitter](https://img.shields.io/badge/twitter-1DA1F2?style=for-the-badge&logo=twitter&logoColor=white)](https://twitter.com/rotoapanta)
