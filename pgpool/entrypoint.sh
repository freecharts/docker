#!/bin/bash
set -euo pipefail

# Default config file
PGPOOL_CONF="${PGPOOL_DATA:-/opt/pgpool}/conf/pgpool.conf"
PGPOOL_BACKENDS_CONF="${PGPOOL_DATA:-/opt/pgpool}/conf/backends.conf"
# Create config directory if needed
mkdir -p "$(dirname "$PGPOOL_CONF")"

if [[ -s "$PGPOOL_CONF" ]]; then
  echo "[INFO] Config file already exists at $PGPOOL_CONF. Skipping config generation."
else
  echo "[INFO] Starting pgpool with arguments: $*"
  echo "[INFO] PGPOOL_DATA: ${PGPOOL_DATA:-/opt/pgpool}"
  echo "[INFO] PGPOOL_PORT: ${PGPOOL_PORT:-5432}"
  echo "[INFO] PGPOOL_MANAGER_PORT: ${PGPOOL_MANAGER_PORT:-9898}"
  echo "[HINT] Backends will be configured from BACKEND_HOSTS if set. Format: 'host1:port1,host2:port2,...'"
  echo "[INFO] BACKEND_HOSTS: ${BACKEND_HOSTS:-}"
  echo "[INFO] Generating configuration at $PGPOOL_CONF"
  echo "[INFO] Generating backends list at $PGPOOL_BACKENDS_CONF"
  cat > "$PGPOOL_CONF" <<EOF
# Generated automatically by entrypoint.sh
backend_clustering_mode = 'snapshot_isolation'
listen_addresses = '*'
port = ${PGPOOL_PORT:-5432}
pcp_listen_addresses = '*'
pcp_port = ${PGPOOL_MANAGER_PORT:-9898}
unix_socket_directories = '${PGPOOL_DATA:-/opt/pgpool}/run'
pcp_socket_dir = '${PGPOOL_DATA:-/opt/pgpool}/run'
pid_file_name = '${PGPOOL_DATA:-/opt/pgpool}/run/pgpool.pid'
log_directory = '${PGPOOL_DATA:-/opt/pgpool}/logs'
logdir = '${PGPOOL_DATA:-/opt/pgpool}/logs'
# Authentication settings
enable_pool_hba = off
pool_passwd = ''
allow_clear_text_frontend_auth = on
EOF

  if [[ -n "${PGPOOL_BACKEND_USER:-}" ]]; then
    echo "health_check_user = '${PGPOOL_BACKEND_USER}'" >> "$PGPOOL_CONF"
    echo "[INFO] Configured health check user: ${PGPOOL_BACKEND_USER}"
  fi

  if [[ -n "${PGPOOL_BACKEND_PASSWORD:-}" ]]; then
    echo "health_check_password = '${PGPOOL_BACKEND_PASSWORD}'" >> "$PGPOOL_CONF"
    echo "health_check_period = 10" >> "$PGPOOL_CONF"
    echo "[INFO] Health check password configured"
  fi

  echo "include '$PGPOOL_DATA/conf/backends.conf'" >> "$PGPOOL_CONF"
  echo "#Generated automatically by entrypoint.sh" >> "$PGPOOL_BACKENDS_CONF"

  if [[ -n "${BACKEND_HOSTS:-}" ]]; then
    echo "[INFO] Configuring backends from BACKEND_HOSTS..."
    
    # Parse BACKEND_HOST format: "host1:port1,host2:port2,..."
    IFS=',' read -ra BACKENDS <<< "$BACKEND_HOSTS"
    
    # Add backend entries
    idx=0
    for backend in "${BACKENDS[@]}"; do
      host="${backend%%:*}"
      port="${backend##*:}"

      # Default port if not specified
      [[ -z "$port" ]] && port=5432

      echo "backend_hostname$idx = '$host'" >> "$PGPOOL_BACKENDS_CONF"
      echo "backend_port$idx = $port" >> "$PGPOOL_BACKENDS_CONF"
      echo "[INFO] Configured backend$idx: $host:$port"

      ((++idx))
    done
  fi

  echo "[INFO] Setting permissions on config files..."
  chmod 600 "$PGPOOL_CONF"
fi

echo "[INFO] End of configuration. Starting pgpool..."
rm -f '${PGPOOL_DATA:-/opt/pgpool}/run/pgpool.pid'

# If the first arg starts with '-', treat it as pgpool argument(s)
if [[ "$#" -gt 0 && "$1" == -* ]]; then
  set -- "pgpool" "-n" "$@"
fi

# If the user did not supply a command, use default config file
if [[ "$#" -eq 0 ]]; then
  set -- "pgpool" "-n" "-f" "$PGPOOL_CONF"
fi

echo "[INFO] Execute command: $*"
exec "$@"
