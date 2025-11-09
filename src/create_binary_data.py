import pandas as pd
import numpy as np
import os

data = {
    'BTC_Price': [45000.00, 46500.00, 44000.00, 48000.00, 47500.00, 50000.00, 49500.00, 51000.00, 52500.00, 51000.00],
    'SP500_Price': [4500.00, 4510.00, 4480.00, 4550.00, 4540.00, 4600.00, 4590.00, 4620.00, 4650.00, 4630.00],
    'Gold_Price': [1800.00, 1810.00, 1805.00, 1820.00, 1815.00, 1830.00, 1825.00, 1840.00, 1850.00, 1845.00]
}
df = pd.DataFrame(data)

output_dir = os.path.join(os.pardir, 'data')
os.makedirs(output_dir, exist_ok=True)

print("--- Making Binary Data Format Files ---")

h5_path = os.path.join(output_dir, 'data_ekonomi.h5')

df.to_hdf(h5_path, key='data_btc', mode='w', format='table')
print(f"[Success] HDF5 data saved at: {h5_path}")

parquet_path = os.path.join(output_dir, 'data_ekonomi.parquet')
df.to_parquet(parquet_path)
print(f"[Success] Parquet data saved at: {parquet_path}")

feather_path = os.path.join(output_dir, 'data_ekonomi.feather')
df.to_feather(feather_path)
print(f"[Success] Feather data saved at: {feather_path}")

print("\nBinary data created. see at \data")