#!/bin/bash
set -euo pipefail

echo "Starting pgpool with arguments: $*"
echo "PGPOOL_DATA: ${PGPOOL_DATA:-/opt/pgpool}"
echo "PGPOOL_PORT: ${PGPOOL_PORT:-5432}"
echo "PGPOOL_MANAGER_PORT: ${PGPOOL_MANAGER_PORT:-9898}"
echo "Backends will be configured from BACKEND_HOSTS if set. Format: 'host1:port1,host2:port2,...'"
echo "BACKEND_HOSTS: ${BACKEND_HOSTS:-}"

# Default config file
PGPOOL_CONF="${PGPOOL_DATA:-/opt/pgpool}/conf/pgpool.conf"

# Configure port from PGPOOL_PORT
echo "port = ${PGPOOL_PORT:-5432}" >> "$PGPOOL_CONF"
# Configure manager port from PGPOOL_MANAGER_PORT
echo "pcp_port = ${PGPOOL_MANAGER_PORT:-9898}" >> "$PGPOOL_CONF"
# Configure socket directory
echo "unix_socket_directories = '${PGPOOL_DATA:-/opt/pgpool}/run'" >> "$PGPOOL_CONF"
echo "pcp_socket_dir = '${PGPOOL_DATA:-/opt/pgpool}/run'" >> "$PGPOOL_CONF"
echo "pid_file_name = '${PGPOOL_DATA:-/opt/pgpool}/run/pgpool.pid'" >> "$PGPOOL_CONF"

# Configure backends from BACKEND_HOST if provided
if [[ -n "${BACKEND_HOSTS:-}" ]]; then
  echo "Configuring backends from BACKEND_HOSTS..."
  
  # Parse BACKEND_HOST format: "host1:port1,host2:port2,..."
  IFS=',' read -ra BACKENDS <<< "$BACKEND_HOSTS"
  
  # Add new backend entries
  idx=0
  for backend in "${BACKENDS[@]}"; do
    host="${backend%%:*}"
    port="${backend##*:}"
    
    # Default port if not specified
    [[ -z "$port" ]] && port=5432
    
    echo "backend_hostname$idx = '$host'" >> "$PGPOOL_CONF"
    echo "backend_port$idx = $port" >> "$PGPOOL_CONF"
    echo "Configured backend$idx: $host:$port"
    
    ((++idx))
  done
fi

echo "End of configuration. Starting pgpool..."

# If the first arg starts with '-', treat it as pgpool argument(s)
if [[ "$#" -gt 0 && "$1" == -* ]]; then
  set -- "pgpool" "-n" "$@"
fi

# If the user did not supply a command, use default config file
if [[ "$#" -eq 0 ]]; then
  set -- "pgpool" "-n" "-f" "$PGPOOL_CONF"
fi

echo "Execute command: $*"
exec "$@"
