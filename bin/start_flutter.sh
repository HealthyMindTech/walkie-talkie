#!/usr/bin/env bash

if command -v enable_flutter.sh > /dev/null; then
    . enable_flutter.sh
fi
cd $(dirname $0)/../flutter

flutter run \
        --web-port=10100 \
        --dart-define "LOGIN_REDIRECT=http://localhost:10100" \
        --dart-define "API_HOST=ws://localhost:8080/" \
        -d web-server
