#!/bin/bash

VERSION=0.5.5 # Bump in layout/app.html.eex too
# ^ Todo: Make this one source of truth

# exit when any command fails
set -e

mix check

echo "Building..."
docker build --tag=mreishus/demon-spirit:$VERSION --tag=mreishus/demon-spirit:latest .
docker push mreishus/demon-spirit:latest
docker push mreishus/demon-spirit:$VERSION
cd ..

echo "Done!"
