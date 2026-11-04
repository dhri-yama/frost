#!/bin/sh
# Creates a self-signed code-signing certificate called "Frost Dev" in your login keychain, so rebuilt copies of Frost
# keep their Accessibility permission. Local use only: it does not make the app trusted by Gatekeeper or other Macs.
# Run it once: ./make-dev-cert.sh. Remove it later in Keychain Access (login keychain, "Frost Dev").
set -e
NAME="Frost Dev"
if security find-certificate -c "$NAME" >/dev/null 2>&1; then echo "\"$NAME\" already exists."; exit 0; fi
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
cat > "$TMP/openssl.cnf" <<CNF
[req]
distinguished_name = dn
x509_extensions = ext
prompt = no
[dn]
CN = $NAME
[ext]
basicConstraints = critical,CA:false
keyUsage = critical,digitalSignature
extendedKeyUsage = critical,codeSigning
CNF
openssl req -x509 -newkey rsa:2048 -nodes -days 3650 -keyout "$TMP/key.pem" -out "$TMP/cert.pem" -config "$TMP/openssl.cnf" 2>/dev/null
openssl pkcs12 -export -inkey "$TMP/key.pem" -in "$TMP/cert.pem" -out "$TMP/frost.p12" -passout pass:frost 2>/dev/null
security import "$TMP/frost.p12" -k "$HOME/Library/Keychains/login.keychain-db" -P frost -T /usr/bin/codesign >/dev/null
echo "Created \"$NAME\". Now run ./bundle.sh, then tccutil reset Accessibility local.frost and allow Frost once more."
