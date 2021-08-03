#!/bin/bash

PUBLIC="./public"

mkdir -p "$PUBLIC/presentations"

for f in ./presentations/*/slides.md; do
    if [ -f "$f" ]; then
        echo "[+] Processing: $f"

        FOLDER=$( dirname "${f}" )
        OUTPUT="$PUBLIC/presentations/$(basename $FOLDER)"

        echo "[+] Output :: $OUTPUT"
        marp --engine ./src/engine.js --output "$OUTPUT.html" $f
    else
        echo "[!] Unable to process file"
    fi
done
