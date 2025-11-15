#!/bin/sh
set -e

# Optional: refresh root.hints if older than 7 days (safe no-op otherwise)
if [ ! -f /etc/unbound/root.hints ] || [ "$(find /etc/unbound/root.hints -mtime +7 -print)" ]; then
  echo "Refreshing root.hints..."
  curl -fsSL -o /tmp/root.hints.new https://www.internic.net/domain/named.root && \
    mv /tmp/root.hints.new /etc/unbound/root.hints
fi

# Update sertificate bundle
echo "Updating seritification bundle"
update-ca-certificates 

# Ensure trust anchor exists/updated (writes to /var/lib/unbound/root.key)
# -v gives useful logs if something fails
echo "Updating trust anchor (root.key)..."
mkdir -p /var/lib/unbound
chown unbound:unbound /var/lib/unbound
unbound-anchor -a /var/lib/unbound/root.key -v || echo ""

# Validate config before starting
echo "Validating Unbound configuration..."
unbound-checkconf -f /etc/unbound/unbound.conf

# Run Unbound in foreground
echo "Starting Unbound..."
exec unbound -d -v -c /etc/unbound/unbound.conf
