# zerotier-rpi-setup

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

## Contribuciones

Las mejoras y sugerencias son bienvenidas. Abre un issue o envía un PR con cambios descriptivos.

---

## Licencia

Este repositorio no incluye una licencia explícita. Si necesitas una, considera agregar una (por ejemplo MIT) según tus necesidades.
