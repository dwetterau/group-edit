#!/usr/bin/env bash

# Stop if any process returns non-zero exit code
set -e

# Sanity check to make sure we're being run from project root
if [ "$0" != "./scripts/build.sh" ]; then
    echo "Start failed: Wrong working directory"
    echo "You need to be in the project root to run this script"
    exit 1
fi

echo "Removing existing build..."
rm -rf ./bin && mkdir ./bin
cp -r ./src/public ./bin/public
cp -r ./src/views ./bin/views
#cp -r ./src/ui ./bin/ui
mkdir ./bin/routes

# Compile all coffeescript to js
echo "Compiling Coffeescript to JS..."
./node_modules/.bin/coffee --output ./bin/ --compile ./src/

# Clear out all the client javascript because we're gonna bundle it all.
find ./bin/public/javascripts -maxdepth 1 -type f -exec rm {} \;
rm -r ./bin/public/javascripts/lib

./node_modules/.bin/browserify --transform coffeeify --debug  \
./src/public/javascripts/client.coffee > ./bin/public/javascripts/bundle.js

echo "Linting..."
find ./src -name "*.coffee" -print0 | xargs -0 ./node_modules/.bin/coffeelint -f ./coffeelint.json

echo "Build successful!"
