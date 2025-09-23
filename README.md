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

### Android / iOS

1) Instala "ZeroTier One" desde Google Play / App Store.
2) Abre la app → Add Network → introduce `<NETWORK_ID>` y activa el toggle.
3) Autoriza el miembro en Central.
4) La app mostrará la IP asignada; prueba conectividad con herramientas de red o hacia otro miembro.

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

## Contribuciones

Las mejoras y sugerencias son bienvenidas. Abre un issue o envía un PR con cambios descriptivos.

---

## Licencia

Este repositorio no incluye una licencia explícita. Si necesitas una, considera agregar una (por ejemplo MIT) según tus necesidades.
