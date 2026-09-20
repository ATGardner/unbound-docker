# unbound-docker

An [Unbound](https://github.com/NLnetLabs/unbound) DNS resolver image, built from
the official source tarball rather than a Linux distro's packaged version.

## Why

Every unbound image I found ties its version to whatever its base OS packages
at the time (`apk add unbound`), which lags upstream releases by months to
years and moves on the distro's schedule, not unbound's. This repo builds
unbound from the pinned `UNBOUND_VERSION` `ARG` in the [Dockerfile](Dockerfile)
instead, so the version tracks
[NLnetLabs/unbound](https://github.com/NLnetLabs/unbound) releases directly —
Renovate bumps that `ARG` like any other dependency.

## Image

```
ghcr.io/atgardner/unbound-docker:latest
ghcr.io/atgardner/unbound-docker:vX.Y.Z
```

The entrypoint (adapted from
[pixelfederation/unbound](https://github.com/pixelfederation/unbound)'s) runs
`unbound-anchor` to bootstrap the DNSSEC root trust anchor and refreshes
`root.hints` from IANA on every start, then execs `unbound -c
/etc/unbound/unbound.conf` — so `unbound.conf` is supplied entirely by
whatever mounts it (a Helm chart's ConfigMap, a bind mount, etc.), not baked
into the image.

Passing any other command (`docker run ... unbound -h`) skips the bootstrap
and runs it directly.
