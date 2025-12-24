FROM teamspeak:latest

# Fix CVE-2025-1094 and CVE-2025-4207
USER root
RUN apk update && \
    apk add --no-cache 'libpq>=15.13-r0' && \
    rm -rf /var/cache/apk/*

USER teamspeak