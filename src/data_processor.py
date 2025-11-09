import pandas as pd
import numpy as np
import os
import sys

def calculate_stats(prices, risk_free_rate=0.02, annual_factor=np.sqrt(252)):
    """Menghitung log return, volatilitas, rasio sharpe, dan growth ratio."""

    returns = np.log(prices / prices.shift(1)).dropna() * 100
    if returns.empty:
        return 0.0, 0.0, 0.0
    mean_return = returns.mean()
    std_dev_return = returns.std(ddof=1)
    
    if std_dev_return > 0:
        daily_risk_free_rate = (risk_free_rate / 252.0) * 100 
        sharpe_ratio = (mean_return - daily_risk_free_rate) * annual_factor / std_dev_return
    else:
        sharpe_ratio = 0.0
    
    growth_ratio = prices.iloc[-1] / prices.iloc[0]
    annual_volatility = std_dev_return * annual_factor
    return growth_ratio, annual_volatility, sharpe_ratio

def process_file(file_path):
    """Membaca berbagai jenis file data (CSV, XLSX, XLS, JSON, JSONC, JSONL, ODS, H5, Parquet, Feather) dan mengekstrak data BTC."""
    
    try:
        ext = file_path.lower().split('.')[-1]
        
        if ext == 'csv':
            df = pd.read_csv(file_path)
        elif ext in ('xlsx', 'xls'):
            df = pd.read_excel(file_path)
        elif ext == 'ods':
            df = pd.read_excel(file_path, engine='odf')
        elif ext in ('json', 'jsonc'):
            df = pd.read_json(file_path)
        elif ext == 'jsonl':
            df = pd.read_json(file_path, lines=True)
        elif ext == 'h5':
            df = pd.read_hdf(file_path)
        elif ext == 'parquet':
            df = pd.read_parquet(file_path)
        elif ext == 'feather':
            df = pd.read_feather(file_path)
        else:
            print(f"ERROR: Format file {file_path} unsupported file type: .{ext}")
            sys.exit(1)

        btc_col = next((col for col in df.columns if 'BTC' in col.upper()), None)
        
        if btc_col is None:
            print("ERROR: Price column BTC not found.")
            sys.exit(1)

        btc_prices = df[btc_col].astype(float).dropna()
        
        if btc_prices.empty or len(btc_prices) < 2:
            print("ERROR: BTC price data is insufficient (less than 2 data points).")
            return 0.0, 0.0, 0.0
            
        return calculate_stats(btc_prices)

    except FileNotFoundError:
        print(f"ERROR: File input {file_path} not found.")
        sys.exit(1)
    except Exception as e:
        print(f"ERROR when processing data: {e}")
        print("\nPetunjuk: Jika Anda menggunakan format data biner/spreadsheet, pastikan pustaka pendukung terinstal (misalnya: pip install openpyxl odfpy h5py pyarrow).")
        sys.exit(1)

output_file_path = os.path.join(os.pardir, 'results', 'hasil_statistik.dat')

if len(sys.argv) < 2:
    print("USAGE: python data_processor.py <file_data_di_folder_data>")
    print("CONTOH: python data_processor.py data_ekonomi.xlsx")
    sys.exit(1)

file_name = sys.argv[1]
input_file_path = os.path.join(os.pardir, 'data', file_name)

growth, annual_vol, sharpe = process_file(input_file_path)

try:
    with open(output_file_path, 'w') as f:
        f.write(f"{growth:.8f}\n")
        f.write(f"{annual_vol:.8f}\n")
        f.write(f"{sharpe:.8f}\n")
    print(f"The analysis is complete. The results are saved in {output_file_path}")
except Exception as e:
    print(f"ERROR: Failed to write output file: {e}")
    sys.exit(1)