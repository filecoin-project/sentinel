# Lily deployment: docker compose

Lily can be easily dockerized and ran inside docker. It also includes a
`docker-compose` that can be used to get familiar with
[Lily operation](operation.md) and how it integrates with supporting services.

Running in production might require a more sophisticated deployment than
docker-compose. For that, we recommend reading the
[hardware requirements](hardware.md) and
[Kubernetes deployment guide](deployment-k8s.md).

---

## Lily docker images

Lily docker images can be produced for multiple networks via `make` by passing
one of the following targets as an argument: `docker-mainnet`,
`docker-calibnet`, `docker-nerpanet`, `docker-butterflynet`,
`docker-interopnet`, `docker-2k`.

Prebuilt images are also available at Docker Hub:
https://hub.docker.com/r/filecoin/lily/tags.

The docker image tagging convention is: 

  * the `<version>[-<network-name>][-dev]` where `<version>` follows semantic
  versioning (`vMAJOR.MINOR.REV`),
  * `-<network-name>` can either be omitted for Main network or use
  `-calibnet` for Calibration network _(Note: Currently only Main and
  Calibration networks have prebuilt Lily images)_,
  * and an optional `-dev` provides the container which has golang toolchain,
  debugging tools and a shell included for debugging and troubleshooting
  within the container.

---

## Docker Compose and additional Docker services

Lily comes with a `docker-compose.yml` template that provides support for
conveniently launching supporting services:

  * timescaledb - database
  * prometheus - metrics
  * grafana - dashboards
  * jaeger - tracing

You can start/stop these services with:

```
docker-compose up -d
docker-compose down
```

For more information about Docker Compose see
[the official documentation](https://docs.docker.com/compose/).

The services run on the following defaults:

  * Postgres (w/ TimescaleDB)
    * `localhost:5432`
    * Username: `postgres`
    * Password `passowrd`

  * Grafana UI
    * `localhost:3000`
    * Username: `admin`
    * Password: `admin`
  * Prometheus UI
    * `localhost:9090`
  * Jaeger UI
    * `localhost:16686`


If you want to separately run Lily in docker you will need to configure it to
use the network overlay created by docker compose and make sure that it is
configured to point to the endpoints used by the supporting services.
