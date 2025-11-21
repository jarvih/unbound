FROM alpine:latest

# Install Unbound, curl, and CA certificates for TLS
RUN apk add --no-cache unbound openssl curl ca-certificates

# Copy hardened Unbound config and entrypoint
COPY unbound.conf /etc/unbound/unbound.conf
COPY entrypoint.sh /entrypoint.sh

# Expose DNS ports
EXPOSE 53/tcp 53/udp

# Run Unbound in foreground
CMD ["sh", "/entrypoint.sh"]
