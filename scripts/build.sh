#!/bin/bash

npm install

PUBLIC="./public"
VERCEL="./.vercel"

export CHROME_PATH=$(echo node_modules/chromium/lib/chromium/*/chrome)
echo "[+] Chrome Path :: $CHROME_PATH"
if [[ ! -f $CHROME_PATH ]]; then
    echo "[!] Chrome not found on the system..."
    PDF_DISABLE=0
fi

if [[ -d $PUBLIC ]]; then
    rm -r $PUBLIC
fi

mkdir -p "$PUBLIC" "./public/common"

if [[ -d $VERCEL ]]; then
    cp -r $VERCEL "$PUBLIC/.vercel"
fi

echo "[+] Creating and coping global assets"
mkdir -p "./public/assets"
cp ./presentations/common/*.{png,jpg,jpeg,svg} ./public/common 2>/dev/null

echo "[+] Public :: $PUBLIC"

for f in ./presentations/*/slides.md; do
    if [ -f "$f" ]; then
        echo "[+] Processing :: $f"

        FOLDER=$( dirname "${f}" )
        
        ASSETS="$FOLDER/assets"
        OUTPUT="$PUBLIC/$(basename $FOLDER)"

        echo "[+] Output :: $OUTPUT"
        echo "[+] Assets :: $ASSETS"

        # mkdir -p "$OUTPUT/assets"
        if [ -d $ASSETS ]; then
            echo "[+] Coping over assets"
            cp $ASSETS/*.{png,jpg,jpeg,svg} $PUBLIC/assets 2>/dev/null
            echo "[+] Finished coping assets"
        fi

        echo "[+] Starting building slides..."
        echo "[+] Creating HTML slides..."
        marp --engine ./src/engine.js \
            --theme-set ./src/ \
            --no-stdin \
            --output "$OUTPUT/index.html" $f

        if [ -z ${PDF_DISABLE+x} ]; then
            echo "[+] Creating PDF slides..."
            marp --engine ./src/engine.js \
                --theme-set ./src/ \
                --allow-local-files --no-stdin \
                --output "$OUTPUT/slides.pdf" $f
        else
            echo "[!] PDF not being created"
        fi

        echo "[+] Finished building slides"
    else
        echo "[!] Unable to process file"
    fi
done
