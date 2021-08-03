#!/bin/bash

PUBLIC="./public"

mkdir -p "$PUBLIC"

for f in ./presentations/*/slides.md; do
    if [ -f "$f" ]; then
        echo "[+] Processing :: $f"

        FOLDER=$( dirname "${f}" )
        ASSETS="$FOLDER/assets"
        OUTPUT="$PUBLIC/$(basename $FOLDER)"

        echo "[+] Output :: $OUTPUT"
        echo "[+] Assets :: $ASSETS"

        mkdir -p "$OUTPUT/assets"
        cp $ASSETS/*.{png,jpg,jpeg} $OUTPUT/assets

        node node_modules/@marp-team/marp-cli/marp-cli.js \
            --engine ./src/engine.js \
            --output "$OUTPUT/index.html" \
            $f
    else
        echo "[!] Unable to process file"
    fi
done
