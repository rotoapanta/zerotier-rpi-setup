
[![Python](https://img.shields.io/badge/Python-3.11-brightgreen)](https://www.python.org/) 
![GitHub issues](https://img.shields.io/github/issues/rotoapanta/serial-tilt-zbx) 
![GitHub repo size](https://img.shields.io/github/repo-size/rotoapanta/serial-tilt-zbx) 
![GitHub last commit](https://img.shields.io/github/last-commit/rotoapanta/serial-tilt-zbx)
[![Discord Invite](https://img.shields.io/badge/discord-join%20now-green)](https://discord.gg/bf6rWDbJ) 
[![Docker](https://img.shields.io/badge/Docker-No-brightgreen)](https://www.docker.com/) 
[![Linux](https://img.shields.io/badge/Linux-Supported-brightgreen)](https://www.linux.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Author](https://img.shields.io/badge/Roberto%20-Toapanta-brightgreen)](https://www.linkedin.com/in/roberto-carlos-toapanta-g/) 
[![Version](https://img.shields.io/badge/Version-1.0.0-brightgreen)](#registro-de-cambios) 
![GitHub forks](https://img.shields.io/github/forks/rotoapanta/serial-tilt-zbx?style=social) 

# <p align="center">Zerotier rpi setup</p>


Script Bash para instalar, unir, verificar y desinstalar ZeroTier One en Raspberry Pi (y sistemas basados en Debian/Ubuntu en general). Automatiza la instalación del servicio, la unión a una red, la espera de autorización en ZeroTier Central y una prueba de conectividad opcional con ping. También permite abandonar una red o desinstalar ZeroTier.

---

## Requisitos

- Ejecutar el script como root (usar `sudo`).
- Conexión a Internet y acceso a `apt`.
- Un ID de red de ZeroTier (lo obtienes en https://my.zerotier.com).

El script instala automáticamente dependencias mínimas (`curl`, `ca-certificates`, `gnupg`, `lsb-release`) y ZeroTier si no están presentes.

---

## Uso rápido

1) Dar permisos de ejecución al script:

```bash
chmod +x zerotier-rpi-setup.sh
```

2) Unirte a una red (reemplaza `NETWORK_ID` por el ID de tu red):

```bash
sudo ./zerotier-rpi-setup.sh -n <NETWORK_ID>
```

3) Autoriza el nuevo miembro en ZeroTier Central si aparece en estado "PENDING". El script espera hasta 180s por la autorización y luego muestra un resumen del estado de la red e IP asignada.

---

## Ayuda y flags

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

---

## Ejemplos comunes

- Unirse a una red:

```bash
sudo ./zerotier-rpi-setup.sh -n 8056c2e21c000001
```

- Unirse y probar conectividad a un peer (IP ZeroTier):

```bash
sudo ./zerotier-rpi-setup.sh -n 8056c2e21c000001 -p 10.147.20.12 -t 5
```

- Abandonar una red:

```bash
sudo ./zerotier-rpi-setup.sh -n 8056c2e21c000001 --leave
```

- Desinstalar ZeroTier por completo:

```bash
sudo ./zerotier-rpi-setup.sh --uninstall
```

- Consultar estado e interfaces (comandos útiles que también sugiere el script):

```bash
sudo zerotier-cli status
sudo zerotier-cli listnetworks
ip -o -4 addr show | awk '/zt/{print $4}'
```

---

## ¿Qué hace el script?

- Detecta si el equipo es una Raspberry Pi e informa el modelo (Raspberry Pi 3/5 y otros). También muestra el sistema operativo y la arquitectura detectada.
- Instala ZeroTier si no está presente (y dependencias mínimas). Habilita y reinicia el servicio `zerotier-one`.
- Se une a la red indicada y espera hasta 180 segundos a que autorices el equipo en ZeroTier Central.
- Muestra un resumen: estado del cliente (`zerotier-cli status`), redes a las que pertenece (`listnetworks`), interfaces `zt*` y la IP ZeroTier asignada (IPv4).
- Si se indicó `-p`, realiza una prueba de ping al peer configurado.

---

## Compatibilidad

- Sistemas basados en Debian/Ubuntu (incluye Raspberry Pi OS).
- Arquitecturas: ARM (armhf/arm64) y x86_64/amd64.

Nota: ZeroTier mantiene instaladores oficiales que el script utiliza de forma no interactiva (`curl -s https://install.zerotier.com | bash`). Si prefieres, puedes instalar ZeroTier manualmente antes de ejecutar el script.

---

## Conectar un nuevo dispositivo desde cero (paso a paso)

Sigue estos pasos según tu plataforma para unir un nuevo equipo a tu red ZeroTier y verificar la conectividad.

Prerequisitos:
- Tener el `NETWORK_ID` de tu red (en https://my.zerotier.com → Networks).
- Acceso para autorizar miembros en ZeroTier Central.

### Opción A: Linux / Raspberry Pi (Debian/Ubuntu)

1) Instalar y unir usando este script (recomendado):

```bash
# Clonar o copiar el script en el equipo
chmod +x zerotier-rpi-setup.sh
sudo ./zerotier-rpi-setup.sh -n <NETWORK_ID>
```

2) Autoriza el nuevo miembro en ZeroTier Central (si aparece como PENDING).

3) Verifica estado y IP asignada:

```bash
sudo zerotier-cli status
sudo zerotier-cli listnetworks
ip -o -4 addr show | awk '/zt/{print $4}'
```

4) (Opcional) Probar ping a otro miembro: `ping <IP_ZeroTier_del_peer>`

5) Conectarte por SSH a una Raspberry: `ssh pi@<IP_ZeroTier>`

—

Alternativa manual (sin script):

```bash
curl -s https://install.zerotier.com | sudo bash
sudo zerotier-cli join <NETWORK_ID>
# Autoriza el miembro en Central y verifica con:
sudo zerotier-cli listnetworks
```

### Windows

1) Descarga e instala "ZeroTier One" desde https://www.zerotier.com/download/.
2) Abre el icono de ZeroTier en la bandeja del sistema → Join Network → pega `<NETWORK_ID>` → Join.
3) En ZeroTier Central autoriza el nuevo miembro.
4) Comprueba la IP asignada en la app de ZeroTier o con `ipconfig` (adaptador ZeroTier).
5) Prueba conectividad con `ping <IP_ZeroTier_del_peer>`.

### macOS

1) Descarga el instalador (.pkg) desde https://www.zerotier.com/download/ e instálalo.
2) Menú de ZeroTier (barra superior) → Join Network → `<NETWORK_ID>`.
3) Autoriza el miembro en Central.
4) Verifica IP en la app de ZeroTier o con `ifconfig` (interfaz `zt*`).
5) Prueba `ping <IP_ZeroTier_del_peer>`.

### iPhone (iOS)

1) Instala "ZeroTier One" desde App Store: https://apps.apple.com/app/zerotier-one/id1085978097
2) Abre ZeroTier → Join Network (+) → introduce `<NETWORK_ID>`.
3) Cuando iOS lo pida, pulsa "Permitir" para añadir la configuración de VPN (se creará un perfil de VPN).
4) Activa el interruptor de la red. Si no se conecta, ve a Ajustes → VPN y activa "ZeroTier".
5) En ZeroTier Central autoriza el nuevo miembro.
6) Verifica la IP asignada dentro de la app (interfaz `zt*`) y que el estado sea "OK".
7) Prueba acceso a otros miembros:
   - SSH a una Raspberry: usa una app como Termius/Blink y conéctate a `ssh pi@<IP_ZeroTier_del_equipo>`.
   - HTTP/Servicios: accede a `http(s)://<IP_ZeroTier_del_equipo>:<puerto>` si hay servicios expuestos.

Notas iOS:
- Si no responde a ping ICMP, no es inusual en iOS; valida conectividad intentando SSH/HTTP hacia otros miembros.
- Para mantener la conexión en segundo plano, deja activo el VPN de ZeroTier en Ajustes. Evita modos de ahorro extremo de batería.
- iCloud Private Relay o perfiles MDM con restricciones pueden interferir con la VPN.

### Salir de la red / Desinstalar

- Linux con el script:
  - Salir de la red: `sudo ./zerotier-rpi-setup.sh -n <NETWORK_ID> --leave`
  - Desinstalar: `sudo ./zerotier-rpi-setup.sh --uninstall`

- Manual Linux:
  - Salir: `sudo zerotier-cli leave <NETWORK_ID>`
  - Desinstalar (Debian/Ubuntu): `sudo apt purge zerotier-one && sudo apt autoremove`

- Windows/macOS:
  - Salir: desde la app ZeroTier → Leave Network.
  - Desinstalar: métodos estándar del sistema (Agregar/Quitar programas, mover a Papelera).

Notas:
- Tras autorizar, el estado debe verse como `OK` en `zerotier-cli listnetworks` y tendrás una IP del pool configurado (por ejemplo 192.168.194.0/24).
- Si no recibes IP, revisa los Pools (Auto-Assign) y reglas en la red de ZeroTier.

---

## Solución de problemas

- Miembro en PENDING y sin IP: Ingresa a https://my.zerotier.com, abre tu red y autoriza el nuevo miembro (checkbox de Auth). Asegúrate de que la red tenga rangos de direcciones configurados (Auto-Assign) si esperas una IP gestionada.
- No se asigna IP ZeroTier: Verifica la configuración de la red (Pools de direcciones y reglas), reinicia el servicio con `sudo systemctl restart zerotier-one` o reintenta la unión.
- Sin conectividad con el peer: Confirma que ambos miembros estén en la misma red, autorizados y con IP asignada. Verifica reglas/firewall (ICMP), rutas gestionadas y que el peer esté en línea.
- Ver logs/estado del servicio:
  - `sudo systemctl status zerotier-one`
  - `sudo journalctl -u zerotier-one -n 200 --no-pager`

---

## Desinstalación

Para quitar ZeroTier completamente:

```bash
sudo ./zerotier-rpi-setup.sh --uninstall
```

Esto detiene el servicio, realiza `apt purge zerotier-one` y `apt autoremove`.

---

## Opciones avanzadas

- Tiempo de espera de autorización: El script espera hasta 180s por la autorización en ZeroTier Central. Si deseas modificarlo, edita la variable `WAIT_AUTH_SECS` al inicio del script.

---

## Comentarios

Si tienes comentarios o sugerencias, contáctanos en robertocarlos.toapanta@gmail.com

## Soporte

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

## Más información

Enlaces útiles:
- ZeroTier Central: https://my.zerotier.com
- Descargas ZeroTier: https://www.zerotier.com/download/
- Documentación CLI: https://docs.zerotier.com/zerotier/cli

## Comandos rápidos
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

## Enlaces

[![linkedin](https://img.shields.io/badge/linkedin-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/roberto-carlos-toapanta-g/)

[![twitter](https://img.shields.io/badge/twitter-1DA1F2?style=for-the-badge&logo=twitter&logoColor=white)](https://twitter.com/rotoapanta)


