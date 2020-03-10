#!/bin/bash

VERSION=1.3.0 # Bump in layout/app.html.eex too
# ^ Todo: Make this one source of truth

# exit when any command fails
set -e

# mix check
# Mix check commented out
# Router fails after upgrading phoenix - not sure what this is about.
echo "Please run 'mix check' manually and verify the results."
echo "This isn't automated because there's a dialyzer error in the "
echo "phoenix router.  I don't think it's my fault, but I don't "
echo "know how to fix it either."
echo " "
echo "See: https://github.com/phoenixframework/phoenix/issues/3697"
echo " "

read -p "Are you sure you want to build? " -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
fi

echo "Building..."
docker build --tag=mreishus/demon-spirit:$VERSION --tag=mreishus/demon-spirit:latest .
docker push mreishus/demon-spirit:latest
docker push mreishus/demon-spirit:$VERSION
cd ..

echo "Done!"
