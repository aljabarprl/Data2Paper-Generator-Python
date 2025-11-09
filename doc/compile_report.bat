@echo off
setlocal

echo -----------------------------------------------------
echo [START] Mulai Eksekusi Pipeline Batch
echo -----------------------------------------------------

set ROOT_DIR=..
set BUILD_DIR=%ROOT_DIR%\build
set SRC_DIR=%ROOT_DIR%\src
set FILE_NAME=artikel.tex
set PDF_FILE=artikel.pdf

echo [DEBUG] ROOT_DIR: %ROOT_DIR%
echo [DEBUG] SRC_DIR: %SRC_DIR%

if "%1"=="" goto ERROR_NO_INPUT
set INPUT_FILE=%1
set INPUT_FILENAME_FULL=%~nx1

echo [DEBUG] INPUT_FILE Diterima: %INPUT_FILE%
echo [DEBUG] INPUT_FILENAME_FULL (untuk LaTeX): %INPUT_FILENAME_FULL%

echo -----------------------------------------------------
echo --- 1. Eksekusi Python Data Processor ---
echo -----------------------------------------------------

echo [CMD] Mencoba Pindah Direktori ke: %SRC_DIR%
cd /d %SRC_DIR%
if errorlevel 1 goto ERROR_CD_FAILED
echo [DEBUG] Berhasil Pindah ke: %cd%

echo [CMD] Mencoba Eksekusi Python dengan 'start /B': python data_processor.py "%INPUT_FILE%"
start /B python data_processor.py "%INPUT_FILE%"

ping 127.0.0.1 -n 2 > nul

call set "errorlevel="

echo [SUCCESS] Python Data Processor selesai. File hasil diupdate.

echo [CMD] Mencoba Kembali ke Direktori: %ROOT_DIR%\doc
cd /d %ROOT_DIR%\doc
echo [DEBUG] Berhasil Kembali ke: %cd%

echo [INFO] Menulis nama file input dinamis mentah ke file raw.

powershell -Command "Out-File -FilePath '..\results\filename_raw.txt' -InputObject '%INPUT_FILENAME_FULL%' -Encoding ASCII -NoNewline"

echo Hasil statistik (hasil_statistik.dat) sudah diperbarui di ..\results\

echo -------------------------------------
echo --- 2. Kompilasi LaTeX dan Biber ---
echo -------------------------------------

echo [CMD] Memulai pdflatex %FILE_NAME%
pdflatex %FILE_NAME% > latex_temp.log 2>&1
if errorlevel 1 (
    echo [CRITICAL ERROR] Kompilasi LaTeX GAGAL pada Pass 1. Lihat log:
    type latex_temp.log
    goto :eof
)

echo [CMD] Menjalankan Biber...
biber artikel > biber_temp.log 2>&1
if errorlevel 1 (
    echo [CRITICAL ERROR] Biber GAGAL memproses referensi. Lihat log:
    type biber_temp.log
    goto :eof
)

echo [CMD] pdflatex %FILE_NAME% (Pass 2)
pdflatex %FILE_NAME% > latex_temp.log 2>&1
if errorlevel 1 (
    echo [CRITICAL ERROR] Kompilasi LaTeX GAGAL pada Pass 2. Lihat log:
    type latex_temp.log
    goto :eof
)

echo [CMD] pdflatex %FILE_NAME% (Pass 3)
pdflatex %FILE_NAME% > NUL 2>&1
if errorlevel 1 (
    echo [CRITICAL ERROR] Kompilasi LaTeX GAGAL pada Pass 3.
    goto :eof
)

echo [SUCCESS] Kompilasi LaTeX berhasil diselesaikan.

echo --------------------------------------------------
echo --- 3. Pindahkan HANYA file PDF ke build\ ---
echo --------------------------------------------------

mkdir %BUILD_DIR% 2>nul
if exist %PDF_FILE% (
    echo [CMD] move /Y %PDF_FILE% %BUILD_DIR%\
    move /Y %PDF_FILE% %BUILD_DIR%\
    echo [SUCCESS] %PDF_FILE% dipindahkan ke %BUILD_DIR%\
) else (
    echo [FAILURE] File PDF tidak ditemukan setelah kompilasi. Cek output pdflatex di atas.
)

goto END_SUCCESS

:ERROR_NO_INPUT
echo [ERROR] Anda harus menentukan file data input (ex: compile_report.bat data_ekonomi.xlsx)
goto END

:ERROR_CD_FAILED
echo [CRITICAL ERROR] Gagal Pindah ke %SRC_DIR%. Cek apakah folder 'src' ada di root proyek.
cd /d %ROOT_DIR%\doc
goto END

:ERROR_PYTHON_FAILED
echo [CRITICAL ERROR] Eksekusi Python Gagal total. Cek instalasi Python/PATH Anda.
cd /d %ROOT_DIR%\doc
goto END

:END_SUCCESS
echo ------------------------------------------
echo [END] Eksekusi Batch Berhasil Selesai.
echo ------------------------------------------

:END
endlocal