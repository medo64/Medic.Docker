# Medic Docker

Docker container that will restart other containers if they turn unhealthy.


## Environment Variables

The following environment variables can further configure the system:

| Variable    | Default | Description                                             |
|-------------|---------|---------------------------------------------------------|
| `TZ`        | `UTC`   | Time zone, e.g., `America/Los_Angeles`                  |
| `LOG_LEVEL` | `INFO`  | Log level, `TRACE`, `DEBUG`, `INFO`, `WARN`, or `ERROR` |
| `INTERVAL`  | `60`    | Interval in seconds between checks                      |


## Volume Settings

You must expose `/var/run/docker.sock` to the container.


## Run Docker Image

To run the docker image, you can use the following command:
~~~bash
docker run --init -v /var/run/docker.sock:/var/run/docker.sock medo64/medic:latest
~~~


## Build Docker Image

If you want to build docker image for yourself, instead using one available on
[DockerHub](https://hub.docker.com/r/medo64/medic), you
can do so using `make`:
~~~bash
make all
~~~
