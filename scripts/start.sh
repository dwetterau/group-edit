#!/usr/bin/env bash

# Stop if any process returns non-zero exit code
set -e

# Sanity check to make sure we're being run from project root
if [ "$0" != "./scripts/start.sh" ]; then
    echo "Start failed: Wrong working directory"
    echo "You need to be in the project root to run this script"
    exit 1
fi

# Run the build script
chmod +x ./scripts/build.sh && ./scripts/build.sh

if [ "$NODE_ENV" == "" ]; then
    NODE_ENV="local"
fi

echo "Starting $NODE_ENV configuration..."
echo ""

env "NODE_ENV=$NODE_ENV" node ./bin/index.js
