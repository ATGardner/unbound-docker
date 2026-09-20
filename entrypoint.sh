#!/bin/sh
set -e

TRUST_DIR=/var/lib/unbound
TRUST_ANCHOR_FILE="${TRUST_DIR}/root.key"
HINTS_FILE="${TRUST_DIR}/root.hints"
CONF_FILE=/etc/unbound/unbound.conf

if [ "$#" -eq 0 ]; then
    mkdir -p "${TRUST_DIR}"
    chown unbound:unbound "${TRUST_DIR}"

    unbound-anchor -a "${TRUST_ANCHOR_FILE}" -v || true
    chown unbound:unbound "${TRUST_ANCHOR_FILE}"

    if curl -fsS -m 10 https://www.internic.net/domain/named.root -o /tmp/hints \
        && grep -qi ROOT-SERVERS /tmp/hints; then
        mv /tmp/hints "${HINTS_FILE}"
    else
        echo "WARNING: failed to refresh root.hints, keeping existing file if present"
    fi

    exec unbound -c "${CONF_FILE}"
else
    exec "$@"
fi
