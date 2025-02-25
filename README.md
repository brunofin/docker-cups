Forked from [https://gitlab.com/ydkn/docker-cups](https://gitlab.com/ydkn/docker-cups)

Objectives:

* Keep CUPS updated
* Make it work with HP Printers by automatically setting up `hp-plugin` to fix "Filter Failed" message
* Maybe switch the base to Fedora Core

# CUPS Docker Image

## Architectures

- amd64
- arm32v7
- arm64v8

## Usage

### Start the container

```bash
docker run -d --restart always -p 631:631 -v $(pwd):/etc/cups brunofin/cups:latest
```

### Configuration

Login in to CUPS web interface on port 631 (e.g. https://localhost:631) and configure CUPS to your needs.
Default credentials: admin / admin

To change the admin password set the environment variable _ADMIN_PASSWORD_ to your password.

```bash
docker run -d --restart always -p 631:631 -v $(pwd):/etc/cups -e ADMIN_PASSWORD=mySecretPassword brunofin/cups:latest
```
