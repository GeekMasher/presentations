#!/bin/bash

PUBLIC="./public"
VERCEL="./.vercel"

if [[ -d $PUBLIC ]]; then
    rm -r $PUBLIC
fi

mkdir -p "$PUBLIC" "./public/common"

if [[ -d $VERCEL ]]; then
    cp -r $VERCEL "$PUBLIC/.vercel"
fi


mkdir -p "./public/assets"
cp ./presentations/common/*.{png,jpg,jpeg,svg} ./public/common

echo "[+] Public :: $PUBLIC"

for f in ./presentations/*/slides.md; do
    if [ -f "$f" ]; then
        echo "[+] Processing :: $f"

        FOLDER=$( dirname "${f}" )
        
        ASSETS="$FOLDER/assets"
        OUTPUT="$PUBLIC/$(basename $FOLDER)"

        echo "[+] Output :: $OUTPUT"
        echo "[+] Assets :: $ASSETS"

        mkdir -p "$OUTPUT/assets"
        cp $ASSETS/*.{png,jpg,jpeg,svg} $PUBLIC/assets

        marp --engine ./src/engine.js --output "$OUTPUT/index.html" $f
    else
        echo "[!] Unable to process file"
    fi
done
