#!/usr/bin/env bash

# Stop if any process returns non-zero exit code
set -e

# Sanity check to make sure we're being run from project root
if [ "$0" != "./scripts/test.sh" ]; then
    echo "Start failed: Wrong working directory"
    echo "You need to be in the project root to run this script"
    exit 1
fi

# Run the build script
chmod +x ./scripts/build.sh && ./scripts/build.sh

echo "Running tests..."
find ./bin -name "*tests.js" -print0 | xargs -0 ./node_modules/.bin/mocha --reporter spec