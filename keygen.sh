#!/bin/bash
set -euo pipefail

NAME=${1:-}
test -z "${NAME:-}" && NAME="brightcove-playback-auth-key-$(date +%s)"
mkdir "$NAME"

PRIVATE_PEM="./$NAME/private.pem"
PUBLIC_PEM="./$NAME/public.pem"
PUBLIC_TXT="./$NAME/public_key.txt"

ssh-keygen -t rsa -b 2048 -m PEM -f "$PRIVATE_PEM" -q -N ""
openssl rsa -in "$PRIVATE_PEM" -pubout -outform PEM -out "$PUBLIC_PEM" 2>/dev/null
openssl rsa -in "$PRIVATE_PEM" -pubout -outform DER | base64 > "$PUBLIC_TXT"

rm "$PRIVATE_PEM".pub

echo "Public key to saved in $PUBLIC_TXT"