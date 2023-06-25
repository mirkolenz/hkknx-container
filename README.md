# HKKNX Container

This repository provides automated Docker image builds for [HKKNX](https://github.com/brutella/hkknx-public).
Every night at 00:00 UTC, a GitHub action will fetch the latest stable and beta releases and update the Docker image.
You can pin your container to a specific version or to `latest`/`beta` to always get the latest version of these channels.
Images are available for `amd64` and `arm64`.

Example `docker-compose.yml`:

```yaml
services:
  hkknx:
    image: ghcr.io/mirkolenz/hkknx-container:latest
    restart: unless-stopped
    network_mode: host
    volumes:
      - ./hkknx:/db
```

## Customization

The container uses the following default values:

```txt
--autoupdate=false
--db=/db
--port=8080
--verbose=false
```

You can override any of these by setting the `command` value in your `docker-compose.yml`.
You only need to specify the values you want to override.
For instance, to use port `80`:

```yaml
services:
  hkknx:
    # ... (see above)
    command:
      - --port=80
```

## Development

The image is created entirely with `Nix`.
