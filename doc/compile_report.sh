#!/bin/bash

DOC_DIR=$(pwd)                  
ROOT_DIR=$(dirname "$DOC_DIR") 
BUILD_DIR="$ROOT_DIR/build"     
SRC_DIR="$ROOT_DIR/src"
RESULTS_DIR="$ROOT_DIR/results"

FILE_NAME="artikel"

if [ -z "$1" ]; then
    echo "ERROR: Anda harus menentukan file data input (ex: ./compile_report.sh data_ekonomi.xlsx)"
    exit 1
fi
INPUT_FILE="$1" 

INPUT_FILENAME_FULL=$(basename "$INPUT_FILE")
echo "[DEBUG] Nama file input bersih untuk LaTeX: $INPUT_FILENAME_FULL"

echo "--- 1. Menjalankan Python Data Processor dengan file: $INPUT_FILE ---"
mkdir -p "$BUILD_DIR"
mkdir -p "$RESULTS_DIR"

cd "$SRC_DIR" || { echo "Gagal pindah ke direktori src/"; exit 1; }

python data_processor.py "$INPUT_FILE"

cd "$DOC_DIR" || { echo "Gagal kembali ke direktori doc/"; exit 1; }
echo "Hasil statistik (hasil_statistik.dat) sudah diperbarui di ../results/"

echo "--- Menulis nama file input mentah ke $RESULTS_DIR/filename_raw.txt ---"

echo -n "$INPUT_FILENAME_FULL" > "$RESULTS_DIR/filename_raw.txt"

echo "--- 2. Kompilasi LaTeX dan Biber ---"
pdflatex "$FILE_NAME.tex"
biber "$FILE_NAME"
pdflatex "$FILE_NAME.tex"
pdflatex "$FILE_NAME.tex"

echo "--- 3. Pindahkan HANYA file PDF ke /build ---"
if [ -f "$FILE_NAME.pdf" ]; then
    mv "$FILE_NAME.pdf" "$BUILD_DIR/"
    echo "[Succes]: ${FILE_NAME}.pdf dipindahkan ke $BUILD_DIR/"
else
    echo "[Failed]: File PDF tidak ditemukan setelah kompilasi."
fi

echo "Selesai. File .pdf di $BUILD_DIR/. File perantara tetap ada di $DOC_DIR/."