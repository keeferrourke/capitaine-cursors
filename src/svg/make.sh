#!/bin/bash

if [ ! -d 'dark' ]; then
  echo 'No sources!'
  exit 1
fi

cp -r ./dark ./light
find ./light -name "*.svg" -type f -exec sed -i 's/fff/000/g' {} \;
find ./light -name "*.svg" -type f -exec sed -i 's/1a1a1a/fefefe/g' {} \;
