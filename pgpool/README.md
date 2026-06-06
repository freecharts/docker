# pgpool Docker Image

Minimal Docker setup for pgpool-II using Debian 13.4-slim.

## Build

```bash
docker build -t pgpool:4.6.1-2.1 .
```

## Run

```bash
docker run --rm -p 5432:5432 -e BACKEND_HOSTS=pg01:15432,pg02:25432 pgpool:4.6.1-2.1

docker run -d -p 15432:5432 --network pg -e POSTGRES_PASSWORD=postgres --name pg01 postgres:18.3 -c default_transaction_isolation='repeatable read'
docker run -d -p 25432:5432 --network pg -e POSTGRES_PASSWORD=postgres --name pg02 postgres:18.3 -c default_transaction_isolation='repeatable read'
docker run -d -p 5432:5432 --network pg -e BACKEND_HOSTS=pg01:5432,pg02:5432 -e PGPOOL_BACKEND_USER=postgres -e PGPOOL_BACKEND_PASSWORD=postgres --name pool pgpool:4.6.1-2.1
```

## Params

| Parameter | Type | Default | Description |
|---|---|---|---|
| `BASE_IMAGE` | Docker build ARG | `debian` | Base image repository used for the final container. |
| `BASE_IMAGE_TAG` | Docker build ARG | `13.4-slim` | Tag for the base Debian image. |
| `PGPOOL_VERSION` | Docker build ARG | `4.6.1-2` | Version of the `pgpool2` runtime package installed in the image. |
| `PGPOOL_DATA` | ENV | `/opt/pgpool` | Base directory for pgpool data, config, sockets, and logs. |
| `PGPOOL_PORT` | ENV | `5432` | TCP port on which pgpool listens for client connections. |
| `PGPOOL_MANAGER_PORT` | ENV | `9898` | TCP port for pgpool manager/PCP communication. |
| `PGPOOL_LOG_LEVEL` | ENV | `info` | Log level for the pgpool runtime environment. |
| `BACKEND_HOSTS` | ENV | `` | Comma-separated list of backend servers in `host:port` format. |
| `PGPOOL_BACKEND_USER` | ENV | `postgres` | User for backend health check authentication. |
| `PGPOOL_BACKEND_PASSWORD` | ENV | `` | Password for backend health check authentication. |

## Notes

- Configuration files are mounted into `/opt/pgpool/conf`
- pgpool listens on port `5432`
- The image installs Debian `pgpool2` and exposes the standard PostgreSQL port
