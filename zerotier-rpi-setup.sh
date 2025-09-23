#!/usr/bin/env bash
set -euo pipefail

# ========================
# Parámetros / Flags
# ========================
NETWORK_ID=""
PEER_IP=""
PING_COUNT=4
WAIT_AUTH_SECS=180

usage() {
  cat <<EOF
Uso: sudo $0 -n <NETWORK_ID> [-p <PEER_IP>] [-t <PING_COUNT>] [--leave] [--uninstall]
  -n   ID de red de ZeroTier (obligatorio, ej. 8056c2e21c000001)
  -p   IP virtual ZeroTier de un peer para probar ping (opcional)
  -t   Número de pings al probar (por defecto: 4)
  --leave     Abandona la red especificada (-n requerido)
  --uninstall Desinstala ZeroTier (purge)
Ejemplos:
  sudo $0 -n 8056c2e21c000001
  sudo $0 -n 8056c2e21c000001 -p 10.147.20.12 -t 5
EOF
}

LEAVE_ONLY=0
UNINSTALL_ONLY=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    -n) NETWORK_ID="$2"; shift 2 ;;
    -p) PEER_IP="$2"; shift 2 ;;
    -t) PING_COUNT="$2"; shift 2 ;;
    --leave) LEAVE_ONLY=1; shift ;;
    --uninstall) UNINSTALL_ONLY=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Flag desconocido: $1"; usage; exit 1 ;;
  esac
done

if [[ $EUID -ne 0 ]]; then
  echo "✖ Este script debe ejecutarse como root (usa sudo)." >&2
  exit 1
fi

if [[ "$UNINSTALL_ONLY" -eq 1 ]]; then
  echo "→ Deteniendo y desinstalando ZeroTier..."
  systemctl stop zerotier-one || true
  apt-get update -y
  apt-get purge -y zerotier-one || true
  apt-get autoremove -y
  echo "✔ ZeroTier desinstalado."
  exit 0
fi

if [[ -z "${NETWORK_ID}" ]]; then
  echo "✖ Debes especificar -n <NETWORK_ID>."
  usage
  exit 1
fi

# ========================
# Funciones auxiliares
# ========================
cmd_exists() { command -v "$1" >/dev/null 2>&1; }

zt_status() { zerotier-cli status || true; }

zt_join() {
  local nid="$1"
  zerotier-cli listnetworks | awk '{print $3}' | grep -qx "$nid" && {
    echo "ℹ Ya unido a la red $nid"
    return 0
  }
  echo "→ Uniéndose a la red $nid..."
  zerotier-cli join "$nid"
}

zt_leave() {
  local nid="$1"
  echo "→ Saliendo de la red $nid..."
  zerotier-cli leave "$nid" || true
}

get_zt_ifaces() {
  ip -o link show | awk -F': ' '/zt/{print $2}'
}

get_zt_ip4() {
  # Devuelve IP v4 asignada en cualquier interfaz zt*
  ip -o -4 addr show | awk '/zt/{print $4}' | head -n1 | cut -d/ -f1
}

# Detectar modelo de Raspberry Pi (si aplica)
get_rpi_model() {
  local model=""
  if [[ -r /proc/device-tree/model ]]; then
    model="$(tr -d '\0' </proc/device-tree/model 2>/dev/null || true)"
  fi
  if [[ -z "$model" ]]; then
    model="$(awk -F': ' '/^Model/ {print $2}' /proc/cpuinfo 2>/dev/null || true)"
  fi
  if [[ -n "$model" ]]; then
    echo "$model"
    return 0
  fi
  return 1
}

wait_for_auth() {
  local nid="$1"
  local secs="$2"
  echo "→ Esperando autorización del nodo en ZeroTier Central (máx ${secs}s)..."
  local end=$((SECONDS + secs))
  while (( SECONDS < end )); do
    # Estados: OK (autorizado), ACCESS_DENIED (pendiente), NOT_FOUND, etc.
    local line
    line="$(zerotier-cli listnetworks | awk -v n="$nid" '$3==n {print $0}')"
    if [[ -n "$line" ]]; then
      local status
      status="$(awk '{print $5}' <<<"$line" )"
      if [[ "$status" == "OK" ]]; then
        echo "✔ Autorizado."
        return 0
      fi
    fi
    sleep 3
  done
  echo "⚠ No se confirmó la autorización dentro del tiempo. Puedes autorizarlo en https://my.zerotier.com y volver a ejecutar pruebas."
  return 1
}

print_summary() {
  local nid="$1"
  echo
  echo "================= RESUMEN ================="
  zt_status || true
  echo
  echo "→ Redes ZeroTier:"
  zerotier-cli listnetworks || true
  echo
  echo "→ Interfaces ZeroTier presentes:"
  get_zt_ifaces || true
  echo
  local ip4="$(get_zt_ip4 || true)"
  echo "→ IP ZeroTier (IPv4): ${ip4:-no-asignada}"
  echo "=========================================="
  echo
}

test_peer() {
  local ip="$1"
  local cnt="$2"
  [[ -z "$ip" ]] && return 0
  echo "→ Probando conectividad a peer ${ip} (ping x${cnt})..."
  if ping -c "$cnt" -W 2 "$ip"; then
    echo "✔ Ping OK a ${ip}"
  else
    echo "✖ Ping falló a ${ip}. Verifica que el peer esté online y autorizado en la misma red."
  fi
}

# ========================
# Detección de plataforma (Raspberry Pi)
# ========================
OS_NAME="$(. /etc/os-release 2>/dev/null && echo "$PRETTY_NAME" || lsb_release -ds 2>/dev/null || uname -srm)"
ARCH="$(dpkg --print-architecture 2>/dev/null || uname -m)"
RPI_MODEL="$(get_rpi_model || true)"

if [[ "$RPI_MODEL" == *"Raspberry Pi"* ]]; then
  echo "→ Detectado Raspberry Pi: $RPI_MODEL"
  if [[ "$RPI_MODEL" =~ Raspberry[[:space:]]Pi[[:space:]]([0-9]+) ]]; then
    RPI_GEN="${BASH_REMATCH[1]}"
    if [[ "$RPI_GEN" == "3" || "$RPI_GEN" == "5" ]]; then
      echo "✔ Raspberry Pi ${RPI_GEN} detectada. Procediendo con la instalación de ZeroTier."
    else
      echo "ℹ Raspberry Pi detectada (modelo no 3/5). Procediendo igualmente."
    fi
  fi
else
  echo "ℹ Equipo no identificado como Raspberry Pi. Modelo: ${RPI_MODEL:-desconocido}"
fi

echo "→ SO: $OS_NAME | Arquitectura: $ARCH"

# ========================
# Instalar ZeroTier (si falta)
# ========================
if ! cmd_exists zerotier-cli; then
  echo "→ Instalando ZeroTier..."
  apt-get update -y
  apt-get install -y curl ca-certificates gnupg lsb-release
  curl -s https://install.zerotier.com | bash
else
  echo "ℹ ZeroTier ya está instalado."
fi

# Asegurar servicio activo
systemctl enable zerotier-one >/dev/null 2>&1 || true
systemctl restart zerotier-one
sleep 2

echo "→ Estado:"
zt_status

# Salir de red si lo pidieron
if [[ "$LEAVE_ONLY" -eq 1 ]]; then
  zt_leave "$NETWORK_ID"
  print_summary "$NETWORK_ID"
  exit 0
fi

# Unirse a la red
zt_join "$NETWORK_ID"

echo
echo "ℹ Si ves el nodo 'PENDING' en https://my.zerotier.com, debes marcarlo como autorizado (Auth)."
echo "  Red: $NETWORK_ID"
echo

# Esperar autorización
if wait_for_auth "$NETWORK_ID" "$WAIT_AUTH_SECS"; then
  :
else
  echo "→ Continuando igualmente para mostrar información actual..."
fi

# Mostrar resumen y probar peer (si se indicó)
print_summary "$NETWORK_ID"
if [[ -n "$PEER_IP" ]]; then
  test_peer "$PEER_IP" "$PING_COUNT"
fi

echo
echo "✅ Listo."
echo "Sugerencias:"
echo "  • Conectar por SSH usando la IP ZeroTier:  ssh pi@\$(getent hosts \$(hostname) >/dev/null 2>&1 && echo \"\$(getent hosts \$(hostname) | awk '{print \$1}')\" || echo \"\$(get_zt_ip4)\")"
echo "  • Para ver el estado:                      sudo zerotier-cli status && sudo zerotier-cli listnetworks"
echo "  • Para abandonar la red:                   sudo $0 -n $NETWORK_ID --leave"
echo "  • Para desinstalar ZeroTier:               sudo $0 --uninstall"
