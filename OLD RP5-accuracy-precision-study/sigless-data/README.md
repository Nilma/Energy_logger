# RAPL Characterization – Data Chunking & Analysis

This archive contains Jupyter notebooks and CSV data for characterizing CPU power using an external power meter (e.g., Siglent). It includes:
- **Raw recordings** from the instrument
- **Chunked** datasets per experiment
- **Analysis notebooks** to load, process, and visualize results

## Repository structure

```
.
├── Analysis/
│   ├── DataChunking_sigmark_RAPLcharacterization.ipynb
│   └── DataProcessing_template.ipynb
├── RawData/
│   └── test/
│       └── TestFile siglent.1761131692566.CH1.csv
├── ChunkedData/
│   ├── ...
└── LICENSE
```

- **RawData/** — unprocessed instrument output (example provided under `RawData/test/`).
- **ChunkedData/** — per‑experiment CSVs produced by the chunking notebook.
- **Analysis/** — Jupyter notebooks for chunking and downstream processing.

## Notebooks

### 1) `Analysis/DataChunking_sigmark_RAPLcharacterization.ipynb`
Splits raw recordings into per‑experiment **chunks** and saves them under `ChunkedData/`.  
Run this first if you add new raw files under `RawData/`. As a test, we have the test_file -remember to remove this before you chunk your own data, or remove the chunked files created from this test (easily recognisable by filename). 

### 2) `Analysis/DataProcessing_template.ipynb`
Loads all chunked CSVs into two pandas DataFrames:
- `dfs` — summarized **energy** per test
- `df_powers` — stacked **power samples** for all tests

The first markdown cell in this notebook briefly explains the workflow.

## Data format

Chunked CSVs have a header row followed by samples like:

| 0 (timestamp ms) | 1 (channel) | 2 (quantity) | 3 (value) | 4 (exp_duration) |
|---:|---|---|---:|---:|
| `1761131644793` | `CH1` | `POWER` | `6.82` |  |
| `1761131644797` | `CH1` | `POWER` | `6.82` |  |

The first data line may include metadata:
```
computerID, class, start_time, channelId, exp_duration
DK1081104,  cpu,  1761131644790, CH1,      20250
```

> **Note:** Your instrument export may differ slightly; adapt the parsing cells in the notebooks if column order or units change.

## Getting started

### Requirements
- Python 3.10+
- JupyterLab or Jupyter Notebook
- Python packages: `pandas`, `numpy`, `matplotlib` (and any others you prefer for plotting)


### Typical workflow
1. Put new raw CSVs from the instrument under `RawData/` (you can mirror the `test/` example).
2. Open and run **`Analysis/DataChunking_sigmark_RAPLcharacterization.ipynb`** to generate/update `ChunkedData/`.
3. Open and run **`Analysis/DataProcessing_template.ipynb`** to build `dfs` and `df_powers`, visualize, and export results/figures as needed.

## Naming conventions

Chunked files follow a pattern like:
```
<computerID>_<class>_<start_time>_<basename>.CH1.csv
```
Example:
```
DK1081104_cpu_1761131644790_TestFile siglent.1761131692566.CH1.csv
```

- `computerID`: machine identifier (e.g., `DK1081104`)
- `class`: load or category (e.g., `cpu`)
- `start_time`: unix ms timestamp marking experiment start
- `basename`: derived from the original raw file
- `.CH1`: instrument channel used

