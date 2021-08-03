#!/bin/bash

PUBLIC="./public"

mkdir -p "$PUBLIC/presentations"

for f in ./presentations/*/slides.md; do
    echo "[+] Processing: $f"

    FOLDER=$( dirname "${f}" )
    OUTPUT="$PUBLIC/presentations/$(basename $FOLDER).html"

    echo "[+] Output :: $OUTPUT"

    marp --engine ./src/engine.js --watch --output "$OUTPUT" $f
done
