#!/bin/bash

PUBLIC="./public"

mkdir -p "$PUBLIC/presentations"

for f in ./presentations/*/slides.md; do
    echo "[+] Processing: $f"

    FOLDER=$( dirname "${f}" )
    OUTPUT="$PUBLIC/presentations/$(basename $FOLDER)"

    if [[ -d $OUTPUT ]]; then
        echo "[!] Directories not supported: $OUTPUT"
    else;
        echo "[+] Output :: $OUTPUT"
        marp --engine ./src/engine.js --output "$OUTPUT.html" $f
    fi
done
