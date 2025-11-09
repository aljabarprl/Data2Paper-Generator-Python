# Data2Paper Generator Python Version
## Support
* ``Windows & Linux``
* `.csv`
* `.xls`
* `.xlxs`
* `.ods`
* `.json`
* `.jsonc`
* `.jsonl`
* `.h5`
* `.feather`
* `.parquet`

## Ouput
* ``.pdf``

# How to use
## Windows (cmd/ps)
Setup:
```bash
open this repo with terminal
```
Directory:
```bash
cd doc
```
Instal Chocolatey:
```Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```
Install MiKTeX:
```bash
https://miktex.org/download or choco install miktex
```
Install Python: (if you already have skip this)
```bash
choco install python
```
Dependencies:
```bash
pip install -r requirements.txt
```
##
Compiling:
```bash
.\compile_report.bat your_data_file.with_extension
```
Example:
```bash
.\compile_report.bat data_ekonomi.csv
```
---
## Linux (wsl/unix)
Setup:
```bash
cd to this repo
```
Directory:
```bash
cd doc
```
Update:
```bash
sudo apt update
```
Install Tex:
```bash
sudo apt install texlive-full biber
```
Or if you want spesific:
```bash
sudo apt install texlive-latex-base texlive-bibtex-extra biber
```
Permission:
```bash
chmod +x compile_report.sh
```
Install Python: (if you already have skip this)
```bash
choco install python
```
Install Dependencies:
```bash
pip install numpy pandas pyarrow tables odfpy h5py fastparquet openpyxl
```
##
Compiling:
```bash
./compile_report.sh your_data_file.with_extension
```
Example:
```bash
./compile_report.sh data_ekonomi.csv
```
---
For binary data you can make the dummy with:
```bash
python ..\src\create_binary_data.py
```
And you customize your own data at ``create_binary_data.py``

Data input is located at ``\data`` (here is your data source for python process it)

Build output (pdf) is located at ``\build``

---

Customize:

```bash
edit your journal at ``artikel.tex``
```

```bash
edit your references at ``references.bib``
```