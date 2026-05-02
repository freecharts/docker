# pgpool Docker Image

Minimal Docker setup for pgpool-II using Debian 13.4-slim.

## Build

```bash
docker build -t pgpool:4.6.1-2 .
```

## Run

```bash
docker run --rm -p 5432:5432 pgpool:4.6.1-2
```

## Notes

- Configuration files are mounted into `/opt/pgpool/conf`
- pgpool listens on port `5432`
- The image installs Debian `pgpool2` and exposes the standard PostgreSQL port
