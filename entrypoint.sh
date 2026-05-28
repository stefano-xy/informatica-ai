#!/bin/bash
set -e

if [ -n "$JUPYTER_PASSWORD" ]; then
    HASHED=$(python3 -c "
import os
from jupyter_server.auth import passwd
print(passwd(os.environ['JUPYTER_PASSWORD']))
")
    exec jupyter lab --no-browser --ip=0.0.0.0 --port=8888 --allow-root \
        --ServerApp.password="$HASHED" \
        --ServerApp.token=''
else
    exec jupyter lab --no-browser --ip=0.0.0.0 --port=8888 --allow-root \
        --ServerApp.token='' \
        --ServerApp.password=''
fi
