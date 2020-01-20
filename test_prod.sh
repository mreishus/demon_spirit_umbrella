#!/bin/bash
docker build --tag=demon-spirit:test .
export SECRET_KEY_BASE="XoF7n0TfVhLJRYVNWUYqPMyW8nbDYWG7wva8ZtPTFaUrOR6D+AojVaWXJwnjdukz" # This isn't a 'real' secret
docker run --publish 4000:4000 -e "SECRET_KEY_BASE=$SECRET_KEY_BASE" demon-spirit:test
