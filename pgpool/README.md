# pgpool Docker Image

Minimal Docker setup for pgpool-II using Debian 13.4-slim.

## Build

```bash
docker build -t pgpool:4.6.1-2 .
```

## Run

```bash
docker run --rm -p 5432:5432 -e BACKEND_HOSTS=pg01:15432,pg02:25432 pgpool:4.6.1-2

docker run -d -p 15432:5432 --network pg -e POSTGRES_PASSWORD=postgres --name pg01 postgres:18.3
docker run -d -p 25432:5432 --network pg -e POSTGRES_PASSWORD=postgres --name pg02 postgres:18.3
docker run -d -p 5432:5432 --network pg -e BACKEND_HOSTS=pg01:5432,pg02:5432 -e PGPOOL_BACKEND_USER=postgres -e PGPOOL_BACKEND_PASSWORD=postgres --name pool pgpool:4.6.1-2
```

## Notes

- Configuration files are mounted into `/opt/pgpool/conf`
- pgpool listens on port `5432`
- The image installs Debian `pgpool2` and exposes the standard PostgreSQL port
