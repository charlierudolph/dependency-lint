#! /bin/bash

for f in src/*/*/*.js; do
    mv -- "$f" "${f%.js}.ts"
done