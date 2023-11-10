#!/usr/bin/env bash

if command -v enable_flutter.sh > /dev/null;  then
    echo "Running enable_flutter.sh"
   . enable_flutter.sh
fi

export API_HOST="https://walkietalkie.tech/api"
cd $(dirname $0)/../flutter

flutter build web \
        --dart-define "API_HOST=${API_HOST}" \
        --web-renderer canvaskit \
        --source-maps \
        --dump-info

rsync -avz --delete build/web/ walkietalkie@walkietalkie.tech:/var/www/html
